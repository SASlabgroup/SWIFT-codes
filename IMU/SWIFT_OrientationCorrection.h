/* This function declaration accepts a single acceleration vector 
 * recorded in the sensor fixed coordinate system, and the orientation 
 * of the sensor in the real world coordinate system (North, East, Down)
 * as recorded in quaternion form.  The sensor fixed acceleration
 * is then rotated to the real world coordinate system using the 
 * quaternion. 
 * 
 * Adam Brown, 2015 (brownapl@uw.edu)
 * 
 */
#ifndef _ROTATEACCEL_
	#define _ROTATEACCEL_
	#include <math.h>

	int XYZ_2_NED(float *aN, float *aE, float *aD, float *qw, float *qx, float *qy, float *qz, float *ax, float *ay, float *az, int signal_length);

#endif
 

