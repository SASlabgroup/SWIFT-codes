function [v_new] = quat_rotate_vector(v, q)
% [v_new] = quat_rotate_vector(v, q)
% This function rotates a vector by a quaternion. The vectors and quaternions
% must be in row array format.  Multiple quaternions and vectors can be included
% in the same array each occupying a row.  The vector and quaternion matrices
% must have the same row length. The code is simplified if the quaternions have
% been normalized prior to being imported.

   % Convert vector to quaternion
	v_q(:,2:4) = v;
	
   % Calculate the quaternion inverse
   q_inv = quat_inverse(q);

	% Rotation operation: v_q_rotated = (q x v) x q^-1, where 'x' stands for the
	% quaternion product.
	v_q = quat_product(quat_product(q, v_q),q_inv);
	v_new = v_q(:,2:4);

end
