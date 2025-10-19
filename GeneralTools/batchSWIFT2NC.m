function batchSWIFT2NC(varargin)
   % Convert batch of SWIFT matlab structures to NetCDF with options
   % 
   % Usage:
   %   swift_batch_convert()  % default: '*SWIFT*.mat' in current dir
   %   swift_batch_convert('glob_path', '*.mat')
   %   swift_batch_convert('output_dir', 'netcdf_files')
   %   swift_batch_convert('dry_run', true)
   
   % Parse inputs
   p = inputParser;
   addParameter(p, 'glob_path', '*SWIFT*.mat', @ischar);
   addParameter(p, 'output_dir', '.', @ischar);
   addParameter(p, 'dry_run', false, @islogical);
   parse(p, varargin{:});
   
   glob_path = p.Results.glob_path;
   output_dir = p.Results.output_dir;
   dry_run = p.Results.dry_run;
   
   % Create output directory if specified
   if ~isempty(output_dir) && ~dry_run
       if ~exist(output_dir, 'dir')
           mkdir(output_dir);
       end
   end
   
   flist = dir(glob_path);
   disp(flist)
   
   if isempty(flist)
       fprintf('No files found matching: %s\n', glob_path);
       return;
   end
   
   for fi = 1:length(flist)
       clear SWIFT
       % Generate output filename
       [~, name, ~] = fileparts(flist(fi).name);
       if isempty(output_dir)
           nc_filename = [name '.nc'];
       else
           nc_filename = fullfile(output_dir, [name '.nc']);
       end
       
       if dry_run
           fprintf('Would process: %s -> %s\n', flist(fi).name, nc_filename);
           continue;
       end
       
       load(flist(fi).name, 'SWIFT')
       if exist('SWIFT', 'var')
           try
               SWIFT2NC(SWIFT, nc_filename);
               fprintf('Successfully processed: %s\n', flist(fi).name);
           catch ME
               fprintf('Error processing %s: %s\n', flist(fi).name, ME.message);
               fprintf('  at line %d in %s\n', ME.stack(1).line, ME.stack(1).name);
               fprintf('Command to reproduce: load("%s", "SWIFT");SWIFT2NC(SWIFT, ''%s'')\n', flist(fi).name, nc_filename);
               continue;
           end
       else
           fprintf('%s does not contain a SWIFT structure\n', nc_filename);
       end
   end
end