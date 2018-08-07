/* This function accepts a single acceleration vector recorded in
 * the sensor fixed coordinate system, and the orientation of the 
 * sensor in the real world coordinate system (North, East, Down)
 * as recorded in quaternion form.  The sensor fixed acceleration
 * is then rotated to the real world coordinate system using the 
 * quaternion. 
 * 
 * The actual function definition is found in:
 * "SWIFT_OrientationCorrection.c"
 * 
 * Adam Brown, 2015 (brownapl@uw.edu)
 * 
 */
 
int XYZ_2_NED(float *aN, float *aE, float *aD, float *qw, float *qx, float *qy, float *qz, float *ax, float *ay, float *az, int signal_length)
{
	// A vector in quaternion form is written: (0, x, y, z).
	// So, we convert the acceleration vector to a quaternion
	// by setting aw = 0 */
	float aw = 0;
	int i;
	for(i=0 ; i < signal_length ; i++)
	{
		// Normalize the quaternions
		float q_mag = sqrt( qw[i]*qw[i] + qx[i]*qx[i] + qy[i]*qy[i] + qz[i]*qz[i] );
		float qw_n = qw[i]/q_mag;
		float qx_n = qx[i]/q_mag;
		float qy_n = qy[i]/q_mag;
		float qz_n = qz[i]/q_mag;
		
		// The inverse of a normalized quaternion is the same as the 
		// conjugate, and the quaternion conjugate is:
		float qw_conj = qw_n;
		float qx_conj = -qx_n;
		float qy_conj = -qy_n;
		float qz_conj = -qz_n;
		
		// Rotate the vector by the quaternion: a_new = (q x a) x q_inverse
		// The quaternion cross product is defined in "Visualizing 
		// Quaternions" by Hanson. The cross product in paretheses is:
		float pw = qw_n*aw - qx_n*ax[i] - qy_n*ay[i] - qz_n*az[i];
		float px = qx_n*aw + qw_n*ax[i] + qy_n*az[i] - qz_n*ay[i];
		float py = qy_n*aw + qw_n*ay[i] + qz_n*ax[i] - qx_n*az[i];
		float pz = qz_n*aw + qw_n*az[i] + qx_n*ay[i] - qy_n*ax[i];
		// The second cross product is:
		aw = pw*qw_conj - px*qx_conj - py*qy_conj - pz*qz_conj;
		aN[i] = px*qw_conj + pw*qx_conj + py*qz_conj - pz*qy_conj;
		aE[i] = py*qw_conj + pw*qy_conj + pz*qx_conj - px*qz_conj;
		aD[i] = pz*qw_conj + pw*qz_conj + px*qy_conj - py*qx_conj;
		
		// After the rotation aw should still be zero.  If it isn't
		// return an error, if it is zero return success.
		if (fabs(aw) > 0.01)
		{
			return 1;
		} 
	}
	// Success!
	return i;
}
