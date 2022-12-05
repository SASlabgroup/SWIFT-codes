/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 05-Dec-2022 10:00:34
 */

/* Include Files */
#include "NEDwaves.h"
#include "NEDwaves_data.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "blockedSummation.h"
#include "detrend.h"
#include "div.h"
#include "fft.h"
#include "mean.h"
#include "minOrMax.h"
#include "nullAssignment.h"
#include "rt_nonfinite.h"
#include "std.h"
#include "sum.h"
#include "var.h"
#include "rt_defines.h"
#include "rt_nonfinite.h"
#include <float.h>
#include <math.h>

/* Function Declarations */
static void b_times(emxArray_real_T *in1, const emxArray_real_T *in2);

static void e_binary_expand_op(emxArray_creal_T *in1,
                               const emxArray_creal_T *in2,
                               const emxArray_creal_T *in3);

static void f_binary_expand_op(emxArray_real_T *in1, double in2,
                               const emxArray_real_T *in3);

static void plus(emxArray_real_T *in1, const emxArray_real_T *in2,
                 const emxArray_real_T *in3);

static double rt_atan2d_snf(double u0, double u1);

static double rt_remd_snf(double u0, double u1);

static double rt_roundd_snf(double u);

static void times(emxArray_real_T *in1, const emxArray_real_T *in2,
                  const emxArray_real_T *in3);

/* Function Definitions */
/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_real_T *in2
 * Return Type  : void
 */
static void b_times(emxArray_real_T *in1, const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const double *in2_data;
  double *b_in1_data;
  double *in1_data;
  int aux_0_1;
  int aux_1_1;
  int b_loop_ub;
  int i;
  int i1;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emxInit_real_T(&b_in1, 2);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = in1->size[0];
  if (in2->size[1] == 1) {
    b_in1->size[1] = in1->size[1];
  } else {
    b_in1->size[1] = in2->size[1];
  }
  emxEnsureCapacity_real_T(b_in1, i);
  b_in1_data = b_in1->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in2->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  if (in2->size[1] == 1) {
    loop_ub = in1->size[1];
  } else {
    loop_ub = in2->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = in1->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      b_in1_data[i1 + b_in1->size[0] * i] =
          in1_data[i1 + in1->size[0] * aux_0_1] *
          in2_data[i1 + in2->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = b_in1->size[0];
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] = b_in1_data[i1 + b_in1->size[0] * i];
    }
  }
  emxFree_real_T(&b_in1);
}

/*
 * Arguments    : emxArray_creal_T *in1
 *                const emxArray_creal_T *in2
 *                const emxArray_creal_T *in3
 * Return Type  : void
 */
