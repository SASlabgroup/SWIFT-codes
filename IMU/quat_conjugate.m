function [q_c] = quat_conjugate(q)
% This function accepts quaternions in row format. The conjugate of each
% quaternion is computed for an array of quaternions. The array should thus
% be formatted as [N-quaternions x 4-components] with the quaternions 
% ordered [q0,q1,q2,q3].

	if (size(q,2) ~= 4)
		error('error: 1st quaternion array does not have four columns'); 
   end
   
q_c = [q(:,1), -q(:,2), -q(:,3), -q(:,4)];

end