function HRprofiles = processSIGfiles_parallel(bfiles,opt,slash)
% Compute HR velocity profiles for independent Signature burst files on a
% thread pool. Bursts left empty are processed serially by reprocess_SIG.

HRprofiles = cell(length(bfiles),1);
if isempty(ver('parallel')) || ...
        ~license('test','Distrib_Computing_Toolbox')
    warning('Parallel toolbox unavailable; processing Signature bursts serially.')
    return
elseif opt.readraw
    warning('Raw Signature reading requested; processing bursts serially.')
    return
elseif opt.plotburst
    warning('Burst graphics requested; processing Signature bursts serially.')
    return
end

pool = gcp('nocreate');
if isempty(pool)
    parpool('Threads',opt.parallelworkers);
elseif pool.NumWorkers ~= opt.parallelworkers
    warning('Using existing parallel pool with %d workers.',pool.NumWorkers)
end

parfor iburst = 1:length(bfiles)
    HRprofiles{iburst} = processHRprofile(bfiles(iburst),opt,slash);
end

end


function HRprofile = processHRprofile(bfile,opt,slash)
% Same skips as the reprocess_SIG burst loop; five-beam bursts stay serial.

HRprofile = [];
data = load([bfile.folder slash bfile.name],'burst');
if ~isfield(data,'burst') || isempty(data.burst)
    return
end
burst = data.burst;
fs = median(diff(burst.time))*24*60*60;
if length(burst.time)*fs < 60 || ~ismatrix(burst.VelocityData) || ...
        ~ismatrix(burst.CorrelationData) || ~ismatrix(burst.AmplitudeData)
    return
end

[HRprofile,~] = processSIGburst(burst,opt);

end
