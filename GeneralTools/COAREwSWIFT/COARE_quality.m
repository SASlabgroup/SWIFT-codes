function [qual] = COARE_quality(SWIFT, fluxes)
% function to create qual table giving time synchonous percent errors of
% COARE vs SWIFT vars. Compiles all percent differences into a corrcoef
% confusion matrix to find what pct errors correlate
% 
% Vars:
% 
% Tskin, ustar, tau, epsilon
%

savepath = 'C:\Users\MichaelJames\Dropbox\mjames\Carson_COAREcomparision\COARE_IO';
cd(savepath); fprintf('Savepath: %s', savepath);
end