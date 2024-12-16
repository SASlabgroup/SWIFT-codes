% remove microSWIFT temp or salinity = zero

flist = dir('*SWIFT*.mat');

for fi=1:length(flist)

    load(flist(fi).name,'SWIFT')

    if isfield(SWIFT,'watertemp')
        for si=1:length(SWIFT)
            if SWIFT(si).watertemp == 0
                SWIFT(si).watertemp = NaN;
            end
        end
    end

    if isfield(SWIFT,'salinity')
        for si=1:length(SWIFT)
            if SWIFT(si).salinity == 0
                SWIFT(si).salinity = NaN;
            end
        end
    end

    save(flist(fi).name,'SWIFT')

end


