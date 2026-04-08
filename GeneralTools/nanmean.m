function y = nanmean(x, dim)
% NANMEAN    Mean value, same as in matlab 5 but ignoring NaNs
%===================================================================
% NANMEAN   2.1 30/5/97
%
% function y = nanmean(x, dim)
%
% DESCRIPTION:
%    Mean value, same as in matlab 5 but ignoring NaNs.
%    For vectors, NANMEAN(X) is the mean value of the elements in X. For
%    matrices, NANMEAN(X) is a row vector containing the mean value of
%    each column.  For N-D arrays, NANMEAN(X) is the mean value of the
%    elements along the first non-singleton dimension of X.
% 
%    NANMEAN(X,DIM) takes the mean along the dimension DIM of X. 
% 
% INPUT:
%    x    = array of any dimension
%    dims = dimension along which to take the mean
%
% OUTPUT:
%    y    =  a mean of actual data values, i.e., ignoring NaNs.
%
% EXAMPLES:
%           x = [ 1  2  3; 5 NaN 7];
%           y = nanmean(x)
%           y = [3 2 5]
%
%           x = [ 1  NaN  3; 5 NaN 7];
%           y = nanmean(x)
%           y = [3 NaN 5]
%
%           x = [ 1  NaN  3; 5 NaN 7];
%           y = nanmean(x, 2)
%           y = [2; 6]
%
% CALLER:   general purpose
% CALLEE:   none
%
% AUTHOR:   Jim Mansbridge
%==================================================================

% $Id: nanmean.m,v 1.4 1997/06/02 06:00:58 mansbrid Exp $
% 
%--------------------------------------------------------------------

if nargin == 1
  aa = ~isnan(x);
  ff = find(aa == 0);
  if (length(ff) ~= 0) % replace NaNs by zeros
    x(ff) = zeros(size(ff));
  end
  ss = sum(aa);        % find the total number of non-nans in the column
  ff = find(ss == 0);
  if (length(ff) ~= 0) % put NaNs where the mean came from a column of NaNs
    ss(ff) = NaN*zeros(size(ff));
  end
  y = sum(x)./ss;      % calculate the mean
elseif nargin == 2
  aa = ~isnan(x);
  ff = find(aa == 0);
  if (length(ff) ~= 0) % replace NaNs by zeros
    x(ff) = zeros(size(ff));
  end
  ss = sum(aa, dim);   % find the total number of non-nans in the column
  ff = find(ss == 0);
  if (length(ff) ~= 0) % put NaNs where the mean came from a column of NaNs
    ss(ff) = NaN*zeros(size(ff));
  end
  y = sum(x, dim)./ss; % calculate the mean
end
