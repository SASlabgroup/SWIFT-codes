/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: mldivide.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "mldivide.h"
#include "GPSwaves_emxutil.h"
#include "xgeqp3.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real_T *A
 *                const emxArray_real_T *B
 *                double Y[2]
 * Return Type  : void
 */
void mldivide(const emxArray_real_T *A, const emxArray_real_T *B, double Y[2])
{
  emxArray_real_T *b_A;
  emxArray_real_T *b_B;
  int i;
  int minmn;
  int maxmn;
  double A_data[4];
  int jpvt[2];
  double tau_data[2];
  int tau_size[1];
  int rankR;
  int j;
  double tol;
  emxInit_real_T(&b_A, 2);
  emxInit_real_T1(&b_B, 1);
  if ((A->size[0] == 0) || (B->size[0] == 0)) {
    for (i = 0; i < 2; i++) {
      Y[i] = 0.0;
    }
  } else if (A->size[0] == 2) {
    maxmn = A->size[0] * A->size[1];
    for (minmn = 0; minmn < maxmn; minmn++) {
      A_data[minmn] = A->data[minmn];
    }

    for (minmn = 0; minmn < 2; minmn++) {
      jpvt[minmn] = 1 + minmn;
    }

    minmn = 0;
    if (fabs(A->data[1]) > fabs(A->data[0])) {
      minmn = 1;
    }

    if (A->data[minmn] != 0.0) {
      if (minmn != 0) {
        jpvt[0] = 2;
        minmn = 0;
        maxmn = 1;
        for (j = 0; j < 2; j++) {
          tol = A_data[minmn];
          A_data[minmn] = A_data[maxmn];
          A_data[maxmn] = tol;
          minmn += 2;
          maxmn += 2;
        }
      }

      A_data[1] /= A_data[0];
    }

    if (A_data[2] != 0.0) {
      A_data[3] += A_data[1] * -A_data[2];
    }

    for (minmn = 0; minmn < 2; minmn++) {
      Y[minmn] = B->data[minmn];
    }

    if (jpvt[0] != 1) {
      Y[0] = B->data[1];
      Y[1] = B->data[0];
    }

    for (j = 0; j < 2; j++) {
      minmn = j << 1;
      if (Y[j] != 0.0) {
        i = j + 2;
        while (i < 3) {
          Y[1] -= Y[j] * A_data[minmn + 1];
          i = 3;
        }
      }
    }

    for (j = 1; j >= 0; j--) {
      minmn = j << 1;
      if (Y[j] != 0.0) {
        Y[j] /= A_data[j + minmn];
        i = 1;
        while (i <= j) {
          Y[0] -= Y[1] * A_data[minmn];
          i = 2;
        }
      }
    }
  } else {
    minmn = b_A->size[0] * b_A->size[1];
    b_A->size[0] = A->size[0];
    b_A->size[1] = 2;
    emxEnsureCapacity_real_T1(b_A, minmn);
    maxmn = A->size[0] * A->size[1];
    for (minmn = 0; minmn < maxmn; minmn++) {
      b_A->data[minmn] = A->data[minmn];
    }

    xgeqp3(b_A, tau_data, tau_size, jpvt);
    rankR = 0;
    if (b_A->size[0] < 2) {
      minmn = b_A->size[0];
      maxmn = 2;
    } else {
      minmn = 2;
      maxmn = b_A->size[0];
    }

    if (minmn > 0) {
      tol = (double)maxmn * fabs(b_A->data[0]) * 2.2204460492503131E-16;
      while ((rankR < minmn) && (!(fabs(b_A->data[rankR + b_A->size[0] * rankR])
               <= tol))) {
        rankR++;
      }
    }

    minmn = b_B->size[0];
    b_B->size[0] = B->size[0];
    emxEnsureCapacity_real_T(b_B, minmn);
    maxmn = B->size[0];
    for (minmn = 0; minmn < maxmn; minmn++) {
      b_B->data[minmn] = B->data[minmn];
    }

    for (i = 0; i < 2; i++) {
      Y[i] = 0.0;
    }

    minmn = b_A->size[0];
    maxmn = b_A->size[0];
    if (!(maxmn < 2)) {
      maxmn = 2;
    }

    for (j = 0; j + 1 <= maxmn; j++) {
      if (tau_data[j] != 0.0) {
        tol = b_B->data[j];
        for (i = j + 1; i + 1 <= minmn; i++) {
          tol += b_A->data[i + b_A->size[0] * j] * b_B->data[i];
        }

        tol *= tau_data[j];
        if (tol != 0.0) {
          b_B->data[j] -= tol;
          for (i = j + 1; i + 1 <= minmn; i++) {
            b_B->data[i] -= b_A->data[i + b_A->size[0] * j] * tol;
          }
        }
      }
    }

    for (i = 0; i + 1 <= rankR; i++) {
      Y[jpvt[i] - 1] = b_B->data[i];
    }

    for (j = rankR - 1; j + 1 > 0; j--) {
      Y[jpvt[j] - 1] /= b_A->data[j + b_A->size[0] * j];
      i = 1;
      while (i <= j) {
        Y[jpvt[0] - 1] -= Y[jpvt[j] - 1] * b_A->data[b_A->size[0] * j];
        i = 2;
      }
    }
  }

  emxFree_real_T(&b_B);
  emxFree_real_T(&b_A);
}

/*
 * File trailer for mldivide.c
 *
 * [EOF]
 */
