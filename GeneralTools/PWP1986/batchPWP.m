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

for row =1:height(runs)
    met_input_file = runs.met{row};
    profile_input_file = runs.prof{row};
    pwp_output_file = runs.out{row};

    PWP_on_SWIFT;

    % Hardcode plot flag
    plt = true;

    if plt == true
        figure('Position',[50 50 750 500]);
        tiledlayout('vertical')

        nexttile(1);
        yyaxis left
        plot(pwp_input.time-8/24, pwp_input.sw_net+ pwp_input.lw_net- pwp_input.hsb -pwp_input.hlb)
        ylabel('Q_n_e_t [W/m^2]')
        yyaxis right
        plot(pwp_input.time-8/24, pwp_input.tau)
        ylabel('\tau [N/m^2]')
        set(findall(gca,'Type','Line'), 'LineWidth', 2)
        datetick

        nexttile(2)
        pcolor(pwp_output.time-8/24, pwp_output.z, pwp_output.t)
        clim([15 17])
        axis ij
        datetick
        shading flat
        ylabel(colorbar,'T [\circC]')      
        colormap(cmocean('thermal'))

        if ~exist(fullfile(pwd, 'plots'), 'dir')
            mkdir('plots'); disp('Making plots directory, changing dir...')
        else
            disp('plots directory exists, changing dir...')
        end
        cd plots

        name = runs.out{row}(1:end-4);
        sgtitle(name,'Interpreter', 'none');
        savefig(name)
        fprintf('Saved %s plot in %s\n', name, pwd);

        cd ..

        close;
    end
    clearvars -except rows runs
end

    
