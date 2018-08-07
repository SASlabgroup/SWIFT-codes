function [ Data, Config, T_beam2xyz ] = signatureAD2CP_beam2xyz_enu( Data, Config, mode, twoZs )

if nargin == 3
	twoZs = 0;
end

%ad2cpstr = 'AD2CP_';
ad2cpstr = '';

if strcmpi( mode, 'avg' )
	dataModeWord = 'Average';
	configModeWord = 'avg';
elseif strcmpi( mode, 'burst' )
	dataModeWord = 'Burst';
	configModeWord = 'burst';
end

% make the assumption the beam mapping is the same for all measurements in a data file
activeBeams = Data.( [dataModeWord '_Physicalbeam'] )( 1, : );
activeBeams = activeBeams(find(activeBeams > 0));
numberOfBeams = length( activeBeams );
if numberOfBeams <= 2
	print( 'Transformations require at least 3 active beams.' )
	T_beam2xyz = nan;
	return
end
% assume max number of beams involved is 4, extra rows removed later
beamVectorsSpherical = zeros( 4, 3 );

for i = activeBeams
	beamVectorsSpherical( i, : ) = [ 1, ...
		Config.( [ad2cpstr 'BeamCfg' num2str( i ) '_theta' ] ), ...
		Config.( [ad2cpstr 'BeamCfg' num2str( i ) '_phi' ] ) ];
end

disp(beamVectorsSpherical)

if numberOfBeams == 3
	% for a three beam system, translate the beam vectors expressed in spherical coordinates
	% into beam vectors in Cartesian coordinates

	% first transform from spherical to cartesian coordinates
	for i = activeBeams
		beamVectorsCartesian( i, : ) = [ ...
			sind( beamVectorsSpherical( i, 2 ) ) * cosd( beamVectorsSpherical( i, 3 ) ), ...
			sind( beamVectorsSpherical( i, 2 ) ) * sind( beamVectorsSpherical( i, 3 ) ), ...
			cosd( beamVectorsSpherical( i, 2 ) ) ];
	end

	cartesianTransformCheck = sum( beamVectorsCartesian.^2, 2 );
	% remove any extra rows for inactive beams
	beamVectorsCartesian( cartesianTransformCheck == 0, : ) = [];
	
	T_beam2xyz = inv( beamVectorsCartesian );

elseif numberOfBeams == 4
	if twoZs == 0
		% for a four beam system, translate the beam vectors expressed in spherical coordinates
		% into beam vectors in Cartesian coordinates, using only three basis vectors
		for i = 1:numberOfBeams
			beamVectorsCartesian( i, : ) = [ ...
				sind( beamVectorsSpherical( i, 2 ) ) * cosd( beamVectorsSpherical( i, 3 ) ), ...
				sind( beamVectorsSpherical( i, 2 ) ) * sind( beamVectorsSpherical( i, 3 ) ), ...
				cosd( beamVectorsSpherical( i, 2 ) ) ];
		end
		cartesianTransformCheck = sum( beamVectorsCartesian.^2, 2 );

		% pseudo inverse needs to be used because beamVectorsCartesian isn't square
		T_beam2xyz = pinv( beamVectorsCartesian );

	else
		% this section makes two estimates of the vertical velocity
		for i = 1:numberOfBeams
			if i == 1 | i == 3
				beamVectorsCartesianzz( i, : ) = [ ...
					beamVectorsSpherical( i, 1 ) * sind( beamVectorsSpherical( i, 2 ) ) * cosd( beamVectorsSpherical( i, 3 ) ), ...
					-1 * beamVectorsSpherical( i, 1 ) * sind( beamVectorsSpherical( i, 2 ) ) * sind( beamVectorsSpherical( i, 3 ) ), ...
					beamVectorsSpherical( i, 1 ) * cosd( beamVectorsSpherical( i, 2 ) ), ...
					0 ];
			else
				beamVectorsCartesianzz( i, : ) = [ ...
					beamVectorsSpherical( i, 1 ) * sind( beamVectorsSpherical( i, 2 ) ) * cosd( beamVectorsSpherical( i, 3 ) ), ...
					-1 * beamVectorsSpherical( i, 1 ) * sind( beamVectorsSpherical( i, 2 ) ) * sind( beamVectorsSpherical( i, 3 ) ), ...
					0, ...
					beamVectorsSpherical( i, 1 ) * cosd( beamVectorsSpherical( i, 2 ) ) ];
			end
		end
		cartesianTransformCheck = sum( beamVectorsCartesianzz.^2, 2 );

		% there should be an inverse for this, no pseudoinverse needed
		T_beam2xyz = inv( beamVectorsCartesianzz );

		% Can also add in a row for the error velocity calculation, 
		% as the difference between the two vertical velcoities
		% T_beam2xyz( end + 1, : ) = T_beam2xyzz( 3, : ) - T_beam2xyzz( 4, : );
		% note the addition of the error velocity row changes the inversion of the matrix, it
		% needs to be removed to recover the xyz2beam matrix.
	end
end

% verify we're not already in 'xyz'
if strcmpi( Config.( [ ad2cpstr configModeWord '_coordSystem' ] ), 'xyz' )
	disp( 'Velocity data is already in xyz coordinate system.' )
	return
end

xAllCells = zeros( length( Data.( [ dataModeWord '_TimeStamp' ] ) ), Config.( [ad2cpstr  configModeWord '_nCells' ] ) );
yAllCells = zeros( length( Data.( [ dataModeWord '_TimeStamp' ] ) ), Config.( [ad2cpstr  configModeWord '_nCells' ] ) );
zAllCells = zeros( length( Data.( [ dataModeWord '_TimeStamp' ] ) ), Config.( [ad2cpstr  configModeWord '_nCells' ] ) );
if twoZs == 1
	z2AllCells = zeros( length( Data.( [ dataModeWord '_TimeStamp' ] ) ), Config.( [ad2cpstr  configModeWord '_nCells' ] ) );
