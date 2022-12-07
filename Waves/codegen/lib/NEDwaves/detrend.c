/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: detrend.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

/* Include Files */
#include "detrend.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "qrsolve.h"
#include "rt_nonfinite.h"
#include "xnrm2.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Declarations */
static void minus(emxArray_real32_T *in1, const emxArray_real32_T *in2);

static double rt_hypotd_snf(double u0, double u1);

/* Function Definitions */
/*
 * Arguments    : emxArray_real32_T *in1
 *                const emxArray_real32_T *in2
 * Return Type  : void
 */
static void minus(emxArray_real32_T *in1, const emxArray_real32_T *in2)
{
  emxArray_real32_T *b_in1;
  const float *in2_data;
  float *b_in1_data;
  float *in1_data;
  int i;
  int loop_ub;
  int stride_0_0;
  int stride_1_0;
  in2_data = in2->data;
  in1_data = in1->data;
  emxInit_real32_T(&b_in1, 1);
  i = b_in1->size[0];
  if (in2->size[0] == 1) {
    b_in1->size[0] = in1->size[0];
  } else {
    b_in1->size[0] = in2->size[0];
  }
  emxEnsureCapacity_real32_T(b_in1, i);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_1_0 = (in2->size[0] != 1);
  if (in2->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2->size[0];
  }
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = in1_data[i * stride_0_0] - in2_data[i * stride_1_0];
  }
  i = in1->size[0];
  in1->size[0] = b_in1->size[0];
  emxEnsureCapacity_real32_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in1->size[0];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real32_T(&b_in1);
}

/*
 * Arguments    : double u0
 *                double u1
 * Return Type  : double
 */
static double rt_hypotd_snf(double u0, double u1)
{
  double a;
  double y;
  a = fabs(u0);
  y = fabs(u1);
  if (a < y) {
    a /= y;
    y *= sqrt(a * a + 1.0);
  } else if (a > y) {
    y /= a;
    y = a * sqrt(y * y + 1.0);
  } else if (!rtIsNaN(y)) {
    y = a * 1.4142135623730951;
  }
  return y;
}

/*
 * Arguments    : emxArray_real32_T *x
 * Return Type  : void
 */
void b_detrend(emxArray_real32_T *x)
{
  emxArray_int32_T *s;
  emxArray_int32_T *y;
  emxArray_real32_T *W;
  emxArray_real32_T *r;
  emxArray_real_T *a;
  double *a_data;
  float *W_data;
  float *r1;
  float *x_data;
  int k;
  int n;
  int yk;
  int *s_data;
  int *y_data;
  x_data = x->data;
  emxInit_int32_T(&y, 2);
  if (x->size[0] - 1 < 0) {
    n = 0;
  } else {
    n = x->size[0];
  }
  k = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = n;
  emxEnsureCapacity_int32_T(y, k);
  y_data = y->data;
  if (n > 0) {
    y_data[0] = 0;
    yk = 0;
    for (k = 2; k <= n; k++) {
      yk++;
      y_data[k - 1] = yk;
    }
  }
  emxInit_int32_T(&s, 1);
  k = s->size[0];
  s->size[0] = y->size[1];
  emxEnsureCapacity_int32_T(s, k);
  s_data = s->data;
  yk = y->size[1];
  for (k = 0; k < yk; k++) {
    s_data[k] = y_data[k];
  }
  emxFree_int32_T(&y);
  emxInit_real_T(&a, 1);
  emxInit_real32_T(&W, 2);
  emxInit_real32_T(&r, 1);
  if (x->size[0] != 0) {
    if (x->size[0] == 1) {
      yk = x->size[0];
      for (k = 0; k < yk; k++) {
        x_data[k] *= 0.0F;
      }
    } else {
      float p[2];
      n = s->size[0] - 1;
      k = a->size[0];
      a->size[0] = s->size[0];
      emxEnsureCapacity_real_T(a, k);
      a_data = a->data;
      for (k = 0; k <= n; k++) {
        a_data[k] = (double)s_data[k] - (double)s_data[0];
      }
      yk = a->size[0];
      for (k = 0; k < yk; k++) {
        a_data[k] /= (double)s_data[s->size[0] - 1];
      }
      yk = a->size[0];
      for (k = 0; k < yk; k++) {
        double varargin_1;
        varargin_1 = a_data[k];
        a_data[k] = fmax(varargin_1, 0.0);
      }
      k = W->size[0] * W->size[1];
      W->size[0] = s->size[0];
      W->size[1] = 2;
      emxEnsureCapacity_real32_T(W, k);
      W_data = W->data;
      for (k = 0; k <= n; k++) {
        W_data[k] = (float)a_data[k];
        W_data[k + W->size[0]] = 1.0F;
      }
      qrsolve(W, x, p, &yk);
      yk = W->size[0];
      k = r->size[0];
      r->size[0] = W->size[0];
      emxEnsureCapacity_real32_T(r, k);
      r1 = r->data;
      for (k = 0; k < yk; k++) {
        r1[k] = W_data[k] * p[0] + W_data[W->size[0] + k] * p[1];
      }
      if (x->size[0] == r->size[0]) {
        yk = x->size[0];
        for (k = 0; k < yk; k++) {
          x_data[k] -= r1[k];
        }
      } else {
        minus(x, r);
      }
    }
  }
  emxFree_real32_T(&r);
  emxFree_real32_T(&W);
  emxFree_real_T(&a);
  emxFree_int32_T(&s);
}

