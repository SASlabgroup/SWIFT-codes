function S = NaNstructR(S)
% Recursive version of NaNstruct
% K. Zeiden 12/26/2023

for i = 1:length(S)
    
    Si = S(i);
    fields = fieldnames(Si);
    
        for ifield = 1:length(fields)
            
            var = Si.(fields{ifield});
            
            if isa(var,'numeric')
                Si.(fields{ifield}) = NaN(size(var));
                
            elseif isa(var,'struct')
                 Si.(fields{ifield}) = NaNstructR(var);
                 
             end
        end
    
    S(i) = Si;
    
end


% End function
end

