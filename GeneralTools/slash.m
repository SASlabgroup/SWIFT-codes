function slashtype = slash()
% Call 'slash' when navigating directories

if ispc 
    slashtype = '\';
else
    slashtype = '/';
end