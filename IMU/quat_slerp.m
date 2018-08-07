% This is a modified version of Sagi Dalyot's "slerp.m" which can be found
% on the Matlab file exchange at:
% http://www.mathworks.com/matlabcentral/fileexchange/11827-slerp

% in general:
% slerp(q1, q2, t) = q1*(sin(1-t)*phi)/sin(t) + q2*(sin(t*phi))/sin(phi)
% where phi is the angle between the two unit quaternions,
% and t is between [0,1]

% two border cases will be delt:
% 1: where q1 = q2 (or close by eps)
% 2: where q1 = -q2 (angle between unit quaternions is 180 degrees).
% in general, if q1 = q2 then Slerp(q; q; t) == q

function [q_out] = quat_slerp(q_in,varargin)
% This function interpolates between members of a quaternion array. Each 
% quaternion occupies a row of the array, and are thus formatted as 
% [q0,q1,q2,q3], where q0 is the real component. Interpolation occurs at
% the fractional locations "t" (fraction of the total angle between q(i) 
% and q(i+1) If the input parameter "steps" is specified as an array, it 
% will be assumed that the step locations are being specified directly. 
% If, "steps" is a single integer, it is assumed that it is the additional
% number of steps between 0 and 1. So all the integer angles
% between 0 and 90, but not including 0, you would specify steps = 90.
% The program can also handle the case where an array with valid 
% quaternions separated by NaNs is passed to the program. The number of
% NaNs between valid points is used to determine the number of "steps". In
% this case, the variable steps if it is specified will be ignored and a
% warning message will be displayed.
   if nargin<1 || nargin>2
      error('Incorrect number of input arguments');
   end
   % epsilon is the max expected computer rounding error
   epsilon = 1e-7;
   % determine if there are any NaNs in the quaternion array
   any_NaNs = any(any(isnan(q_in)));
   % If there are NaNs populate the NaN locations with interpolated values
   if any_NaNs
      if nargin == 2
         warning('NaNs were found in the quaternion array.The specified steps variable will be ignored.');
      end % if
      % Determine the size of the quaternion array
      [n_rows,n_cols] = size(q_in);
      if n_cols ~= 4
         error('The quaternion array does not contain 4 columns');
      end
      % Find the indeces of the NaNs and the valid quaternions
      NaN_indeces = sum(isnan(q_in),2) > 0;
      good_indeces = (~NaN_indeces).*[1:1:n_rows]';
      good_indeces(good_indeces==0) = [];
      n_good_indeces = length(good_indeces);
      if n_good_indeces<2
         q_out = q_in;
         display('The array contains too many NaNs to interpolate. Returning original array.');
         return;
      end
      step_array = diff(good_indeces);
      % Loop through the rows of the quaternion array
      q_out = zeros(n_rows,4);
      q_out(1:good_indeces(1),:) = repmat(q_in(good_indeces(1),:),[good_indeces(1),1]);
      for i = 1:(n_good_indeces-1)
         q_out(good_indeces(i),:) = q_in(good_indeces(i),:);
         
         C = quat_dot(q_in(good_indeces(i),:),q_in(good_indeces(i+1),:));
         if C<0
            q_in(good_indeces(i+1),:) =-q_in(good_indeces(i+1),:);
            C = quat_dot(q_in(good_indeces(i),:),q_in(good_indeces(i+1),:));
         end
         phi = acos(C);
         step_size = 1/step_array(i);
         steps = [step_size:step_size:1]';
         for a = 1:length(steps)
            %if (1 - C) <= epsilon % if angle teta is close by epsilon to 0 degrees -> calculate by linear interpolation
            %   q_step = q_in(good_indeces(i),:)*(1-steps(a)) + q_in(good_indeces(i+1),:)*steps(a); % avoiding divisions by number close to 0
            %elseif (1 + C) <= epsilon % when teta is close by epsilon to 180 degrees the result is undefined -> no shortest direction to rotate
            %   q_fixed = [q_in(good_indeces(i),4) -q_in(good_indeces(i),3) q_in(good_indeces(i),2) -q_in(good_indeces(i),1)]; % rotating one of the unit quaternions by 90 degrees -> q2
            %   q_step = q_in(good_indeces(i),:)*(sin((1-steps(a))*(pi/2))) + q_fixed*sin(steps(a)*(pi/2));
            %else
               q_step = q_in(good_indeces(i),:)*(sin((1-steps(a))*phi))/sin(phi) + q_in(good_indeces(i+1),:)*sin(steps(a)*phi)/sin(phi);
            %end
            q_out(good_indeces(i)+a,:) = q_step;
         end % for
      end % for
      q_out((good_indeces(end)+1):n_rows,:) = repmat(q_in(good_indeces(end),:),[n_rows-good_indeces(end),1]);
   % If there aren't any NaNs, interpolated between the array rows using
   % the specified number of evenly spaced steps
   else
   % Test to see how "steps" was specified
      if nargin == 1
         error('No NaNs were found in the quaternion array. "steps" must be specified')
      end % if
      
      % Retrieve the steps variable from the input arguments
      steps = varagin{1};
      
      % Determine if the steps variable is a single integer. If it is, create a steps
      % array and assign it to the "steps" variable.
      if (numel(steps) == 1) && mod(steps,1)==0
         step_size = 1/(steps);
         steps = linspace(step_size,1,steps);
      end % if
      
      % Determine the size of the quaternion array
      [n_rows,n_cols] = size(q_in);
      
      % Loop through the rows of the quaternion array
      q_out(1,:) = q_in(1,:);
      for i = 1:(n_rows-1)
         C = quat_dot(q_in(i,:),q_in(i+1,:)); 
         phi = acos(C);
         % Interpolate at each step between the rows of the input quaternion array
         for a = 1:length(steps)
            if (1 - C) <= epsilon % if angle teta is close by epsilon to 0 degrees -> calculate by linear interpolation
               q_step = q_in(i,:)*(1-steps(a)) + q_in(i+1,:)*steps(a); % avoiding divisions by number close to 0
            elseif (1 + C) <= epsilon % when teta is close by epsilon to 180 degrees the result is undefined -> no shortest direction to rotate
               q_fixed = [q_in(i,4) -q_in(i,3) q_in(i,2) -q_in(i,1)]; % rotating one of the unit quaternions by 90 degrees -> q2
               q_step = q_in(i,:)*(sin((1-steps(a))*(pi/2))) + q_fixed*sin(steps(a)*(pi/2));
            else
               q_step = q_in(i,:)*(sin((1-steps(a))*phi))/sin(phi) + q_in(i+1,:)*sin(steps(a)*phi)/sin(phi);
            end
            q_out = [q_out;q_step];
         end % for
      end % for
   end % if
end
