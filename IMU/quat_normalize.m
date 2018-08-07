function [quat_normalized] = quat_normalize(q)
% This function accepts quaternions in row format.  Normalization is
% completed on each row of a quaternion array.  The array should thus
% be formatted as [N-quaternions x 4-components] with the quaternions 
% ordered [q0,q1,q2,q3].

	if (size(q,2) ~= 4)
		error('error: 1st quaternion array does not have four columns'); 
	end

   quat_norm = sqrt(sum(q.^2,2));
   quat_normalized = bsxfun(@rdivide,q,quat_norm);
  
end
