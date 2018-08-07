function [q_prod] = quat_product(p,q)
%  The quaternion product of p and q is returned in row array format.
%  both p and q should be input in array format: p = [q_w,q_x,q_y,q_z].

	if (size(p,2) ~= 4)
		error('error: 1st quaternion array does not have four columns'); 
	end
	if (size(q,2) ~= 4)
		error('error: 2nd quaternion array does not have four columns');
	end 

  q_prod = [p(:,1).*q(:,1) - p(:,2).*q(:,2) - p(:,3).*q(:,3) - p(:,4).*q(:,4),...
            p(:,2).*q(:,1) + p(:,1).*q(:,2) + p(:,3).*q(:,4) - p(:,4).*q(:,3),...
            p(:,3).*q(:,1) + p(:,1).*q(:,3) + p(:,4).*q(:,2) - p(:,2).*q(:,4),...
            p(:,4).*q(:,1) + p(:,1).*q(:,4) + p(:,2).*q(:,3) - p(:,3).*q(:,2)];
  
          
end
