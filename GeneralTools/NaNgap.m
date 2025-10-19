function [timeng, datang] = NaNgap(time, data, dtmax)
    % INSERT_NAN_GAPS Inserts NaN (or NaN array) in data and mid-gap time in time vector
    % when time difference exceeds dt.
    %
    % Inputs:
    %   time - Vector of time points (sorted ascending, 1xNt or Nt x 1)
    %   data - Vector (1xNt), matrix (Nbin x Nt), or 3D array (Nbin x Nt x Ndatatype)
    %   dtmax   - Time difference threshold for inserting NaN
    %
    % Outputs:
    %   timeng - New time vector with added mid-gap times
    %   datang - New data vector/matrix/array with added NaNs

    % Ensure time is a row vector for consistency
    time = time(:)';
    
    % Initialize output arrays
    timeng = time;
    datang = data;
    
    % Get dimensions of data
    datasz = size(data);
    if length(datasz) == 2
        [Nbin, Nt] = deal(datasz(1), datasz(2));
        Ndatatype = 1;
    elseif length(datasz) == 3
        [Nbin, Nt, Ndatatype] = deal(datasz(1), datasz(2), datasz(3));
    else
        % Handle 1D case by reshaping to 1xNt x 1
        Nbin = 1;
        Nt = length(data);
        Ndatatype = 1;
        datang = reshape(data, 1, Nt, 1);
    end
    
    % Find indices where time difference exceeds dt
    dt = diff(time);
    igap = find(dt > dtmax);
    
    % Insert NaNs and mid-gap times
    offset = 0;
    for i = 1:length(igap)
        idx = igap(i) + offset;

        % Calculate mid-gap time
        gaptime = (timeng(idx) + timeng(idx+1)) / 2;

        % Create NaN entry (Nbin x 1 x Ndatatype)
        gapnan = NaN(Nbin, 1, Ndatatype);

        % Insert mid_time and NaN
        timeng = [timeng(1:idx), gaptime, timeng(idx+1:end)];
        datang = cat(2, datang(:,1:idx,:), gapnan, datang(:,idx+1:end,:));

        % Update counter
        offset = offset + 1;
    end
end