function model = fitCircleKasa(x,y)
%FITCIRCLEKASA Algebraic least-squares circle [xCenter yCenter radius].
x = x(:);
y = y(:);
valid = isfinite(x) & isfinite(y);
x = x(valid);
y = y(valid);
model = [NaN NaN NaN];
if numel(x) < 3; return; end

% Center coordinates before solving x^2+y^2+D*x+E*y+F = 0.
origin = [mean(x) mean(y)];
xy = [x-origin(1) y-origin(2)];
A = [xy ones(numel(x),1)];
if rank(A) < 3; return; end
coef = A \ -sum(xy.^2,2);
center = -coef(1:2)'/2;
radiusSquared = sum(center.^2)-coef(3);
if radiusSquared <= 0; return; end
model = [origin+center sqrt(radiusSquared)];
end
