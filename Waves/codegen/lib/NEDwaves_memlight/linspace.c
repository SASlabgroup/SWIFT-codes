/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: linspace.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 10-Oct-2023 20:23:55
 */

/* Include Files */
#include "linspace.h"
#include "NEDwaves_memlight_emxutil.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : double d1
 *                double d2
 *                double n
 *                emxArray_real_T *y
 * Return Type  : void
 */
void linspace(double d1, double d2, double n, emxArray_real_T *y)
{
  double *y_data;
  int k;
  if (!(n >= 0.0)) {
    y->size[0] = 1;
    y->size[1] = 0;
  } else {
    double delta1;
    int y_tmp_tmp;
    delta1 = floor(n);
    y_tmp_tmp = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = (int)delta1;
    emxEnsureCapacity_real_T(y, y_tmp_tmp);
    y_data = y->data;
    if ((int)delta1 >= 1) {
      y_tmp_tmp = (int)delta1 - 1;
      y_data[(int)floor(n) - 1] = d2;
      if (y->size[1] >= 2) {
        y_data[0] = d1;
        if (y->size[1] >= 3) {
          if ((d1 == -d2) && ((int)delta1 > 2)) {
            double delta2;
            delta2 = d2 / ((double)(int)delta1 - 1.0);
            for (k = 2; k <= y_tmp_tmp; k++) {
              y_data[k - 1] = (double)(((k << 1) - (int)delta1) - 1) * delta2;
            }
            if (((int)delta1 & 1) == 1) {
              y_data[(int)delta1 >> 1] = 0.0;
            }
          } else if (((d1 < 0.0) != (d2 < 0.0)) &&
                     ((fabs(d1) > 8.9884656743115785E+307) ||
                      (fabs(d2) > 8.9884656743115785E+307))) {
            double delta2;
            delta1 = d1 / ((double)y->size[1] - 1.0);
            delta2 = d2 / ((double)y->size[1] - 1.0);
            y_tmp_tmp = y->size[1];
            for (k = 0; k <= y_tmp_tmp - 3; k++) {
              y_data[k + 1] = (d1 + delta2 * ((double)k + 1.0)) -
                              delta1 * ((double)k + 1.0);
            }
          } else {
            delta1 = (d2 - d1) / ((double)y->size[1] - 1.0);
            y_tmp_tmp = y->size[1];
            for (k = 0; k <= y_tmp_tmp - 3; k++) {
              y_data[k + 1] = d1 + ((double)k + 1.0) * delta1;
            }
          }
        }
      }
    }
  }
}

/*
 * File trailer for linspace.c
 *
 * [EOF]
 */
