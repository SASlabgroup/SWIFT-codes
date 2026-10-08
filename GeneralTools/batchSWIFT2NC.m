function batchSWIFT2NC(varargin)
% Matlab script to convert a batch of SWIFT matlab structures into NetCDF
%
% J. Thomson, May 2021
% M. LeClair, Oct 2025
%
% Usage:
%   batchSWIFT2NC    % default: '*SWIFT*.mat' in current dir
%   batchSWIFT2NC('glob_path', '*.mat')
%   batchSWIFT2NC('glob_path', '*L5.mat', 'nfreq', 85)

% Parse inputs
p = inputParser;
addParameter(p, 'glob_path', '*SWIFT*.mat', @ischar);
addParameter(p, 'nfreq', 42, @(x) ismember(x,[42 85]));
parse(p, varargin{:});

glob_path = p.Results.glob_path;
nfreq = p.Results.nfreq;

flist = dir(glob_path);

if isempty(flist)
    fprintf('No files found matching: %s\n', glob_path);
    return;
end

fprintf('Found %d file(s) matching "%s":\n', length(flist), glob_path);
fprintf('Processing:\n');

for fi = 1:length(flist)
    clear SWIFT
    
    % Generate output filename in current directory
    [~, name, ~] = fileparts(flist(fi).name);
    nc_filename = [name '.nc'];
    
    fprintf('  %d. %s -> %s\n', fi, flist(fi).name, nc_filename);
    
    % Load SWIFT or SIG structure
    data = load(flist(fi).name);
    
    if isfield(data, 'SWIFT')
        SWIFT = data.SWIFT;
    elseif isfield(data, 'SIG')
        fprintf('       SIG structure not yet supported\n');
        continue
    else
        fprintf('       File does not contain SWIFT or SIG structure\n');
        continue;
    end
    
    % If we found one, convert to NC
    if exist('SWIFT', 'var')
        try
            SWIFT2NC(SWIFT, nc_filename, 'nfreq', nfreq);
            fprintf('       Successfully processed\n');
        catch ME
            fprintf('       Error: %s\n', ME.message);
            fprintf('              at line %d in %s\n', ME.stack(1).line, ME.stack(1).name);
            fprintf('       Command to reproduce: SWIFT2NC(SWIFT, ''%s'')\n', nc_filename);
        end
    else
        fprintf('         File does not contain a SWIFT structure\n');
    end
end

end
