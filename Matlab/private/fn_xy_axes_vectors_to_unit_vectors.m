function [ex, ey, ez] = fn_xy_axes_vectors_to_unit_vectors(ax, ay)
%SUMMARY
%   Converts vectors ax and ay, nominally representing directions x and y
%   in a coordinate system, to 3 orthogonal unit vectors in the x, y and z
%   axes of that system. ax and ay do not have to be unit vectors or
%   orthogonal (but they do have to be linearly independent). The
%   calculation is
%       ex = ax / |ax|
%       ey = normalised component of ay that is perpendicular to ax
%       ez = ex x ey
sz = size(ax);
if any(sz~=size(ay))
    error('Inputs ax and ay must be same size');
end
d = find(sz == 3);
if length(d) ~= 1 || ndims(ax) > 2
    error('One and only one dimension of ax and ay must be 3');
end

if d == 1
    ax = ax.';
    ay = ay.';
end

ex = ax ./ repmat(sqrt(sum(ax .^ 2, 2)), [1, 3]);
ey = ay - repmat((sum(ex .* ay, 2)), [1, 3]) .* ex;
ey = ey ./ repmat(sqrt(sum(ey .^ 2, 2)), [1, 3]);

ez(: ,1) = [ex(:, 2) .* ey(:, 3) - ex(:, 3) .* ey(:, 2)];
ez(: ,2) = [ex(:, 3) .* ey(:, 1) - ex(:, 1) .* ey(:, 3)];
ez(: ,3) = [ex(:, 1) .* ey(:, 2) - ex(:, 2) .* ey(:, 1)];

ex = reshape(ex, sz);
ey = reshape(ey, sz);
ez = reshape(ez, sz);

end