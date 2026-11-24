function test_sbgBinaryToMatlab(datfile,matfile)
% Check that sbgBinaryToMatlab reads only complete frames with a valid CRC.
%   test_sbgBinaryToMatlab               synthetic logs only
%   test_sbgBinaryToMatlab(datfile,matfile)  also decode a real SBG .dat and
%                                        compare with a reference sbgData
%                                        .mat (every field equal)
%
% The reference CRC here is sbgCalcCRC, the manual's calcCRC line for line
% (sbgECom Firmware Reference Manual SBGFWM 2.4, 2.1.3). Synthetic logs of ImuData
% and Status frames with known values:
% 1) clean frames are decoded exactly; frames with random payloads are all
%    accepted (the reader's table CRC agrees with sbgCalcCRC)
% 2) a frame with bytes lost in the middle, or only its end (ETX, CRC) lost,
%    is skipped, the next one is read
% 3) a frame with one changed byte (bad CRC) is skipped
% 4) a lost-bytes frame ending in 0xFF right before the next frame's sync
% 5) junk between frames containing a sync and a frame header
% 6) a frame cut off at the end of the file, also right after its header
% 7) a longer payload (newer firmware) with a valid CRC
% 8) valid frames that are not read: an unknown message ID, a class other
%    than 0, a payload longer than 4086 bytes
%
% Changelog:
% M. LeClair w/ claude, Nov 2026

nfail = 0;
crc = sbgCalcCRC(uint8('123456789'));
nfail = nfail + report('CRC check value 0x2189',crc == hex2dec('2189'));

n = 6;
imu = cell(n,1); sts = cell(n,1); vals = zeros(n,13); stamps = zeros(n,1);
for k = 1:n
    stamps(k) = 1e6 + 2e5*k;
    vals(k,:) = single(k + (1:13)/16); % exactly representable
    imu{k} = frame(3,[typecast(uint32(stamps(k)),'uint8') typecast(uint16(k),'uint8') ...
        typecast(single(vals(k,:)),'uint8')]);
    sts{k} = frame(1,[typecast(uint32(stamps(k)+1000),'uint8') zeros(1,18,'uint8')]);
end
clean = [imu sts]'; clean = [clean{:}];

% 1) clean
s = decode(clean);
nfail = nfail + check('clean',s,1:n,stamps,vals);
nfail = nfail + report('  Status frames read too',isequal(s.Status.time_stamp(:),stamps+1000));
rng(1); nrand = 500; rnd = cell(nrand,1);
for k = 1:nrand
    rnd{k} = frame(3,[typecast(uint32(k),'uint8') uint8(randi([0 255],1,54))]);
end
s = decode(join(rnd));
nfail = nfail + report(sprintf('  %d frames with random payloads all accepted',nrand), ...
    isequal(s.ImuData.time_stamp(:),(1:nrand)'));

% 2) bytes lost in the middle of frame 3, several lengths
for nlost = [1 5 20 40]
    f3 = imu{3}; f3(20:19+nlost) = [];
    s = decode(join([imu(1:2); {f3}; imu(4:n)]));
    nfail = nfail + check(sprintf('%d byte(s) lost in a frame',nlost),s,[1 2 4:n],stamps,vals);
end

% 2b) only the end of frame 3 lost: its ETX, or its CRC and ETX
for nlost = [1 3]
    f3 = imu{3}; f3 = f3(1:end-nlost);
    s = decode(join([imu(1:2); {f3}; imu(4:n)]));
    nfail = nfail + check(sprintf('last %d byte(s) of a frame lost',nlost),s,[1 2 4:n],stamps,vals);
end

% 3) one changed byte in the payload of frame 3
f3 = imu{3}; f3(30) = bitxor(f3(30),uint8(1));
s = decode(join([imu(1:2); {f3}; imu(4:n)]));
nfail = nfail + check('changed byte (bad CRC)',s,[1 2 4:n],stamps,vals);

% 4) frame 3 cut right after an FF byte, then frame 4's sync (FF FF 5A)
f3 = imu{3}; f3(25) = 255; f3 = f3(1:25); % ends in 0xFF
s = decode(join([imu(1:2); {f3}; imu(4:n)]));
nfail = nfail + check('lost bytes ending in FF before a sync',s,[1 2 4:n],stamps,vals);

