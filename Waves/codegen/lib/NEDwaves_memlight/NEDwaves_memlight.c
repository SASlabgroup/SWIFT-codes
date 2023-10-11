/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves_memlight.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 10-Oct-2023 20:23:55
 */

/* Include Files */
#include "NEDwaves_memlight.h"
#include "NEDwaves_memlight_data.h"
#include "NEDwaves_memlight_emxutil.h"
#include "NEDwaves_memlight_types.h"
#include "combineVectorElements.h"
#include "div.h"
#include "fft.h"
#include "linspace.h"
#include "mean.h"
#include "minOrMax.h"
#include "nullAssignment.h"
#include "rt_nonfinite.h"
#include "rtwhalf.h"
#include "std.h"
#include "var.h"
#include "rt_defines.h"
#include "rt_nonfinite.h"
#include <float.h>
#include <math.h>
#include <string.h>

/* Function Declarations */
static void b_binary_expand_op(emxArray_real32_T *in1,
                               const emxArray_real_T *in2);

static void binary_expand_op(emxArray_real32_T *in1,
                             const emxArray_real32_T *in2,
                             const emxArray_real_T *in3);

static float rt_atan2f_snf(float u0, float u1);

static double rt_remd_snf(double u0, double u1);

static double rt_roundd_snf(double u);

/* Function Definitions */
/*
 * Arguments    : emxArray_real32_T *in1
 *                const emxArray_real_T *in2
 * Return Type  : void
 */
