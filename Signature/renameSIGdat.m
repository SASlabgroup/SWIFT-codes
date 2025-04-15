function renameSIGdat(missiondir)
% Renames all raw '.dat' Signature files in a mission directory '.ad2cp'.
%       To enable reading in by MIDAS or Signature Deployment software).
% Note: if prefer to create copies of files, then rename, use 'copyfile'.
% K. Zeiden 04/2025

if ispc
    slash = '\';
else
    slash = '/';
end

dfiles = dir([missiondir slash 'SIG' slash 'Raw' slash '*' slash '*.dat']);
if isempty(dfiles)
    disp('No Signature dat files found')
    return
end

for ifile = 1:length(dfiles)

    cd(dfiles(ifile).folder)
    copyfile(dfiles(ifile).name,[dfiles(ifile).name(1:end-4) '.ad2cp'])

end

cd(missiondir)

end