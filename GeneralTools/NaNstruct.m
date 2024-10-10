function S = NaNstruct(S)
% NaNs out all doubles/vectors in the structure S. 
% Limited to 3 levels (not recursive). 
% K. Zeiden 12/26/2023;

for i = 1:length(S)
    
    Si = S(i);
    fields = fieldnames(Si);
    
        for ifield = 1:length(fields)
            if isa(Si.(fields{ifield}),'double')
                Si.(fields{ifield}) = NaN(size(Si.(fields{ifield})));
            elseif isa(Si.(fields{ifield}),'struct')

                Si2 = Si.(fields{ifield});
                fields2 = fieldnames(Si2);

                for ifield2 = 1:length(fields2)
                    if isa(Si2.(fields2{ifield2}),'double')
                        Si2.(fields2{ifield2}) = NaN(size(Si2.(fields2{ifield2})));
                    elseif isa(Si2.(fields2{ifield2}),'struct')

                        Si3 = Si2.(fields2{ifield2});
                        fields3 = fieldnames(Si3);
                        
                        for ifield3 = 1:length(fields3)
                            if isa(Si3.(fields3{ifield3}),'double')
                                Si3.(fields3{ifield3}) = NaN(size(Si3.(fields3{ifield3})));
                            elseif isa(Si3.(fields3{ifield3}),'struct')
                                warning('Structure 3+ levels deep')
                            end
                        end

                        Si2.(fields2{ifield2}) = Si3;
                    end
                end
                Si.(fields{ifield}) = Si2;
             end
        end
    
    S(i) = Si;
    
end


% End function
end