/*
 * Arguments    : const emxArray_real_T *x
 *                emxArray_real_T *y
 * Return Type  : void
 */
void detrend(const emxArray_real_T *x, emxArray_real_T *y)
{
  emxArray_int32_T *b_y;
  emxArray_real_T *A;
  emxArray_real_T *W;
  emxArray_real_T *a;
  emxArray_real_T *s;
  double tau_data[2];
  double vn1[2];
  double vn2[2];
  double work[2];
  const double *x_data;
  double temp;
  double *W_data;
  double *a_data;
  double *s_data;
  int b_i;
  int i;
  int iac;
  int k;
  int m;
  int ma;
  int n;
  int yk;
  int *y_data;
  signed char jpvt[2];
  x_data = x->data;
  emxInit_int32_T(&b_y, 2);
  if (x->size[0] - 1 < 0) {
    n = 0;
  } else {
    n = x->size[0];
  }
  i = b_y->size[0] * b_y->size[1];
  b_y->size[0] = 1;
  b_y->size[1] = n;
  emxEnsureCapacity_int32_T(b_y, i);
  y_data = b_y->data;
  if (n > 0) {
    y_data[0] = 0;
    yk = 0;
    for (k = 2; k <= n; k++) {
      yk++;
      y_data[k - 1] = yk;
    }
  }
  emxInit_real_T(&s, 1);
  i = s->size[0];
  s->size[0] = b_y->size[1];
  emxEnsureCapacity_real_T(s, i);
  s_data = s->data;
  yk = b_y->size[1];
  for (i = 0; i < yk; i++) {
    s_data[i] = y_data[i];
  }
  emxFree_int32_T(&b_y);
  emxInit_real_T(&a, 1);
  n = s->size[0] - 1;
  i = a->size[0];
  a->size[0] = s->size[0];
  emxEnsureCapacity_real_T(a, i);
  a_data = a->data;
  for (b_i = 0; b_i <= n; b_i++) {
    a_data[b_i] = s_data[b_i] - s_data[0];
  }
  yk = a->size[0];
  for (i = 0; i < yk; i++) {
    a_data[i] /= s_data[s->size[0] - 1];
  }
  yk = a->size[0];
  for (i = 0; i < yk; i++) {
    temp = a_data[i];
    a_data[i] = fmax(temp, 0.0);
  }
  emxInit_real_T(&W, 2);
  i = W->size[0] * W->size[1];
  W->size[0] = s->size[0];
  W->size[1] = 2;
  emxEnsureCapacity_real_T(W, i);
  W_data = W->data;
  for (b_i = 0; b_i <= n; b_i++) {
    W_data[b_i] = a_data[b_i];
    W_data[b_i + W->size[0]] = 1.0;
  }
  emxFree_real_T(&a);
  emxInit_real_T(&A, 2);
  i = A->size[0] * A->size[1];
  A->size[0] = W->size[0];
  A->size[1] = 2;
  emxEnsureCapacity_real_T(A, i);
  a_data = A->data;
  yk = W->size[0] * 2;
  for (i = 0; i < yk; i++) {
    a_data[i] = W_data[i];
  }
  m = W->size[0] - 1;
  ma = W->size[0];
  tau_data[0] = 0.0;
  jpvt[0] = 1;
  work[0] = 0.0;
  temp = b_xnrm2(W->size[0], W, 1);
  vn1[0] = temp;
  vn2[0] = temp;
  tau_data[1] = 0.0;
  jpvt[1] = 2;
  work[1] = 0.0;
  temp = b_xnrm2(W->size[0], W, W->size[0] + 1);
  vn1[1] = temp;
  vn2[1] = temp;
  for (b_i = 0; b_i < 2; b_i++) {
    double atmp;
    double beta1;
    int ii;
    int ip1;
    int lastv;
    int mmi;
    int pvt;
    ip1 = b_i + 2;
    lastv = b_i * ma;
    ii = lastv + b_i;
    mmi = m - b_i;
    yk = 0;
    if ((2 - b_i > 1) && (fabs(vn1[b_i + 1]) > fabs(vn1[b_i]))) {
      yk = 1;
    }
    pvt = b_i + yk;
    if (pvt != b_i) {
      yk = pvt * ma;
      for (k = 0; k <= m; k++) {
        n = yk + k;
        temp = a_data[n];
        i = lastv + k;
        a_data[n] = a_data[i];
        a_data[i] = temp;
      }
      yk = jpvt[pvt];
      jpvt[pvt] = jpvt[b_i];
      jpvt[b_i] = (signed char)yk;
      vn1[pvt] = vn1[b_i];
      vn2[pvt] = vn2[b_i];
    }
    atmp = a_data[ii];
    yk = ii + 2;
    tau_data[b_i] = 0.0;
    temp = b_xnrm2(mmi, A, ii + 2);
    if (temp != 0.0) {
      beta1 = rt_hypotd_snf(a_data[ii], temp);
      if (a_data[ii] >= 0.0) {
        beta1 = -beta1;
      }
      if (fabs(beta1) < 1.0020841800044864E-292) {
        n = 0;
        i = ii + mmi;
        do {
          n++;
          for (k = yk; k <= i + 1; k++) {
            a_data[k - 1] *= 9.9792015476736E+291;
          }
          beta1 *= 9.9792015476736E+291;
          atmp *= 9.9792015476736E+291;
        } while ((fabs(beta1) < 1.0020841800044864E-292) && (n < 20));
        beta1 = rt_hypotd_snf(atmp, b_xnrm2(mmi, A, ii + 2));
        if (atmp >= 0.0) {
          beta1 = -beta1;
        }
        tau_data[b_i] = (beta1 - atmp) / beta1;
        temp = 1.0 / (atmp - beta1);
        for (k = yk; k <= i + 1; k++) {
          a_data[k - 1] *= temp;
        }
        for (k = 0; k < n; k++) {
          beta1 *= 1.0020841800044864E-292;
        }
        atmp = beta1;
      } else {
        tau_data[b_i] = (beta1 - a_data[ii]) / beta1;
        temp = 1.0 / (a_data[ii] - beta1);
        i = ii + mmi;
        for (k = yk; k <= i + 1; k++) {
          a_data[k - 1] *= temp;
        }
        atmp = beta1;
      }
    }
    a_data[ii] = atmp;
    if (b_i + 1 < 2) {
      atmp = a_data[ii];
      a_data[ii] = 1.0;
      pvt = (ii + ma) + 1;
      if (tau_data[0] != 0.0) {
        lastv = mmi;
        yk = ii + mmi;
        while ((lastv + 1 > 0) && (a_data[yk] == 0.0)) {
          lastv--;
          yk--;
        }
        n = 1;
        k = pvt;
        int exitg1;
        do {
          exitg1 = 0;
          if (k <= pvt + lastv) {
            if (a_data[k - 1] != 0.0) {
              exitg1 = 1;
            } else {
              k++;
            }
          } else {
            n = 0;
            exitg1 = 1;
          }
        } while (exitg1 == 0);
      } else {
        lastv = -1;
        n = 0;
      }
      if (lastv + 1 > 0) {
        if (n != 0) {
          work[0] = 0.0;
          yk = 0;
          for (iac = pvt; ma < 0 ? iac >= pvt : iac <= pvt; iac += ma) {
            temp = 0.0;
            i = iac + lastv;
            for (k = iac; k <= i; k++) {
              temp += a_data[k - 1] * a_data[(ii + k) - iac];
            }
            work[yk] += temp;
            yk++;
          }
        }
        if (!(-tau_data[0] == 0.0)) {
          for (k = 0; k < n; k++) {
            if (work[0] != 0.0) {
              temp = work[0] * -tau_data[0];
              i = lastv + pvt;
              for (yk = pvt; yk <= i; yk++) {
                a_data[yk - 1] += a_data[(ii + yk) - pvt] * temp;
              }
            }
            pvt += ma;
          }
        }
      }
      a_data[ii] = atmp;
    }
    for (k = ip1; k < 3; k++) {
      yk = b_i + ma;
      if (vn1[1] != 0.0) {
        temp = fabs(a_data[yk]) / vn1[1];
        temp = 1.0 - temp * temp;
        if (temp < 0.0) {
          temp = 0.0;
        }
        beta1 = vn1[1] / vn2[1];
        beta1 = temp * (beta1 * beta1);
        if (beta1 <= 1.4901161193847656E-8) {
          temp = b_xnrm2(mmi, A, yk + 2);
          vn1[1] = temp;
          vn2[1] = temp;
        } else {
          vn1[1] *= sqrt(temp);
        }
      }
    }
  }
  n = 0;
  temp =
      fmin(1.4901161193847656E-8, 2.2204460492503131E-15 * (double)A->size[0]) *
      fabs(a_data[0]);
  while ((n < 2) && (!(fabs(a_data[n + A->size[0] * n]) <= temp))) {
    n++;
  }
  i = s->size[0];
  s->size[0] = x->size[0];
  emxEnsureCapacity_real_T(s, i);
  s_data = s->data;
  yk = x->size[0];
  for (i = 0; i < yk; i++) {
    s_data[i] = x_data[i];
  }
  m = A->size[0];
  for (k = 0; k < 2; k++) {
    work[k] = 0.0;
    if (tau_data[k] != 0.0) {
      temp = s_data[k];
      i = k + 2;
      for (b_i = i; b_i <= m; b_i++) {
        temp += a_data[(b_i + A->size[0] * k) - 1] * s_data[b_i - 1];
      }
      temp *= tau_data[k];
      if (temp != 0.0) {
        s_data[k] -= temp;
        for (b_i = i; b_i <= m; b_i++) {
          s_data[b_i - 1] -= a_data[(b_i + A->size[0] * k) - 1] * temp;
        }
      }
    }
  }
  for (b_i = 0; b_i < n; b_i++) {
    work[jpvt[b_i] - 1] = s_data[b_i];
  }
  emxFree_real_T(&s);
  for (k = n; k >= 1; k--) {
    yk = jpvt[k - 1] - 1;
    work[yk] /= a_data[(k + A->size[0] * (k - 1)) - 1];
    for (b_i = 0; b_i <= k - 2; b_i++) {
      work[jpvt[0] - 1] -= work[yk] * a_data[A->size[0] * (k - 1)];
    }
  }
  emxFree_real_T(&A);
  m = W->size[0];
  i = y->size[0];
  y->size[0] = W->size[0];
  emxEnsureCapacity_real_T(y, i);
  a_data = y->data;
  for (b_i = 0; b_i < m; b_i++) {
    a_data[b_i] = W_data[b_i] * work[0] + W_data[W->size[0] + b_i] * work[1];
  }
  emxFree_real_T(&W);
  i = y->size[0];
  y->size[0] = x->size[0];
  emxEnsureCapacity_real_T(y, i);
  a_data = y->data;
  yk = x->size[0];
  for (i = 0; i < yk; i++) {
    a_data[i] = x_data[i] - a_data[i];
  }
}

/*
 * File trailer for detrend.c
 *
 * [EOF]
 */
