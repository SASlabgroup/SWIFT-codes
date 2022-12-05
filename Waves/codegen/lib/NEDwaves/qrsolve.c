/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: qrsolve.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 05-Dec-2022 10:00:34
 */

/* Include Files */
#include "qrsolve.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"
#include "xnrm2.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Declarations */
static float rt_hypotf_snf(float u0, float u1);

/* Function Definitions */
/*
 * Arguments    : float u0
 *                float u1
 * Return Type  : float
 */
static float rt_hypotf_snf(float u0, float u1)
{
  float a;
  float y;
  a = fabsf(u0);
  y = fabsf(u1);
  if (a < y) {
    a /= y;
    y *= sqrtf(a * a + 1.0F);
  } else if (a > y) {
    y /= a;
    y = a * sqrtf(y * y + 1.0F);
  } else if (!rtIsNaNF(y)) {
    y = a * 1.41421354F;
  }
  return y;
}

/*
 * Arguments    : const emxArray_real32_T *A
 *                const emxArray_real32_T *B
 *                float Y[2]
 *                int *rankA
 * Return Type  : void
 */
void qrsolve(const emxArray_real32_T *A, const emxArray_real32_T *B, float Y[2],
             int *rankA)
{
  emxArray_real32_T *b_A;
  emxArray_real32_T *b_B;
  float tau_data[2];
  const float *A_data;
  const float *B_data;
  float temp;
  float *b_A_data;
  float *b_B_data;
  int b_i;
  int i;
  int iac;
  int k;
  int m;
  int minmana;
  int minmn;
  signed char jpvt[2];
  B_data = B->data;
  A_data = A->data;
  emxInit_real32_T(&b_A, 2);
  i = b_A->size[0] * b_A->size[1];
  b_A->size[0] = A->size[0];
  b_A->size[1] = 2;
  emxEnsureCapacity_real32_T(b_A, i);
  b_A_data = b_A->data;
  minmana = A->size[0] * 2;
  for (i = 0; i < minmana; i++) {
    b_A_data[i] = A_data[i];
  }
  m = A->size[0];
  minmana = A->size[0];
  if (minmana > 2) {
    minmana = 2;
  }
  if (minmana - 1 >= 0) {
    memset(&tau_data[0], 0, minmana * sizeof(float));
  }
  if (A->size[0] == 0) {
    jpvt[0] = 1;
    jpvt[1] = 2;
  } else {
    float vn1[2];
    float vn2[2];
    float work[2];
    int ma;
    ma = A->size[0];
    minmn = A->size[0];
    if (minmn > 2) {
      minmn = 2;
    }
    jpvt[0] = 1;
    work[0] = 0.0F;
    temp = xnrm2(A->size[0], A, 1);
    vn1[0] = temp;
    vn2[0] = temp;
    jpvt[1] = 2;
    work[1] = 0.0F;
    temp = xnrm2(A->size[0], A, A->size[0] + 1);
    vn1[1] = temp;
    vn2[1] = temp;
    for (b_i = 0; b_i < minmn; b_i++) {
      float atmp;
      float beta1;
      int ii;
      int ip1;
      int knt;
      int lastv;
      int mmi;
      int pvt;
      ip1 = b_i + 2;
      lastv = b_i * ma;
      ii = lastv + b_i;
      mmi = m - b_i;
      minmana = 0;
      if ((2 - b_i > 1) && (fabsf(vn1[1]) > fabsf(vn1[b_i]))) {
        minmana = 1;
      }
      pvt = b_i + minmana;
      if (pvt != b_i) {
        minmana = pvt * ma;
        for (k = 0; k < m; k++) {
          knt = minmana + k;
          temp = b_A_data[knt];
          i = lastv + k;
          b_A_data[knt] = b_A_data[i];
          b_A_data[i] = temp;
        }
        minmana = jpvt[pvt];
        jpvt[pvt] = jpvt[b_i];
        jpvt[b_i] = (signed char)minmana;
        vn1[pvt] = vn1[b_i];
        vn2[pvt] = vn2[b_i];
      }
      if (b_i + 1 < m) {
        atmp = b_A_data[ii];
        minmana = ii + 2;
        tau_data[b_i] = 0.0F;
        if (mmi > 0) {
          temp = xnrm2(mmi - 1, b_A, ii + 2);
          if (temp != 0.0F) {
            beta1 = rt_hypotf_snf(b_A_data[ii], temp);
            if (b_A_data[ii] >= 0.0F) {
              beta1 = -beta1;
            }
            if (fabsf(beta1) < 9.86076132E-32F) {
              knt = 0;
              i = ii + mmi;
              do {
                knt++;
                for (k = minmana; k <= i; k++) {
                  b_A_data[k - 1] *= 1.01412048E+31F;
                }
                beta1 *= 1.01412048E+31F;
                atmp *= 1.01412048E+31F;
              } while ((fabsf(beta1) < 9.86076132E-32F) && (knt < 20));
              beta1 = rt_hypotf_snf(atmp, xnrm2(mmi - 1, b_A, ii + 2));
              if (atmp >= 0.0F) {
                beta1 = -beta1;
              }
              tau_data[b_i] = (beta1 - atmp) / beta1;
              temp = 1.0F / (atmp - beta1);
              for (k = minmana; k <= i; k++) {
                b_A_data[k - 1] *= temp;
              }
              for (k = 0; k < knt; k++) {
                beta1 *= 9.86076132E-32F;
              }
              atmp = beta1;
            } else {
              tau_data[b_i] = (beta1 - b_A_data[ii]) / beta1;
              temp = 1.0F / (b_A_data[ii] - beta1);
              i = ii + mmi;
              for (k = minmana; k <= i; k++) {
                b_A_data[k - 1] *= temp;
              }
              atmp = beta1;
            }
          }
        }
        b_A_data[ii] = atmp;
      } else {
        tau_data[b_i] = 0.0F;
      }
      if (b_i + 1 < 2) {
        atmp = b_A_data[ii];
        b_A_data[ii] = 1.0F;
        pvt = (ii + ma) + 1;
        if (tau_data[0] != 0.0F) {
          lastv = mmi - 1;
          minmana = (ii + mmi) - 1;
          while ((lastv + 1 > 0) && (b_A_data[minmana] == 0.0F)) {
            lastv--;
            minmana--;
          }
          knt = 1;
          k = pvt;
          int exitg1;
          do {
            exitg1 = 0;
            if (k <= pvt + lastv) {
              if (b_A_data[k - 1] != 0.0F) {
                exitg1 = 1;
              } else {
                k++;
              }
            } else {
              knt = 0;
              exitg1 = 1;
            }
          } while (exitg1 == 0);
        } else {
          lastv = -1;
          knt = 0;
        }
        if (lastv + 1 > 0) {
          if (knt != 0) {
            work[0] = 0.0F;
            minmana = 0;
            for (iac = pvt; ma < 0 ? iac >= pvt : iac <= pvt; iac += ma) {
              temp = 0.0F;
              i = iac + lastv;
              for (k = iac; k <= i; k++) {
                temp += b_A_data[k - 1] * b_A_data[(ii + k) - iac];
              }
              work[minmana] += temp;
              minmana++;
            }
          }
          if (!(-tau_data[0] == 0.0F)) {
            for (iac = 0; iac < knt; iac++) {
              if (work[0] != 0.0F) {
                temp = work[0] * -tau_data[0];
                i = lastv + pvt;
                for (minmana = pvt; minmana <= i; minmana++) {
                  b_A_data[minmana - 1] +=
                      b_A_data[(ii + minmana) - pvt] * temp;
                }
              }
              pvt += ma;
            }
          }
        }
        b_A_data[ii] = atmp;
      }
      for (iac = ip1; iac < 3; iac++) {
        minmana = b_i + ma;
        if (vn1[1] != 0.0F) {
          temp = fabsf(b_A_data[minmana]) / vn1[1];
          temp = 1.0F - temp * temp;
          if (temp < 0.0F) {
            temp = 0.0F;
          }
          beta1 = vn1[1] / vn2[1];
          beta1 = temp * (beta1 * beta1);
          if (beta1 <= 0.000345266977F) {
            if (b_i + 1 < m) {
              temp = xnrm2(mmi - 1, b_A, minmana + 2);
              vn1[1] = temp;
              vn2[1] = temp;
            } else {
              vn1[1] = 0.0F;
              vn2[1] = 0.0F;
            }
          } else {
            vn1[1] *= sqrtf(temp);
          }
        }
      }
    }
  }
  *rankA = 0;
  if (b_A->size[0] < 2) {
    minmn = b_A->size[0];
    minmana = 2;
  } else {
    minmn = 2;
    minmana = b_A->size[0];
  }
  if (minmn > 0) {
    temp = fminf(0.000345266977F, 1.1920929E-6F * (float)minmana) *
           fabsf(b_A_data[0]);
    while ((*rankA < minmn) &&
           (!(fabsf(b_A_data[*rankA + b_A->size[0] * *rankA]) <= temp))) {
      (*rankA)++;
    }
  }
  emxInit_real32_T(&b_B, 1);
  i = b_B->size[0];
  b_B->size[0] = B->size[0];
  emxEnsureCapacity_real32_T(b_B, i);
  b_B_data = b_B->data;
  minmana = B->size[0];
  for (i = 0; i < minmana; i++) {
    b_B_data[i] = B_data[i];
  }
  Y[0] = 0.0F;
  Y[1] = 0.0F;
  m = b_A->size[0];
  minmana = b_A->size[0];
  if (minmana > 2) {
    minmana = 2;
  }
  for (iac = 0; iac < minmana; iac++) {
    if (tau_data[iac] != 0.0F) {
      temp = b_B_data[iac];
      i = iac + 2;
      for (b_i = i; b_i <= m; b_i++) {
        temp += b_A_data[(b_i + b_A->size[0] * iac) - 1] * b_B_data[b_i - 1];
      }
      temp *= tau_data[iac];
      if (temp != 0.0F) {
        b_B_data[iac] -= temp;
        for (b_i = i; b_i <= m; b_i++) {
          b_B_data[b_i - 1] -= b_A_data[(b_i + b_A->size[0] * iac) - 1] * temp;
        }
      }
    }
  }
  for (b_i = 0; b_i < *rankA; b_i++) {
    Y[jpvt[b_i] - 1] = b_B_data[b_i];
  }
  emxFree_real32_T(&b_B);
  for (iac = *rankA; iac >= 1; iac--) {
    minmana = jpvt[iac - 1] - 1;
    Y[minmana] /= b_A_data[(iac + b_A->size[0] * (iac - 1)) - 1];
    for (b_i = 0; b_i <= iac - 2; b_i++) {
      Y[jpvt[0] - 1] -= Y[minmana] * b_A_data[b_A->size[0] * (iac - 1)];
    }
  }
  emxFree_real32_T(&b_A);
}

/*
 * File trailer for qrsolve.c
 *
 * [EOF]
 */
