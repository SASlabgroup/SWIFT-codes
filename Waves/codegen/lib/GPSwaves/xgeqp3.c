/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xgeqp3.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "xgeqp3.h"
#include "xnrm2.h"
#include "xscal.h"

/* Function Declarations */
static double rt_hypotd_snf(double u0, double u1);

/* Function Definitions */

/*
 * Arguments    : double u0
 *                double u1
 * Return Type  : double
 */
static double rt_hypotd_snf(double u0, double u1)
{
  double y;
  double a;
  double b;
  a = fabs(u0);
  b = fabs(u1);
  if (a < b) {
    a /= b;
    y = b * sqrt(a * a + 1.0);
  } else if (a > b) {
    b /= a;
    y = a * sqrt(b * b + 1.0);
  } else if (rtIsNaN(b)) {
    y = b;
  } else {
    y = a * 1.4142135623730951;
  }

  return y;
}

/*
 * Arguments    : emxArray_real_T *A
 *                double tau_data[]
 *                int tau_size[1]
 *                int jpvt[2]
 * Return Type  : void
 */
void xgeqp3(emxArray_real_T *A, double tau_data[], int tau_size[1], int jpvt[2])
{
  int m;
  int mn;
  int i5;
  int k;
  int j;
  int i;
  double work[2];
  double xnorm;
  double vn2[2];
  int i_i;
  int mmi;
  double vn1[2];
  int pvt;
  int ix;
  double temp2;
  double d0;
  int lastv;
  int lastc;
  boolean_T exitg2;
  int jy;
  int exitg1;
  m = A->size[0];
  mn = A->size[0];
  if (!(mn < 2)) {
    mn = 2;
  }

  tau_size[0] = mn;
  for (i5 = 0; i5 < 2; i5++) {
    jpvt[i5] = 1 + i5;
  }

  if (A->size[0] != 0) {
    k = 1;
    for (j = 0; j < 2; j++) {
      work[j] = 0.0;
      xnorm = xnrm2(m, A, k);
      vn2[j] = xnorm;
      k += m;
      vn1[j] = xnorm;
    }

    for (i = 0; i + 1 <= mn; i++) {
      i_i = i + i * m;
      mmi = (m - i) - 1;
      j = 0;
      if ((2 - i > 1) && (fabs(vn1[i + 1]) > fabs(vn1[i]))) {
        j = 1;
      }

      pvt = i + j;
      if (pvt + 1 != i + 1) {
        ix = m * pvt;
        j = m * i;
        for (k = 1; k <= m; k++) {
          xnorm = A->data[ix];
          A->data[ix] = A->data[j];
          A->data[j] = xnorm;
          ix++;
          j++;
        }

        j = jpvt[pvt];
        jpvt[pvt] = jpvt[i];
        jpvt[i] = j;
        vn1[pvt] = vn1[i];
        vn2[pvt] = vn2[i];
      }

      if (i + 1 < m) {
        temp2 = A->data[i_i];
        d0 = 0.0;
        if (!(1 + mmi <= 0)) {
          xnorm = xnrm2(mmi, A, i_i + 2);
          if (xnorm != 0.0) {
            xnorm = rt_hypotd_snf(A->data[i_i], xnorm);
            if (A->data[i_i] >= 0.0) {
              xnorm = -xnorm;
            }

            if (fabs(xnorm) < 1.0020841800044864E-292) {
              j = 0;
              do {
                j++;
                xscal(mmi, 9.9792015476736E+291, A, i_i + 2);
                xnorm *= 9.9792015476736E+291;
                temp2 *= 9.9792015476736E+291;
              } while (!(fabs(xnorm) >= 1.0020841800044864E-292));

              xnorm = rt_hypotd_snf(temp2, xnrm2(mmi, A, i_i + 2));
              if (temp2 >= 0.0) {
                xnorm = -xnorm;
              }

              d0 = (xnorm - temp2) / xnorm;
              xscal(mmi, 1.0 / (temp2 - xnorm), A, i_i + 2);
              for (k = 1; k <= j; k++) {
                xnorm *= 1.0020841800044864E-292;
              }

              temp2 = xnorm;
            } else {
              d0 = (xnorm - A->data[i_i]) / xnorm;
              temp2 = 1.0 / (A->data[i_i] - xnorm);
              xscal(mmi, temp2, A, i_i + 2);
              temp2 = xnorm;
            }
          }
        }

        tau_data[i] = d0;
        A->data[i_i] = temp2;
      } else {
        tau_data[i] = 0.0;
      }

      if (i + 1 < 2) {
        temp2 = A->data[i_i];
        A->data[i_i] = 1.0;
        if (tau_data[0] != 0.0) {
          lastv = 1 + mmi;
          j = i_i + mmi;
          while ((lastv > 0) && (A->data[j] == 0.0)) {
            lastv--;
            j--;
          }

          lastc = 1 - i;
          exitg2 = false;
          while ((!exitg2) && (lastc > 0)) {
            pvt = m;
            do {
              exitg1 = 0;
              if (pvt + 1 <= m + lastv) {
                if (A->data[pvt] != 0.0) {
                  exitg1 = 1;
                } else {
                  pvt++;
                }
              } else {
                lastc = 0;
                exitg1 = 2;
              }
            } while (exitg1 == 0);

            if (exitg1 == 1) {
              exitg2 = true;
            }
          }
        } else {
          lastv = 0;
          lastc = 0;
        }

        if (lastv > 0) {
          if (lastc != 0) {
            work[0] = 0.0;
            j = 0;
            k = m + 1;
            while ((m > 0) && (k <= 1 + m)) {
              ix = i_i;
              xnorm = 0.0;
              i5 = (k + lastv) - 1;
              for (pvt = k; pvt <= i5; pvt++) {
                xnorm += A->data[pvt - 1] * A->data[ix];
                ix++;
              }

              work[j] += xnorm;
              j++;
              k += m;
            }
          }

          if (!(-tau_data[0] == 0.0)) {
            k = m;
            jy = 0;
            j = 1;
            while (j <= lastc) {
              if (work[jy] != 0.0) {
                xnorm = work[jy] * -tau_data[0];
                ix = i_i;
                i5 = lastv + k;
                for (pvt = k; pvt + 1 <= i5; pvt++) {
                  A->data[pvt] += A->data[ix] * xnorm;
                  ix++;
                }
              }

              jy++;
              k += m;
              j = 2;
            }
          }
        }

        A->data[i_i] = temp2;
      }

      j = i + 2;
      while (j < 3) {
        if (vn1[1] != 0.0) {
          xnorm = fabs(A->data[i + A->size[0]]) / vn1[1];
          xnorm = 1.0 - xnorm * xnorm;
          if (xnorm < 0.0) {
            xnorm = 0.0;
          }

          temp2 = vn1[1] / vn2[1];
          temp2 = xnorm * (temp2 * temp2);
          if (temp2 <= 1.4901161193847656E-8) {
            if (i + 1 < m) {
              vn1[1] = xnrm2(mmi, A, (i + m) + 2);
              vn2[1] = vn1[1];
            } else {
              vn1[1] = 0.0;
              vn2[1] = 0.0;
            }
          } else {
            vn1[1] *= sqrt(xnorm);
          }
        }

        j = 3;
      }
    }
  }
}

/*
 * File trailer for xgeqp3.c
 *
 * [EOF]
 */