% 5) junk with a sync and an ImuData header (no valid frame) between frames
junk = uint8([1 2 255 90 3 0 58 0 255 255 90 7 9 255]); % FF 5A 03 00 3A 00 (ImuData header), FF FF 5A, trailing FF
s = decode(join([imu(1:3); {junk}; imu(4:n)]));
nfail = nfail + check('junk with a false sync',s,1:n,stamps,vals);

% 6) last frame cut off at the end of the file
fn = imu{n}; fn = fn(1:30);
s = decode(join([imu(1:n-1); {fn}]));
nfail = nfail + check('frame cut off at the end',s,1:n-1,stamps,vals);
lens = structfun(@numel,s.ImuData);
nfail = nfail + report('  every ImuData field the same length',all(lens == lens(1)));
for nkeep = [6 7] % file ends right after the header, or 1 byte into the payload
    fn = imu{n}; fn = fn(1:nkeep);
    s = decode(join([imu(1:n-1); {fn}]));
    nfail = nfail + check(sprintf('file ends %d byte(s) into the last frame',nkeep),s,1:n-1,stamps,vals);
end

% 7) a longer ImuData payload (4 extra bytes) with a valid CRC
f3 = imu{3}; payload = [f3(7:end-3) uint8([9 9 9 9])];
s = decode(join([imu(1:2); {frame(3,payload)}; imu(4:n)]));
nfail = nfail + check('longer payload, valid CRC',s,1:n,stamps,vals);

% 8) valid frames that are not read, between frames 3 and 4
s = decode(join([imu(1:3); {frame(99,uint8(1:20))}; imu(4:n)]));
nfail = nfail + check('unknown message ID skipped',s,1:n,stamps,vals);
s = decode(join([imu(1:3); {frame(3,imu{3},1)}; imu(4:n)])); % its payload is a whole valid ImuData frame
nfail = nfail + check('class 1 frame with an ImuData ID skipped whole',s,1:n,stamps,vals);
s = decode(join([imu(1:3); {frame(3,[payload zeros(1,4087-numel(payload),'uint8')])}; imu(4:n)]));
nfail = nfail + check('payload over 4086 bytes not read',s,1:n,stamps,vals);

% Real file
if nargin == 2
    ref = load(matfile,'sbgData'); ref = ref.sbgData;
    s = sbgBinaryToMatlab(datfile);
    ok = true;
    for name = string(fieldnames(ref))'
        for fld = string(fieldnames(ref.(name)))'
            ok = ok && isequaln(double(s.(name).(fld)(:)),double(ref.(name).(fld)(:)));
        end
    end
    nfail = nfail + report("real file " + datfile,ok);
end

if nfail > 0
    error('test_sbgBinaryToMatlab:Failed','%d check(s) failed',nfail)
end
disp('All checks passed')
end

function s = decode(bytes)
fn = [tempname '.dat'];
fid = fopen(fn,'w'); fwrite(fid,bytes,'uint8'); fclose(fid);
s = sbgBinaryToMatlab(fn);
delete(fn)
end

function bytes = join(frames)
bytes = [frames{:}];
end

function f = frame(id,payload,cls)
% sbgECom frame: sync, ID, class (default 0), length, payload, CRC, ETX
if nargin < 3; cls = 0; end
body = [uint8(id) uint8(cls) typecast(uint16(numel(payload)),'uint8') uint8(payload)];
f = [uint8([255 90]) body typecast(uint16(sbgCalcCRC(body)),'uint8') uint8(51)]; % sync 0xFF 0x5A, ETX 0x33
end

function nfail = check(label,s,keep,stamps,vals)
imu = s.ImuData;
lens = structfun(@numel,imu);
if any(lens ~= lens(1)) % fields of unequal length
    nfail = report(label,false);
    return
end
got = [imu.accel_x(:) imu.accel_y(:) imu.accel_z(:) imu.gyro_x(:) imu.gyro_y(:) imu.gyro_z(:) ...
    imu.temp(:) imu.delta_vel_x(:) imu.delta_vel_y(:) imu.delta_vel_z(:) ...
    imu.delta_angle_x(:) imu.delta_angle_y(:) imu.delta_angle_z(:)];
ok = numel(imu.time_stamp) == numel(keep) && isequal(imu.time_stamp(:),stamps(keep)) && ...
    isequal(imu.imu_status(:),keep(:)) && isequal(got,vals(keep,:));
nfail = report(label,ok);
end

function nfail = report(label,ok)
if ok
    fprintf('  ok    %s\n',label)
    nfail = 0;
else
    fprintf('  FAIL  %s\n',label)
    nfail = 1;
end
end
