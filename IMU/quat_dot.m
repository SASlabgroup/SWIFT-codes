function p = quat_dot(q0,q1)
% This function accepts quaternions in row format. The dot (inner) products 
% of q0 and q1 are calculated. Both q0 and q1 are arrays of quaternions of 
% equal length. The arrays should thus be formatted as 
% [N-quaternions x 4-components] with the quaternions ordered [q0,q1,q2,q3].

   p = q0*q1';

end