static void b_binary_expand_op(emxArray_real32_T *in1,
                               const emxArray_real_T *in2)
{
  emxArray_real32_T *b_in1;
  const double *in2_data;
  float *b_in1_data;
  float *in1_data;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emxInit_real32_T(&b_in1, 2);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = 1;
  if (in2->size[1] == 1) {
    b_in1->size[1] = in1->size[1];
  } else {
    b_in1->size[1] = in2->size[1];
  }
  emxEnsureCapacity_real32_T(b_in1, i);
  b_in1_data = b_in1->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in2->size[1] != 1);
  if (in2->size[1] == 1) {
    loop_ub = in1->size[1];
  } else {
    loop_ub = in2->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = in1_data[i * stride_0_1] * (float)in2_data[i * stride_1_1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real32_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real32_T(&b_in1);
}

/*
 * Arguments    : emxArray_real32_T *in1
 *                const emxArray_real32_T *in2
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
static void binary_expand_op(emxArray_real32_T *in1,
                             const emxArray_real32_T *in2,
                             const emxArray_real_T *in3)
{
  const double *in3_data;
  const float *in2_data;
  float *in1_data;
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
  emxEnsureCapacity_real32_T(in1, i);
  in1_data = in1->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  if (in3->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = in2_data[i * stride_0_1] * (float)in3_data[i * stride_1_1];
  }
}

/*
 * Arguments    : float u0
 *                float u1
 * Return Type  : float
 */
static float rt_atan2f_snf(float u0, float u1)
{
  float y;
  if (rtIsNaNF(u0) || rtIsNaNF(u1)) {
    y = rtNaNF;
  } else if (rtIsInfF(u0) && rtIsInfF(u1)) {
    int b_u0;
    int b_u1;
    if (u0 > 0.0F) {
      b_u0 = 1;
    } else {
      b_u0 = -1;
    }
    if (u1 > 0.0F) {
      b_u1 = 1;
    } else {
      b_u1 = -1;
    }
    y = atan2f((float)b_u0, (float)b_u1);
  } else if (u1 == 0.0F) {
    if (u0 > 0.0F) {
      y = RT_PIF / 2.0F;
    } else if (u0 < 0.0F) {
      y = -(RT_PIF / 2.0F);
    } else {
      y = 0.0F;
    }
  } else {
    y = atan2f(u0, u1);
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
 * NEDwaves_memlight(north,east,down,fs);
 *
 *  note that outputs are slightly different than other wave codes
 *  b/c this matches the half-float precision format of telemetry type 52
 *  and only uses frequency limits, not full f array
 *
 *  J. Thomson,  12/2022 (modified from GPSwaves)
 *
 *               1/2023 memory light version... removes filtering, windowing,etc
 *                        assumes input data is clean and ready
 *
 *               6/2023 put windowing back in (as for loop that over-writes)
 *                    abandon convention that upper cases is in frequency domain
 *
 *               9/2023 reverse convention for wave direction and filter twice
 *
 *               10/2023 fix major bug introduced at 6/2023 wherein raw fft
 *               coefficients where merged across neighbor frequencies before
 *               calculating auto and cross spectra (i.e., averaging before
 *               applying a nonlinear operator)
 *
 *               10/2023 reintroduce simply despiking
 *
 *
 * Arguments    : emxArray_real32_T *north
 *                emxArray_real32_T *east
 *                emxArray_real32_T *down
 *                double fs
 *                real16_T *Hs
 *                real16_T *Tp
 *                real16_T *Dp
 *                real16_T E[42]
 *                real16_T *b_fmin
 *                real16_T *b_fmax
 *                signed char a1[42]
 *                signed char b1[42]
 *                signed char a2[42]
 *                signed char b2[42]
 *                unsigned char check[42]
 * Return Type  : void
 */
void NEDwaves_memlight(emxArray_real32_T *north, emxArray_real32_T *east,
                       emxArray_real32_T *down, double fs, real16_T *Hs,
                       real16_T *Tp, real16_T *Dp, real16_T E[42],
                       real16_T *b_fmin, real16_T *b_fmax, signed char a1[42],
                       signed char b1[42], signed char a2[42],
                       signed char b2[42], unsigned char check[42])
{
  emxArray_boolean_T *bad;
  emxArray_creal32_T *UVwindow;
  emxArray_creal32_T *UWwindow;
  emxArray_creal32_T *b_u;
  emxArray_creal32_T *b_v;
  emxArray_creal32_T *b_w;
  emxArray_int32_T *r;
  emxArray_int32_T *r10;
  emxArray_int32_T *r11;
  emxArray_int32_T *r12;
  emxArray_int32_T *r13;
  emxArray_int32_T *r14;
  emxArray_int32_T *r15;
  emxArray_int32_T *r2;
  emxArray_int32_T *r4;
  emxArray_int32_T *r5;
  emxArray_int32_T *r6;
  emxArray_int32_T *r7;
  emxArray_int32_T *r8;
  emxArray_int32_T *r9;
  emxArray_real32_T *c_u;
  emxArray_real32_T *filtereddata;
  emxArray_real32_T *u;
  emxArray_real32_T *v;
  emxArray_real32_T *w;
  emxArray_real_T *f;
  emxArray_real_T *rawf;
  emxArray_real_T *taper;
  emxArray_real_T *u_tmp;
  creal32_T UV[42];
  creal32_T UW[42];
  creal32_T VW[42];
  creal32_T *UVwindow_data;
  creal32_T *UWwindow_data;
  creal32_T *b_u_data;
  creal32_T *b_v_data;
  creal32_T *b_w_data;
  double Nyquist;
  double alpha;
  double bandwidth;
  double d;
  double d1;
  double n;
  double rawf_tmp;
  double windows;
  double wpts;
  double y;
  double y_tmp;
  double *f_data;
  double *rawf_data;
  double *taper_data;
  float UU[42];
  float VV[42];
  float WW[42];
  float b_E[42];
  float b_a1[42];
  float b_b1[42];
  float y_tmp_tmp[42];
  float fe;
  float u_re;
  float u_re_tmp;
  float v_re;
  float w_im;
  float w_re;
  float x;
  float *down_data;
  float *east_data;
  float *filtereddata_data;
  float *north_data;
  float *u_data;
  float *v_data;
  float *w_data;
  int b_end;
  int b_i;
  int c_end;
  int d_end;
  int e_end;
  int end;
  int f_end;
  int fpindex;
  int i;
  int i1;
  int i2;
  int i4;
  int loop_ub;
  int loop_ub_tmp;
  int mi;
  int nx;
  int q;
  int *r1;
  int *r3;
  bool *bad_data;
  down_data = down->data;
  east_data = east->data;
  north_data = north->data;
  /*  parameters */
  /*  length of the input data (should be 2^N for efficiency) */
  /*  number of standard deviations to identify spikes */
  /*  time constant [s] for high-pass filter (pass T < 2 pi * RC) */
  /*  window length in seconds, should make 2^N samples is fs is even */
  /*  freq bands to merge, must be odd? */
  /*  frequency cutoff for telemetry Hz */
  wpts = rt_roundd_snf(fs * 256.0);
  /*  window length in data points */
  if (rt_remd_snf(wpts, 2.0) != 0.0) {
    wpts--;
  }
  emxInit_real_T(&rawf, 2);
  emxInit_real_T(&f, 2);
  /*  make wpts an even number */
  windows = floor(4.0 * ((double)east->size[1] / wpts - 1.0) + 1.0);
  /*  number of windows, the 4 comes from a 75% overlap */
  /* dof = 2*windows*merge; % degrees of freedom */
  /*  frequency resolution */
  Nyquist = fs / 2.0;
  /*  highest spectral frequency */
  /*  frequency resolution */
  rawf_tmp = rt_roundd_snf(wpts / 2.0);
  linspace(1.0 / (wpts / fs), Nyquist, rawf_tmp, rawf);
  rawf_data = rawf->data;
  /*  raw frequency bands */
  n = wpts / 2.0 / 3.0;
  /*  number of f bands after merging */
  bandwidth = Nyquist / n;
  /*  freq (Hz) bandwitdh after merging */
  /*  find middle of each merged freq band, to make the final frequency vector
   */
  /*  using the middle ONLY WORKS WHEN MERGING ODD NUMBER OF BANDS! */
  if (rtIsNaN(n - 1.0)) {
    i = f->size[0] * f->size[1];
    f->size[0] = 1;
    f->size[1] = 1;
    emxEnsureCapacity_real_T(f, i);
    f_data = f->data;
    f_data[0] = rtNaN;
  } else if (n - 1.0 < 0.0) {
    f->size[1] = 0;
  } else {
    i = f->size[0] * f->size[1];
    f->size[0] = 1;
    f->size[1] = (int)(n - 1.0) + 1;
    emxEnsureCapacity_real_T(f, i);
    f_data = f->data;
    fpindex = (int)(n - 1.0);
    for (i = 0; i <= fpindex; i++) {
      f_data[i] = i;
    }
  }
  i = f->size[0] * f->size[1];
  f->size[0] = 1;
  emxEnsureCapacity_real_T(f, i);
  f_data = f->data;
  Nyquist = bandwidth / 2.0 + 0.00390625;
  fpindex = f->size[1] - 1;
  for (i = 0; i <= fpindex; i++) {
    f_data[i] = Nyquist + bandwidth * f_data[i];
  }
  emxInit_boolean_T(&bad);
  i = bad->size[0] * bad->size[1];
  bad->size[0] = 1;
  bad->size[1] = f->size[1];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  fpindex = f->size[1];
  for (i = 0; i < fpindex; i++) {
    bad_data[i] = (f_data[i] > 0.5);
  }
  nullAssignment(f, bad);
  f_data = f->data;
  /*  should end up with length(f) = 42 with maxf=0.5, merge=3, and wsecs = 256
   */
  /*  initialize spectral ouput, which will accumulate as windows are processed
   */
  /*  length will only be 42 if wsecs = 256, merge = 3, maxf = 0.5 (params
   * above) */
  memset(&UU[0], 0, 42U * sizeof(float));
  memset(&VV[0], 0, 42U * sizeof(float));
  memset(&WW[0], 0, 42U * sizeof(float));
  memset(&UV[0], 0, 42U * sizeof(creal32_T));
  memset(&UW[0], 0, 42U * sizeof(creal32_T));
  memset(&VW[0], 0, 42U * sizeof(creal32_T));
  emxInit_real32_T(&u, 2);
  /*  Despike the full time series */
  fe = 10.0F * b_std(east);
  nx = east->size[1];
  i = u->size[0] * u->size[1];
  u->size[0] = 1;
  u->size[1] = east->size[1];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  for (fpindex = 0; fpindex < nx; fpindex++) {
    u_data[fpindex] = fabsf(east_data[fpindex]);
  }
  i = bad->size[0] * bad->size[1];
  bad->size[0] = 1;
  bad->size[1] = u->size[1];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  fpindex = u->size[1];
  for (i = 0; i < fpindex; i++) {
    bad_data[i] = (u_data[i] >= fe);
  }
  /*  logical array of indices for bad points */
  fpindex = bad->size[1] - 1;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (bad_data[b_i]) {
      nx++;
    }
  }
  emxInit_int32_T(&r, 2);
  i = r->size[0] * r->size[1];
  r->size[0] = 1;
  r->size[1] = nx;
  emxEnsureCapacity_int32_T(r, i);
  r1 = r->data;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (bad_data[b_i]) {
      r1[nx] = b_i + 1;
      nx++;
    }
  }
  fpindex = bad->size[1] - 1;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (!bad_data[b_i]) {
      nx++;
    }
  }
  emxInit_int32_T(&r2, 2);
  i = r2->size[0] * r2->size[1];
  r2->size[0] = 1;
  r2->size[1] = nx;
  emxEnsureCapacity_int32_T(r2, i);
  r3 = r2->data;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (!bad_data[b_i]) {
      r3[nx] = b_i + 1;
      nx++;
    }
  }
  emxInit_real32_T(&filtereddata, 2);
  i = filtereddata->size[0] * filtereddata->size[1];
  filtereddata->size[0] = 1;
  filtereddata->size[1] = r2->size[1];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  fpindex = r2->size[1];
  for (i = 0; i < fpindex; i++) {
    filtereddata_data[i] = east_data[r3[i] - 1];
  }
  fe = b_combineVectorElements(filtereddata) / (float)r2->size[1];
  fpindex = r->size[1] - 1;
  emxFree_int32_T(&r2);
  for (i = 0; i <= fpindex; i++) {
    east_data[r1[i] - 1] = fe;
  }
  fe = 10.0F * b_std(north);
  nx = north->size[1];
  i = u->size[0] * u->size[1];
  u->size[0] = 1;
  u->size[1] = north->size[1];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  for (fpindex = 0; fpindex < nx; fpindex++) {
    u_data[fpindex] = fabsf(north_data[fpindex]);
  }
  i = bad->size[0] * bad->size[1];
  bad->size[0] = 1;
  bad->size[1] = u->size[1];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  fpindex = u->size[1];
  for (i = 0; i < fpindex; i++) {
    bad_data[i] = (u_data[i] >= fe);
  }
  /*  logical array of indices for bad points */
  fpindex = bad->size[1] - 1;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (bad_data[b_i]) {
      nx++;
    }
  }
  emxInit_int32_T(&r4, 2);
  i = r4->size[0] * r4->size[1];
  r4->size[0] = 1;
  r4->size[1] = nx;
  emxEnsureCapacity_int32_T(r4, i);
  r1 = r4->data;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (bad_data[b_i]) {
      r1[nx] = b_i + 1;
      nx++;
    }
  }
  fpindex = bad->size[1] - 1;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (!bad_data[b_i]) {
      nx++;
    }
  }
  emxInit_int32_T(&r5, 2);
  i = r5->size[0] * r5->size[1];
  r5->size[0] = 1;
  r5->size[1] = nx;
  emxEnsureCapacity_int32_T(r5, i);
  r3 = r5->data;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (!bad_data[b_i]) {
      r3[nx] = b_i + 1;
      nx++;
    }
  }
  i = filtereddata->size[0] * filtereddata->size[1];
  filtereddata->size[0] = 1;
  filtereddata->size[1] = r5->size[1];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  fpindex = r5->size[1];
  for (i = 0; i < fpindex; i++) {
    filtereddata_data[i] = north_data[r3[i] - 1];
  }
  fe = b_combineVectorElements(filtereddata) / (float)r5->size[1];
  fpindex = r4->size[1] - 1;
  emxFree_int32_T(&r5);
  for (i = 0; i <= fpindex; i++) {
    north_data[r1[i] - 1] = fe;
  }
  emxFree_int32_T(&r4);
  fe = 10.0F * b_std(down);
  nx = down->size[1];
  i = u->size[0] * u->size[1];
  u->size[0] = 1;
  u->size[1] = down->size[1];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  for (fpindex = 0; fpindex < nx; fpindex++) {
    u_data[fpindex] = fabsf(down_data[fpindex]);
  }
  i = bad->size[0] * bad->size[1];
  bad->size[0] = 1;
  bad->size[1] = u->size[1];
  emxEnsureCapacity_boolean_T(bad, i);
  bad_data = bad->data;
  fpindex = u->size[1];
  for (i = 0; i < fpindex; i++) {
    bad_data[i] = (u_data[i] >= fe);
  }
  /*  logical array of indices for bad points */
  fpindex = bad->size[1] - 1;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (bad_data[b_i]) {
      nx++;
    }
  }
  emxInit_int32_T(&r6, 2);
  i = r6->size[0] * r6->size[1];
  r6->size[0] = 1;
  r6->size[1] = nx;
  emxEnsureCapacity_int32_T(r6, i);
  r1 = r6->data;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (bad_data[b_i]) {
      r1[nx] = b_i + 1;
      nx++;
    }
  }
  fpindex = bad->size[1] - 1;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (!bad_data[b_i]) {
      nx++;
    }
  }
  emxInit_int32_T(&r7, 2);
  i = r7->size[0] * r7->size[1];
  r7->size[0] = 1;
  r7->size[1] = nx;
  emxEnsureCapacity_int32_T(r7, i);
  r3 = r7->data;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (!bad_data[b_i]) {
      r3[nx] = b_i + 1;
      nx++;
    }
  }
  emxFree_boolean_T(&bad);
  i = filtereddata->size[0] * filtereddata->size[1];
  filtereddata->size[0] = 1;
  filtereddata->size[1] = r7->size[1];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  fpindex = r7->size[1];
  for (i = 0; i < fpindex; i++) {
    filtereddata_data[i] = down_data[r3[i] - 1];
  }
  fe = b_combineVectorElements(filtereddata) / (float)r7->size[1];
  fpindex = r6->size[1] - 1;
  emxFree_int32_T(&r7);
  for (i = 0; i <= fpindex; i++) {
    down_data[r1[i] - 1] = fe;
  }
  emxFree_int32_T(&r6);
  /*  loop thru windows, accumulating spectral results */
  i = (int)windows;
  emxInit_real_T(&taper, 2);
  if ((int)windows - 1 >= 0) {
    loop_ub = (int)(wpts - 1.0);
    alpha = 4.0 / (1.0 / fs + 4.0);
    d = rt_roundd_snf(wpts / 2.0 + 1.0);
    loop_ub_tmp = (int)(wpts - d);
    d1 = rawf_tmp;
    end = rawf->size[1] - 1;
    y = rawf_tmp * fs;
    b_end = rawf->size[1] - 1;
    y_tmp = rt_roundd_snf(wpts / 2.0) * fs;
    c_end = rawf->size[1] - 1;
    d_end = rawf->size[1] - 1;
    e_end = rawf->size[1] - 1;
    f_end = rawf->size[1] - 1;
    i1 = (int)((double)f->size[1] * 3.0 / 3.0);
  }
  emxInit_real32_T(&v, 2);
  emxInit_real32_T(&w, 2);
  emxInit_creal32_T(&UVwindow, 2);
  emxInit_creal32_T(&UWwindow, 2);
  emxInit_creal32_T(&b_u, 2);
  emxInit_creal32_T(&b_v, 2);
  emxInit_creal32_T(&b_w, 2);
  emxInit_int32_T(&r8, 2);
  emxInit_int32_T(&r9, 2);
  emxInit_int32_T(&r10, 2);
  emxInit_int32_T(&r11, 2);
  emxInit_int32_T(&r12, 2);
  emxInit_int32_T(&r13, 2);
  emxInit_real_T(&u_tmp, 1);
  emxInit_real32_T(&c_u, 2);
  for (q = 0; q < i; q++) {
    Nyquist = (((double)q + 1.0) - 1.0) * (0.25 * wpts);
    i2 = u_tmp->size[0];
    u_tmp->size[0] = (int)(wpts - 1.0) + 1;
    emxEnsureCapacity_real_T(u_tmp, i2);
    taper_data = u_tmp->data;
    for (i2 = 0; i2 <= loop_ub; i2++) {
      taper_data[i2] = Nyquist + ((double)i2 + 1.0);
    }
    i2 = u->size[0] * u->size[1];
    u->size[0] = 1;
    u->size[1] = u_tmp->size[0];
    emxEnsureCapacity_real32_T(u, i2);
    u_data = u->data;
    fpindex = u_tmp->size[0];
    for (i2 = 0; i2 < fpindex; i2++) {
      u_data[i2] = east_data[(int)taper_data[i2] - 1];
    }
    i2 = v->size[0] * v->size[1];
    v->size[0] = 1;
    v->size[1] = u_tmp->size[0];
    emxEnsureCapacity_real32_T(v, i2);
    v_data = v->data;
    fpindex = u_tmp->size[0];
    for (i2 = 0; i2 < fpindex; i2++) {
      v_data[i2] = north_data[(int)taper_data[i2] - 1];
    }
    i2 = w->size[0] * w->size[1];
    w->size[0] = 1;
    w->size[1] = u_tmp->size[0];
    emxEnsureCapacity_real32_T(w, i2);
    w_data = w->data;
    fpindex = u_tmp->size[0];
    for (i2 = 0; i2 < fpindex; i2++) {
      w_data[i2] = down_data[(int)taper_data[i2] - 1];
    }
    /*     %% remove the mean */
    fe = b_combineVectorElements(u) / (float)u_tmp->size[0];
    i2 = u->size[0] * u->size[1];
    u->size[0] = 1;
    emxEnsureCapacity_real32_T(u, i2);
    u_data = u->data;
    fpindex = u->size[1] - 1;
    for (i2 = 0; i2 <= fpindex; i2++) {
      u_data[i2] -= fe;
    }
    fe = b_combineVectorElements(v) / (float)u_tmp->size[0];
    i2 = v->size[0] * v->size[1];
    v->size[0] = 1;
    emxEnsureCapacity_real32_T(v, i2);
    v_data = v->data;
    fpindex = v->size[1] - 1;
    for (i2 = 0; i2 <= fpindex; i2++) {
      v_data[i2] -= fe;
    }
    fe = b_combineVectorElements(w) / (float)u_tmp->size[0];
    i2 = w->size[0] * w->size[1];
    w->size[0] = 1;
    emxEnsureCapacity_real32_T(w, i2);
    w_data = w->data;
    fpindex = w->size[1] - 1;
    for (i2 = 0; i2 <= fpindex; i2++) {
      w_data[i2] -= fe;
    }
    /*     %% high-pass RC filter this window */
    i2 = filtereddata->size[0] * filtereddata->size[1];
    filtereddata->size[0] = 1;
    filtereddata->size[1] = u->size[1];
    emxEnsureCapacity_real32_T(filtereddata, i2);
    filtereddata_data = filtereddata->data;
    fpindex = u->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      filtereddata_data[i2] = u_data[i2];
    }
    i2 = u->size[1];
    for (fpindex = 0; fpindex <= i2 - 2; fpindex++) {
      filtereddata_data[fpindex + 1] =
          (float)alpha * filtereddata_data[fpindex] +
          (float)alpha * (u_data[fpindex + 1] - u_data[fpindex]);
    }
    i2 = u->size[0] * u->size[1];
    u->size[0] = 1;
    u->size[1] = filtereddata->size[1];
    emxEnsureCapacity_real32_T(u, i2);
    u_data = u->data;
    fpindex = filtereddata->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      u_data[i2] = filtereddata_data[i2];
    }
    i2 = filtereddata->size[0] * filtereddata->size[1];
    filtereddata->size[0] = 1;
    filtereddata->size[1] = v->size[1];
    emxEnsureCapacity_real32_T(filtereddata, i2);
    filtereddata_data = filtereddata->data;
    fpindex = v->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      filtereddata_data[i2] = v_data[i2];
    }
    i2 = v->size[1];
    for (fpindex = 0; fpindex <= i2 - 2; fpindex++) {
      filtereddata_data[fpindex + 1] =
          (float)alpha * filtereddata_data[fpindex] +
          (float)alpha * (v_data[fpindex + 1] - v_data[fpindex]);
    }
    i2 = v->size[0] * v->size[1];
    v->size[0] = 1;
    v->size[1] = filtereddata->size[1];
    emxEnsureCapacity_real32_T(v, i2);
    v_data = v->data;
    fpindex = filtereddata->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      v_data[i2] = filtereddata_data[i2];
    }
    i2 = filtereddata->size[0] * filtereddata->size[1];
    filtereddata->size[0] = 1;
    filtereddata->size[1] = w->size[1];
    emxEnsureCapacity_real32_T(filtereddata, i2);
    filtereddata_data = filtereddata->data;
    fpindex = w->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      filtereddata_data[i2] = w_data[i2];
    }
    i2 = w->size[1];
    for (fpindex = 0; fpindex <= i2 - 2; fpindex++) {
      filtereddata_data[fpindex + 1] =
          (float)alpha * filtereddata_data[fpindex] +
          (float)alpha * (w_data[fpindex + 1] - w_data[fpindex]);
    }
    /*     %% taper and rescale (to preserve variance) */
    /*  get original variance of each window */
    fe = var(u);
    x = var(v);
    /*  define the taper */
    if (rtIsNaN(wpts)) {
      i2 = taper->size[0] * taper->size[1];
      taper->size[0] = 1;
      taper->size[1] = 1;
      emxEnsureCapacity_real_T(taper, i2);
      taper_data = taper->data;
      taper_data[0] = rtNaN;
    } else if (wpts < 1.0) {
      taper->size[1] = 0;
    } else {
      i2 = taper->size[0] * taper->size[1];
      taper->size[0] = 1;
      taper->size[1] = (int)(wpts - 1.0) + 1;
      emxEnsureCapacity_real_T(taper, i2);
      taper_data = taper->data;
      fpindex = (int)(wpts - 1.0);
      for (i2 = 0; i2 <= fpindex; i2++) {
        taper_data[i2] = (double)i2 + 1.0;
      }
    }
    i2 = taper->size[0] * taper->size[1];
    taper->size[0] = 1;
    emxEnsureCapacity_real_T(taper, i2);
    taper_data = taper->data;
    fpindex = taper->size[1] - 1;
    for (i2 = 0; i2 <= fpindex; i2++) {
      taper_data[i2] = taper_data[i2] * 3.1415926535897931 / wpts;
    }
    nx = taper->size[1];
    for (fpindex = 0; fpindex < nx; fpindex++) {
      taper_data[fpindex] = sin(taper_data[fpindex]);
    }
    /*  apply the taper */
    if (u->size[1] == taper->size[1]) {
      fpindex = u->size[1] - 1;
      i2 = u->size[0] * u->size[1];
      u->size[0] = 1;
      emxEnsureCapacity_real32_T(u, i2);
      u_data = u->data;
      for (i2 = 0; i2 <= fpindex; i2++) {
        u_data[i2] *= (float)taper_data[i2];
      }
    } else {
      b_binary_expand_op(u, taper);
    }
    if (v->size[1] == taper->size[1]) {
      fpindex = v->size[1] - 1;
      i2 = v->size[0] * v->size[1];
      v->size[0] = 1;
      emxEnsureCapacity_real32_T(v, i2);
      v_data = v->data;
      for (i2 = 0; i2 <= fpindex; i2++) {
        v_data[i2] *= (float)taper_data[i2];
      }
    } else {
      b_binary_expand_op(v, taper);
    }
    if (filtereddata->size[1] == taper->size[1]) {
      i2 = w->size[0] * w->size[1];
      w->size[0] = 1;
      w->size[1] = filtereddata->size[1];
      emxEnsureCapacity_real32_T(w, i2);
      w_data = w->data;
      fpindex = filtereddata->size[1];
      for (i2 = 0; i2 < fpindex; i2++) {
        w_data[i2] = filtereddata_data[i2] * (float)taper_data[i2];
      }
    } else {
      binary_expand_op(w, filtereddata, taper);
    }
    /*  then rescale to regain the same original variance */
    fe = sqrtf(fe / var(u));
    i2 = u->size[0] * u->size[1];
    u->size[0] = 1;
    emxEnsureCapacity_real32_T(u, i2);
    u_data = u->data;
    fpindex = u->size[1] - 1;
    for (i2 = 0; i2 <= fpindex; i2++) {
      u_data[i2] *= fe;
    }
    fe = sqrtf(x / var(v));
    i2 = v->size[0] * v->size[1];
    v->size[0] = 1;
    emxEnsureCapacity_real32_T(v, i2);
    v_data = v->data;
    fpindex = v->size[1] - 1;
    for (i2 = 0; i2 <= fpindex; i2++) {
      v_data[i2] *= fe;
    }
    fe = sqrtf(var(filtereddata) / var(w));
    i2 = w->size[0] * w->size[1];
    w->size[0] = 1;
    emxEnsureCapacity_real32_T(w, i2);
    w_data = w->data;
    fpindex = w->size[1] - 1;
    for (i2 = 0; i2 <= fpindex; i2++) {
      w_data[i2] *= fe;
    }
    /*     %% FFT */
    /*  calculate Fourier coefs (complex values, double sided) */
    fft(u, b_u);
    fft(v, b_v);
    fft(w, b_w);
    /*  second half of Matlab's FFT is redundant, so throw it out */
    i2 = r->size[0] * r->size[1];
    r->size[0] = 1;
    r->size[1] = (int)(wpts - d) + 1;
    emxEnsureCapacity_int32_T(r, i2);
    r1 = r->data;
    for (i2 = 0; i2 <= loop_ub_tmp; i2++) {
      r1[i2] = (int)(d + (double)i2);
    }
    b_nullAssignment(b_u, r);
    i2 = r->size[0] * r->size[1];
    r->size[0] = 1;
    r->size[1] = (int)(wpts - d) + 1;
    emxEnsureCapacity_int32_T(r, i2);
    r1 = r->data;
    for (i2 = 0; i2 <= loop_ub_tmp; i2++) {
      r1[i2] = (int)(d + (double)i2);
    }
    b_nullAssignment(b_v, r);
    i2 = r->size[0] * r->size[1];
    r->size[0] = 1;
    r->size[1] = (int)(wpts - d) + 1;
    emxEnsureCapacity_int32_T(r, i2);
    r1 = r->data;
    for (i2 = 0; i2 <= loop_ub_tmp; i2++) {
      r1[i2] = (int)(d + (double)i2);
    }
    b_nullAssignment(b_w, r);
    /*  throw out the mean (first coef) and add a zero (to make it the right
     * length) */
    c_nullAssignment(b_u);
    b_u_data = b_u->data;
    c_nullAssignment(b_v);
    b_v_data = b_v->data;
    c_nullAssignment(b_w);
    b_w_data = b_w->data;
    b_u_data[(int)d1 - 1].re = 0.0F;
    b_u_data[(int)d1 - 1].im = 0.0F;
    b_v_data[(int)rawf_tmp - 1].re = 0.0F;
    b_v_data[(int)rawf_tmp - 1].im = 0.0F;
    b_w_data[(int)rawf_tmp - 1].re = 0.0F;
    b_w_data[(int)rawf_tmp - 1].im = 0.0F;
    /*  Calculate the auto-spectra and cross-spectra from this window  */
    /*  ** do this before merging frequency bands or ensemble averging windows
     * ** */
    /*  only compute for raw frequencies less than the max frequency of interest
     * (to save memory) */
    nx = 0;
    for (b_i = 0; b_i <= end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        nx++;
      }
    }
    i2 = r8->size[0] * r8->size[1];
    r8->size[0] = 1;
    r8->size[1] = nx;
    emxEnsureCapacity_int32_T(r8, i2);
    r1 = r8->data;
    nx = 0;
    for (b_i = 0; b_i <= end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        r1[nx] = b_i + 1;
        nx++;
      }
    }
    i2 = u->size[0] * u->size[1];
    u->size[0] = 1;
    u->size[1] = r8->size[1];
    emxEnsureCapacity_real32_T(u, i2);
    u_data = u->data;
    fpindex = r8->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      u_re_tmp = b_u_data[r1[i2] - 1].re;
      fe = b_u_data[r1[i2] - 1].im;
      u_data[i2] = (u_re_tmp * u_re_tmp - fe * -fe) / (float)y;
    }
    nx = 0;
    for (b_i = 0; b_i <= b_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        nx++;
      }
    }
    i2 = r9->size[0] * r9->size[1];
    r9->size[0] = 1;
    r9->size[1] = nx;
    emxEnsureCapacity_int32_T(r9, i2);
    r1 = r9->data;
    nx = 0;
    for (b_i = 0; b_i <= b_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        r1[nx] = b_i + 1;
        nx++;
      }
    }
    i2 = v->size[0] * v->size[1];
    v->size[0] = 1;
    v->size[1] = r9->size[1];
    emxEnsureCapacity_real32_T(v, i2);
    v_data = v->data;
    fpindex = r9->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      x = b_v_data[r1[i2] - 1].re;
      fe = b_v_data[r1[i2] - 1].im;
      v_data[i2] = (x * x - fe * -fe) / (float)y_tmp;
    }
    nx = 0;
    for (b_i = 0; b_i <= c_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        nx++;
      }
    }
    i2 = r10->size[0] * r10->size[1];
    r10->size[0] = 1;
    r10->size[1] = nx;
    emxEnsureCapacity_int32_T(r10, i2);
    r1 = r10->data;
    nx = 0;
    for (b_i = 0; b_i <= c_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        r1[nx] = b_i + 1;
        nx++;
      }
    }
    i2 = w->size[0] * w->size[1];
    w->size[0] = 1;
    w->size[1] = r10->size[1];
    emxEnsureCapacity_real32_T(w, i2);
    w_data = w->data;
    fpindex = r10->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      fe = b_w_data[r1[i2] - 1].re;
      x = b_w_data[r1[i2] - 1].im;
      w_data[i2] = (fe * fe - x * -x) / (float)y_tmp;
    }
    nx = 0;
    for (b_i = 0; b_i <= d_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        nx++;
      }
    }
    i2 = r11->size[0] * r11->size[1];
    r11->size[0] = 1;
    r11->size[1] = nx;
    emxEnsureCapacity_int32_T(r11, i2);
    r1 = r11->data;
    nx = 0;
    for (b_i = 0; b_i <= d_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        r1[nx] = b_i + 1;
        nx++;
      }
    }
    i2 = UVwindow->size[0] * UVwindow->size[1];
    UVwindow->size[0] = 1;
    UVwindow->size[1] = r11->size[1];
    emxEnsureCapacity_creal32_T(UVwindow, i2);
    UVwindow_data = UVwindow->data;
    fpindex = r11->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      v_re = b_v_data[r1[i2] - 1].re;
      fe = -b_v_data[r1[i2] - 1].im;
      u_re_tmp = b_u_data[r1[i2] - 1].re;
      x = b_u_data[r1[i2] - 1].im;
      u_re = u_re_tmp * v_re - x * fe;
      fe = u_re_tmp * fe + x * v_re;
      if (fe == 0.0F) {
        UVwindow_data[i2].re = u_re / (float)y_tmp;
        UVwindow_data[i2].im = 0.0F;
      } else if (u_re == 0.0F) {
        UVwindow_data[i2].re = 0.0F;
        UVwindow_data[i2].im = fe / (float)y_tmp;
      } else {
        UVwindow_data[i2].re = u_re / (float)y_tmp;
        UVwindow_data[i2].im = fe / (float)y_tmp;
      }
    }
    nx = 0;
    for (b_i = 0; b_i <= e_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        nx++;
      }
    }
    i2 = r12->size[0] * r12->size[1];
    r12->size[0] = 1;
    r12->size[1] = nx;
    emxEnsureCapacity_int32_T(r12, i2);
    r1 = r12->data;
    nx = 0;
    for (b_i = 0; b_i <= e_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        r1[nx] = b_i + 1;
        nx++;
      }
    }
    i2 = UWwindow->size[0] * UWwindow->size[1];
    UWwindow->size[0] = 1;
    UWwindow->size[1] = r12->size[1];
    emxEnsureCapacity_creal32_T(UWwindow, i2);
    UWwindow_data = UWwindow->data;
    fpindex = r12->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      w_re = b_w_data[r1[i2] - 1].re;
      w_im = -b_w_data[r1[i2] - 1].im;
      u_re_tmp = b_u_data[r1[i2] - 1].re;
      x = b_u_data[r1[i2] - 1].im;
      u_re = u_re_tmp * w_re - x * w_im;
      fe = u_re_tmp * w_im + x * w_re;
      if (fe == 0.0F) {
        UWwindow_data[i2].re = u_re / (float)y_tmp;
        UWwindow_data[i2].im = 0.0F;
      } else if (u_re == 0.0F) {
        UWwindow_data[i2].re = 0.0F;
        UWwindow_data[i2].im = fe / (float)y_tmp;
      } else {
        UWwindow_data[i2].re = u_re / (float)y_tmp;
        UWwindow_data[i2].im = fe / (float)y_tmp;
      }
    }
    nx = 0;
    for (b_i = 0; b_i <= f_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        nx++;
      }
    }
    i2 = r13->size[0] * r13->size[1];
    r13->size[0] = 1;
    r13->size[1] = nx;
    emxEnsureCapacity_int32_T(r13, i2);
    r1 = r13->data;
    nx = 0;
    for (b_i = 0; b_i <= f_end; b_i++) {
      if (rawf_data[b_i] < 0.5) {
        r1[nx] = b_i + 1;
        nx++;
      }
    }
    i2 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = r13->size[1];
    emxEnsureCapacity_creal32_T(b_u, i2);
    b_u_data = b_u->data;
    fpindex = r13->size[1];
    for (i2 = 0; i2 < fpindex; i2++) {
      w_re = b_w_data[r1[i2] - 1].re;
      w_im = -b_w_data[r1[i2] - 1].im;
      x = b_v_data[r1[i2] - 1].re;
      fe = b_v_data[r1[i2] - 1].im;
      v_re = x * w_re - fe * w_im;
      fe = x * w_im + fe * w_re;
      if (fe == 0.0F) {
        b_u_data[i2].re = v_re / (float)y_tmp;
        b_u_data[i2].im = 0.0F;
      } else if (v_re == 0.0F) {
        b_u_data[i2].re = 0.0F;
        b_u_data[i2].im = fe / (float)y_tmp;
      } else {
        b_u_data[i2].re = v_re / (float)y_tmp;
        b_u_data[i2].im = fe / (float)y_tmp;
      }
    }
    /*  accumulate window results and merge neighboring frequency bands (to
     * increase DOFs) */
    for (mi = 0; mi < i1; mi++) {
      creal32_T fc;
      Nyquist = (double)mi * 3.0 + 3.0;
      if ((Nyquist - 3.0) + 1.0 > Nyquist) {
        i2 = -1;
        i4 = -1;
      } else {
        i2 = (int)((Nyquist - 3.0) + 1.0) - 2;
        i4 = (int)Nyquist - 1;
      }
      nx = c_u->size[0] * c_u->size[1];
      c_u->size[0] = 1;
      fpindex = i4 - i2;
      c_u->size[1] = fpindex;
      emxEnsureCapacity_real32_T(c_u, nx);
      filtereddata_data = c_u->data;
      for (i4 = 0; i4 < fpindex; i4++) {
        filtereddata_data[i4] = u_data[(i2 + i4) + 1];
      }
      b_i = (int)(Nyquist / 3.0) - 1;
      UU[b_i] += b_combineVectorElements(c_u) / (float)fpindex;
      if ((Nyquist - 3.0) + 1.0 > Nyquist) {
        i2 = -1;
        i4 = -1;
      } else {
        i2 = (int)((Nyquist - 3.0) + 1.0) - 2;
        i4 = (int)Nyquist - 1;
      }
      nx = filtereddata->size[0] * filtereddata->size[1];
      filtereddata->size[0] = 1;
      fpindex = i4 - i2;
      filtereddata->size[1] = fpindex;
      emxEnsureCapacity_real32_T(filtereddata, nx);
      filtereddata_data = filtereddata->data;
      for (i4 = 0; i4 < fpindex; i4++) {
        filtereddata_data[i4] = v_data[(i2 + i4) + 1];
      }
      VV[b_i] += b_combineVectorElements(filtereddata) / (float)fpindex;
      if ((Nyquist - 3.0) + 1.0 > Nyquist) {
        i2 = -1;
        i4 = -1;
      } else {
        i2 = (int)((Nyquist - 3.0) + 1.0) - 2;
        i4 = (int)Nyquist - 1;
      }
      nx = filtereddata->size[0] * filtereddata->size[1];
      filtereddata->size[0] = 1;
      fpindex = i4 - i2;
      filtereddata->size[1] = fpindex;
      emxEnsureCapacity_real32_T(filtereddata, nx);
      filtereddata_data = filtereddata->data;
      for (i4 = 0; i4 < fpindex; i4++) {
        filtereddata_data[i4] = w_data[(i2 + i4) + 1];
      }
      WW[b_i] += b_combineVectorElements(filtereddata) / (float)fpindex;
      if ((Nyquist - 3.0) + 1.0 > Nyquist) {
        i2 = 0;
        i4 = 0;
      } else {
        i2 = (int)((Nyquist - 3.0) + 1.0) - 1;
        i4 = (int)Nyquist;
      }
      nx = b_v->size[0] * b_v->size[1];
      b_v->size[0] = 1;
      fpindex = i4 - i2;
      b_v->size[1] = fpindex;
      emxEnsureCapacity_creal32_T(b_v, nx);
      b_v_data = b_v->data;
      for (i4 = 0; i4 < fpindex; i4++) {
        b_v_data[i4] = UVwindow_data[i2 + i4];
      }
      fc = mean(b_v);
      UV[b_i].re += fc.re;
      UV[b_i].im += fc.im;
      if ((Nyquist - 3.0) + 1.0 > Nyquist) {
        i2 = 0;
        i4 = 0;
      } else {
        i2 = (int)((Nyquist - 3.0) + 1.0) - 1;
        i4 = (int)Nyquist;
      }
      nx = b_v->size[0] * b_v->size[1];
      b_v->size[0] = 1;
      fpindex = i4 - i2;
      b_v->size[1] = fpindex;
      emxEnsureCapacity_creal32_T(b_v, nx);
      b_v_data = b_v->data;
      for (i4 = 0; i4 < fpindex; i4++) {
        b_v_data[i4] = UWwindow_data[i2 + i4];
      }
      fc = mean(b_v);
      UW[b_i].re += fc.re;
      UW[b_i].im += fc.im;
      if ((Nyquist - 3.0) + 1.0 > Nyquist) {
        i2 = 0;
        i4 = 0;
      } else {
        i2 = (int)((Nyquist - 3.0) + 1.0) - 1;
        i4 = (int)Nyquist;
      }
      nx = b_v->size[0] * b_v->size[1];
      b_v->size[0] = 1;
      fpindex = i4 - i2;
      b_v->size[1] = fpindex;
      emxEnsureCapacity_creal32_T(b_v, nx);
      b_v_data = b_v->data;
      for (i4 = 0; i4 < fpindex; i4++) {
        b_v_data[i4] = b_u_data[i2 + i4];
      }
      fc = mean(b_v);
      VW[b_i].re += fc.re;
      VW[b_i].im += fc.im;
    }
  }
  emxFree_real_T(&u_tmp);
  emxFree_int32_T(&r13);
  emxFree_int32_T(&r12);
  emxFree_int32_T(&r11);
  emxFree_int32_T(&r10);
  emxFree_int32_T(&r9);
  emxFree_int32_T(&r8);
  emxFree_int32_T(&r);
  emxFree_creal32_T(&b_w);
  emxFree_creal32_T(&b_v);
  emxFree_creal32_T(&b_u);
  emxFree_creal32_T(&UWwindow);
  emxFree_creal32_T(&UVwindow);
  emxFree_real_T(&taper);
  emxFree_real32_T(&w);
  /*  close window loop */
  /*  divide accumulated results by number of windows (effectively an ensemble
   * avg) */
  /*  wave spectral moments */
  /*  see definitions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012,
   * Thomson et al, J Tech 2018 */
  /*  save memory by calling the co- and quad spectra inline, rather than making
   * the variables */
  /* Qxz = imag(UW); % quadspectrum of vertical and east horizontal motion */
  /* Cxz = real(UW); % cospectrum of vertical and east horizontal motion */
  /* Qyz = imag(VW); % quadspectrum of vertical and north horizontal motion */
  /* Cyz = real(VW); % cospectrum of vertical and north horizontal motion */
  /* Cxy = real(UV) ./ ( (2*pi*f).^2 );  % cospectrum of east and north motion
   */
  for (fpindex = 0; fpindex < 42; fpindex++) {
    w_re = UU[fpindex] / (float)windows;
    UU[fpindex] = w_re;
    w_im = VV[fpindex] / (float)windows;
    VV[fpindex] = w_im;
    v_re = WW[fpindex] / (float)windows;
    WW[fpindex] = v_re;
    fe = UV[fpindex].re;
    u_re_tmp = UV[fpindex].im;
    if (u_re_tmp == 0.0F) {
      x = fe / (float)windows;
      u_re = 0.0F;
    } else if (fe == 0.0F) {
      x = 0.0F;
      u_re = u_re_tmp / (float)windows;
    } else {
      x = fe / (float)windows;
      u_re = u_re_tmp / (float)windows;
    }
    UV[fpindex].re = x;
    UV[fpindex].im = u_re;
    fe = UW[fpindex].re;
    u_re_tmp = UW[fpindex].im;
    if (u_re_tmp == 0.0F) {
      x = fe / (float)windows;
      u_re = 0.0F;
    } else if (fe == 0.0F) {
      x = 0.0F;
      u_re = u_re_tmp / (float)windows;
    } else {
      x = fe / (float)windows;
      u_re = u_re_tmp / (float)windows;
    }
    UW[fpindex].re = x;
    UW[fpindex].im = u_re;
    fe = VW[fpindex].re;
    u_re_tmp = VW[fpindex].im;
    if (u_re_tmp == 0.0F) {
      x = fe / (float)windows;
      fe = 0.0F;
    } else if (fe == 0.0F) {
      x = 0.0F;
      fe = u_re_tmp / (float)windows;
    } else {
      x = fe / (float)windows;
      fe = u_re_tmp / (float)windows;
    }
    VW[fpindex].re = x;
    VW[fpindex].im = fe;
    w_re += w_im;
    y_tmp_tmp[fpindex] = w_re;
    w_re = sqrtf(w_re * v_re);
    b_a1[fpindex] = u_re / w_re;
    w_re = fe / w_re;
    b_b1[fpindex] = w_re;
  }
  /*  Scalar energy spectra (a0) */
  i = rawf->size[0] * rawf->size[1];
  rawf->size[0] = 1;
  rawf->size[1] = f->size[1];
  emxEnsureCapacity_real_T(rawf, i);
  rawf_data = rawf->data;
  fpindex = f->size[1];
  for (i = 0; i < fpindex; i++) {
    Nyquist = 6.2831853071795862 * f_data[i];
    rawf_data[i] = Nyquist * Nyquist;
  }
  if (rawf->size[1] == 42) {
    for (i = 0; i < 42; i++) {
      b_E[i] = y_tmp_tmp[i] / (float)rawf_data[i];
    }
  } else {
    c_binary_expand_op(b_E, y_tmp_tmp, rawf);
  }
  emxFree_real_T(&rawf);
  /*  assumes perfectly circular deepwater orbits */
  /*  E = ( WW ) ./ ( (2*pi*f).^2 ); % arbitrary depth, but more noise? */
  /*  use orbit shape as check on quality (=1 in deep water) */
  /*  wave stats */
  /*  frequency cutoff for wave stats */
  /*  significant wave height */
  fpindex = f->size[1] - 1;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (f_data[b_i] > 0.05) {
      nx++;
    }
  }
  emxInit_int32_T(&r14, 2);
  i = r14->size[0] * r14->size[1];
  r14->size[0] = 1;
  r14->size[1] = nx;
  emxEnsureCapacity_int32_T(r14, i);
  r1 = r14->data;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (f_data[b_i] > 0.05) {
      r1[nx] = b_i + 1;
      nx++;
    }
  }
  /*   energy period */
  fpindex = f->size[1] - 1;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (f_data[b_i] > 0.05) {
      nx++;
    }
  }
  emxInit_int32_T(&r15, 2);
  i = r15->size[0] * r15->size[1];
  r15->size[0] = 1;
  r15->size[1] = nx;
  emxEnsureCapacity_int32_T(r15, i);
  r3 = r15->data;
  nx = 0;
  for (b_i = 0; b_i <= fpindex; b_i++) {
    if (f_data[b_i] > 0.05) {
      r3[nx] = b_i + 1;
      nx++;
    }
  }
  i = filtereddata->size[0] * filtereddata->size[1];
  filtereddata->size[0] = 1;
  filtereddata->size[1] = r15->size[1];
  emxEnsureCapacity_real32_T(filtereddata, i);
  filtereddata_data = filtereddata->data;
  fpindex = r15->size[1];
  for (i = 0; i < fpindex; i++) {
    i1 = r3[i];
    filtereddata_data[i] = (float)f_data[i1 - 1] * b_E[i1 - 1];
  }
  i = c_u->size[0] * c_u->size[1];
  c_u->size[0] = 1;
  c_u->size[1] = r15->size[1];
  emxEnsureCapacity_real32_T(c_u, i);
  filtereddata_data = c_u->data;
  fpindex = r15->size[1];
  for (i = 0; i < fpindex; i++) {
    filtereddata_data[i] = b_E[r3[i] - 1];
  }
  emxFree_int32_T(&r15);
  fe = b_combineVectorElements(filtereddata) / b_combineVectorElements(c_u);
  i = v->size[0] * v->size[1];
  v->size[0] = 1;
  v->size[1] = f->size[1];
  emxEnsureCapacity_real32_T(v, i);
  v_data = v->data;
  fpindex = f->size[1];
  emxFree_real32_T(&filtereddata);
  for (i = 0; i < fpindex; i++) {
    v_data[i] = (float)f_data[i] - fe;
  }
  nx = v->size[1];
  i = u->size[0] * u->size[1];
  u->size[0] = 1;
  u->size[1] = v->size[1];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  for (fpindex = 0; fpindex < nx; fpindex++) {
    u_data[fpindex] = fabsf(v_data[fpindex]);
  }
  emxFree_real32_T(&v);
  minimum(u, &x, &nx);
  /*  peak period */
  /* [~ , fpindex] = max(UU+VV); % can use velocity (picks out more distint
   * peak) */
  maximum(b_E, &x, &fpindex);
  Nyquist = 1.0 / f_data[fpindex - 1];
  emxFree_real32_T(&u);
  if (Nyquist > 18.0) {
    /*  if reasonable peak not found, use centroid */
    Nyquist = 1.0F / fe;
    fpindex = nx;
  }
  /*  wave directions */
  /*  peak wave direction, rotated to geographic conventions */
  /*  [rad], 4 quadrant */
  /*  switch from rad to deg, and CCW to CW (negate) */
  fe = -57.3248405F * rt_atan2f_snf(b_b1[fpindex - 1], b_a1[fpindex - 1]) +
       90.0F;
  /*  rotate from eastward = 0 to northward  = 0 */
  if (fe < 0.0F) {
    fe += 360.0F;
  }
  /*  take NW quadrant from negative to 270-360 range */
  /* if Dp > 180, Dp = Dp - 180; end % take reciprocal such wave direction is
   * FROM, not TOWARDS */
  /* if Dp < 180, Dp = Dp + 180; end % take reciprocal such wave direction is
   * FROM, not TOWARDS */
  /*  format for microSWIFT telemetry output (payload type 52) */
  i = c_u->size[0] * c_u->size[1];
  c_u->size[0] = 1;
  c_u->size[1] = r14->size[1];
  emxEnsureCapacity_real32_T(c_u, i);
  filtereddata_data = c_u->data;
  fpindex = r14->size[1];
  for (i = 0; i < fpindex; i++) {
    filtereddata_data[i] = b_E[r1[i] - 1];
  }
  emxFree_int32_T(&r14);
  *Hs = floatToHalf(4.0F *
                    sqrtf(b_combineVectorElements(c_u) * (float)bandwidth));
  *Tp = doubleToHalf(Nyquist);
  *Dp = floatToHalf(fe);
  *b_fmin = doubleToHalf(b_minimum(f));
  *b_fmax = doubleToHalf(b_maximum(f));
  emxFree_real32_T(&c_u);
  emxFree_real_T(&f);
  for (i = 0; i < 42; i++) {
    unsigned char d_u;
    signed char i3;
    E[i] = floatToHalf(b_E[i]);
    w_re = roundf(b_a1[i] * 100.0F);
    if (w_re < 128.0F) {
      if (w_re >= -128.0F) {
        i3 = (signed char)w_re;
      } else {
        i3 = MIN_int8_T;
      }
    } else if (w_re >= 128.0F) {
      i3 = MAX_int8_T;
    } else {
      i3 = 0;
    }
    a1[i] = i3;
    w_re = roundf(b_b1[i] * 100.0F);
    if (w_re < 128.0F) {
      if (w_re >= -128.0F) {
        i3 = (signed char)w_re;
      } else {
        i3 = MIN_int8_T;
      }
    } else if (w_re >= 128.0F) {
      i3 = MAX_int8_T;
    } else {
      i3 = 0;
    }
    b1[i] = i3;
    w_re = y_tmp_tmp[i];
    w_im = roundf((UU[i] - VV[i]) / w_re * 100.0F);
    if (w_im < 128.0F) {
      if (w_im >= -128.0F) {
        i3 = (signed char)w_im;
      } else {
        i3 = MIN_int8_T;
      }
    } else if (w_im >= 128.0F) {
      i3 = MAX_int8_T;
    } else {
      i3 = 0;
    }
    a2[i] = i3;
    w_im = roundf(2.0F * UV[i].re / w_re * 100.0F);
    if (w_im < 128.0F) {
      if (w_im >= -128.0F) {
        i3 = (signed char)w_im;
      } else {
        i3 = MIN_int8_T;
      }
    } else if (w_im >= 128.0F) {
      i3 = MAX_int8_T;
    } else {
      i3 = 0;
    }
    b2[i] = i3;
    w_re = roundf(WW[i] / w_re * 10.0F);
    if (w_re < 256.0F) {
      if (w_re >= 0.0F) {
        d_u = (unsigned char)w_re;
      } else {
        d_u = 0U;
      }
    } else if (w_re >= 256.0F) {
      d_u = MAX_uint8_T;
    } else {
      d_u = 0U;
    }
    check[i] = d_u;
  }
}

/*
 * File trailer for NEDwaves_memlight.c
 *
 * [EOF]
 */
