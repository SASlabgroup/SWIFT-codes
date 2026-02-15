function fullscreen(varargin)
% fullscreen(varargin) expands current figure to fit monitor, either primary 
% or additional monitor if specified. Varargin is a single integer indicating
% which monitor to fill (e.g. 1 is primary, 2 is secondary). If the integer
% supplied is greater than the number of monitors, the figure fills the 
% primary screen. If no integer is supplied, the figure fills the primary 
% screen. K.Zeiden 2019.

MP = get(0,'monitorposition');

if nargin > 0
n = varargin{1};
ns = size(MP,1);

    if n <= ns
        set(gcf,'outerposition',MP(n,:));
        else
            set(gcf,'outerposition',MP(1,:));
    end
    
else
set(gcf,'outerposition',MP(1,:));
end

end