static void e_binary_expand_op(emxArray_creal_T *in1,
                               const emxArray_creal_T *in2,
                               const emxArray_creal_T *in3)
{
  const creal_T *in2_data;
  const creal_T *in3_data;
  creal_T *in1_data;
  int aux_0_1;
  int aux_1_1;
  int i;
  int i1;
  int loop_ub;
  int stride_0_0;
  int stride_0_1;
  int stride_1_0;
  int stride_1_1;
  in3_data = in3->data;
  in2_data = in2->data;
  i = in1->size[0] * in1->size[1];
  if (in3->size[0] == 1) {
    in1->size[0] = in2->size[0];
  } else {
    in1->size[0] = in3->size[0];
  }
  if (in3->size[1] == 1) {
    in1->size[1] = in2->size[1];
  } else {
    in1->size[1] = in3->size[1];
  }
  emxEnsureCapacity_creal_T(in1, i);
  in1_data = in1->data;
  stride_0_0 = (in2->size[0] != 1);
  stride_0_1 = (in2->size[1] != 1);
  stride_1_0 = (in3->size[0] != 1);
  stride_1_1 = (in3->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  if (in3->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    int b_loop_ub;
    if (in3->size[0] == 1) {
      b_loop_ub = in2->size[0];
    } else {
      b_loop_ub = in3->size[0];
    }
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      double in3_im;
      double in3_re;
      int in3_re_tmp;
      in3_re_tmp = i1 * stride_1_0;
      in3_re = in3_data[in3_re_tmp + in3->size[0] * aux_1_1].re;
      in3_im = -in3_data[in3_re_tmp + in3->size[0] * aux_1_1].im;
      in1_data[i1 + in1->size[0] * i].re =
          in2_data[i1 * stride_0_0 + in2->size[0] * aux_0_1].re * in3_re -
          in2_data[i1 * stride_0_0 + in2->size[0] * aux_0_1].im * in3_im;
      in1_data[i1 + in1->size[0] * i].im =
          in2_data[i1 * stride_0_0 + in2->size[0] * aux_0_1].re * in3_im +
          in2_data[i1 * stride_0_0 + in2->size[0] * aux_0_1].im * in3_re;
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
}

/*
 * Arguments    : emxArray_real_T *in1
 *                double in2
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
static void f_binary_expand_op(emxArray_real_T *in1, double in2,
                               const emxArray_real_T *in3)
{
  emxArray_real_T *r;
  emxArray_real_T *r2;
  const double *in3_data;
  double *in1_data;
  double *r1;
  double *r3;
  int aux_0_1;
  int aux_1_1;
  int b_loop_ub;
  int i;
  int i1;
  int loop_ub;
  int loop_ub_tmp;
  int stride_1_0;
  int stride_1_1;
  in3_data = in3->data;
  in1_data = in1->data;
  emxInit_real_T(&r, 2);
  loop_ub_tmp = (int)in2;
  i = r->size[0] * r->size[1];
  r->size[0] = (int)in2;
  r->size[1] = in3->size[1];
  emxEnsureCapacity_real_T(r, i);
  r1 = r->data;
  loop_ub = in3->size[1];
  for (i = 0; i < loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub_tmp; i1++) {
      r1[i1 + r->size[0] * i] = in3_data[i];
    }
  }
  emxInit_real_T(&r2, 2);
  i = r2->size[0] * r2->size[1];
  r2->size[0] = r->size[0];
  if (in1->size[1] == 1) {
    r2->size[1] = r->size[1];
  } else {
    r2->size[1] = in1->size[1];
  }
  emxEnsureCapacity_real_T(r2, i);
  r3 = r2->data;
  loop_ub_tmp = (r->size[1] != 1);
  stride_1_0 = (in1->size[0] != 1);
  stride_1_1 = (in1->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  if (in1->size[1] == 1) {
    loop_ub = r->size[1];
  } else {
    loop_ub = in1->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = r->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      r3[i1 + r2->size[0] * i] =
          r1[i1 + r->size[0] * aux_0_1] *
          in1_data[i1 * stride_1_0 + in1->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += loop_ub_tmp;
  }
  emxFree_real_T(&r);
  i = in1->size[0] * in1->size[1];
  in1->size[0] = r2->size[0];
  in1->size[1] = r2->size[1];
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = r2->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = r2->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] = r3[i1 + r2->size[0] * i];
    }
  }
  emxFree_real_T(&r2);
}

/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_real_T *in2
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
static void plus(emxArray_real_T *in1, const emxArray_real_T *in2,
                 const emxArray_real_T *in3)
{
  const double *in2_data;
  const double *in3_data;
  double *in1_data;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in3_data = in3->data;
  in2_data = in2->data;
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  if (in3->size[1] == 1) {
    in1->size[1] = in2->size[1];
  } else {
    in1->size[1] = in3->size[1];
  }
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  if (in3->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = in2_data[i * stride_0_1] + in3_data[i * stride_1_1];
  }
}

/*
 * Arguments    : double u0
 *                double u1
 * Return Type  : double
 */
static double rt_atan2d_snf(double u0, double u1)
{
  double y;
  if (rtIsNaN(u0) || rtIsNaN(u1)) {
    y = rtNaN;
  } else if (rtIsInf(u0) && rtIsInf(u1)) {
    int b_u0;
    int b_u1;
    if (u0 > 0.0) {
      b_u0 = 1;
    } else {
      b_u0 = -1;
    }
    if (u1 > 0.0) {
      b_u1 = 1;
    } else {
      b_u1 = -1;
    }
    y = atan2(b_u0, b_u1);
  } else if (u1 == 0.0) {
    if (u0 > 0.0) {
      y = RT_PI / 2.0;
    } else if (u0 < 0.0) {
      y = -(RT_PI / 2.0);
    } else {
      y = 0.0;
    }
  } else {
    y = atan2(u0, u1);
  }
  return y;
}

/*
 * Arguments    : double u0
 *                double u1
 * Return Type  : double
 */
static double rt_remd_snf(double u0, double u1)
{
  double y;
  if (rtIsNaN(u0) || rtIsNaN(u1) || rtIsInf(u0)) {
    y = rtNaN;
  } else if (rtIsInf(u1)) {
    y = u0;
  } else if ((u1 != 0.0) && (u1 != trunc(u1))) {
    double q;
    q = fabs(u0 / u1);
    if (!(fabs(q - floor(q + 0.5)) > DBL_EPSILON * q)) {
      y = 0.0 * u0;
    } else {
      y = fmod(u0, u1);
    }
  } else {
    y = fmod(u0, u1);
  }
  return y;
}

/*
 * Arguments    : double u
 * Return Type  : double
 */
static double rt_roundd_snf(double u)
{
  double y;
  if (fabs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = ceil(u - 0.5);
    }
  } else {
    y = u;
  }
  return y;
}

/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_real_T *in2
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
static void times(emxArray_real_T *in1, const emxArray_real_T *in2,
                  const emxArray_real_T *in3)
{
  const double *in2_data;
  const double *in3_data;
  double *in1_data;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in3_data = in3->data;
  in2_data = in2->data;
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  if (in3->size[1] == 1) {
    in1->size[1] = in2->size[1];
  } else {
    in1->size[1] = in3->size[1];
  }
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  if (in3->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = in2_data[i * stride_0_1] * in3_data[i * stride_1_1];
  }
}

/*
 * matlab function to process GPS velocity components north, east, down
 *    to estimate wave height, period, direction, and spectral moments
 *    assuming deep-water limit of surface gravity wave dispersion relation
 *
 *  input time series are velocity components north [m/s], east [m/s], down
 * [m/s] and sampling rate [Hz], which must be at least 1 Hz Input time series
 * data must have at least 512 points and all be the same size.
 *
 *  Outputs are significat wave height [m], dominant period [s], dominant
 * direction [deg T, using meteorological from which waves are propagating],
 * spectral energy density [m^2/Hz], frequency [Hz], and the normalized spectral
 * moments a1, b1, a2, b2, and the check factor (ratio of vertical to horizontal
 * motion)
 *
 *  Outputs will be '9999' for invalid results.
 *
 *  Usage is as follows:
 *
 *    [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] =
 * NEDwaves(north,east,down,fs);
 *
 *
 *  J. Thomson,  12/2022 (modified from GPSwaves)
 *
 *
 * Arguments    : emxArray_real32_T *north
 *                emxArray_real32_T *east
 *                emxArray_real32_T *down
 *                double fs
 *                double *Hs
 *                double *Tp
 *                double *Dp
 *                emxArray_real_T *E
 *                emxArray_real_T *f
 *                emxArray_real_T *a1
 *                emxArray_real_T *b1
 *                emxArray_real_T *a2
 *                emxArray_real_T *b2
 *                emxArray_real_T *check
 * Return Type  : void
 */
void NEDwaves(emxArray_real32_T *north, emxArray_real32_T *east,
              emxArray_real32_T *down, double fs, double *Hs, double *Tp,
              double *Dp, emxArray_real_T *E, emxArray_real_T *f,
              emxArray_real_T *a1, emxArray_real_T *b1, emxArray_real_T *a2,
              emxArray_real_T *b2, emxArray_real_T *check)
{
  emxArray_boolean_T *b_f;
  emxArray_boolean_T *bad;
  emxArray_boolean_T *r7;
  emxArray_creal_T *UV;
  emxArray_creal_T *UVwindow;
  emxArray_creal_T *UW;
  emxArray_creal_T *UWwindow;
  emxArray_creal_T *Uwindow;
  emxArray_creal_T *VW;
  emxArray_creal_T *VWwindow;
  emxArray_creal_T *Vwindow;
  emxArray_creal_T *Wwindow;
  emxArray_creal_T *b_UVwindow;
  emxArray_int32_T *Uwindow_tmp;
  emxArray_int32_T *r;
  emxArray_int32_T *r1;
  emxArray_int32_T *r3;
  emxArray_int32_T *r4;
  emxArray_int32_T *r5;
  emxArray_int32_T *r6;
  emxArray_int32_T *r8;
  emxArray_int32_T *r9;
  emxArray_real32_T *u;
  emxArray_real32_T *v;
  emxArray_real32_T *w;
  emxArray_real_T *UUwindow;
  emxArray_real_T *VV;
  emxArray_real_T *VVwindow;
  emxArray_real_T *WWwindow;
  emxArray_real_T *b_UUwindow;
  emxArray_real_T *b_uwindow;
  emxArray_real_T *b_y;
  emxArray_real_T *r10;
  emxArray_real_T *r11;
  emxArray_real_T *r12;
  emxArray_real_T *taper;
  emxArray_real_T *uvar;
  emxArray_real_T *uwindow;
  emxArray_real_T *vvar;
  emxArray_real_T *vwindow;
  emxArray_real_T *wvar;
  emxArray_real_T *wwindow;
  creal_T *UV_data;
  creal_T *UVwindow_data;
  creal_T *UWwindow_data;
  creal_T *Uwindow_data;
  creal_T *VWwindow_data;
  creal_T *Vwindow_data;
  creal_T *Wwindow_data;
  creal_T *b_UVwindow_data;
  double alpha;
  double *E_data;
  double *VV_data;
  double *a1_data;
  double *b1_data;
  double *check_data;
  double *f_data;
  double *uwindow_data;
  double *vwindow_data;
  double *wwindow_data;
  float y;
  float *down_data;
  float *east_data;
  float *north_data;
  float *u_data;
  float *v_data;
  float *w_data;
  int b_i;
  int i;
  int i1;
  int i2;
  int i4;
  int k;
  int loop_ub;
  int mi;
  int nx;
  int trueCount;
  int *Uwindow_tmp_data;
  int *r2;
  bool guard1 = false;
  bool *bad_data;
  bool *r13;
  emxInit_real32_T(&u, 1);
  /*  tunable parameters */
  /*  standard deviations for despiking         */
  /*  time constant [s] for high-pass filter (pass T < 2 pi * RC) */
  /*  fixed parameters (which will produce 42 frequency bands) */
  /*  windoz length in seconds, should make 2^N samples */
  /*  freq bands to merge, must be odd? */
  /*  frequency cutoff for telemetry Hz */
  /*  detrend */
  b_detrend(east);
  east_data = east->data;
  b_detrend(north);
  north_data = north->data;
  b_detrend(down);
  down_data = down->data;
  /*  Despike the time series */
  y = 4.0F * b_std(east);
  nx = east->size[0];
  i = u->size[0];
  u->size[0] = east->size[0];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  for (k = 0; k < nx; k++) {
    u_data[k] = fabsf(east_data[k]);
  }
  emxInit_boolean_T(&bad, 1);
  i = bad->size[0];
  bad->size[0] = u->size[0];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  loop_ub = u->size[0];
  for (i = 0; i < loop_ub; i++) {
    bad_data[i] = (u_data[i] >= y);
  }
  /*  logical array of indices for bad points */
  nx = bad->size[0] - 1;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (bad_data[b_i]) {
      trueCount++;
    }
  }
  emxInit_int32_T(&r, 1);
  i = r->size[0];
  r->size[0] = trueCount;
  emxEnsureCapacity_int32_T(r, i);
  Uwindow_tmp_data = r->data;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (bad_data[b_i]) {
      Uwindow_tmp_data[trueCount] = b_i + 1;
      trueCount++;
    }
  }
  nx = bad->size[0] - 1;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (!bad_data[b_i]) {
      trueCount++;
    }
  }
  emxInit_int32_T(&r1, 1);
  i = r1->size[0];
  r1->size[0] = trueCount;
  emxEnsureCapacity_int32_T(r1, i);
  r2 = r1->data;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (!bad_data[b_i]) {
      r2[trueCount] = b_i + 1;
      trueCount++;
    }
  }
  i = u->size[0];
  u->size[0] = r1->size[0];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  loop_ub = r1->size[0];
  for (i = 0; i < loop_ub; i++) {
    u_data[i] = east_data[r2[i] - 1];
  }
  y = blockedSummation(u, r1->size[0]) / (float)r1->size[0];
  loop_ub = r->size[0];
  emxFree_int32_T(&r1);
  for (i = 0; i < loop_ub; i++) {
    east_data[Uwindow_tmp_data[i] - 1] = y;
  }
  emxFree_int32_T(&r);
  y = 4.0F * b_std(north);
  nx = north->size[0];
  i = u->size[0];
  u->size[0] = north->size[0];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  for (k = 0; k < nx; k++) {
    u_data[k] = fabsf(north_data[k]);
  }
  i = bad->size[0];
  bad->size[0] = u->size[0];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  loop_ub = u->size[0];
  for (i = 0; i < loop_ub; i++) {
    bad_data[i] = (u_data[i] >= y);
  }
  /*  logical array of indices for bad points */
  nx = bad->size[0] - 1;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (bad_data[b_i]) {
      trueCount++;
    }
  }
  emxInit_int32_T(&r3, 1);
  i = r3->size[0];
  r3->size[0] = trueCount;
  emxEnsureCapacity_int32_T(r3, i);
  Uwindow_tmp_data = r3->data;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (bad_data[b_i]) {
      Uwindow_tmp_data[trueCount] = b_i + 1;
      trueCount++;
    }
  }
  nx = bad->size[0] - 1;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (!bad_data[b_i]) {
      trueCount++;
    }
  }
  emxInit_int32_T(&r4, 1);
  i = r4->size[0];
  r4->size[0] = trueCount;
  emxEnsureCapacity_int32_T(r4, i);
  r2 = r4->data;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (!bad_data[b_i]) {
      r2[trueCount] = b_i + 1;
      trueCount++;
    }
  }
  i = u->size[0];
  u->size[0] = r4->size[0];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  loop_ub = r4->size[0];
  for (i = 0; i < loop_ub; i++) {
    u_data[i] = north_data[r2[i] - 1];
  }
  y = blockedSummation(u, r4->size[0]) / (float)r4->size[0];
  loop_ub = r3->size[0];
  emxFree_int32_T(&r4);
  for (i = 0; i < loop_ub; i++) {
    north_data[Uwindow_tmp_data[i] - 1] = y;
  }
  emxFree_int32_T(&r3);
  y = 4.0F * b_std(down);
  nx = down->size[0];
  i = u->size[0];
  u->size[0] = down->size[0];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  for (k = 0; k < nx; k++) {
    u_data[k] = fabsf(down_data[k]);
  }
  i = bad->size[0];
  bad->size[0] = u->size[0];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  loop_ub = u->size[0];
  for (i = 0; i < loop_ub; i++) {
    bad_data[i] = (u_data[i] >= y);
  }
  /*  logical array of indices for bad points */
  nx = bad->size[0] - 1;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (bad_data[b_i]) {
      trueCount++;
    }
  }
  emxInit_int32_T(&r5, 1);
  i = r5->size[0];
  r5->size[0] = trueCount;
  emxEnsureCapacity_int32_T(r5, i);
  Uwindow_tmp_data = r5->data;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (bad_data[b_i]) {
      Uwindow_tmp_data[trueCount] = b_i + 1;
      trueCount++;
    }
  }
  nx = bad->size[0] - 1;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (!bad_data[b_i]) {
      trueCount++;
    }
  }
  emxInit_int32_T(&r6, 1);
  i = r6->size[0];
  r6->size[0] = trueCount;
  emxEnsureCapacity_int32_T(r6, i);
  r2 = r6->data;
  trueCount = 0;
  for (b_i = 0; b_i <= nx; b_i++) {
    if (!bad_data[b_i]) {
      r2[trueCount] = b_i + 1;
      trueCount++;
    }
  }
  i = u->size[0];
  u->size[0] = r6->size[0];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  loop_ub = r6->size[0];
  for (i = 0; i < loop_ub; i++) {
    u_data[i] = down_data[r2[i] - 1];
  }
  y = blockedSummation(u, r6->size[0]) / (float)r6->size[0];
  loop_ub = r5->size[0];
  emxFree_int32_T(&r6);
  for (i = 0; i < loop_ub; i++) {
    down_data[Uwindow_tmp_data[i] - 1] = y;
  }
  emxFree_int32_T(&r5);
  /*  begin processing, if data sufficient */
  /*  record length in data points */
  emxInit_real32_T(&v, 1);
  emxInit_real32_T(&w, 1);
  emxInit_real_T(&uwindow, 2);
  emxInit_real_T(&vwindow, 2);
  emxInit_real_T(&wwindow, 2);
  emxInit_real_T(&uvar, 2);
  emxInit_real_T(&vvar, 2);
  emxInit_real_T(&wvar, 2);
  emxInit_real_T(&taper, 2);
  emxInit_creal_T(&Uwindow, 2);
  emxInit_creal_T(&Vwindow, 2);
  emxInit_creal_T(&Wwindow, 2);
  emxInit_real_T(&UUwindow, 2);
  emxInit_real_T(&VVwindow, 2);
  emxInit_real_T(&WWwindow, 2);
  emxInit_creal_T(&UVwindow, 2);
  emxInit_creal_T(&UWwindow, 2);
  emxInit_creal_T(&VWwindow, 2);
  emxInit_real_T(&VV, 2);
  emxInit_creal_T(&UV, 2);
  emxInit_creal_T(&UW, 2);
  emxInit_creal_T(&VW, 2);
  emxInit_boolean_T(&r7, 2);
  emxInit_int32_T(&r8, 2);
  emxInit_int32_T(&r9, 2);
  emxInit_real_T(&r10, 1);
  emxInit_int32_T(&Uwindow_tmp, 2);
  emxInit_real_T(&b_y, 2);
  emxInit_real_T(&r11, 2);
  emxInit_real_T(&r12, 2);
  emxInit_real_T(&b_uwindow, 1);
  emxInit_real_T(&b_UUwindow, 2);
  emxInit_boolean_T(&b_f, 2);
  emxInit_creal_T(&b_UVwindow, 2);
  guard1 = false;
  if ((east->size[0] >= 512) && (fs >= 1.0)) {
    nx = bad->size[0];
    if (bad->size[0] == 0) {
      trueCount = 0;
    } else {
      trueCount = bad_data[0];
      for (k = 2; k <= nx; k++) {
        trueCount += bad_data[k - 1];
      }
    }
    if (trueCount < 100) {
      double bandwidth;
      double fe;
      double win;
      double y_tmp;
      int windows;
      /*  minimum length and quality for processing */
      /*  high-pass RC filter,  */
      /* initialize and rename the variables (match original GPSwaves usage) */
      i = u->size[0];
      u->size[0] = east->size[0];
      emxEnsureCapacity_real32_T(u, i);
      u_data = u->data;
      loop_ub = east->size[0];
      for (i = 0; i < loop_ub; i++) {
        u_data[i] = east_data[i];
      }
      i = v->size[0];
      v->size[0] = north->size[0];
      emxEnsureCapacity_real32_T(v, i);
      v_data = v->data;
      loop_ub = north->size[0];
      for (i = 0; i < loop_ub; i++) {
        v_data[i] = north_data[i];
      }
      i = w->size[0];
      w->size[0] = down->size[0];
      emxEnsureCapacity_real32_T(w, i);
      w_data = w->data;
      loop_ub = down->size[0];
      for (i = 0; i < loop_ub; i++) {
        w_data[i] = down_data[i];
      }
      alpha = 3.5 / (1.0 / fs + 3.5);
      i = down->size[0];
      for (trueCount = 0; trueCount <= i - 2; trueCount++) {
        u_data[trueCount + 1] =
            (float)alpha * u_data[trueCount] +
            (float)alpha * (east_data[trueCount + 1] - east_data[trueCount]);
        v_data[trueCount + 1] =
            (float)alpha * v_data[trueCount] +
            (float)alpha * (north_data[trueCount + 1] - north_data[trueCount]);
        w_data[trueCount + 1] =
            (float)alpha * w_data[trueCount] +
            (float)alpha * (down_data[trueCount + 1] - down_data[trueCount]);
      }
      /*  break into windows (use 75 percent overlap) */
      win = rt_roundd_snf(fs * 256.0);
      /*  window length in data points */
      if (rt_remd_snf(win, 2.0) != 0.0) {
        win--;
      }
      /*  make win an even number */
      windows = (int)floor(4.0 * ((double)east->size[0] / win - 1.0) + 1.0);
      /*  number of windows, the 4 comes from a 75% overlap */
      /*  degrees of freedom */
      /*  loop to create a matrix of time series, where COLUMN = WINDOw  */
      b_i = (int)win;
      i = uwindow->size[0] * uwindow->size[1];
      uwindow->size[0] = (int)win;
      uwindow->size[1] = windows;
      emxEnsureCapacity_real_T(uwindow, i);
      uwindow_data = uwindow->data;
      i = vwindow->size[0] * vwindow->size[1];
      vwindow->size[0] = (int)win;
      vwindow->size[1] = windows;
      emxEnsureCapacity_real_T(vwindow, i);
      vwindow_data = vwindow->data;
      i = wwindow->size[0] * wwindow->size[1];
      wwindow->size[0] = (int)win;
      wwindow->size[1] = windows;
      emxEnsureCapacity_real_T(wwindow, i);
      wwindow_data = wwindow->data;
      for (nx = 0; nx < windows; nx++) {
        alpha = (((double)nx + 1.0) - 1.0) * (0.25 * win);
        i = VV->size[0] * VV->size[1];
        VV->size[0] = 1;
        VV->size[1] = (int)(win - 1.0) + 1;
        emxEnsureCapacity_real_T(VV, i);
        VV_data = VV->data;
        loop_ub = (int)(win - 1.0);
        for (i = 0; i <= loop_ub; i++) {
          VV_data[i] = alpha + ((double)i + 1.0);
        }
        loop_ub = VV->size[1];
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i + uwindow->size[0] * nx] = u_data[(int)VV_data[i] - 1];
        }
        i = r10->size[0];
        r10->size[0] = (int)(win - 1.0) + 1;
        emxEnsureCapacity_real_T(r10, i);
        E_data = r10->data;
        loop_ub = (int)(win - 1.0);
        for (i = 0; i <= loop_ub; i++) {
          E_data[i] = alpha + ((double)i + 1.0);
        }
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i + vwindow->size[0] * nx] = v_data[(int)E_data[i] - 1];
        }
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          wwindow_data[i + wwindow->size[0] * nx] = w_data[(int)E_data[i] - 1];
        }
      }
      /*  detrend individual windows (full series already detrended) */
      for (nx = 0; nx < windows; nx++) {
        trueCount = uwindow->size[0] - 1;
        i = b_uwindow->size[0];
        b_uwindow->size[0] = uwindow->size[0];
        emxEnsureCapacity_real_T(b_uwindow, i);
        E_data = b_uwindow->data;
        for (i = 0; i <= trueCount; i++) {
          E_data[i] = uwindow_data[i + uwindow->size[0] * nx];
        }
        detrend(b_uwindow, r10);
        E_data = r10->data;
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i + uwindow->size[0] * nx] = E_data[i];
        }
        trueCount = vwindow->size[0] - 1;
        i = b_uwindow->size[0];
        b_uwindow->size[0] = vwindow->size[0];
        emxEnsureCapacity_real_T(b_uwindow, i);
        E_data = b_uwindow->data;
        for (i = 0; i <= trueCount; i++) {
          E_data[i] = vwindow_data[i + vwindow->size[0] * nx];
        }
        detrend(b_uwindow, r10);
        E_data = r10->data;
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i + vwindow->size[0] * nx] = E_data[i];
        }
        trueCount = wwindow->size[0] - 1;
        i = b_uwindow->size[0];
        b_uwindow->size[0] = wwindow->size[0];
        emxEnsureCapacity_real_T(b_uwindow, i);
        E_data = b_uwindow->data;
        for (i = 0; i <= trueCount; i++) {
          E_data[i] = wwindow_data[i + wwindow->size[0] * nx];
        }
        detrend(b_uwindow, r10);
        E_data = r10->data;
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          wwindow_data[i + wwindow->size[0] * nx] = E_data[i];
        }
      }
      /*  taper and rescale (to preserve variance) */
      /*  get original variance of each window */
      var(uwindow, uvar);
      check_data = uvar->data;
      var(vwindow, vvar);
      a1_data = vvar->data;
      var(wwindow, wvar);
      b1_data = wvar->data;
      /*  form taper matrix (columns of taper coef) */
      i = VV->size[0] * VV->size[1];
      VV->size[0] = 1;
      VV->size[1] = (int)(win - 1.0) + 1;
      emxEnsureCapacity_real_T(VV, i);
      VV_data = VV->data;
      loop_ub = (int)(win - 1.0);
      for (i = 0; i <= loop_ub; i++) {
        VV_data[i] = ((double)i + 1.0) * 3.1415926535897931 / win;
      }
      nx = VV->size[1];
      for (k = 0; k < nx; k++) {
        VV_data[k] = sin(VV_data[k]);
      }
      i = taper->size[0] * taper->size[1];
      taper->size[0] = VV->size[1];
      taper->size[1] = windows;
      emxEnsureCapacity_real_T(taper, i);
      E_data = taper->data;
      for (i = 0; i < windows; i++) {
        loop_ub = VV->size[1];
        for (i1 = 0; i1 < loop_ub; i1++) {
          E_data[i1 + taper->size[0] * i] = VV_data[i1];
        }
      }
      /*  taper each window */
      if (uwindow->size[1] == taper->size[1]) {
        loop_ub = uwindow->size[0] * uwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i] *= E_data[i];
        }
      } else {
        b_times(uwindow, taper);
      }
      if (vwindow->size[1] == taper->size[1]) {
        loop_ub = vwindow->size[0] * vwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i] *= E_data[i];
        }
      } else {
        b_times(vwindow, taper);
      }
      if (wwindow->size[1] == taper->size[1]) {
        loop_ub = wwindow->size[0] * wwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          wwindow_data[i] *= E_data[i];
        }
      } else {
        b_times(wwindow, taper);
      }
      /*  now find the correction factor (comparing old/new variance) */
      /*  and correct for the change in variance */
      /*  (mult each window by it's variance ratio factor) */
      var(uwindow, r11);
      E_data = r11->data;
      if (uvar->size[1] == r11->size[1]) {
        i = VV->size[0] * VV->size[1];
        VV->size[0] = 1;
        VV->size[1] = uvar->size[1];
        emxEnsureCapacity_real_T(VV, i);
        VV_data = VV->data;
        loop_ub = uvar->size[1];
        for (i = 0; i < loop_ub; i++) {
          VV_data[i] = check_data[i] / E_data[i];
        }
      } else {
        g_binary_expand_op(VV, uvar, r11);
        VV_data = VV->data;
      }
      nx = VV->size[1];
      for (k = 0; k < nx; k++) {
        VV_data[k] = sqrt(VV_data[k]);
      }
      i = taper->size[0] * taper->size[1];
      taper->size[0] = (int)win;
      taper->size[1] = VV->size[1];
      emxEnsureCapacity_real_T(taper, i);
      E_data = taper->data;
      loop_ub = VV->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < b_i; i1++) {
          E_data[i1 + taper->size[0] * i] = VV_data[i];
        }
      }
      i = r12->size[0] * r12->size[1];
      r12->size[0] = (int)win;
      r12->size[1] = VV->size[1];
      emxEnsureCapacity_real_T(r12, i);
      E_data = r12->data;
      loop_ub = VV->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < b_i; i1++) {
          E_data[i1 + r12->size[0] * i] = VV_data[i];
        }
      }
      if ((taper->size[0] == uwindow->size[0]) &&
          (r12->size[1] == uwindow->size[1])) {
        i = taper->size[0] * taper->size[1];
        taper->size[0] = (int)win;
        taper->size[1] = VV->size[1];
        emxEnsureCapacity_real_T(taper, i);
        E_data = taper->data;
        loop_ub = VV->size[1];
        for (i = 0; i < loop_ub; i++) {
          for (i1 = 0; i1 < b_i; i1++) {
            E_data[i1 + taper->size[0] * i] = VV_data[i];
          }
        }
        loop_ub = taper->size[0] * taper->size[1];
        i = uwindow->size[0] * uwindow->size[1];
        uwindow->size[0] = taper->size[0];
        uwindow->size[1] = taper->size[1];
        emxEnsureCapacity_real_T(uwindow, i);
        uwindow_data = uwindow->data;
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i] *= E_data[i];
        }
      } else {
        f_binary_expand_op(uwindow, win, VV);
      }
      var(vwindow, r11);
      E_data = r11->data;
      if (vvar->size[1] == r11->size[1]) {
        i = VV->size[0] * VV->size[1];
        VV->size[0] = 1;
        VV->size[1] = vvar->size[1];
        emxEnsureCapacity_real_T(VV, i);
        VV_data = VV->data;
        loop_ub = vvar->size[1];
        for (i = 0; i < loop_ub; i++) {
          VV_data[i] = a1_data[i] / E_data[i];
        }
      } else {
        g_binary_expand_op(VV, vvar, r11);
        VV_data = VV->data;
      }
      nx = VV->size[1];
      for (k = 0; k < nx; k++) {
        VV_data[k] = sqrt(VV_data[k]);
      }
      i = taper->size[0] * taper->size[1];
      taper->size[0] = (int)win;
      taper->size[1] = VV->size[1];
      emxEnsureCapacity_real_T(taper, i);
      E_data = taper->data;
      loop_ub = VV->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < b_i; i1++) {
          E_data[i1 + taper->size[0] * i] = VV_data[i];
        }
      }
      i = r12->size[0] * r12->size[1];
      r12->size[0] = (int)win;
      r12->size[1] = VV->size[1];
      emxEnsureCapacity_real_T(r12, i);
      E_data = r12->data;
      loop_ub = VV->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < b_i; i1++) {
          E_data[i1 + r12->size[0] * i] = VV_data[i];
        }
      }
      if ((taper->size[0] == vwindow->size[0]) &&
          (r12->size[1] == vwindow->size[1])) {
        i = taper->size[0] * taper->size[1];
        taper->size[0] = (int)win;
        taper->size[1] = VV->size[1];
        emxEnsureCapacity_real_T(taper, i);
        E_data = taper->data;
        loop_ub = VV->size[1];
        for (i = 0; i < loop_ub; i++) {
          for (i1 = 0; i1 < b_i; i1++) {
            E_data[i1 + taper->size[0] * i] = VV_data[i];
          }
        }
        loop_ub = taper->size[0] * taper->size[1];
        i = vwindow->size[0] * vwindow->size[1];
        vwindow->size[0] = taper->size[0];
        vwindow->size[1] = taper->size[1];
        emxEnsureCapacity_real_T(vwindow, i);
        vwindow_data = vwindow->data;
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i] *= E_data[i];
        }
      } else {
        f_binary_expand_op(vwindow, win, VV);
      }
      var(wwindow, r11);
      E_data = r11->data;
      if (wvar->size[1] == r11->size[1]) {
        i = VV->size[0] * VV->size[1];
        VV->size[0] = 1;
        VV->size[1] = wvar->size[1];
        emxEnsureCapacity_real_T(VV, i);
        VV_data = VV->data;
        loop_ub = wvar->size[1];
        for (i = 0; i < loop_ub; i++) {
          VV_data[i] = b1_data[i] / E_data[i];
        }
      } else {
        g_binary_expand_op(VV, wvar, r11);
        VV_data = VV->data;
      }
      nx = VV->size[1];
      for (k = 0; k < nx; k++) {
        VV_data[k] = sqrt(VV_data[k]);
      }
      i = taper->size[0] * taper->size[1];
      taper->size[0] = (int)win;
      taper->size[1] = VV->size[1];
      emxEnsureCapacity_real_T(taper, i);
      E_data = taper->data;
      loop_ub = VV->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < b_i; i1++) {
          E_data[i1 + taper->size[0] * i] = VV_data[i];
        }
      }
      i = r12->size[0] * r12->size[1];
      r12->size[0] = (int)win;
      r12->size[1] = VV->size[1];
      emxEnsureCapacity_real_T(r12, i);
      E_data = r12->data;
      loop_ub = VV->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < b_i; i1++) {
          E_data[i1 + r12->size[0] * i] = VV_data[i];
        }
      }
      if ((taper->size[0] == wwindow->size[0]) &&
          (r12->size[1] == wwindow->size[1])) {
        i = taper->size[0] * taper->size[1];
        taper->size[0] = (int)win;
        taper->size[1] = VV->size[1];
        emxEnsureCapacity_real_T(taper, i);
        E_data = taper->data;
        loop_ub = VV->size[1];
        for (i = 0; i < loop_ub; i++) {
          for (i1 = 0; i1 < b_i; i1++) {
            E_data[i1 + taper->size[0] * i] = VV_data[i];
          }
        }
        loop_ub = taper->size[0] * taper->size[1];
        i = wwindow->size[0] * wwindow->size[1];
        wwindow->size[0] = taper->size[0];
        wwindow->size[1] = taper->size[1];
        emxEnsureCapacity_real_T(wwindow, i);
        wwindow_data = wwindow->data;
        for (i = 0; i < loop_ub; i++) {
          wwindow_data[i] *= E_data[i];
        }
      } else {
        f_binary_expand_op(wwindow, win, VV);
      }
      /*  FFT */
      /*  note convention for lower case as time-domain and upper case as freq
       * domain */
      /*  calculate Fourier coefs */
      fft(uwindow, Uwindow);
      fft(vwindow, Vwindow);
      fft(wwindow, Wwindow);
      /*  second half of fft is redundant, so throw it out */
      fe = win / 2.0 + 1.0;
      i = Uwindow_tmp->size[0] * Uwindow_tmp->size[1];
      Uwindow_tmp->size[0] = 1;
      loop_ub = (int)(win - fe);
      Uwindow_tmp->size[1] = loop_ub + 1;
      emxEnsureCapacity_int32_T(Uwindow_tmp, i);
      Uwindow_tmp_data = Uwindow_tmp->data;
      for (i = 0; i <= loop_ub; i++) {
        Uwindow_tmp_data[i] = (int)(fe + (double)i);
      }
      nullAssignment(Uwindow, Uwindow_tmp);
      nullAssignment(Vwindow, Uwindow_tmp);
      nullAssignment(Wwindow, Uwindow_tmp);
      /*  throw out the mean (first coef) and add a zero (to make it the right
       * length)   */
      b_nullAssignment(Uwindow);
      Uwindow_data = Uwindow->data;
      b_nullAssignment(Vwindow);
      Vwindow_data = Vwindow->data;
      b_nullAssignment(Wwindow);
      Wwindow_data = Wwindow->data;
      nx = (int)(win / 2.0);
      loop_ub = Uwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        Uwindow_data[(nx + Uwindow->size[0] * i) - 1].re = 0.0;
        Uwindow_data[(nx + Uwindow->size[0] * i) - 1].im = 0.0;
      }
      loop_ub = Vwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        Vwindow_data[(nx + Vwindow->size[0] * i) - 1].re = 0.0;
        Vwindow_data[(nx + Vwindow->size[0] * i) - 1].im = 0.0;
      }
      loop_ub = Wwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        Wwindow_data[(nx + Wwindow->size[0] * i) - 1].re = 0.0;
        Wwindow_data[(nx + Wwindow->size[0] * i) - 1].im = 0.0;
      }
      /*  POWER SPECTRA (auto-spectra) */
      i = UUwindow->size[0] * UUwindow->size[1];
      UUwindow->size[0] = Uwindow->size[0];
      UUwindow->size[1] = Uwindow->size[1];
      emxEnsureCapacity_real_T(UUwindow, i);
      E_data = UUwindow->data;
      loop_ub = Uwindow->size[0] * Uwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        E_data[i] = Uwindow_data[i].re * Uwindow_data[i].re -
                    Uwindow_data[i].im * -Uwindow_data[i].im;
      }
      i = VVwindow->size[0] * VVwindow->size[1];
      VVwindow->size[0] = Vwindow->size[0];
      VVwindow->size[1] = Vwindow->size[1];
      emxEnsureCapacity_real_T(VVwindow, i);
      check_data = VVwindow->data;
      loop_ub = Vwindow->size[0] * Vwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        check_data[i] = Vwindow_data[i].re * Vwindow_data[i].re -
                        Vwindow_data[i].im * -Vwindow_data[i].im;
      }
      i = WWwindow->size[0] * WWwindow->size[1];
      WWwindow->size[0] = Wwindow->size[0];
      WWwindow->size[1] = Wwindow->size[1];
      emxEnsureCapacity_real_T(WWwindow, i);
      a1_data = WWwindow->data;
      loop_ub = Wwindow->size[0] * Wwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        a1_data[i] = Wwindow_data[i].re * Wwindow_data[i].re -
                     Wwindow_data[i].im * -Wwindow_data[i].im;
      }
      /*  CROSS-SPECTRA  */
      if ((Uwindow->size[0] == Vwindow->size[0]) &&
          (Uwindow->size[1] == Vwindow->size[1])) {
        i = UVwindow->size[0] * UVwindow->size[1];
        UVwindow->size[0] = Uwindow->size[0];
        UVwindow->size[1] = Uwindow->size[1];
        emxEnsureCapacity_creal_T(UVwindow, i);
        UVwindow_data = UVwindow->data;
        loop_ub = Uwindow->size[0] * Uwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          alpha = Vwindow_data[i].re;
          fe = -Vwindow_data[i].im;
          UVwindow_data[i].re =
              Uwindow_data[i].re * alpha - Uwindow_data[i].im * fe;
          UVwindow_data[i].im =
              Uwindow_data[i].re * fe + Uwindow_data[i].im * alpha;
        }
      } else {
        e_binary_expand_op(UVwindow, Uwindow, Vwindow);
        UVwindow_data = UVwindow->data;
      }
      if ((Uwindow->size[0] == Wwindow->size[0]) &&
          (Uwindow->size[1] == Wwindow->size[1])) {
        i = UWwindow->size[0] * UWwindow->size[1];
        UWwindow->size[0] = Uwindow->size[0];
        UWwindow->size[1] = Uwindow->size[1];
        emxEnsureCapacity_creal_T(UWwindow, i);
        UWwindow_data = UWwindow->data;
        loop_ub = Uwindow->size[0] * Uwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          alpha = Wwindow_data[i].re;
          fe = -Wwindow_data[i].im;
          UWwindow_data[i].re =
              Uwindow_data[i].re * alpha - Uwindow_data[i].im * fe;
          UWwindow_data[i].im =
              Uwindow_data[i].re * fe + Uwindow_data[i].im * alpha;
        }
      } else {
        e_binary_expand_op(UWwindow, Uwindow, Wwindow);
        UWwindow_data = UWwindow->data;
      }
      if ((Vwindow->size[0] == Wwindow->size[0]) &&
          (Vwindow->size[1] == Wwindow->size[1])) {
        i = VWwindow->size[0] * VWwindow->size[1];
        VWwindow->size[0] = Vwindow->size[0];
        VWwindow->size[1] = Vwindow->size[1];
        emxEnsureCapacity_creal_T(VWwindow, i);
        VWwindow_data = VWwindow->data;
        loop_ub = Vwindow->size[0] * Vwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          alpha = Wwindow_data[i].re;
          fe = -Wwindow_data[i].im;
          VWwindow_data[i].re =
              Vwindow_data[i].re * alpha - Vwindow_data[i].im * fe;
          VWwindow_data[i].im =
              Vwindow_data[i].re * fe + Vwindow_data[i].im * alpha;
        }
      } else {
        e_binary_expand_op(VWwindow, Vwindow, Wwindow);
        VWwindow_data = VWwindow->data;
      }
      /*  merge neighboring freq bands (number of bands to merge is a fixed
       * parameter) */
      /*  initialize */
      alpha = floor(win / 6.0);
      i = uwindow->size[0] * uwindow->size[1];
      uwindow->size[0] = (int)alpha;
      uwindow->size[1] = windows;
      emxEnsureCapacity_real_T(uwindow, i);
      uwindow_data = uwindow->data;
      b_i = (int)alpha * windows;
      for (i = 0; i < b_i; i++) {
        uwindow_data[i] = 0.0;
      }
      i = vwindow->size[0] * vwindow->size[1];
      vwindow->size[0] = (int)alpha;
      vwindow->size[1] = windows;
      emxEnsureCapacity_real_T(vwindow, i);
      vwindow_data = vwindow->data;
      for (i = 0; i < b_i; i++) {
        vwindow_data[i] = 0.0;
      }
      i = wwindow->size[0] * wwindow->size[1];
      wwindow->size[0] = (int)alpha;
      wwindow->size[1] = windows;
      emxEnsureCapacity_real_T(wwindow, i);
      wwindow_data = wwindow->data;
      for (i = 0; i < b_i; i++) {
        wwindow_data[i] = 0.0;
      }
      i = Uwindow->size[0] * Uwindow->size[1];
      Uwindow->size[0] = (int)alpha;
      Uwindow->size[1] = windows;
      emxEnsureCapacity_creal_T(Uwindow, i);
      Uwindow_data = Uwindow->data;
      for (i = 0; i < b_i; i++) {
        Uwindow_data[i].re = 0.0;
        Uwindow_data[i].im = 1.0;
      }
      i = Vwindow->size[0] * Vwindow->size[1];
      Vwindow->size[0] = (int)alpha;
      Vwindow->size[1] = windows;
      emxEnsureCapacity_creal_T(Vwindow, i);
      Vwindow_data = Vwindow->data;
      for (i = 0; i < b_i; i++) {
        Vwindow_data[i].re = 0.0;
        Vwindow_data[i].im = 1.0;
      }
      i = Wwindow->size[0] * Wwindow->size[1];
      Wwindow->size[0] = (int)alpha;
      Wwindow->size[1] = windows;
      emxEnsureCapacity_creal_T(Wwindow, i);
      Wwindow_data = Wwindow->data;
      for (i = 0; i < b_i; i++) {
        Wwindow_data[i].re = 0.0;
        Wwindow_data[i].im = 1.0;
      }
      fe = win / 2.0 / 3.0;
      i = (int)fe;
      loop_ub = UUwindow->size[1];
      trueCount = VVwindow->size[1];
      nx = WWwindow->size[1];
      b_i = UVwindow->size[1];
      windows = UWwindow->size[1];
      k = VWwindow->size[1];
      for (mi = 0; mi < i; mi++) {
        int b_loop_ub;
        int i3;
        alpha = (double)mi * 3.0 + 3.0;
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = (int)((alpha - 3.0) + 1.0) - 1;
          i2 = (int)alpha;
        }
        i3 = (int)(alpha / 3.0) - 1;
        b_loop_ub = i2 - i1;
        i2 = b_UUwindow->size[0] * b_UUwindow->size[1];
        b_UUwindow->size[0] = b_loop_ub;
        b_UUwindow->size[1] = loop_ub;
        emxEnsureCapacity_real_T(b_UUwindow, i2);
        b1_data = b_UUwindow->data;
        for (i2 = 0; i2 < loop_ub; i2++) {
          for (i4 = 0; i4 < b_loop_ub; i4++) {
            b1_data[i4 + b_UUwindow->size[0] * i2] =
                E_data[(i1 + i4) + UUwindow->size[0] * i2];
          }
        }
        mean(b_UUwindow, VV);
        VV_data = VV->data;
        b_loop_ub = VV->size[1];
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          uwindow_data[i3 + uwindow->size[0] * i1] = VV_data[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = (int)((alpha - 3.0) + 1.0) - 1;
          i2 = (int)alpha;
        }
        b_loop_ub = i2 - i1;
        i2 = b_UUwindow->size[0] * b_UUwindow->size[1];
        b_UUwindow->size[0] = b_loop_ub;
        b_UUwindow->size[1] = trueCount;
        emxEnsureCapacity_real_T(b_UUwindow, i2);
        b1_data = b_UUwindow->data;
        for (i2 = 0; i2 < trueCount; i2++) {
          for (i4 = 0; i4 < b_loop_ub; i4++) {
            b1_data[i4 + b_UUwindow->size[0] * i2] =
                check_data[(i1 + i4) + VVwindow->size[0] * i2];
          }
        }
        mean(b_UUwindow, VV);
        VV_data = VV->data;
        b_loop_ub = VV->size[1];
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          vwindow_data[i3 + vwindow->size[0] * i1] = VV_data[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = (int)((alpha - 3.0) + 1.0) - 1;
          i2 = (int)alpha;
        }
        b_loop_ub = i2 - i1;
        i2 = b_UUwindow->size[0] * b_UUwindow->size[1];
        b_UUwindow->size[0] = b_loop_ub;
        b_UUwindow->size[1] = nx;
        emxEnsureCapacity_real_T(b_UUwindow, i2);
        b1_data = b_UUwindow->data;
        for (i2 = 0; i2 < nx; i2++) {
          for (i4 = 0; i4 < b_loop_ub; i4++) {
            b1_data[i4 + b_UUwindow->size[0] * i2] =
                a1_data[(i1 + i4) + WWwindow->size[0] * i2];
          }
        }
        mean(b_UUwindow, VV);
        VV_data = VV->data;
        b_loop_ub = VV->size[1];
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          wwindow_data[i3 + wwindow->size[0] * i1] = VV_data[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = (int)((alpha - 3.0) + 1.0) - 1;
          i2 = (int)alpha;
        }
        b_loop_ub = i2 - i1;
        i2 = b_UVwindow->size[0] * b_UVwindow->size[1];
        b_UVwindow->size[0] = b_loop_ub;
        b_UVwindow->size[1] = b_i;
        emxEnsureCapacity_creal_T(b_UVwindow, i2);
        b_UVwindow_data = b_UVwindow->data;
        for (i2 = 0; i2 < b_i; i2++) {
          for (i4 = 0; i4 < b_loop_ub; i4++) {
            b_UVwindow_data[i4 + b_UVwindow->size[0] * i2] =
                UVwindow_data[(i1 + i4) + UVwindow->size[0] * i2];
          }
        }
        b_mean(b_UVwindow, UV);
        UV_data = UV->data;
        b_loop_ub = UV->size[1];
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          Uwindow_data[i3 + Uwindow->size[0] * i1] = UV_data[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = (int)((alpha - 3.0) + 1.0) - 1;
          i2 = (int)alpha;
        }
        b_loop_ub = i2 - i1;
        i2 = b_UVwindow->size[0] * b_UVwindow->size[1];
        b_UVwindow->size[0] = b_loop_ub;
        b_UVwindow->size[1] = windows;
        emxEnsureCapacity_creal_T(b_UVwindow, i2);
        b_UVwindow_data = b_UVwindow->data;
        for (i2 = 0; i2 < windows; i2++) {
          for (i4 = 0; i4 < b_loop_ub; i4++) {
            b_UVwindow_data[i4 + b_UVwindow->size[0] * i2] =
                UWwindow_data[(i1 + i4) + UWwindow->size[0] * i2];
          }
        }
        b_mean(b_UVwindow, UV);
        UV_data = UV->data;
        b_loop_ub = UV->size[1];
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          Vwindow_data[i3 + Vwindow->size[0] * i1] = UV_data[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = (int)((alpha - 3.0) + 1.0) - 1;
          i2 = (int)alpha;
        }
        b_loop_ub = i2 - i1;
        i2 = b_UVwindow->size[0] * b_UVwindow->size[1];
        b_UVwindow->size[0] = b_loop_ub;
        b_UVwindow->size[1] = k;
        emxEnsureCapacity_creal_T(b_UVwindow, i2);
        b_UVwindow_data = b_UVwindow->data;
        for (i2 = 0; i2 < k; i2++) {
          for (i4 = 0; i4 < b_loop_ub; i4++) {
            b_UVwindow_data[i4 + b_UVwindow->size[0] * i2] =
                VWwindow_data[(i1 + i4) + VWwindow->size[0] * i2];
          }
        }
        b_mean(b_UVwindow, UV);
        UV_data = UV->data;
        b_loop_ub = UV->size[1];
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          Wwindow_data[i3 + Wwindow->size[0] * i1] = UV_data[i1];
        }
      }
      /*  freq range and bandwidth */
      /*  number of f bands */
      /*  highest spectral frequency  */
      bandwidth = 0.5 * fs / fe;
      /*  freq (Hz) bandwitdh */
      /*  find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF
       * BANDS! */
      alpha = bandwidth / 2.0 + 0.00390625;
      i = f->size[0] * f->size[1];
      f->size[0] = 1;
      f->size[1] = (int)(fe - 1.0) + 1;
      emxEnsureCapacity_real_T(f, i);
      f_data = f->data;
      loop_ub = (int)(fe - 1.0);
      for (i = 0; i <= loop_ub; i++) {
        f_data[i] = alpha + bandwidth * (double)i;
      }
      /*  ensemble average windows together */
      /*  take the average of all windows at each freq-band */
      /*  and divide by N*samplerate to get power spectral density */
      /*  the two is b/c Matlab's fft output is the symmetric FFT,  */
      /*  and we did not use the redundant half (so need to multiply the psd by
       * 2) */
      y_tmp = win / 2.0 * fs;
      /*  prune high frequency results  */
      i = b_UUwindow->size[0] * b_UUwindow->size[1];
      b_UUwindow->size[0] = uwindow->size[1];
      b_UUwindow->size[1] = uwindow->size[0];
      emxEnsureCapacity_real_T(b_UUwindow, i);
      b1_data = b_UUwindow->data;
      loop_ub = uwindow->size[0];
      for (i = 0; i < loop_ub; i++) {
        trueCount = uwindow->size[1];
        for (i1 = 0; i1 < trueCount; i1++) {
          b1_data[i1 + b_UUwindow->size[0] * i] =
              uwindow_data[i + uwindow->size[0] * i1];
        }
      }
      mean(b_UUwindow, a2);
      i = a2->size[0] * a2->size[1];
      a2->size[0] = 1;
      emxEnsureCapacity_real_T(a2, i);
      E_data = a2->data;
      loop_ub = a2->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        E_data[i] /= y_tmp;
      }
      i = b_f->size[0] * b_f->size[1];
      b_f->size[0] = 1;
      b_f->size[1] = f->size[1];
      emxEnsureCapacity_boolean_T(b_f, i);
      bad_data = b_f->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        bad_data[i] = (f_data[i] > 0.5);
      }
      c_nullAssignment(a2, b_f);
      E_data = a2->data;
      i = b_UUwindow->size[0] * b_UUwindow->size[1];
      b_UUwindow->size[0] = vwindow->size[1];
      b_UUwindow->size[1] = vwindow->size[0];
      emxEnsureCapacity_real_T(b_UUwindow, i);
      b1_data = b_UUwindow->data;
      loop_ub = vwindow->size[0];
      for (i = 0; i < loop_ub; i++) {
        trueCount = vwindow->size[1];
        for (i1 = 0; i1 < trueCount; i1++) {
          b1_data[i1 + b_UUwindow->size[0] * i] =
              vwindow_data[i + vwindow->size[0] * i1];
        }
      }
      mean(b_UUwindow, VV);
      i = VV->size[0] * VV->size[1];
      VV->size[0] = 1;
      emxEnsureCapacity_real_T(VV, i);
      VV_data = VV->data;
      loop_ub = VV->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        VV_data[i] /= y_tmp;
      }
      i = b_f->size[0] * b_f->size[1];
      b_f->size[0] = 1;
      b_f->size[1] = f->size[1];
      emxEnsureCapacity_boolean_T(b_f, i);
      bad_data = b_f->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        bad_data[i] = (f_data[i] > 0.5);
      }
      c_nullAssignment(VV, b_f);
      VV_data = VV->data;
      i = b_UUwindow->size[0] * b_UUwindow->size[1];
      b_UUwindow->size[0] = wwindow->size[1];
      b_UUwindow->size[1] = wwindow->size[0];
      emxEnsureCapacity_real_T(b_UUwindow, i);
      b1_data = b_UUwindow->data;
      loop_ub = wwindow->size[0];
      for (i = 0; i < loop_ub; i++) {
        trueCount = wwindow->size[1];
        for (i1 = 0; i1 < trueCount; i1++) {
          b1_data[i1 + b_UUwindow->size[0] * i] =
              wwindow_data[i + wwindow->size[0] * i1];
        }
      }
      mean(b_UUwindow, check);
      i = check->size[0] * check->size[1];
      check->size[0] = 1;
      emxEnsureCapacity_real_T(check, i);
      check_data = check->data;
      loop_ub = check->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        check_data[i] /= y_tmp;
      }
      i = b_f->size[0] * b_f->size[1];
      b_f->size[0] = 1;
      b_f->size[1] = f->size[1];
      emxEnsureCapacity_boolean_T(b_f, i);
      bad_data = b_f->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        bad_data[i] = (f_data[i] > 0.5);
      }
      c_nullAssignment(check, b_f);
      check_data = check->data;
      i = b_UVwindow->size[0] * b_UVwindow->size[1];
      b_UVwindow->size[0] = Uwindow->size[1];
      b_UVwindow->size[1] = Uwindow->size[0];
      emxEnsureCapacity_creal_T(b_UVwindow, i);
      b_UVwindow_data = b_UVwindow->data;
      loop_ub = Uwindow->size[0];
      for (i = 0; i < loop_ub; i++) {
        trueCount = Uwindow->size[1];
        for (i1 = 0; i1 < trueCount; i1++) {
          b_UVwindow_data[i1 + b_UVwindow->size[0] * i] =
              Uwindow_data[i + Uwindow->size[0] * i1];
        }
      }
      b_mean(b_UVwindow, UV);
      i = UV->size[0] * UV->size[1];
      UV->size[0] = 1;
      emxEnsureCapacity_creal_T(UV, i);
      UV_data = UV->data;
      loop_ub = UV->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        alpha = UV_data[i].re;
        win = UV_data[i].im;
        if (win == 0.0) {
          fe = alpha / y_tmp;
          alpha = 0.0;
        } else if (alpha == 0.0) {
          fe = 0.0;
          alpha = win / y_tmp;
        } else {
          fe = alpha / y_tmp;
          alpha = win / y_tmp;
        }
        UV_data[i].re = fe;
        UV_data[i].im = alpha;
      }
      i = b_f->size[0] * b_f->size[1];
      b_f->size[0] = 1;
      b_f->size[1] = f->size[1];
      emxEnsureCapacity_boolean_T(b_f, i);
      bad_data = b_f->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        bad_data[i] = (f_data[i] > 0.5);
      }
      d_nullAssignment(UV, b_f);
      UV_data = UV->data;
      i = b_UVwindow->size[0] * b_UVwindow->size[1];
      b_UVwindow->size[0] = Vwindow->size[1];
      b_UVwindow->size[1] = Vwindow->size[0];
      emxEnsureCapacity_creal_T(b_UVwindow, i);
      b_UVwindow_data = b_UVwindow->data;
      loop_ub = Vwindow->size[0];
      for (i = 0; i < loop_ub; i++) {
        trueCount = Vwindow->size[1];
        for (i1 = 0; i1 < trueCount; i1++) {
          b_UVwindow_data[i1 + b_UVwindow->size[0] * i] =
              Vwindow_data[i + Vwindow->size[0] * i1];
        }
      }
      b_mean(b_UVwindow, UW);
      i = UW->size[0] * UW->size[1];
      UW->size[0] = 1;
      emxEnsureCapacity_creal_T(UW, i);
      Vwindow_data = UW->data;
      loop_ub = UW->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        alpha = Vwindow_data[i].re;
        win = Vwindow_data[i].im;
        if (win == 0.0) {
          fe = alpha / y_tmp;
          alpha = 0.0;
        } else if (alpha == 0.0) {
          fe = 0.0;
          alpha = win / y_tmp;
        } else {
          fe = alpha / y_tmp;
          alpha = win / y_tmp;
        }
        Vwindow_data[i].re = fe;
        Vwindow_data[i].im = alpha;
      }
      i = b_f->size[0] * b_f->size[1];
      b_f->size[0] = 1;
      b_f->size[1] = f->size[1];
      emxEnsureCapacity_boolean_T(b_f, i);
      bad_data = b_f->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        bad_data[i] = (f_data[i] > 0.5);
      }
      d_nullAssignment(UW, b_f);
      Vwindow_data = UW->data;
      i = b_UVwindow->size[0] * b_UVwindow->size[1];
      b_UVwindow->size[0] = Wwindow->size[1];
      b_UVwindow->size[1] = Wwindow->size[0];
      emxEnsureCapacity_creal_T(b_UVwindow, i);
      b_UVwindow_data = b_UVwindow->data;
      loop_ub = Wwindow->size[0];
      for (i = 0; i < loop_ub; i++) {
        trueCount = Wwindow->size[1];
        for (i1 = 0; i1 < trueCount; i1++) {
          b_UVwindow_data[i1 + b_UVwindow->size[0] * i] =
              Wwindow_data[i + Wwindow->size[0] * i1];
        }
      }
      b_mean(b_UVwindow, VW);
      i = VW->size[0] * VW->size[1];
      VW->size[0] = 1;
      emxEnsureCapacity_creal_T(VW, i);
      Uwindow_data = VW->data;
      loop_ub = VW->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        alpha = Uwindow_data[i].re;
        win = Uwindow_data[i].im;
        if (win == 0.0) {
          fe = alpha / y_tmp;
          alpha = 0.0;
        } else if (alpha == 0.0) {
          fe = 0.0;
          alpha = win / y_tmp;
        } else {
          fe = alpha / y_tmp;
          alpha = win / y_tmp;
        }
        Uwindow_data[i].re = fe;
        Uwindow_data[i].im = alpha;
      }
      i = b_f->size[0] * b_f->size[1];
      b_f->size[0] = 1;
      b_f->size[1] = f->size[1];
      emxEnsureCapacity_boolean_T(b_f, i);
      bad_data = b_f->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        bad_data[i] = (f_data[i] > 0.5);
      }
      d_nullAssignment(VW, b_f);
      Uwindow_data = VW->data;
      i = b_f->size[0] * b_f->size[1];
      b_f->size[0] = 1;
      b_f->size[1] = f->size[1];
      emxEnsureCapacity_boolean_T(b_f, i);
      bad_data = b_f->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        bad_data[i] = (f_data[i] > 0.5);
      }
      c_nullAssignment(f, b_f);
      f_data = f->data;
      /*  wave spectral moments  */
      /*  see definitions from Kuik et al, JPO, 1988 and Herbers et al, JTech,
       * 2012, Thomson et al, J Tech 2018 */
      /* Qxz = imag(UW); % quadspectrum of vertical and east horizontal motion
       */
      /* Cxz = real(UW); % cospectrum of vertical and east horizontal motion */
      /* Qyz = imag(VW); % quadspectrum of vertical and north horizontal motion
       */
      /* Cyz = real(VW); % cospectrum of vertical and north horizontal motion */
      /* Cxy = real(UV) ./ ( (2*pi*f).^2 );  % cospectrum of east and north
       * motion */
      if (a2->size[1] == VV->size[1]) {
        i = b_y->size[0] * b_y->size[1];
        b_y->size[0] = 1;
        b_y->size[1] = a2->size[1];
        emxEnsureCapacity_real_T(b_y, i);
        uwindow_data = b_y->data;
        loop_ub = a2->size[1];
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i] = E_data[i] + VV_data[i];
        }
      } else {
        plus(b_y, a2, VV);
        uwindow_data = b_y->data;
      }
      if (b_y->size[1] == check->size[1]) {
        i = b1->size[0] * b1->size[1];
        b1->size[0] = 1;
        b1->size[1] = b_y->size[1];
        emxEnsureCapacity_real_T(b1, i);
        b1_data = b1->data;
        loop_ub = b_y->size[1];
        for (i = 0; i < loop_ub; i++) {
          b1_data[i] = uwindow_data[i] * check_data[i];
        }
      } else {
        times(b1, b_y, check);
        b1_data = b1->data;
      }
      nx = b1->size[1];
      for (k = 0; k < nx; k++) {
        b1_data[k] = sqrt(b1_data[k]);
      }
      if (UW->size[1] == b1->size[1]) {
        i = a1->size[0] * a1->size[1];
        a1->size[0] = 1;
        a1->size[1] = UW->size[1];
        emxEnsureCapacity_real_T(a1, i);
        a1_data = a1->data;
        loop_ub = UW->size[1];
        for (i = 0; i < loop_ub; i++) {
          a1_data[i] = Vwindow_data[i].im / b1_data[i];
        }
      } else {
        d_binary_expand_op(a1, UW, b1);
        a1_data = a1->data;
      }
      if (VW->size[1] == b1->size[1]) {
        loop_ub = VW->size[1] - 1;
        i = b1->size[0] * b1->size[1];
        b1->size[0] = 1;
        b1->size[1] = VW->size[1];
        emxEnsureCapacity_real_T(b1, i);
        b1_data = b1->data;
        for (i = 0; i <= loop_ub; i++) {
          b1_data[i] = Uwindow_data[i].im / b1_data[i];
        }
      } else {
        c_binary_expand_op(b1, VW);
        b1_data = b1->data;
      }
      if (a2->size[1] == 1) {
        loop_ub = VV->size[1];
      } else {
        loop_ub = a2->size[1];
      }
      if ((a2->size[1] == VV->size[1]) && (loop_ub == b_y->size[1])) {
        loop_ub = a2->size[1] - 1;
        i = a2->size[0] * a2->size[1];
        a2->size[0] = 1;
        emxEnsureCapacity_real_T(a2, i);
        E_data = a2->data;
        for (i = 0; i <= loop_ub; i++) {
          E_data[i] = (E_data[i] - VV_data[i]) / uwindow_data[i];
        }
      } else {
        b_binary_expand_op(a2, VV, b_y);
      }
      if (UV->size[1] == b_y->size[1]) {
        i = b2->size[0] * b2->size[1];
        b2->size[0] = 1;
        b2->size[1] = UV->size[1];
        emxEnsureCapacity_real_T(b2, i);
        E_data = b2->data;
        loop_ub = UV->size[1];
        for (i = 0; i < loop_ub; i++) {
          E_data[i] = 2.0 * UV_data[i].re / uwindow_data[i];
        }
      } else {
        binary_expand_op(b2, UV, b_y);
      }
      /*  Scalar energy spectra (a0) */
      i = E->size[0] * E->size[1];
      E->size[0] = 1;
      E->size[1] = f->size[1];
      emxEnsureCapacity_real_T(E, i);
      E_data = E->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        alpha = 6.2831853071795862 * f_data[i];
        E_data[i] = alpha * alpha;
      }
      if (b_y->size[1] == E->size[1]) {
        loop_ub = b_y->size[1] - 1;
        i = E->size[0] * E->size[1];
        E->size[0] = 1;
        E->size[1] = b_y->size[1];
        emxEnsureCapacity_real_T(E, i);
        E_data = E->data;
        for (i = 0; i <= loop_ub; i++) {
          E_data[i] = uwindow_data[i] / E_data[i];
        }
      } else {
        b_rdivide(E, b_y);
        E_data = E->data;
      }
      /*  assumes perfectly circular deepwater orbits */
      /*  E = ( WW ) ./ ( (2*pi*f).^2 ); % arbitrary depth, but more noise? */
      /*  use orbit shape as check on quality (=1 in deep water) */
      if (check->size[1] == b_y->size[1]) {
        loop_ub = check->size[1] - 1;
        i = check->size[0] * check->size[1];
        check->size[0] = 1;
        emxEnsureCapacity_real_T(check, i);
        check_data = check->data;
        for (i = 0; i <= loop_ub; i++) {
          check_data[i] /= uwindow_data[i];
        }
      } else {
        rdivide(check, b_y);
      }
      /*  wave stats */
      i = b_f->size[0] * b_f->size[1];
      b_f->size[0] = 1;
      b_f->size[1] = f->size[1];
      emxEnsureCapacity_boolean_T(b_f, i);
      bad_data = b_f->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        bad_data[i] = (f_data[i] > 0.05);
      }
      i = r7->size[0] * r7->size[1];
      r7->size[0] = 1;
      r7->size[1] = f->size[1];
      emxEnsureCapacity_boolean_T(r7, i);
      r13 = r7->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        r13[i] = (f_data[i] < 0.5);
      }
      /*  frequency cutoff for wave stats, 0.4 is specific to SWIFT hull */
      nx = b_f->size[1];
      for (b_i = 0; b_i < nx; b_i++) {
        if ((!bad_data[b_i]) || (!r13[b_i])) {
          E_data[b_i] = 0.0;
        }
      }
      /*  significant wave height */
      nx = b_f->size[1] - 1;
      trueCount = 0;
      for (b_i = 0; b_i <= nx; b_i++) {
        if (bad_data[b_i] && r13[b_i]) {
          trueCount++;
        }
      }
      i = r8->size[0] * r8->size[1];
      r8->size[0] = 1;
      r8->size[1] = trueCount;
      emxEnsureCapacity_int32_T(r8, i);
      Uwindow_tmp_data = r8->data;
      trueCount = 0;
      for (b_i = 0; b_i <= nx; b_i++) {
        if (bad_data[b_i] && r13[b_i]) {
          Uwindow_tmp_data[trueCount] = b_i + 1;
          trueCount++;
        }
      }
      i = VV->size[0] * VV->size[1];
      VV->size[0] = 1;
      VV->size[1] = r8->size[1];
      emxEnsureCapacity_real_T(VV, i);
      VV_data = VV->data;
      loop_ub = r8->size[1];
      for (i = 0; i < loop_ub; i++) {
        VV_data[i] = E_data[Uwindow_tmp_data[i] - 1];
      }
      *Hs = 4.0 * sqrt(sum(VV) * bandwidth);
      /*   energy period */
      nx = b_f->size[1] - 1;
      trueCount = 0;
      for (b_i = 0; b_i <= nx; b_i++) {
        if (bad_data[b_i] && r13[b_i]) {
          trueCount++;
        }
      }
      i = r9->size[0] * r9->size[1];
      r9->size[0] = 1;
      r9->size[1] = trueCount;
      emxEnsureCapacity_int32_T(r9, i);
      Uwindow_tmp_data = r9->data;
      trueCount = 0;
      for (b_i = 0; b_i <= nx; b_i++) {
        if (bad_data[b_i] && r13[b_i]) {
          Uwindow_tmp_data[trueCount] = b_i + 1;
          trueCount++;
        }
      }
      i = b_y->size[0] * b_y->size[1];
      b_y->size[0] = 1;
      b_y->size[1] = r9->size[1];
      emxEnsureCapacity_real_T(b_y, i);
      uwindow_data = b_y->data;
      loop_ub = r9->size[1];
      for (i = 0; i < loop_ub; i++) {
        i1 = Uwindow_tmp_data[i];
        uwindow_data[i] = f_data[i1 - 1] * E_data[i1 - 1];
      }
      i = VV->size[0] * VV->size[1];
      VV->size[0] = 1;
      VV->size[1] = r9->size[1];
      emxEnsureCapacity_real_T(VV, i);
      VV_data = VV->data;
      loop_ub = r9->size[1];
      for (i = 0; i < loop_ub; i++) {
        VV_data[i] = E_data[Uwindow_tmp_data[i] - 1];
      }
      fe = sum(b_y) / sum(VV);
      i = VV->size[0] * VV->size[1];
      VV->size[0] = 1;
      VV->size[1] = f->size[1];
      emxEnsureCapacity_real_T(VV, i);
      VV_data = VV->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        VV_data[i] = f_data[i] - fe;
      }
      nx = VV->size[1];
      i = b_y->size[0] * b_y->size[1];
      b_y->size[0] = 1;
      b_y->size[1] = VV->size[1];
      emxEnsureCapacity_real_T(b_y, i);
      uwindow_data = b_y->data;
      for (k = 0; k < nx; k++) {
        uwindow_data[k] = fabs(VV_data[k]);
      }
      minimum(b_y, &alpha, &trueCount);
      /*  peak period */
      /* [~ , fpindex] = max(UU+VV); % can use velocity (picks out more distint
       * peak) */
      maximum(E, &alpha, &nx);
      *Tp = 1.0 / f_data[nx - 1];
      if (*Tp > 18.0) {
        /*  if peak not found, use centroid */
        *Tp = 1.0 / fe;
        nx = trueCount;
      }
      /*  wave directions */
      /*  begin with cartesian, 0 deg is for waves headed towards positive x
       * (EAST, right hand system) */
      /* dir1 = atan2(b1,a1) ;  % [rad], 4 quadrant */
      /* dir2 = atan2(b2,a2)/2 ; % [rad], only 2 quadrant */
      /* spread1 = sqrt( 2 * ( 1 - sqrt(a1.^2 + b2.^2) ) ); */
      /* spread2 = sqrt( abs( 0.5 - 0.5 .* ( a2.*cos(2.*dir2) + b2.*cos(2.*dir2)
       * )  )); */
      /*  peak wave direction, rotated to geographic conventions */
      /*  [rad], 4 quadrant */
      /*  switch from rad to deg, and CCW to CW (negate) */
      *Dp = -57.324840764331206 *
                rt_atan2d_snf(b1_data[nx - 1], a1_data[nx - 1]) +
            90.0;
      /*  rotate from eastward = 0 to northward  = 0 */
      if (*Dp < 0.0) {
        *Dp += 360.0;
      }
      /*  take NW quadrant from negative to 270-360 range */
      if (*Dp > 180.0) {
        *Dp -= 180.0;
      }
      /*  take reciprocal such wave direction is FROM, not TOWARDS */
      if (*Dp < 180.0) {
        *Dp += 180.0;
      }
      /*  take reciprocal such wave direction is FROM, not TOWARDS */
    } else {
      guard1 = true;
    }
  } else {
    guard1 = true;
  }
  if (guard1) {
    /*  if not enough points or insufficent sampling rate give 9999 */
    *Hs = 9999.0;
    *Tp = 9999.0;
    *Dp = 9999.0;
    i = E->size[0] * E->size[1];
    E->size[0] = 1;
    E->size[1] = 1;
    emxEnsureCapacity_real_T(E, i);
    E_data = E->data;
    E_data[0] = 9999.0;
    i = f->size[0] * f->size[1];
    f->size[0] = 1;
    f->size[1] = 1;
    emxEnsureCapacity_real_T(f, i);
    f_data = f->data;
    f_data[0] = 9999.0;
    i = a1->size[0] * a1->size[1];
    a1->size[0] = 1;
    a1->size[1] = 1;
    emxEnsureCapacity_real_T(a1, i);
    a1_data = a1->data;
    a1_data[0] = 9999.0;
    i = b1->size[0] * b1->size[1];
    b1->size[0] = 1;
    b1->size[1] = 1;
    emxEnsureCapacity_real_T(b1, i);
    b1_data = b1->data;
    b1_data[0] = 9999.0;
    i = a2->size[0] * a2->size[1];
    a2->size[0] = 1;
    a2->size[1] = 1;
    emxEnsureCapacity_real_T(a2, i);
    E_data = a2->data;
    E_data[0] = 9999.0;
    i = b2->size[0] * b2->size[1];
    b2->size[0] = 1;
    b2->size[1] = 1;
    emxEnsureCapacity_real_T(b2, i);
    E_data = b2->data;
    E_data[0] = 9999.0;
    i = check->size[0] * check->size[1];
    check->size[0] = 1;
    check->size[1] = 1;
    emxEnsureCapacity_real_T(check, i);
    check_data = check->data;
    check_data[0] = 9999.0;
  }
  emxFree_creal_T(&b_UVwindow);
  emxFree_boolean_T(&b_f);
  emxFree_real_T(&b_UUwindow);
  emxFree_real_T(&b_uwindow);
  emxFree_real_T(&r12);
  emxFree_real_T(&r11);
  emxFree_real_T(&b_y);
  emxFree_int32_T(&Uwindow_tmp);
  emxFree_real_T(&r10);
  emxFree_int32_T(&r9);
  emxFree_int32_T(&r8);
  emxFree_boolean_T(&r7);
  emxFree_creal_T(&VW);
  emxFree_creal_T(&UW);
  emxFree_creal_T(&UV);
  emxFree_real_T(&VV);
  emxFree_creal_T(&VWwindow);
  emxFree_creal_T(&UWwindow);
  emxFree_creal_T(&UVwindow);
  emxFree_real_T(&WWwindow);
  emxFree_real_T(&VVwindow);
  emxFree_real_T(&UUwindow);
  emxFree_creal_T(&Wwindow);
  emxFree_creal_T(&Vwindow);
  emxFree_creal_T(&Uwindow);
  emxFree_real_T(&taper);
  emxFree_real_T(&wvar);
  emxFree_real_T(&vvar);
  emxFree_real_T(&uvar);
  emxFree_real_T(&wwindow);
  emxFree_real_T(&vwindow);
  emxFree_real_T(&uwindow);
  emxFree_real32_T(&w);
  emxFree_real32_T(&v);
  emxFree_real32_T(&u);
  emxFree_boolean_T(&bad);
  /*  quality control for excessive low frequency problems */
  if (*Tp > 20.0) {
    *Hs = 9999.0;
    *Tp = 9999.0;
    *Dp = 9999.0;
  }
  /*  testing bits */
  /*  if testing */
  /*   */
  /*      figure(1), clf */
  /*      subplot(2,1,1) */
  /*      loglog(f,( UU + VV) ./ ( (2*pi*f).^2 ), f, ( WW ) ./ ( (2*pi*f).^2 ) )
   */
  /*      set(gca,'YLim',[1e-3 2e2]) */
  /*      legend('E=(UU+VV)/f^2','E=WW/f^2') */
  /*      ylabel('Energy [m^2/Hz]') */
  /*      title(['Hs = ' num2str(Hs,2) ', Tp = ' num2str(Tp,2) ', Dp = '
   * num2str(Dp,3)]) */
  /*      subplot(2,1,2) */
  /*      semilogx(f,a1, f,b1, f,a2,  f,b2) */
  /*      set(gca,'YLim',[-1 1]) */
  /*      legend('a1','b1','a2','b2') */
  /*      xlabel('frequency [Hz]') */
  /*      drawnow */
  /*   */
  /*  end */
}

/*
 * File trailer for NEDwaves.c
 *
 * [EOF]
 */
