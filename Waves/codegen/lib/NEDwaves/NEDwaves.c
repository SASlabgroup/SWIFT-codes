/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
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
#include "rtwhalf.h"
#include "std.h"
#include "sum.h"
#include "var.h"
#include "rt_defines.h"
#include "rt_nonfinite.h"
#include <float.h>
#include <math.h>

/* Function Declarations */
static void b_times(emxArray_real_T *in1, const emxArray_real_T *in2);

static void e_binary_expand_op(emxArray_creal32_T *in1,
                               const emxArray_creal32_T *in2,
                               const emxArray_creal32_T *in3);

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
 * Arguments    : emxArray_creal32_T *in1
 *                const emxArray_creal32_T *in2
 *                const emxArray_creal32_T *in3
 * Return Type  : void
 */
static void e_binary_expand_op(emxArray_creal32_T *in1,
                               const emxArray_creal32_T *in2,
                               const emxArray_creal32_T *in3)
{
  const creal32_T *in2_data;
  const creal32_T *in3_data;
  creal32_T *in1_data;
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
  emxEnsureCapacity_creal32_T(in1, i);
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
      float in3_im;
      float in3_re;
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
 *    [ Hs, Tp, Dp, E, fmin, fmax, a1, b1, a2, b2, check ] =
 * NEDwaves(north,east,down,fs);
 *
 *  note that outputs are slightly different than other wave codes
 *  b/c this matches the half-float precision format of telemetry type 52
 *  and only uses frequency limits, not full f array
 *
 *  J. Thomson,  12/2022 (modified from GPSwaves)
 *
 *
 * Arguments    : emxArray_real32_T *north
 *                emxArray_real32_T *east
 *                emxArray_real32_T *down
 *                double fs
 *                real16_T *Hs
 *                real16_T *Tp
 *                real16_T *Dp
 *                emxArray_real16_T *E
 *                real16_T *b_fmin
 *                real16_T *b_fmax
 *                emxArray_int8_T *a1
 *                emxArray_int8_T *b1
 *                emxArray_int8_T *a2
 *                emxArray_int8_T *b2
 *                emxArray_uint8_T *check
 * Return Type  : void
 */
void NEDwaves(emxArray_real32_T *north, emxArray_real32_T *east,
              emxArray_real32_T *down, double fs, real16_T *Hs, real16_T *Tp,
              real16_T *Dp, emxArray_real16_T *E, real16_T *b_fmin,
              real16_T *b_fmax, emxArray_int8_T *a1, emxArray_int8_T *b1,
              emxArray_int8_T *a2, emxArray_int8_T *b2, emxArray_uint8_T *check)
{
  emxArray_boolean_T *b_f;
  emxArray_boolean_T *bad;
  emxArray_boolean_T *r7;
  emxArray_creal32_T *UVwindow;
  emxArray_creal32_T *UWwindow;
  emxArray_creal32_T *Uwindow;
  emxArray_creal32_T *VWwindow;
  emxArray_creal32_T *Vwindow;
  emxArray_creal32_T *Wwindow;
  emxArray_creal32_T *b_UVwindow;
  emxArray_creal32_T *r13;
  emxArray_creal_T *UV;
  emxArray_creal_T *UVwindowmerged;
  emxArray_creal_T *UW;
  emxArray_creal_T *UWwindowmerged;
  emxArray_creal_T *VW;
  emxArray_creal_T *VWwindowmerged;
  emxArray_creal_T *b_UVwindowmerged;
  emxArray_int32_T *Uwindow_tmp;
  emxArray_int32_T *r;
  emxArray_int32_T *r1;
  emxArray_int32_T *r3;
  emxArray_int32_T *r4;
  emxArray_int32_T *r5;
  emxArray_int32_T *r6;
  emxArray_int32_T *r8;
  emxArray_int32_T *r9;
  emxArray_real32_T *UUwindow;
  emxArray_real32_T *VVwindow;
  emxArray_real32_T *WWwindow;
  emxArray_real32_T *b_UUwindow;
  emxArray_real32_T *filtereddata;
  emxArray_real32_T *r12;
  emxArray_real_T *UU;
  emxArray_real_T *WW;
  emxArray_real_T *b_E;
  emxArray_real_T *b_a1;
  emxArray_real_T *b_b1;
  emxArray_real_T *b_b2;
  emxArray_real_T *b_uwindow;
  emxArray_real_T *b_y;
  emxArray_real_T *c_uwindow;
  emxArray_real_T *f;
  emxArray_real_T *r10;
  emxArray_real_T *r11;
  emxArray_real_T *r14;
  emxArray_real_T *taper;
  emxArray_real_T *uvar;
  emxArray_real_T *uwindow;
  emxArray_real_T *vvar;
  emxArray_real_T *vwindow;
  emxArray_real_T *wvar;
  emxArray_real_T *wwindow;
  emxArray_real_T *x;
  creal_T *UV_data;
  creal_T *UVwindowmerged_data;
  creal_T *UWwindowmerged_data;
  creal_T *VWwindowmerged_data;
  creal_T *b_UVwindowmerged_data;
  creal32_T *UVwindow_data;
  creal32_T *UWwindow_data;
  creal32_T *Uwindow_data;
  creal32_T *VWwindow_data;
  creal32_T *Vwindow_data;
  creal32_T *Wwindow_data;
  double b_Dp;
  double b_Hs;
  double b_Tp;
  double d;
  double *E_data;
  double *UU_data;
  double *WW_data;
  double *a1_data;
  double *b1_data;
  double *b2_data;
  double *f_data;
  double *uwindow_data;
  double *vwindow_data;
  double *wwindow_data;
  float y;
  float *down_data;
  float *east_data;
  float *filtereddata_data;
  float *north_data;
  int i;
  int i2;
  int i3;
  int i5;
  int k;
  int loop_ub;
  int mi;
  int nx;
  int pts;
  int vlen;
  int windows;
  int *Uwindow_tmp_data;
  int *r2;
  real16_T *b_E_data;
  signed char i1;
  signed char *b_a1_data;
  unsigned char *check_data;
  bool guard1 = false;
  bool *bad_data;
  bool *r15;
  emxInit_real32_T(&filtereddata, 1);
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
  i = filtereddata->size[0];
  filtereddata->size[0] = east->size[0];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  for (k = 0; k < nx; k++) {
    filtereddata_data[k] = fabsf(east_data[k]);
  }
  emxInit_boolean_T(&bad, 1);
  i = bad->size[0];
  bad->size[0] = filtereddata->size[0];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  loop_ub = filtereddata->size[0];
  for (i = 0; i < loop_ub; i++) {
    bad_data[i] = (filtereddata_data[i] >= y);
  }
  /*  logical array of indices for bad points */
  pts = bad->size[0] - 1;
  vlen = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (bad_data[windows]) {
      vlen++;
    }
  }
  emxInit_int32_T(&r, 1);
  i = r->size[0];
  r->size[0] = vlen;
  emxEnsureCapacity_int32_T(r, i);
  Uwindow_tmp_data = r->data;
  nx = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (bad_data[windows]) {
      Uwindow_tmp_data[nx] = windows + 1;
      nx++;
    }
  }
  pts = bad->size[0] - 1;
  vlen = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (!bad_data[windows]) {
      vlen++;
    }
  }
  emxInit_int32_T(&r1, 1);
  i = r1->size[0];
  r1->size[0] = vlen;
  emxEnsureCapacity_int32_T(r1, i);
  r2 = r1->data;
  nx = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (!bad_data[windows]) {
      r2[nx] = windows + 1;
      nx++;
    }
  }
  i = filtereddata->size[0];
  filtereddata->size[0] = r1->size[0];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  loop_ub = r1->size[0];
  for (i = 0; i < loop_ub; i++) {
    filtereddata_data[i] = east_data[r2[i] - 1];
  }
  y = blockedSummation(filtereddata, r1->size[0]) / (float)r1->size[0];
  loop_ub = r->size[0];
  emxFree_int32_T(&r1);
  for (i = 0; i < loop_ub; i++) {
    east_data[Uwindow_tmp_data[i] - 1] = y;
  }
  emxFree_int32_T(&r);
  y = 4.0F * b_std(north);
  nx = north->size[0];
  i = filtereddata->size[0];
  filtereddata->size[0] = north->size[0];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  for (k = 0; k < nx; k++) {
    filtereddata_data[k] = fabsf(north_data[k]);
  }
  i = bad->size[0];
  bad->size[0] = filtereddata->size[0];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  loop_ub = filtereddata->size[0];
  for (i = 0; i < loop_ub; i++) {
    bad_data[i] = (filtereddata_data[i] >= y);
  }
  /*  logical array of indices for bad points */
  pts = bad->size[0] - 1;
  vlen = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (bad_data[windows]) {
      vlen++;
    }
  }
  emxInit_int32_T(&r3, 1);
  i = r3->size[0];
  r3->size[0] = vlen;
  emxEnsureCapacity_int32_T(r3, i);
  Uwindow_tmp_data = r3->data;
  nx = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (bad_data[windows]) {
      Uwindow_tmp_data[nx] = windows + 1;
      nx++;
    }
  }
  pts = bad->size[0] - 1;
  vlen = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (!bad_data[windows]) {
      vlen++;
    }
  }
  emxInit_int32_T(&r4, 1);
  i = r4->size[0];
  r4->size[0] = vlen;
  emxEnsureCapacity_int32_T(r4, i);
  r2 = r4->data;
  nx = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (!bad_data[windows]) {
      r2[nx] = windows + 1;
      nx++;
    }
  }
  i = filtereddata->size[0];
  filtereddata->size[0] = r4->size[0];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  loop_ub = r4->size[0];
  for (i = 0; i < loop_ub; i++) {
    filtereddata_data[i] = north_data[r2[i] - 1];
  }
  y = blockedSummation(filtereddata, r4->size[0]) / (float)r4->size[0];
  loop_ub = r3->size[0];
  emxFree_int32_T(&r4);
  for (i = 0; i < loop_ub; i++) {
    north_data[Uwindow_tmp_data[i] - 1] = y;
  }
  emxFree_int32_T(&r3);
  y = 4.0F * b_std(down);
  nx = down->size[0];
  i = filtereddata->size[0];
  filtereddata->size[0] = down->size[0];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  for (k = 0; k < nx; k++) {
    filtereddata_data[k] = fabsf(down_data[k]);
  }
  i = bad->size[0];
  bad->size[0] = filtereddata->size[0];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  loop_ub = filtereddata->size[0];
  for (i = 0; i < loop_ub; i++) {
    bad_data[i] = (filtereddata_data[i] >= y);
  }
  /*  logical array of indices for bad points */
  pts = bad->size[0] - 1;
  vlen = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (bad_data[windows]) {
      vlen++;
    }
  }
  emxInit_int32_T(&r5, 1);
  i = r5->size[0];
  r5->size[0] = vlen;
  emxEnsureCapacity_int32_T(r5, i);
  Uwindow_tmp_data = r5->data;
  nx = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (bad_data[windows]) {
      Uwindow_tmp_data[nx] = windows + 1;
      nx++;
    }
  }
  pts = bad->size[0] - 1;
  vlen = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (!bad_data[windows]) {
      vlen++;
    }
  }
  emxInit_int32_T(&r6, 1);
  i = r6->size[0];
  r6->size[0] = vlen;
  emxEnsureCapacity_int32_T(r6, i);
  r2 = r6->data;
  nx = 0;
  for (windows = 0; windows <= pts; windows++) {
    if (!bad_data[windows]) {
      r2[nx] = windows + 1;
      nx++;
    }
  }
  i = filtereddata->size[0];
  filtereddata->size[0] = r6->size[0];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  loop_ub = r6->size[0];
  for (i = 0; i < loop_ub; i++) {
    filtereddata_data[i] = down_data[r2[i] - 1];
  }
  y = blockedSummation(filtereddata, r6->size[0]) / (float)r6->size[0];
  loop_ub = r5->size[0];
  emxFree_int32_T(&r6);
  for (i = 0; i < loop_ub; i++) {
    down_data[Uwindow_tmp_data[i] - 1] = y;
  }
  emxFree_int32_T(&r5);
  /*  begin processing, if data sufficient */
  pts = east->size[0];
  /*  record length in data points */
  emxInit_real_T(&uwindow, 2);
  emxInit_real_T(&vwindow, 2);
  emxInit_real_T(&wwindow, 2);
  emxInit_real_T(&uvar, 2);
  emxInit_real_T(&vvar, 2);
  emxInit_real_T(&wvar, 2);
  emxInit_real_T(&taper, 2);
  emxInit_creal32_T(&Uwindow);
  emxInit_creal32_T(&Vwindow);
  emxInit_creal32_T(&Wwindow);
  emxInit_real32_T(&UUwindow, 2);
  emxInit_real32_T(&VVwindow, 2);
  emxInit_real32_T(&WWwindow, 2);
  emxInit_creal32_T(&UVwindow);
  emxInit_creal32_T(&UWwindow);
  emxInit_creal32_T(&VWwindow);
  emxInit_creal_T(&UVwindowmerged, 2);
  emxInit_creal_T(&UWwindowmerged, 2);
  emxInit_creal_T(&VWwindowmerged, 2);
  emxInit_real_T(&f, 2);
  emxInit_real_T(&UU, 2);
  emxInit_real_T(&WW, 2);
  emxInit_creal_T(&UV, 2);
  emxInit_creal_T(&UW, 2);
  emxInit_creal_T(&VW, 2);
  emxInit_real_T(&b_E, 2);
  emxInit_real_T(&b_a1, 2);
  emxInit_real_T(&b_b1, 2);
  emxInit_real_T(&b_b2, 2);
  emxInit_boolean_T(&r7, 2);
  emxInit_int32_T(&r8, 2);
  emxInit_int32_T(&r9, 2);
  emxInit_real_T(&r10, 1);
  emxInit_int32_T(&Uwindow_tmp, 2);
  emxInit_real_T(&b_y, 2);
  emxInit_real_T(&x, 2);
  emxInit_real_T(&r11, 2);
  emxInit_real32_T(&r12, 2);
  emxInit_creal32_T(&r13);
  emxInit_real_T(&r14, 2);
  emxInit_real_T(&b_uwindow, 1);
  emxInit_real32_T(&b_UUwindow, 2);
  emxInit_real_T(&c_uwindow, 2);
  emxInit_boolean_T(&b_f, 2);
  emxInit_creal32_T(&b_UVwindow);
  emxInit_creal_T(&b_UVwindowmerged, 2);
  guard1 = false;
  if ((east->size[0] >= 512) && (fs >= 1.0)) {
    vlen = bad->size[0];
    if (bad->size[0] == 0) {
      nx = 0;
    } else {
      nx = bad_data[0];
      for (k = 2; k <= vlen; k++) {
        nx += bad_data[k - 1];
      }
    }
    if (nx < 100) {
      double bandwidth;
      double win;
      float Vwindow_im;
      /*  minimum length and quality for processing */
      /*  high-pass RC filter,  */
      b_Dp = 3.5 / (1.0 / fs + 3.5);
      i = filtereddata->size[0];
      filtereddata->size[0] = east->size[0];
      emxEnsureCapacity_real32_T(filtereddata, i);
      filtereddata_data = filtereddata->data;
      loop_ub = east->size[0];
      for (i = 0; i < loop_ub; i++) {
        filtereddata_data[i] = east_data[i];
      }
      i = east->size[0];
      for (vlen = 0; vlen <= i - 2; vlen++) {
        filtereddata_data[vlen + 1] =
            (float)b_Dp * filtereddata_data[vlen] +
            (float)b_Dp * (east_data[vlen + 1] - east_data[vlen]);
      }
      i = east->size[0];
      east->size[0] = filtereddata->size[0];
      emxEnsureCapacity_real32_T(east, i);
      east_data = east->data;
      loop_ub = filtereddata->size[0];
      for (i = 0; i < loop_ub; i++) {
        east_data[i] = filtereddata_data[i];
      }
      i = filtereddata->size[0];
      filtereddata->size[0] = north->size[0];
      emxEnsureCapacity_real32_T(filtereddata, i);
      filtereddata_data = filtereddata->data;
      loop_ub = north->size[0];
      for (i = 0; i < loop_ub; i++) {
        filtereddata_data[i] = north_data[i];
      }
      i = north->size[0];
      for (vlen = 0; vlen <= i - 2; vlen++) {
        filtereddata_data[vlen + 1] =
            (float)b_Dp * filtereddata_data[vlen] +
            (float)b_Dp * (north_data[vlen + 1] - north_data[vlen]);
      }
      i = north->size[0];
      north->size[0] = filtereddata->size[0];
      emxEnsureCapacity_real32_T(north, i);
      north_data = north->data;
      loop_ub = filtereddata->size[0];
      for (i = 0; i < loop_ub; i++) {
        north_data[i] = filtereddata_data[i];
      }
      i = filtereddata->size[0];
      filtereddata->size[0] = down->size[0];
      emxEnsureCapacity_real32_T(filtereddata, i);
      filtereddata_data = filtereddata->data;
      loop_ub = down->size[0];
      for (i = 0; i < loop_ub; i++) {
        filtereddata_data[i] = down_data[i];
      }
      i = down->size[0];
      for (vlen = 0; vlen <= i - 2; vlen++) {
        filtereddata_data[vlen + 1] =
            (float)b_Dp * filtereddata_data[vlen] +
            (float)b_Dp * (down_data[vlen + 1] - down_data[vlen]);
      }
      /*  break into windows (use 75 percent overlap) */
      win = rt_roundd_snf(fs * 256.0);
      /*  window length in data points */
      if (rt_remd_snf(win, 2.0) != 0.0) {
        win--;
      }
      /*  make win an even number */
      windows = (int)floor(4.0 * ((double)pts / win - 1.0) + 1.0);
      /*  number of windows, the 4 comes from a 75% overlap */
      /*  degrees of freedom */
      /*  loop to create a matrix of time series, where COLUMN = WINDOW  */
      pts = (int)win;
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
        b_Dp = (((double)nx + 1.0) - 1.0) * (0.25 * win);
        i = b_E->size[0] * b_E->size[1];
        b_E->size[0] = 1;
        b_E->size[1] = (int)(win - 1.0) + 1;
        emxEnsureCapacity_real_T(b_E, i);
        E_data = b_E->data;
        loop_ub = (int)(win - 1.0);
        for (i = 0; i <= loop_ub; i++) {
          E_data[i] = b_Dp + ((double)i + 1.0);
        }
        loop_ub = b_E->size[1];
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i + uwindow->size[0] * nx] =
              east_data[(int)E_data[i] - 1];
        }
        i = r10->size[0];
        r10->size[0] = (int)(win - 1.0) + 1;
        emxEnsureCapacity_real_T(r10, i);
        a1_data = r10->data;
        loop_ub = (int)(win - 1.0);
        for (i = 0; i <= loop_ub; i++) {
          a1_data[i] = b_Dp + ((double)i + 1.0);
        }
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i + vwindow->size[0] * nx] =
              north_data[(int)a1_data[i] - 1];
        }
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          wwindow_data[i + wwindow->size[0] * nx] =
              filtereddata_data[(int)a1_data[i] - 1];
        }
      }
      /*  detrend individual windows (full series already detrended) */
      for (nx = 0; nx < windows; nx++) {
        vlen = uwindow->size[0] - 1;
        i = b_uwindow->size[0];
        b_uwindow->size[0] = uwindow->size[0];
        emxEnsureCapacity_real_T(b_uwindow, i);
        a1_data = b_uwindow->data;
        for (i = 0; i <= vlen; i++) {
          a1_data[i] = uwindow_data[i + uwindow->size[0] * nx];
        }
        detrend(b_uwindow, r10);
        a1_data = r10->data;
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i + uwindow->size[0] * nx] = a1_data[i];
        }
        vlen = vwindow->size[0] - 1;
        i = b_uwindow->size[0];
        b_uwindow->size[0] = vwindow->size[0];
        emxEnsureCapacity_real_T(b_uwindow, i);
        a1_data = b_uwindow->data;
        for (i = 0; i <= vlen; i++) {
          a1_data[i] = vwindow_data[i + vwindow->size[0] * nx];
        }
        detrend(b_uwindow, r10);
        a1_data = r10->data;
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i + vwindow->size[0] * nx] = a1_data[i];
        }
        vlen = wwindow->size[0] - 1;
        i = b_uwindow->size[0];
        b_uwindow->size[0] = wwindow->size[0];
        emxEnsureCapacity_real_T(b_uwindow, i);
        a1_data = b_uwindow->data;
        for (i = 0; i <= vlen; i++) {
          a1_data[i] = wwindow_data[i + wwindow->size[0] * nx];
        }
        detrend(b_uwindow, r10);
        a1_data = r10->data;
        loop_ub = r10->size[0];
        for (i = 0; i < loop_ub; i++) {
          wwindow_data[i + wwindow->size[0] * nx] = a1_data[i];
        }
      }
      /*  taper and rescale (to preserve variance) */
      /*  get original variance of each window */
      var(uwindow, uvar);
      b1_data = uvar->data;
      var(vwindow, vvar);
      b2_data = vvar->data;
      var(wwindow, wvar);
      WW_data = wvar->data;
      /*  form taper matrix (columns of taper coef) */
      i = b_E->size[0] * b_E->size[1];
      b_E->size[0] = 1;
      b_E->size[1] = (int)(win - 1.0) + 1;
      emxEnsureCapacity_real_T(b_E, i);
      E_data = b_E->data;
      loop_ub = (int)(win - 1.0);
      for (i = 0; i <= loop_ub; i++) {
        E_data[i] = ((double)i + 1.0) * 3.1415926535897931 / win;
      }
      nx = b_E->size[1];
      for (k = 0; k < nx; k++) {
        E_data[k] = sin(E_data[k]);
      }
      i = taper->size[0] * taper->size[1];
      taper->size[0] = b_E->size[1];
      taper->size[1] = windows;
      emxEnsureCapacity_real_T(taper, i);
      a1_data = taper->data;
      for (i = 0; i < windows; i++) {
        loop_ub = b_E->size[1];
        for (i2 = 0; i2 < loop_ub; i2++) {
          a1_data[i2 + taper->size[0] * i] = E_data[i2];
        }
      }
      /*  taper each window */
      if (uwindow->size[1] == taper->size[1]) {
        loop_ub = uwindow->size[0] * uwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i] *= a1_data[i];
        }
      } else {
        b_times(uwindow, taper);
      }
      if (vwindow->size[1] == taper->size[1]) {
        loop_ub = vwindow->size[0] * vwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i] *= a1_data[i];
        }
      } else {
        b_times(vwindow, taper);
      }
      if (wwindow->size[1] == taper->size[1]) {
        loop_ub = wwindow->size[0] * wwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          wwindow_data[i] *= a1_data[i];
        }
      } else {
        b_times(wwindow, taper);
      }
      /*  now find the correction factor (comparing old/new variance) */
      /*  and correct for the change in variance */
      /*  (mult each window by it's variance ratio factor) */
      var(uwindow, r11);
      a1_data = r11->data;
      if (uvar->size[1] == r11->size[1]) {
        i = x->size[0] * x->size[1];
        x->size[0] = 1;
        x->size[1] = uvar->size[1];
        emxEnsureCapacity_real_T(x, i);
        vwindow_data = x->data;
        loop_ub = uvar->size[1];
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i] = b1_data[i] / a1_data[i];
        }
      } else {
        g_binary_expand_op(x, uvar, r11);
        vwindow_data = x->data;
      }
      nx = x->size[1];
      for (k = 0; k < nx; k++) {
        vwindow_data[k] = sqrt(vwindow_data[k]);
      }
      i = taper->size[0] * taper->size[1];
      taper->size[0] = (int)win;
      taper->size[1] = x->size[1];
      emxEnsureCapacity_real_T(taper, i);
      a1_data = taper->data;
      loop_ub = x->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i2 = 0; i2 < pts; i2++) {
          a1_data[i2 + taper->size[0] * i] = vwindow_data[i];
        }
      }
      i = r14->size[0] * r14->size[1];
      r14->size[0] = (int)win;
      r14->size[1] = x->size[1];
      emxEnsureCapacity_real_T(r14, i);
      a1_data = r14->data;
      loop_ub = x->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i2 = 0; i2 < pts; i2++) {
          a1_data[i2 + r14->size[0] * i] = vwindow_data[i];
        }
      }
      if ((taper->size[0] == uwindow->size[0]) &&
          (r14->size[1] == uwindow->size[1])) {
        i = taper->size[0] * taper->size[1];
        taper->size[0] = (int)win;
        taper->size[1] = x->size[1];
        emxEnsureCapacity_real_T(taper, i);
        a1_data = taper->data;
        loop_ub = x->size[1];
        for (i = 0; i < loop_ub; i++) {
          for (i2 = 0; i2 < pts; i2++) {
            a1_data[i2 + taper->size[0] * i] = vwindow_data[i];
          }
        }
        loop_ub = taper->size[0] * taper->size[1];
        i = uwindow->size[0] * uwindow->size[1];
        uwindow->size[0] = taper->size[0];
        uwindow->size[1] = taper->size[1];
        emxEnsureCapacity_real_T(uwindow, i);
        uwindow_data = uwindow->data;
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i] *= a1_data[i];
        }
      } else {
        f_binary_expand_op(uwindow, win, x);
      }
      var(vwindow, r11);
      a1_data = r11->data;
      if (vvar->size[1] == r11->size[1]) {
        i = x->size[0] * x->size[1];
        x->size[0] = 1;
        x->size[1] = vvar->size[1];
        emxEnsureCapacity_real_T(x, i);
        vwindow_data = x->data;
        loop_ub = vvar->size[1];
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i] = b2_data[i] / a1_data[i];
        }
      } else {
        g_binary_expand_op(x, vvar, r11);
        vwindow_data = x->data;
      }
      nx = x->size[1];
      for (k = 0; k < nx; k++) {
        vwindow_data[k] = sqrt(vwindow_data[k]);
      }
      i = taper->size[0] * taper->size[1];
      taper->size[0] = (int)win;
      taper->size[1] = x->size[1];
      emxEnsureCapacity_real_T(taper, i);
      a1_data = taper->data;
      loop_ub = x->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i2 = 0; i2 < pts; i2++) {
          a1_data[i2 + taper->size[0] * i] = vwindow_data[i];
        }
      }
      i = r14->size[0] * r14->size[1];
      r14->size[0] = (int)win;
      r14->size[1] = x->size[1];
      emxEnsureCapacity_real_T(r14, i);
      a1_data = r14->data;
      loop_ub = x->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i2 = 0; i2 < pts; i2++) {
          a1_data[i2 + r14->size[0] * i] = vwindow_data[i];
        }
      }
      if ((taper->size[0] == vwindow->size[0]) &&
          (r14->size[1] == vwindow->size[1])) {
        i = taper->size[0] * taper->size[1];
        taper->size[0] = (int)win;
        taper->size[1] = x->size[1];
        emxEnsureCapacity_real_T(taper, i);
        a1_data = taper->data;
        loop_ub = x->size[1];
        for (i = 0; i < loop_ub; i++) {
          for (i2 = 0; i2 < pts; i2++) {
            a1_data[i2 + taper->size[0] * i] = vwindow_data[i];
          }
        }
        loop_ub = taper->size[0] * taper->size[1];
        i = vwindow->size[0] * vwindow->size[1];
        vwindow->size[0] = taper->size[0];
        vwindow->size[1] = taper->size[1];
        emxEnsureCapacity_real_T(vwindow, i);
        vwindow_data = vwindow->data;
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i] *= a1_data[i];
        }
      } else {
        f_binary_expand_op(vwindow, win, x);
      }
      var(wwindow, r11);
      a1_data = r11->data;
      if (wvar->size[1] == r11->size[1]) {
        i = x->size[0] * x->size[1];
        x->size[0] = 1;
        x->size[1] = wvar->size[1];
        emxEnsureCapacity_real_T(x, i);
        vwindow_data = x->data;
        loop_ub = wvar->size[1];
        for (i = 0; i < loop_ub; i++) {
          vwindow_data[i] = WW_data[i] / a1_data[i];
        }
      } else {
        g_binary_expand_op(x, wvar, r11);
        vwindow_data = x->data;
      }
      nx = x->size[1];
      for (k = 0; k < nx; k++) {
        vwindow_data[k] = sqrt(vwindow_data[k]);
      }
      i = taper->size[0] * taper->size[1];
      taper->size[0] = (int)win;
      taper->size[1] = x->size[1];
      emxEnsureCapacity_real_T(taper, i);
      a1_data = taper->data;
      loop_ub = x->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i2 = 0; i2 < pts; i2++) {
          a1_data[i2 + taper->size[0] * i] = vwindow_data[i];
        }
      }
      i = r14->size[0] * r14->size[1];
      r14->size[0] = (int)win;
      r14->size[1] = x->size[1];
      emxEnsureCapacity_real_T(r14, i);
      a1_data = r14->data;
      loop_ub = x->size[1];
      for (i = 0; i < loop_ub; i++) {
        for (i2 = 0; i2 < pts; i2++) {
          a1_data[i2 + r14->size[0] * i] = vwindow_data[i];
        }
      }
      if ((taper->size[0] == wwindow->size[0]) &&
          (r14->size[1] == wwindow->size[1])) {
        i = taper->size[0] * taper->size[1];
        taper->size[0] = (int)win;
        taper->size[1] = x->size[1];
        emxEnsureCapacity_real_T(taper, i);
        a1_data = taper->data;
        loop_ub = x->size[1];
        for (i = 0; i < loop_ub; i++) {
          for (i2 = 0; i2 < pts; i2++) {
            a1_data[i2 + taper->size[0] * i] = vwindow_data[i];
          }
        }
        loop_ub = taper->size[0] * taper->size[1];
        i = wwindow->size[0] * wwindow->size[1];
        wwindow->size[0] = taper->size[0];
        wwindow->size[1] = taper->size[1];
        emxEnsureCapacity_real_T(wwindow, i);
        wwindow_data = wwindow->data;
        for (i = 0; i < loop_ub; i++) {
          wwindow_data[i] *= a1_data[i];
        }
      } else {
        f_binary_expand_op(wwindow, win, x);
      }
      /*  FFT */
      /*  note convention for lower case as time-domain and upper case as freq
       * domain */
      /*  calculate Fourier coefs */
      fft(uwindow, UVwindowmerged);
      UVwindowmerged_data = UVwindowmerged->data;
      i = Uwindow->size[0] * Uwindow->size[1];
      Uwindow->size[0] = UVwindowmerged->size[0];
      Uwindow->size[1] = UVwindowmerged->size[1];
      emxEnsureCapacity_creal32_T(Uwindow, i);
      Uwindow_data = Uwindow->data;
      loop_ub = UVwindowmerged->size[0] * UVwindowmerged->size[1];
      for (i = 0; i < loop_ub; i++) {
        Uwindow_data[i].re = (float)UVwindowmerged_data[i].re;
        Uwindow_data[i].im = (float)UVwindowmerged_data[i].im;
      }
      fft(vwindow, UVwindowmerged);
      UVwindowmerged_data = UVwindowmerged->data;
      i = Vwindow->size[0] * Vwindow->size[1];
      Vwindow->size[0] = UVwindowmerged->size[0];
      Vwindow->size[1] = UVwindowmerged->size[1];
      emxEnsureCapacity_creal32_T(Vwindow, i);
      Vwindow_data = Vwindow->data;
      loop_ub = UVwindowmerged->size[0] * UVwindowmerged->size[1];
      for (i = 0; i < loop_ub; i++) {
        Vwindow_data[i].re = (float)UVwindowmerged_data[i].re;
        Vwindow_data[i].im = (float)UVwindowmerged_data[i].im;
      }
      fft(wwindow, UVwindowmerged);
      UVwindowmerged_data = UVwindowmerged->data;
      i = Wwindow->size[0] * Wwindow->size[1];
      Wwindow->size[0] = UVwindowmerged->size[0];
      Wwindow->size[1] = UVwindowmerged->size[1];
      emxEnsureCapacity_creal32_T(Wwindow, i);
      Wwindow_data = Wwindow->data;
      loop_ub = UVwindowmerged->size[0] * UVwindowmerged->size[1];
      for (i = 0; i < loop_ub; i++) {
        Wwindow_data[i].re = (float)UVwindowmerged_data[i].re;
        Wwindow_data[i].im = (float)UVwindowmerged_data[i].im;
      }
      /*  second half of fft is redundant, so throw it out */
      d = win / 2.0 + 1.0;
      i = Uwindow_tmp->size[0] * Uwindow_tmp->size[1];
      Uwindow_tmp->size[0] = 1;
      loop_ub = (int)(win - d);
      Uwindow_tmp->size[1] = loop_ub + 1;
      emxEnsureCapacity_int32_T(Uwindow_tmp, i);
      Uwindow_tmp_data = Uwindow_tmp->data;
      for (i = 0; i <= loop_ub; i++) {
        Uwindow_tmp_data[i] = (int)(d + (double)i);
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
        Uwindow_data[(nx + Uwindow->size[0] * i) - 1].re = 0.0F;
        Uwindow_data[(nx + Uwindow->size[0] * i) - 1].im = 0.0F;
      }
      loop_ub = Vwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        Vwindow_data[(nx + Vwindow->size[0] * i) - 1].re = 0.0F;
        Vwindow_data[(nx + Vwindow->size[0] * i) - 1].im = 0.0F;
      }
      loop_ub = Wwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        Wwindow_data[(nx + Wwindow->size[0] * i) - 1].re = 0.0F;
        Wwindow_data[(nx + Wwindow->size[0] * i) - 1].im = 0.0F;
      }
      /*  POWER SPECTRA (auto-spectra) */
      i = UUwindow->size[0] * UUwindow->size[1];
      UUwindow->size[0] = Uwindow->size[0];
      UUwindow->size[1] = Uwindow->size[1];
      emxEnsureCapacity_real32_T(UUwindow, i);
      north_data = UUwindow->data;
      loop_ub = Uwindow->size[0] * Uwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        north_data[i] = Uwindow_data[i].re * Uwindow_data[i].re -
                        Uwindow_data[i].im * -Uwindow_data[i].im;
      }
      i = VVwindow->size[0] * VVwindow->size[1];
      VVwindow->size[0] = Vwindow->size[0];
      VVwindow->size[1] = Vwindow->size[1];
      emxEnsureCapacity_real32_T(VVwindow, i);
      down_data = VVwindow->data;
      loop_ub = Vwindow->size[0] * Vwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        down_data[i] = Vwindow_data[i].re * Vwindow_data[i].re -
                       Vwindow_data[i].im * -Vwindow_data[i].im;
      }
      i = WWwindow->size[0] * WWwindow->size[1];
      WWwindow->size[0] = Wwindow->size[0];
      WWwindow->size[1] = Wwindow->size[1];
      emxEnsureCapacity_real32_T(WWwindow, i);
      filtereddata_data = WWwindow->data;
      loop_ub = Wwindow->size[0] * Wwindow->size[1];
      for (i = 0; i < loop_ub; i++) {
        filtereddata_data[i] = Wwindow_data[i].re * Wwindow_data[i].re -
                               Wwindow_data[i].im * -Wwindow_data[i].im;
      }
      /*  CROSS-SPECTRA  */
      if ((Uwindow->size[0] == Vwindow->size[0]) &&
          (Uwindow->size[1] == Vwindow->size[1])) {
        i = UVwindow->size[0] * UVwindow->size[1];
        UVwindow->size[0] = Uwindow->size[0];
        UVwindow->size[1] = Uwindow->size[1];
        emxEnsureCapacity_creal32_T(UVwindow, i);
        UVwindow_data = UVwindow->data;
        loop_ub = Uwindow->size[0] * Uwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          y = Vwindow_data[i].re;
          Vwindow_im = -Vwindow_data[i].im;
          UVwindow_data[i].re =
              Uwindow_data[i].re * y - Uwindow_data[i].im * Vwindow_im;
          UVwindow_data[i].im =
              Uwindow_data[i].re * Vwindow_im + Uwindow_data[i].im * y;
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
        emxEnsureCapacity_creal32_T(UWwindow, i);
        UWwindow_data = UWwindow->data;
        loop_ub = Uwindow->size[0] * Uwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          y = Wwindow_data[i].re;
          Vwindow_im = -Wwindow_data[i].im;
          UWwindow_data[i].re =
              Uwindow_data[i].re * y - Uwindow_data[i].im * Vwindow_im;
          UWwindow_data[i].im =
              Uwindow_data[i].re * Vwindow_im + Uwindow_data[i].im * y;
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
        emxEnsureCapacity_creal32_T(VWwindow, i);
        VWwindow_data = VWwindow->data;
        loop_ub = Vwindow->size[0] * Vwindow->size[1];
        for (i = 0; i < loop_ub; i++) {
          y = Wwindow_data[i].re;
          Vwindow_im = -Wwindow_data[i].im;
          VWwindow_data[i].re =
              Vwindow_data[i].re * y - Vwindow_data[i].im * Vwindow_im;
          VWwindow_data[i].im =
              Vwindow_data[i].re * Vwindow_im + Vwindow_data[i].im * y;
        }
      } else {
        e_binary_expand_op(VWwindow, Vwindow, Wwindow);
        VWwindow_data = VWwindow->data;
      }
      /*  merge neighboring freq bands (number of bands to merge is a fixed
       * parameter) */
      /*  initialize */
      b_Dp = floor(win / 6.0);
      i = uwindow->size[0] * uwindow->size[1];
      uwindow->size[0] = (int)b_Dp;
      uwindow->size[1] = windows;
      emxEnsureCapacity_real_T(uwindow, i);
      uwindow_data = uwindow->data;
      pts = (int)b_Dp * windows;
      for (i = 0; i < pts; i++) {
        uwindow_data[i] = 0.0;
      }
      i = vwindow->size[0] * vwindow->size[1];
      vwindow->size[0] = (int)b_Dp;
      vwindow->size[1] = windows;
      emxEnsureCapacity_real_T(vwindow, i);
      vwindow_data = vwindow->data;
      for (i = 0; i < pts; i++) {
        vwindow_data[i] = 0.0;
      }
      i = wwindow->size[0] * wwindow->size[1];
      wwindow->size[0] = (int)b_Dp;
      wwindow->size[1] = windows;
      emxEnsureCapacity_real_T(wwindow, i);
      wwindow_data = wwindow->data;
      for (i = 0; i < pts; i++) {
        wwindow_data[i] = 0.0;
      }
      i = UVwindowmerged->size[0] * UVwindowmerged->size[1];
      UVwindowmerged->size[0] = (int)b_Dp;
      UVwindowmerged->size[1] = windows;
      emxEnsureCapacity_creal_T(UVwindowmerged, i);
      UVwindowmerged_data = UVwindowmerged->data;
      for (i = 0; i < pts; i++) {
        UVwindowmerged_data[i].re = 0.0;
        UVwindowmerged_data[i].im = 1.0;
      }
      i = UWwindowmerged->size[0] * UWwindowmerged->size[1];
      UWwindowmerged->size[0] = (int)b_Dp;
      UWwindowmerged->size[1] = windows;
      emxEnsureCapacity_creal_T(UWwindowmerged, i);
      UWwindowmerged_data = UWwindowmerged->data;
      for (i = 0; i < pts; i++) {
        UWwindowmerged_data[i].re = 0.0;
        UWwindowmerged_data[i].im = 1.0;
      }
      i = VWwindowmerged->size[0] * VWwindowmerged->size[1];
      VWwindowmerged->size[0] = (int)b_Dp;
      VWwindowmerged->size[1] = windows;
      emxEnsureCapacity_creal_T(VWwindowmerged, i);
      VWwindowmerged_data = VWwindowmerged->data;
      for (i = 0; i < pts; i++) {
        VWwindowmerged_data[i].re = 0.0;
        VWwindowmerged_data[i].im = 1.0;
      }
      d = win / 2.0 / 3.0;
      i = (int)d;
      loop_ub = UUwindow->size[1];
      vlen = VVwindow->size[1];
      nx = WWwindow->size[1];
      pts = UVwindow->size[1];
      windows = UWwindow->size[1];
      k = VWwindow->size[1];
      for (mi = 0; mi < i; mi++) {
        int b_loop_ub;
        int i4;
        b_Dp = (double)mi * 3.0 + 3.0;
        if ((b_Dp - 3.0) + 1.0 > b_Dp) {
          i2 = 0;
          i3 = 0;
        } else {
          i2 = (int)((b_Dp - 3.0) + 1.0) - 1;
          i3 = (int)b_Dp;
        }
        i4 = (int)(b_Dp / 3.0) - 1;
        b_loop_ub = i3 - i2;
        i3 = b_UUwindow->size[0] * b_UUwindow->size[1];
        b_UUwindow->size[0] = b_loop_ub;
        b_UUwindow->size[1] = loop_ub;
        emxEnsureCapacity_real32_T(b_UUwindow, i3);
        east_data = b_UUwindow->data;
        for (i3 = 0; i3 < loop_ub; i3++) {
          for (i5 = 0; i5 < b_loop_ub; i5++) {
            east_data[i5 + b_UUwindow->size[0] * i3] =
                north_data[(i2 + i5) + UUwindow->size[0] * i3];
          }
        }
        mean(b_UUwindow, r12);
        east_data = r12->data;
        b_loop_ub = r12->size[1];
        for (i2 = 0; i2 < b_loop_ub; i2++) {
          uwindow_data[i4 + uwindow->size[0] * i2] = east_data[i2];
        }
        if ((b_Dp - 3.0) + 1.0 > b_Dp) {
          i2 = 0;
          i3 = 0;
        } else {
          i2 = (int)((b_Dp - 3.0) + 1.0) - 1;
          i3 = (int)b_Dp;
        }
        b_loop_ub = i3 - i2;
        i3 = b_UUwindow->size[0] * b_UUwindow->size[1];
        b_UUwindow->size[0] = b_loop_ub;
        b_UUwindow->size[1] = vlen;
        emxEnsureCapacity_real32_T(b_UUwindow, i3);
        east_data = b_UUwindow->data;
        for (i3 = 0; i3 < vlen; i3++) {
          for (i5 = 0; i5 < b_loop_ub; i5++) {
            east_data[i5 + b_UUwindow->size[0] * i3] =
                down_data[(i2 + i5) + VVwindow->size[0] * i3];
          }
        }
        mean(b_UUwindow, r12);
        east_data = r12->data;
        b_loop_ub = r12->size[1];
        for (i2 = 0; i2 < b_loop_ub; i2++) {
          vwindow_data[i4 + vwindow->size[0] * i2] = east_data[i2];
        }
        if ((b_Dp - 3.0) + 1.0 > b_Dp) {
          i2 = 0;
          i3 = 0;
        } else {
          i2 = (int)((b_Dp - 3.0) + 1.0) - 1;
          i3 = (int)b_Dp;
        }
        b_loop_ub = i3 - i2;
        i3 = b_UUwindow->size[0] * b_UUwindow->size[1];
        b_UUwindow->size[0] = b_loop_ub;
        b_UUwindow->size[1] = nx;
        emxEnsureCapacity_real32_T(b_UUwindow, i3);
        east_data = b_UUwindow->data;
        for (i3 = 0; i3 < nx; i3++) {
          for (i5 = 0; i5 < b_loop_ub; i5++) {
            east_data[i5 + b_UUwindow->size[0] * i3] =
                filtereddata_data[(i2 + i5) + WWwindow->size[0] * i3];
          }
        }
        mean(b_UUwindow, r12);
        east_data = r12->data;
        b_loop_ub = r12->size[1];
        for (i2 = 0; i2 < b_loop_ub; i2++) {
          wwindow_data[i4 + wwindow->size[0] * i2] = east_data[i2];
        }
        if ((b_Dp - 3.0) + 1.0 > b_Dp) {
          i2 = 0;
          i3 = 0;
        } else {
          i2 = (int)((b_Dp - 3.0) + 1.0) - 1;
          i3 = (int)b_Dp;
        }
        b_loop_ub = i3 - i2;
        i3 = b_UVwindow->size[0] * b_UVwindow->size[1];
        b_UVwindow->size[0] = b_loop_ub;
        b_UVwindow->size[1] = pts;
        emxEnsureCapacity_creal32_T(b_UVwindow, i3);
        Uwindow_data = b_UVwindow->data;
        for (i3 = 0; i3 < pts; i3++) {
          for (i5 = 0; i5 < b_loop_ub; i5++) {
            Uwindow_data[i5 + b_UVwindow->size[0] * i3] =
                UVwindow_data[(i2 + i5) + UVwindow->size[0] * i3];
          }
        }
        b_mean(b_UVwindow, r13);
        Uwindow_data = r13->data;
        b_loop_ub = r13->size[1];
        for (i2 = 0; i2 < b_loop_ub; i2++) {
          UVwindowmerged_data[i4 + UVwindowmerged->size[0] * i2].re =
              Uwindow_data[i2].re;
          UVwindowmerged_data[i4 + UVwindowmerged->size[0] * i2].im =
              Uwindow_data[i2].im;
        }
        if ((b_Dp - 3.0) + 1.0 > b_Dp) {
          i2 = 0;
          i3 = 0;
        } else {
          i2 = (int)((b_Dp - 3.0) + 1.0) - 1;
          i3 = (int)b_Dp;
        }
        b_loop_ub = i3 - i2;
        i3 = b_UVwindow->size[0] * b_UVwindow->size[1];
        b_UVwindow->size[0] = b_loop_ub;
        b_UVwindow->size[1] = windows;
        emxEnsureCapacity_creal32_T(b_UVwindow, i3);
        Uwindow_data = b_UVwindow->data;
        for (i3 = 0; i3 < windows; i3++) {
          for (i5 = 0; i5 < b_loop_ub; i5++) {
            Uwindow_data[i5 + b_UVwindow->size[0] * i3] =
                UWwindow_data[(i2 + i5) + UWwindow->size[0] * i3];
          }
        }
        b_mean(b_UVwindow, r13);
        Uwindow_data = r13->data;
        b_loop_ub = r13->size[1];
        for (i2 = 0; i2 < b_loop_ub; i2++) {
          UWwindowmerged_data[i4 + UWwindowmerged->size[0] * i2].re =
              Uwindow_data[i2].re;
          UWwindowmerged_data[i4 + UWwindowmerged->size[0] * i2].im =
              Uwindow_data[i2].im;
        }
        if ((b_Dp - 3.0) + 1.0 > b_Dp) {
          i2 = 0;
          i3 = 0;
        } else {
          i2 = (int)((b_Dp - 3.0) + 1.0) - 1;
          i3 = (int)b_Dp;
        }
        b_loop_ub = i3 - i2;
        i3 = b_UVwindow->size[0] * b_UVwindow->size[1];
        b_UVwindow->size[0] = b_loop_ub;
        b_UVwindow->size[1] = k;
        emxEnsureCapacity_creal32_T(b_UVwindow, i3);
        Uwindow_data = b_UVwindow->data;
        for (i3 = 0; i3 < k; i3++) {
          for (i5 = 0; i5 < b_loop_ub; i5++) {
            Uwindow_data[i5 + b_UVwindow->size[0] * i3] =
                VWwindow_data[(i2 + i5) + VWwindow->size[0] * i3];
          }
        }
        b_mean(b_UVwindow, r13);
        Uwindow_data = r13->data;
        b_loop_ub = r13->size[1];
        for (i2 = 0; i2 < b_loop_ub; i2++) {
          VWwindowmerged_data[i4 + VWwindowmerged->size[0] * i2].re =
              Uwindow_data[i2].re;
          VWwindowmerged_data[i4 + VWwindowmerged->size[0] * i2].im =
              Uwindow_data[i2].im;
        }
      }
      /*  freq range and bandwidth */
      /*  number of f bands */
      /*  highest spectral frequency  */
      bandwidth = 0.5 * fs / d;
      /*  freq (Hz) bandwitdh */
      /*  find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF
       * BANDS! */
      b_Dp = bandwidth / 2.0 + 0.00390625;
      i = f->size[0] * f->size[1];
      f->size[0] = 1;
      f->size[1] = (int)(d - 1.0) + 1;
      emxEnsureCapacity_real_T(f, i);
      f_data = f->data;
      loop_ub = (int)(d - 1.0);
      for (i = 0; i <= loop_ub; i++) {
        f_data[i] = b_Dp + bandwidth * (double)i;
      }
      /*  ensemble average windows together */
      /*  take the average of all windows at each freq-band */
      /*  and divide by N*samplerate to get power spectral density */
      /*  the two is b/c Matlab's fft output is the symmetric FFT,  */
      /*  and we did not use the redundant half (so need to multiply the psd by
       * 2) */
      b_Hs = win / 2.0 * fs;
      /*  prune high frequency results  */
      i = c_uwindow->size[0] * c_uwindow->size[1];
      c_uwindow->size[0] = uwindow->size[1];
      c_uwindow->size[1] = uwindow->size[0];
      emxEnsureCapacity_real_T(c_uwindow, i);
      a1_data = c_uwindow->data;
      loop_ub = uwindow->size[0];
      for (i = 0; i < loop_ub; i++) {
        vlen = uwindow->size[1];
        for (i2 = 0; i2 < vlen; i2++) {
          a1_data[i2 + c_uwindow->size[0] * i] =
              uwindow_data[i + uwindow->size[0] * i2];
        }
      }
      c_mean(c_uwindow, UU);
      i = UU->size[0] * UU->size[1];
      UU->size[0] = 1;
      emxEnsureCapacity_real_T(UU, i);
      UU_data = UU->data;
      loop_ub = UU->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        UU_data[i] /= b_Hs;
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
      c_nullAssignment(UU, b_f);
      UU_data = UU->data;
      i = c_uwindow->size[0] * c_uwindow->size[1];
      c_uwindow->size[0] = vwindow->size[1];
      c_uwindow->size[1] = vwindow->size[0];
      emxEnsureCapacity_real_T(c_uwindow, i);
      a1_data = c_uwindow->data;
      loop_ub = vwindow->size[0];
      for (i = 0; i < loop_ub; i++) {
        vlen = vwindow->size[1];
        for (i2 = 0; i2 < vlen; i2++) {
          a1_data[i2 + c_uwindow->size[0] * i] =
              vwindow_data[i + vwindow->size[0] * i2];
        }
      }
      c_mean(c_uwindow, b_E);
      i = b_E->size[0] * b_E->size[1];
      b_E->size[0] = 1;
      emxEnsureCapacity_real_T(b_E, i);
      E_data = b_E->data;
      loop_ub = b_E->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        E_data[i] /= b_Hs;
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
      c_nullAssignment(b_E, b_f);
      E_data = b_E->data;
      i = c_uwindow->size[0] * c_uwindow->size[1];
      c_uwindow->size[0] = wwindow->size[1];
      c_uwindow->size[1] = wwindow->size[0];
      emxEnsureCapacity_real_T(c_uwindow, i);
      a1_data = c_uwindow->data;
      loop_ub = wwindow->size[0];
      for (i = 0; i < loop_ub; i++) {
        vlen = wwindow->size[1];
        for (i2 = 0; i2 < vlen; i2++) {
          a1_data[i2 + c_uwindow->size[0] * i] =
              wwindow_data[i + wwindow->size[0] * i2];
        }
      }
      c_mean(c_uwindow, WW);
      i = WW->size[0] * WW->size[1];
      WW->size[0] = 1;
      emxEnsureCapacity_real_T(WW, i);
      WW_data = WW->data;
      loop_ub = WW->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        WW_data[i] /= b_Hs;
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
      c_nullAssignment(WW, b_f);
      WW_data = WW->data;
      i = b_UVwindowmerged->size[0] * b_UVwindowmerged->size[1];
      b_UVwindowmerged->size[0] = UVwindowmerged->size[1];
      b_UVwindowmerged->size[1] = UVwindowmerged->size[0];
      emxEnsureCapacity_creal_T(b_UVwindowmerged, i);
      b_UVwindowmerged_data = b_UVwindowmerged->data;
      loop_ub = UVwindowmerged->size[0];
      for (i = 0; i < loop_ub; i++) {
        vlen = UVwindowmerged->size[1];
        for (i2 = 0; i2 < vlen; i2++) {
          b_UVwindowmerged_data[i2 + b_UVwindowmerged->size[0] * i] =
              UVwindowmerged_data[i + UVwindowmerged->size[0] * i2];
        }
      }
      d_mean(b_UVwindowmerged, UV);
      i = UV->size[0] * UV->size[1];
      UV->size[0] = 1;
      emxEnsureCapacity_creal_T(UV, i);
      UV_data = UV->data;
      loop_ub = UV->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        b_Dp = UV_data[i].re;
        b_Tp = UV_data[i].im;
        if (b_Tp == 0.0) {
          win = b_Dp / b_Hs;
          b_Dp = 0.0;
        } else if (b_Dp == 0.0) {
          win = 0.0;
          b_Dp = b_Tp / b_Hs;
        } else {
          win = b_Dp / b_Hs;
          b_Dp = b_Tp / b_Hs;
        }
        UV_data[i].re = win;
        UV_data[i].im = b_Dp;
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
      i = b_UVwindowmerged->size[0] * b_UVwindowmerged->size[1];
      b_UVwindowmerged->size[0] = UWwindowmerged->size[1];
      b_UVwindowmerged->size[1] = UWwindowmerged->size[0];
      emxEnsureCapacity_creal_T(b_UVwindowmerged, i);
      b_UVwindowmerged_data = b_UVwindowmerged->data;
      loop_ub = UWwindowmerged->size[0];
      for (i = 0; i < loop_ub; i++) {
        vlen = UWwindowmerged->size[1];
        for (i2 = 0; i2 < vlen; i2++) {
          b_UVwindowmerged_data[i2 + b_UVwindowmerged->size[0] * i] =
              UWwindowmerged_data[i + UWwindowmerged->size[0] * i2];
        }
      }
      d_mean(b_UVwindowmerged, UW);
      i = UW->size[0] * UW->size[1];
      UW->size[0] = 1;
      emxEnsureCapacity_creal_T(UW, i);
      UWwindowmerged_data = UW->data;
      loop_ub = UW->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        b_Dp = UWwindowmerged_data[i].re;
        b_Tp = UWwindowmerged_data[i].im;
        if (b_Tp == 0.0) {
          win = b_Dp / b_Hs;
          b_Dp = 0.0;
        } else if (b_Dp == 0.0) {
          win = 0.0;
          b_Dp = b_Tp / b_Hs;
        } else {
          win = b_Dp / b_Hs;
          b_Dp = b_Tp / b_Hs;
        }
        UWwindowmerged_data[i].re = win;
        UWwindowmerged_data[i].im = b_Dp;
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
      UWwindowmerged_data = UW->data;
      i = b_UVwindowmerged->size[0] * b_UVwindowmerged->size[1];
      b_UVwindowmerged->size[0] = VWwindowmerged->size[1];
      b_UVwindowmerged->size[1] = VWwindowmerged->size[0];
      emxEnsureCapacity_creal_T(b_UVwindowmerged, i);
      b_UVwindowmerged_data = b_UVwindowmerged->data;
      loop_ub = VWwindowmerged->size[0];
      for (i = 0; i < loop_ub; i++) {
        vlen = VWwindowmerged->size[1];
        for (i2 = 0; i2 < vlen; i2++) {
          b_UVwindowmerged_data[i2 + b_UVwindowmerged->size[0] * i] =
              VWwindowmerged_data[i + VWwindowmerged->size[0] * i2];
        }
      }
      d_mean(b_UVwindowmerged, VW);
      i = VW->size[0] * VW->size[1];
      VW->size[0] = 1;
      emxEnsureCapacity_creal_T(VW, i);
      UVwindowmerged_data = VW->data;
      loop_ub = VW->size[1] - 1;
      for (i = 0; i <= loop_ub; i++) {
        b_Dp = UVwindowmerged_data[i].re;
        b_Tp = UVwindowmerged_data[i].im;
        if (b_Tp == 0.0) {
          win = b_Dp / b_Hs;
          b_Dp = 0.0;
        } else if (b_Dp == 0.0) {
          win = 0.0;
          b_Dp = b_Tp / b_Hs;
        } else {
          win = b_Dp / b_Hs;
          b_Dp = b_Tp / b_Hs;
        }
        UVwindowmerged_data[i].re = win;
        UVwindowmerged_data[i].im = b_Dp;
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
      UVwindowmerged_data = VW->data;
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
      if (UU->size[1] == b_E->size[1]) {
        i = b_y->size[0] * b_y->size[1];
        b_y->size[0] = 1;
        b_y->size[1] = UU->size[1];
        emxEnsureCapacity_real_T(b_y, i);
        uwindow_data = b_y->data;
        loop_ub = UU->size[1];
        for (i = 0; i < loop_ub; i++) {
          uwindow_data[i] = UU_data[i] + E_data[i];
        }
      } else {
        plus(b_y, UU, b_E);
        uwindow_data = b_y->data;
      }
      if (b_y->size[1] == WW->size[1]) {
        i = b_b1->size[0] * b_b1->size[1];
        b_b1->size[0] = 1;
        b_b1->size[1] = b_y->size[1];
        emxEnsureCapacity_real_T(b_b1, i);
        b1_data = b_b1->data;
        loop_ub = b_y->size[1];
        for (i = 0; i < loop_ub; i++) {
          b1_data[i] = uwindow_data[i] * WW_data[i];
        }
      } else {
        times(b_b1, b_y, WW);
        b1_data = b_b1->data;
      }
      nx = b_b1->size[1];
      for (k = 0; k < nx; k++) {
        b1_data[k] = sqrt(b1_data[k]);
      }
      if (UW->size[1] == b_b1->size[1]) {
        i = b_a1->size[0] * b_a1->size[1];
        b_a1->size[0] = 1;
        b_a1->size[1] = UW->size[1];
        emxEnsureCapacity_real_T(b_a1, i);
        a1_data = b_a1->data;
        loop_ub = UW->size[1];
        for (i = 0; i < loop_ub; i++) {
          a1_data[i] = UWwindowmerged_data[i].im / b1_data[i];
        }
      } else {
        d_binary_expand_op(b_a1, UW, b_b1);
        a1_data = b_a1->data;
      }
      if (VW->size[1] == b_b1->size[1]) {
        loop_ub = VW->size[1] - 1;
        i = b_b1->size[0] * b_b1->size[1];
        b_b1->size[0] = 1;
        b_b1->size[1] = VW->size[1];
        emxEnsureCapacity_real_T(b_b1, i);
        b1_data = b_b1->data;
        for (i = 0; i <= loop_ub; i++) {
          b1_data[i] = UVwindowmerged_data[i].im / b1_data[i];
        }
      } else {
        c_binary_expand_op(b_b1, VW);
        b1_data = b_b1->data;
      }
      if (UU->size[1] == 1) {
        loop_ub = b_E->size[1];
      } else {
        loop_ub = UU->size[1];
      }
      if ((UU->size[1] == b_E->size[1]) && (loop_ub == b_y->size[1])) {
        loop_ub = UU->size[1] - 1;
        i = UU->size[0] * UU->size[1];
        UU->size[0] = 1;
        emxEnsureCapacity_real_T(UU, i);
        UU_data = UU->data;
        for (i = 0; i <= loop_ub; i++) {
          UU_data[i] = (UU_data[i] - E_data[i]) / uwindow_data[i];
        }
      } else {
        b_binary_expand_op(UU, b_E, b_y);
        UU_data = UU->data;
      }
      if (UV->size[1] == b_y->size[1]) {
        i = b_b2->size[0] * b_b2->size[1];
        b_b2->size[0] = 1;
        b_b2->size[1] = UV->size[1];
        emxEnsureCapacity_real_T(b_b2, i);
        b2_data = b_b2->data;
        loop_ub = UV->size[1];
        for (i = 0; i < loop_ub; i++) {
          b2_data[i] = 2.0 * UV_data[i].re / uwindow_data[i];
        }
      } else {
        binary_expand_op(b_b2, UV, b_y);
        b2_data = b_b2->data;
      }
      /*  Scalar energy spectra (a0) */
      i = b_E->size[0] * b_E->size[1];
      b_E->size[0] = 1;
      b_E->size[1] = f->size[1];
      emxEnsureCapacity_real_T(b_E, i);
      E_data = b_E->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        b_Dp = 6.2831853071795862 * f_data[i];
        E_data[i] = b_Dp * b_Dp;
      }
      if (b_y->size[1] == b_E->size[1]) {
        loop_ub = b_y->size[1] - 1;
        i = b_E->size[0] * b_E->size[1];
        b_E->size[0] = 1;
        b_E->size[1] = b_y->size[1];
        emxEnsureCapacity_real_T(b_E, i);
        E_data = b_E->data;
        for (i = 0; i <= loop_ub; i++) {
          E_data[i] = uwindow_data[i] / E_data[i];
        }
      } else {
        b_rdivide(b_E, b_y);
        E_data = b_E->data;
      }
      /*  assumes perfectly circular deepwater orbits */
      /*  E = ( WW ) ./ ( (2*pi*f).^2 ); % arbitrary depth, but more noise? */
      /*  use orbit shape as check on quality (=1 in deep water) */
      if (WW->size[1] == b_y->size[1]) {
        loop_ub = WW->size[1] - 1;
        i = WW->size[0] * WW->size[1];
        WW->size[0] = 1;
        emxEnsureCapacity_real_T(WW, i);
        WW_data = WW->data;
        for (i = 0; i <= loop_ub; i++) {
          WW_data[i] /= uwindow_data[i];
        }
      } else {
        rdivide(WW, b_y);
        WW_data = WW->data;
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
      r15 = r7->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        r15[i] = (f_data[i] < 0.5);
      }
      /*  frequency cutoff for wave stats, 0.4 is specific to SWIFT hull */
      pts = b_f->size[1];
      for (windows = 0; windows < pts; windows++) {
        if ((!bad_data[windows]) || (!r15[windows])) {
          E_data[windows] = 0.0;
        }
      }
      /*  significant wave height */
      pts = b_f->size[1] - 1;
      vlen = 0;
      for (windows = 0; windows <= pts; windows++) {
        if (bad_data[windows] && r15[windows]) {
          vlen++;
        }
      }
      i = r8->size[0] * r8->size[1];
      r8->size[0] = 1;
      r8->size[1] = vlen;
      emxEnsureCapacity_int32_T(r8, i);
      Uwindow_tmp_data = r8->data;
      nx = 0;
      for (windows = 0; windows <= pts; windows++) {
        if (bad_data[windows] && r15[windows]) {
          Uwindow_tmp_data[nx] = windows + 1;
          nx++;
        }
      }
      i = x->size[0] * x->size[1];
      x->size[0] = 1;
      x->size[1] = r8->size[1];
      emxEnsureCapacity_real_T(x, i);
      vwindow_data = x->data;
      loop_ub = r8->size[1];
      for (i = 0; i < loop_ub; i++) {
        vwindow_data[i] = E_data[Uwindow_tmp_data[i] - 1];
      }
      b_Hs = 4.0 * sqrt(sum(x) * bandwidth);
      /*   energy period */
      pts = b_f->size[1] - 1;
      vlen = 0;
      for (windows = 0; windows <= pts; windows++) {
        if (bad_data[windows] && r15[windows]) {
          vlen++;
        }
      }
      i = r9->size[0] * r9->size[1];
      r9->size[0] = 1;
      r9->size[1] = vlen;
      emxEnsureCapacity_int32_T(r9, i);
      Uwindow_tmp_data = r9->data;
      nx = 0;
      for (windows = 0; windows <= pts; windows++) {
        if (bad_data[windows] && r15[windows]) {
          Uwindow_tmp_data[nx] = windows + 1;
          nx++;
        }
      }
      i = b_y->size[0] * b_y->size[1];
      b_y->size[0] = 1;
      b_y->size[1] = r9->size[1];
      emxEnsureCapacity_real_T(b_y, i);
      uwindow_data = b_y->data;
      loop_ub = r9->size[1];
      for (i = 0; i < loop_ub; i++) {
        i2 = Uwindow_tmp_data[i];
        uwindow_data[i] = f_data[i2 - 1] * E_data[i2 - 1];
      }
      i = x->size[0] * x->size[1];
      x->size[0] = 1;
      x->size[1] = r9->size[1];
      emxEnsureCapacity_real_T(x, i);
      vwindow_data = x->data;
      loop_ub = r9->size[1];
      for (i = 0; i < loop_ub; i++) {
        vwindow_data[i] = E_data[Uwindow_tmp_data[i] - 1];
      }
      win = sum(b_y) / sum(x);
      i = x->size[0] * x->size[1];
      x->size[0] = 1;
      x->size[1] = f->size[1];
      emxEnsureCapacity_real_T(x, i);
      vwindow_data = x->data;
      loop_ub = f->size[1];
      for (i = 0; i < loop_ub; i++) {
        vwindow_data[i] = f_data[i] - win;
      }
      nx = x->size[1];
      i = b_y->size[0] * b_y->size[1];
      b_y->size[0] = 1;
      b_y->size[1] = x->size[1];
      emxEnsureCapacity_real_T(b_y, i);
      uwindow_data = b_y->data;
      for (k = 0; k < nx; k++) {
        uwindow_data[k] = fabs(vwindow_data[k]);
      }
      minimum(b_y, &b_Dp, &nx);
      /*  peak period */
      /* [~ , fpindex] = max(UU+VV); % can use velocity (picks out more distint
       * peak) */
      maximum(b_E, &b_Dp, &vlen);
      b_Tp = 1.0 / f_data[vlen - 1];
      if (b_Tp > 18.0) {
        /*  if peak not found, use centroid */
        b_Tp = 1.0 / win;
        vlen = nx;
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
      b_Dp = -57.324840764331206 *
                 rt_atan2d_snf(b1_data[vlen - 1], a1_data[vlen - 1]) +
             90.0;
      /*  rotate from eastward = 0 to northward  = 0 */
      if (b_Dp < 0.0) {
        b_Dp += 360.0;
      }
      /*  take NW quadrant from negative to 270-360 range */
      if (b_Dp > 180.0) {
        b_Dp -= 180.0;
      }
      /*  take reciprocal such wave direction is FROM, not TOWARDS */
      if (b_Dp < 180.0) {
        b_Dp += 180.0;
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
    b_Hs = 9999.0;
    b_Tp = 9999.0;
    b_Dp = 9999.0;
    i = b_E->size[0] * b_E->size[1];
    b_E->size[0] = 1;
    b_E->size[1] = 1;
    emxEnsureCapacity_real_T(b_E, i);
    E_data = b_E->data;
    E_data[0] = 9999.0;
    i = f->size[0] * f->size[1];
    f->size[0] = 1;
    f->size[1] = 1;
    emxEnsureCapacity_real_T(f, i);
    f_data = f->data;
    f_data[0] = 9999.0;
    i = b_a1->size[0] * b_a1->size[1];
    b_a1->size[0] = 1;
    b_a1->size[1] = 1;
    emxEnsureCapacity_real_T(b_a1, i);
    a1_data = b_a1->data;
    a1_data[0] = 9999.0;
    i = b_b1->size[0] * b_b1->size[1];
    b_b1->size[0] = 1;
    b_b1->size[1] = 1;
    emxEnsureCapacity_real_T(b_b1, i);
    b1_data = b_b1->data;
    b1_data[0] = 9999.0;
    i = UU->size[0] * UU->size[1];
    UU->size[0] = 1;
    UU->size[1] = 1;
    emxEnsureCapacity_real_T(UU, i);
    UU_data = UU->data;
    UU_data[0] = 9999.0;
    i = b_b2->size[0] * b_b2->size[1];
    b_b2->size[0] = 1;
    b_b2->size[1] = 1;
    emxEnsureCapacity_real_T(b_b2, i);
    b2_data = b_b2->data;
    b2_data[0] = 9999.0;
    i = WW->size[0] * WW->size[1];
    WW->size[0] = 1;
    WW->size[1] = 1;
    emxEnsureCapacity_real_T(WW, i);
    WW_data = WW->data;
    WW_data[0] = 9999.0;
  }
  emxFree_creal_T(&b_UVwindowmerged);
  emxFree_creal32_T(&b_UVwindow);
  emxFree_boolean_T(&b_f);
  emxFree_real_T(&c_uwindow);
  emxFree_real32_T(&b_UUwindow);
  emxFree_real_T(&b_uwindow);
  emxFree_real_T(&r14);
  emxFree_creal32_T(&r13);
  emxFree_real32_T(&r12);
  emxFree_real_T(&r11);
  emxFree_real_T(&x);
  emxFree_real_T(&b_y);
  emxFree_int32_T(&Uwindow_tmp);
  emxFree_real_T(&r10);
  emxFree_int32_T(&r9);
  emxFree_int32_T(&r8);
  emxFree_boolean_T(&r7);
  emxFree_creal_T(&VW);
  emxFree_creal_T(&UW);
  emxFree_creal_T(&UV);
  emxFree_creal_T(&VWwindowmerged);
  emxFree_creal_T(&UWwindowmerged);
  emxFree_creal_T(&UVwindowmerged);
  emxFree_creal32_T(&VWwindow);
  emxFree_creal32_T(&UWwindow);
  emxFree_creal32_T(&UVwindow);
  emxFree_real32_T(&WWwindow);
  emxFree_real32_T(&VVwindow);
  emxFree_real32_T(&UUwindow);
  emxFree_creal32_T(&Wwindow);
  emxFree_creal32_T(&Vwindow);
  emxFree_creal32_T(&Uwindow);
  emxFree_real_T(&taper);
  emxFree_real_T(&wvar);
  emxFree_real_T(&vvar);
  emxFree_real_T(&uvar);
  emxFree_real_T(&wwindow);
  emxFree_real_T(&vwindow);
  emxFree_real_T(&uwindow);
  emxFree_real32_T(&filtereddata);
  emxFree_boolean_T(&bad);
  /*  quality control for excessive low frequency problems */
  if (b_Tp > 20.0) {
    b_Hs = 9999.0;
    b_Tp = 9999.0;
    b_Dp = 9999.0;
  }
  /*  format for microSWIFT telemetry output (payload type 52) */
  i = E->size[0] * E->size[1];
  E->size[0] = 1;
  E->size[1] = b_E->size[1];
  emxEnsureCapacity_real16_T(E, i);
  b_E_data = E->data;
  loop_ub = b_E->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_E_data[i] = doubleToHalf(E_data[i]);
  }
  emxFree_real_T(&b_E);
  *b_fmin = doubleToHalf(b_minimum(f));
  *b_fmax = doubleToHalf(b_maximum(f));
  i = a1->size[0] * a1->size[1];
  a1->size[0] = 1;
  a1->size[1] = b_a1->size[1];
  emxEnsureCapacity_int8_T(a1, i);
  b_a1_data = a1->data;
  loop_ub = b_a1->size[1];
  emxFree_real_T(&f);
  for (i = 0; i < loop_ub; i++) {
    d = rt_roundd_snf(a1_data[i] * 100.0);
    if (d < 128.0) {
      if (d >= -128.0) {
        i1 = (signed char)d;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (d >= 128.0) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    b_a1_data[i] = i1;
  }
  emxFree_real_T(&b_a1);
  i = b1->size[0] * b1->size[1];
  b1->size[0] = 1;
  b1->size[1] = b_b1->size[1];
  emxEnsureCapacity_int8_T(b1, i);
  b_a1_data = b1->data;
  loop_ub = b_b1->size[1];
  for (i = 0; i < loop_ub; i++) {
    d = rt_roundd_snf(b1_data[i] * 100.0);
    if (d < 128.0) {
      if (d >= -128.0) {
        i1 = (signed char)d;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (d >= 128.0) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    b_a1_data[i] = i1;
  }
  emxFree_real_T(&b_b1);
  i = a2->size[0] * a2->size[1];
  a2->size[0] = 1;
  a2->size[1] = UU->size[1];
  emxEnsureCapacity_int8_T(a2, i);
  b_a1_data = a2->data;
  loop_ub = UU->size[1];
  for (i = 0; i < loop_ub; i++) {
    d = rt_roundd_snf(UU_data[i] * 100.0);
    if (d < 128.0) {
      if (d >= -128.0) {
        i1 = (signed char)d;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (d >= 128.0) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    b_a1_data[i] = i1;
  }
  emxFree_real_T(&UU);
  i = b2->size[0] * b2->size[1];
  b2->size[0] = 1;
  b2->size[1] = b_b2->size[1];
  emxEnsureCapacity_int8_T(b2, i);
  b_a1_data = b2->data;
  loop_ub = b_b2->size[1];
  for (i = 0; i < loop_ub; i++) {
    d = rt_roundd_snf(b2_data[i] * 100.0);
    if (d < 128.0) {
      if (d >= -128.0) {
        i1 = (signed char)d;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (d >= 128.0) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    b_a1_data[i] = i1;
  }
  emxFree_real_T(&b_b2);
  i = check->size[0] * check->size[1];
  check->size[0] = 1;
  check->size[1] = WW->size[1];
  emxEnsureCapacity_uint8_T(check, i);
  check_data = check->data;
  loop_ub = WW->size[1];
  for (i = 0; i < loop_ub; i++) {
    unsigned char u;
    d = rt_roundd_snf(WW_data[i] * 10.0);
    if (d < 256.0) {
      if (d >= 0.0) {
        u = (unsigned char)d;
      } else {
        u = 0U;
      }
    } else if (d >= 256.0) {
      u = MAX_uint8_T;
    } else {
      u = 0U;
    }
    check_data[i] = u;
  }
  emxFree_real_T(&WW);
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
  *Hs = doubleToHalf(b_Hs);
  *Tp = doubleToHalf(b_Tp);
  *Dp = doubleToHalf(b_Dp);
}

/*
 * File trailer for NEDwaves.c
 *
 * [EOF]
 */
