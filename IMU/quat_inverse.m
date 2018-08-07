function [q_inv] = quat_inverse(q)
% This function accepts quaternions in row format.  The quaternion 
% inverse is calculated for the given quaternion array. The array 
% should thus be formatted as: [N-quaternions x 4-components]
% with the quaternions ordered [q0,q1,q2,q3].

	q = quat_normalize(q);
	q_inv = [q(:,1), -q(:,2), -q(:,3), -q(:,4)];
   

end
