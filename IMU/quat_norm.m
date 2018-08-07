function [q_norm] = quat_norm(q)
% This function accepts quaternions in row format.  The norms are
% calculated for the given quaternion array. The array should thus
% be formatted as [N-quaternions x 4-components] with the quaternions 
% ordered [q0,q1,q2,q3].

	if (size(q,2) ~= 4)
		error('Quaternion array does not have four columns');
	end 

   q_norm = sqrt(sum(q.^2,2));
  
end
