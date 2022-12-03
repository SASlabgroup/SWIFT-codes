/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: detrend.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "detrend.h"
#include "GPSwaves_emxutil.h"
#include "mldivide.h"

/* Function Definitions */

/*
 * Arguments    : emxArray_real_T *x
 * Return Type  : void
 */
void detrend(emxArray_real_T *x)
{
  emxArray_real_T *a;
  int nrows;
  int ar;
  int ia;
  emxArray_real_T *C;
  double b[2];
  unsigned int a_idx_0;
  int m;
  int br;
  int ic;
  emxInit_real_T(&a, 2);
  nrows = x->size[0];
  ar = x->size[0];
  ia = a->size[0] * a->size[1];
  a->size[0] = ar;
  a->size[1] = 2;
  emxEnsureCapacity_real_T1(a, ia);
  for (ar = 1; ar <= nrows; ar++) {
    a->data[ar - 1] = (double)ar / (double)nrows;
    a->data[(ar + a->size[0]) - 1] = 1.0;
  }

  emxInit_real_T1(&C, 1);
  mldivide(a, x, b);
  a_idx_0 = (unsigned int)a->size[0];
  ia = C->size[0];
  C->size[0] = (int)a_idx_0;
  emxEnsureCapacity_real_T(C, ia);
  m = a->size[0];
  ar = C->size[0];
  ia = C->size[0];
  C->size[0] = ar;
  emxEnsureCapacity_real_T(C, ia);
  for (ia = 0; ia < ar; ia++) {
    C->data[ia] = 0.0;
  }

  if (a->size[0] != 0) {
    ar = 0;
    while ((m > 0) && (ar <= 0)) {
      for (ic = 1; ic <= m; ic++) {
        C->data[ic - 1] = 0.0;
      }

      ar = m;
    }

    br = 0;
    ar = 0;
    while ((m > 0) && (ar <= 0)) {
      ar = -1;
      for (nrows = br; nrows + 1 <= br + 2; nrows++) {
        if (b[nrows] != 0.0) {
          ia = ar;
          for (ic = 0; ic + 1 <= m; ic++) {
            ia++;
            C->data[ic] += b[nrows] * a->data[ia];
          }
        }

        ar += m;
      }

      br += 2;
      ar = m;
    }
  }

  emxFree_real_T(&a);
  ia = x->size[0];
  emxEnsureCapacity_real_T(x, ia);
  ar = x->size[0];
  for (ia = 0; ia < ar; ia++) {
    x->data[ia] -= C->data[ia];
  }

  emxFree_real_T(&C);
}

/*
 * File trailer for detrend.c
 *
 * [EOF]
 */