end

xyz = zeros( size( T_beam2xyz, 2 ), length( Data.( [ dataModeWord '_TimeStamp' ] ) ) );
beam = zeros( size( T_beam2xyz, 2 ), length( Data.( [ dataModeWord '_TimeStamp' ] ) ) );
for nCell = 1:Config.( [ad2cpstr  configModeWord '_nCells' ] )
	for i = 1:numberOfBeams
		beam( i, : ) = Data.( [ dataModeWord '_VelBeam' num2str( Data.( [ dataModeWord '_Physicalbeam' ] )( 1, i ) ) ] )( :, nCell )';
	end
	xyz = T_beam2xyz * beam;
	xAllCells( :, nCell ) = xyz( 1, : )';	
	yAllCells( :, nCell ) = xyz( 2, : )';
	zAllCells( :, nCell ) = xyz( 3, : )';
	if twoZs == 1
		z2AllCells( :, nCell ) = xyz( 4, : )';
	end
end

Config.( [ad2cpstr   configModeWord '_coordSystem' ] ) = 'xyz';
Data.( [ dataModeWord '_VelX' ] ) = xAllCells;
Data.( [ dataModeWord '_VelY' ] ) = yAllCells;

if twoZs == 1
	Data.( [ dataModeWord '_VelZ1' ] ) = zAllCells;
	Data.( [ dataModeWord '_VelZ2' ] ) = z2AllCells;
else
	Data.( [ dataModeWord '_VelZ' ] ) = zAllCells;
end





% verify we're not already in 'enu'
if strcmpi( Config.( [ad2cpstr   configModeWord '_coordSystem' ] ), 'enu' )
	disp( 'Velocity data is already in enu coordinate system.' )
	return
end

K = 3;
EAllCells = zeros( length( Data.( [dataModeWord  '_TimeStamp' ] ) ), Config.( [ad2cpstr   configModeWord '_nCells' ] ) );
NAllCells = zeros( length( Data.( [dataModeWord  '_TimeStamp' ] ) ), Config.( [ad2cpstr   configModeWord '_nCells' ] ) );
UAllCells = zeros( length( Data.( [dataModeWord  '_TimeStamp' ] ) ), Config.( [ad2cpstr   configModeWord '_nCells' ] ) );
if twoZs == 1
	U2AllCells = zeros( length( Data.( [dataModeWord  '_TimeStamp' ] ) ), Config.( [ad2cpstr  configModeWord '_nCells' ] ) );
   K = 4;
end

Name = ['X','Y','Z'];
ENU = zeros( K, Config.([ad2cpstr   configModeWord '_nCells' ]));
xyz = zeros( K, Config.([ad2cpstr   configModeWord '_nCells' ]));
for sampleIndex = 1:length(Data.( [dataModeWord  '_Error' ]));
   if (bitand(bitshift(uint32(Data.( [dataModeWord  '_Status' ])(sampleIndex)), -25),7) == 5)
      signXYZ=[1 -1 -1 -1];
   else
      signXYZ=[1 1 1 1];
   end

   hh = pi*(Data.([dataModeWord  '_Heading'])(sampleIndex)-90)/180;
   pp = pi*Data.([dataModeWord  '_Pitch'])(sampleIndex)/180;
   rr = pi*Data.([dataModeWord  '_Roll'])(sampleIndex)/180;

   % Make heading matrix
   H = [cos(hh) sin(hh) 0; -sin(hh) cos(hh) 0; 0 0 1];

   % Make tilt matrix
   P = [cos(pp) -sin(pp)*sin(rr) -cos(rr)*sin(pp);...
         0             cos(rr)          -sin(rr);  ...
         sin(pp) sin(rr)*cos(pp)  cos(pp)*cos(rr)];

   % Make resulting transformation matrix
   xyz2enu = H*P; 
   if (twoZs == 1)
      xyz2enu(1,3) = xyz2enu(1,3)/2;
      xyz2enu(1,4) = xyz2enu(1,3);
      xyz2enu(2,3) = xyz2enu(2,3)/2;
      xyz2enu(2,4) = xyz2enu(2,3);
      
      xyz2enu(4,:) = xyz2enu(3,:);
      xyz2enu(3,4) = 0;
      xyz2enu(4,4) = xyz2enu(3,3);
      xyz2enu(4,3) = 0;
   end

   for i = 1:K
      if (twoZs == 1) && (i >= 3)
         axs = [ Name(3) num2str((i-2),1) ];
      else
         axs = Name(i);
      end
      xyz( i, : ) = signXYZ(i) * Data.( [ dataModeWord '_Vel' axs] )( sampleIndex, : )';
   end
   ENU = xyz2enu * xyz;
   EAllCells( sampleIndex, : ) = ENU( 1, : )';	
   NAllCells( sampleIndex, : ) = ENU( 2, : )';
   UAllCells( sampleIndex, : ) = ENU( 3, : )';
      if twoZs == 1
      U2AllCells( sampleIndex, : ) = ENU( 4, : )';
      end
end
Config.( [ad2cpstr   configModeWord '_coordSystem' ] ) = 'enu';
Data.( [ dataModeWord '_VelEast' ] ) = EAllCells;
Data.( [ dataModeWord '_VelNorth' ] ) = NAllCells;
if twoZs == 1
	Data.( [ dataModeWord '_VelUp1' ] ) = UAllCells;
	Data.( [ dataModeWord '_VelUp2' ] ) = U2AllCells;
else
	Data.( [ dataModeWord '_VelUp' ] ) = UAllCells;
end



