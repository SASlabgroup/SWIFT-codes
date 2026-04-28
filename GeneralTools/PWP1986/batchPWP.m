% Run multiple PWP cases from a run table
% 28 4 2026
% Michael James
% University of Washington
% Civil and Environmental Engineering
% 
%--------------------------------------------------------------------------
% Utilizes "PWP_on_SWIFT script and a csv table to run through multiple
% user defined cases of PWP with various inputs. 
% Allows for more autonomous running of PWP to cover all cases of interest.
% 
%--------------------------------------------------------------------------
% Table Layout
%  - met: filename or path of met file
%  - prof: filename or path of profile file
%  - out: filename or path of output file

clc, clear, close all;

path = "C:\Users\MichaelJames\Dropbox\mjames\Carson_COAREcomparision\PWP\PWP_test_cases\runtable.xlsx";

runs = readtable(path);
cd(fileparts(path));

for i =1:height(runs)
    met_input_file = runs.met{i};
    profile_input_file = runs.prof{i};
    pwp_output_file = runs.out{i};

    PWP_on_SWIFT;
end

    
