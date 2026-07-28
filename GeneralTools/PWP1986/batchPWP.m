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

path = "C:\Users\MichaelJames\Dropbox\mjames\Carson_COAREcomparision\PWP\PWP_test_cases\temp_runtable.xlsx";

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
        figure('Position',[50 50 1200 500]);
        tiledlayout(2,4)

        nexttile([1 2]);
        yyaxis left
        plot(pwp_input.time-8/24, pwp_input.sw_net+ pwp_input.lw_net- pwp_input.hsb -pwp_input.hlb) % qi + qo
        ylabel('Q_n_e_t [W/m^2]')
        yyaxis right
        plot(pwp_input.time-8/24, pwp_input.tau)
        ylabel('\tau [N/m^2]')
        set(findall(gca,'Type','Line'), 'LineWidth', 2)
        datetick

        nexttile([1 1])
        plot(pwp_input.s, pwp_input.z,'LineWidth',2)
        ylabel('depth [m]')
        xlabel('S [PSU]')
        axis ij
        grid
        title('initial profile')

        nexttile([2 1])
        lat 		= 55.35;        %latitude (degrees)
        lon         = -131.65       %longitude (degrees)
        SA = gsw_SA_from_SP(pwp_input.s, pwp_input.z, lon, lat);
        CT = gsw_CT_from_t(SA, pwp_input.t, pwp_input.z);
        rho = gsw_rho(SA, CT, pwp_input.z);


        plot(rho, pwp_input.z,'k','LineWidth',2)
        ylabel('depth [m]')
        xlabel('\rho [kg/m^3]')
        axis ij
        grid
        title('initial profile')

        nexttile([1 2]);
        pcolor(pwp_output.time-8/24, pwp_output.z, pwp_output.t)
        % clim(mean(pwp_output.t,'all') + [1 2].*std(pwp_output.t,1,'all'))
        clim([12 17])
        axis ij
        datetick
        shading flat
        ylabel(colorbar,'T [\circC]')      
        colormap(cmocean('thermal'))

        hold on

        plot(pwp_output.time(1,:)-8/24, pwp_output.mld,'r','LineWidth',1)
        legend('','Mixed layer depth','location','best')


        nexttile([1 1])
        plot(pwp_input.t, pwp_input.z,'r','LineWidth',2)
        ylabel('depth [m]')
        xlabel('T[\circC]')
        axis ij
        grid
        title('initial profile')


        % Add closure check and zero line
        H = trapz(pwp_output.z',pwp_output.t,1);
        Cp = 4183.3;
        rho = mean(pwp_output.d,'all','omitnan');
        dHdt = diff(H)./diff(pwp_output.time(1,:))./86400.*Cp.*rho; % need some constant of int.
        nexttile(1)
        yyaxis left
        hold on
        plot(pwp_output.time(1,1:end-1)-8/24, dHdt)
        yline(0,'k--');
        legend('Q_n_e_t', '\rhoc_p(dH/dt)','location', 'best')

        if ~exist(fullfile(pwd, 'plots'), 'dir')
            mkdir('plots'); disp('Making plots directory, changing dir...')
        else
            disp('plots directory exists, changing dir...')
        end
        cd plots

        name = pwp_output_file(1:end-4);
        sgtitle(name,'Interpreter', 'none');
        savefig(name)
        fprintf('Saved %s plot in %s\n', name, pwd);

        cd ..

        close;
    end
    clearvars -except rows runs
end

    
