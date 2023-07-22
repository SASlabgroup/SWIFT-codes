/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves_memlight.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jul-2023 15:08:49
 */

/* Include Files */
#include "NEDwaves_memlight.h"
#include "NEDwaves_memlight_emxutil.h"
#include "NEDwaves_memlight_types.h"
#include "combineVectorElements.h"
#include "div.h"
#include "fft.h"
#include "interp1.h"
#include "linspace.h"
#include "minOrMax.h"
#include "nullAssignment.h"
#include "rt_nonfinite.h"
#include "rtwhalf.h"
#include "var.h"
#include "rt_defines.h"
#include "rt_nonfinite.h"
#include <float.h>
#include <math.h>
#include <string.h>

/* Function Declarations */
static void b_binary_expand_op(float in1[42], const emxArray_creal32_T *in2,
                               double in3);

static void binary_expand_op(creal32_T in1[42], const emxArray_creal32_T *in2,
                             const emxArray_creal32_T *in3, double in4);

static void c_binary_expand_op(emxArray_real32_T *in1,
                               const emxArray_real32_T *in2,
                               const emxArray_real_T *in3);

static void d_binary_expand_op(emxArray_real32_T *in1,
                               const emxArray_real_T *in2);

static float rt_atan2f_snf(float u0, float u1);

static double rt_remd_snf(double u0, double u1);

static double rt_roundd_snf(double u);

/* Function Definitions */
/*
 * Arguments    : float in1[42]
 *                const emxArray_creal32_T *in2
 *                double in3
 * Return Type  : void
 */
static void b_binary_expand_op(float in1[42], const emxArray_creal32_T *in2,
                               double in3)
{
  const creal32_T *in2_data;
  int i;
  int stride_0_1;
  in2_data = in2->data;
  stride_0_1 = (in2->size[1] != 1);
  for (i = 0; i < 42; i++) {
    in1[i] += (in2_data[i * stride_0_1].re * in2_data[i * stride_0_1].re -
               in2_data[i * stride_0_1].im * -in2_data[i * stride_0_1].im) /
              (float)in3;
  }
}

/*
 * Arguments    : creal32_T in1[42]
 *                const emxArray_creal32_T *in2
 *                const emxArray_creal32_T *in3
 *                double in4
 * Return Type  : void
 */
static void binary_expand_op(creal32_T in1[42], const emxArray_creal32_T *in2,
                             const emxArray_creal32_T *in3, double in4)
{
  const creal32_T *in2_data;
  const creal32_T *in3_data;
  int i;
  int stride_0_1;
  int stride_1_1;
  in3_data = in3->data;
  in2_data = in2->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  for (i = 0; i < 42; i++) {
    float in2_re;
    float in3_im;
    float in3_re;
    int in3_re_tmp;
    in3_re_tmp = i * stride_1_1;
    in3_re = in3_data[in3_re_tmp].re;
    in3_im = -in3_data[in3_re_tmp].im;
    in2_re = in2_data[i * stride_0_1].re * in3_re -
             in2_data[i * stride_0_1].im * in3_im;
    in3_re = in2_data[i * stride_0_1].re * in3_im +
             in2_data[i * stride_0_1].im * in3_re;
    if (in3_re == 0.0F) {
      in2_re /= (float)in4;
      in3_re = 0.0F;
    } else if (in2_re == 0.0F) {
      in2_re = 0.0F;
      in3_re /= (float)in4;
    } else {
      in2_re /= (float)in4;
      in3_re /= (float)in4;
    }
    in1[i].re += in2_re;
    in1[i].im += in3_re;
  }
}

/*
 * Arguments    : emxArray_real32_T *in1
 *                const emxArray_real32_T *in2
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
static void c_binary_expand_op(emxArray_real32_T *in1,
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
 * Arguments    : emxArray_real32_T *in1
 *                const emxArray_real_T *in2
 * Return Type  : void
 */
static void d_binary_expand_op(emxArray_real32_T *in1,
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
 *               1/2023 memory light version... removes filtering, windowing,etc
 *                        assumes input data is clean and ready
 *               6/2023 attempt to put windowing back in,
 *                    abandon convention that upper cases is in frequency domain
 *
 *
 * Arguments    : const emxArray_real32_T *north
 *                const emxArray_real32_T *east
 *                const emxArray_real32_T *down
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
void NEDwaves_memlight(const emxArray_real32_T *north,
                       const emxArray_real32_T *east,
                       const emxArray_real32_T *down, double fs, real16_T *Hs,
                       real16_T *Tp, real16_T *Dp, real16_T E[42],
                       real16_T *b_fmin, real16_T *b_fmax, signed char a1[42],
                       signed char b1[42], signed char a2[42],
                       signed char b2[42], unsigned char check[42])
{
  emxArray_boolean_T *b_f;
  emxArray_creal32_T *b_u;
  emxArray_creal32_T *b_v;
  emxArray_creal32_T *b_w;
  emxArray_creal32_T *c_u;
  emxArray_int32_T *r;
  emxArray_int32_T *r1;
  emxArray_int32_T *r3;
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
  creal32_T *b_u_data;
  creal32_T *b_v_data;
  creal32_T *b_w_data;
  creal32_T *c_u_data;
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
  double *taper_data;
  float UU[42];
  float VV[42];
  float WW[42];
  float b_E[42];
  float b_a1[42];
  float b_b1[42];
  float y_tmp_tmp[42];
  const float *down_data;
  const float *east_data;
  const float *north_data;
  float fe;
  float u_re;
  float u_re_tmp;
  float v_re;
  float w_im;
  float w_re;
  float x;
  float *filtereddata_data;
  float *u_data;
  float *v_data;
  float *w_data;
  int b_n;
  int i;
  int k;
  int k0;
  int loop_ub;
  int loop_ub_tmp;
  int nx;
  int nxin;
  int q;
  int *r2;
  int *r4;
  bool *b_f_data;
  down_data = down->data;
  east_data = east->data;
  north_data = north->data;
  /*  parameters  */
  /*  length of the input data (should be 2^N for efficiency) */
  /* fmin = 0.01; % min frequecny for final output, Hz */
  /* fmax = 0.5; % max frequecny for final output, Hz */
  /* nf = 42; % number of frequency bands in final result */
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
  /*  frequency resolution  */
  Nyquist = fs / 2.0;
  /*  highest spectral frequency  */
  /*  frequency resolution  */
  rawf_tmp = rt_roundd_snf(wpts / 2.0);
  linspace(1.0 / (wpts / fs), Nyquist, rawf_tmp, rawf);
  /*  raw frequency bands */
  n = wpts / 2.0 / 3.0;
  /*  number of f bands after merging */
  bandwidth = Nyquist / n;
  /*  freq (Hz) bandwitdh after merging */
  /*  find middle of each merged freq band, ONLY WORKS WHEN MERGING ODD NUMBER
   * OF BANDS! */
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
    nx = (int)(n - 1.0);
    for (i = 0; i <= nx; i++) {
      f_data[i] = i;
    }
  }
  i = f->size[0] * f->size[1];
  f->size[0] = 1;
  emxEnsureCapacity_real_T(f, i);
  f_data = f->data;
  Nyquist = bandwidth / 2.0 + 0.00390625;
  nx = f->size[1] - 1;
  for (i = 0; i <= nx; i++) {
    f_data[i] = Nyquist + bandwidth * f_data[i];
  }
  /*  initialize spectral ouput, which will accumulate as windows are processed
   */
  /*  length will only be 42 is wsecs = 256, merge = 3, maxf = 0.5 (params
   * above) */
  memset(&UU[0], 0, 42U * sizeof(float));
  memset(&VV[0], 0, 42U * sizeof(float));
  memset(&WW[0], 0, 42U * sizeof(float));
  memset(&UV[0], 0, 42U * sizeof(creal32_T));
  memset(&UW[0], 0, 42U * sizeof(creal32_T));
  memset(&VW[0], 0, 42U * sizeof(creal32_T));
  /*  loop thru windows, accumulating spectral results */
  i = (int)windows;
  emxInit_real_T(&taper, 2);
  if ((int)windows - 1 >= 0) {
    loop_ub = (int)(wpts - 1.0);
    alpha = 3.0 / (1.0 / fs + 3.0);
    d = rt_roundd_snf(wpts / 2.0 + 1.0);
    loop_ub_tmp = (int)(wpts - d);
    d1 = rawf_tmp;
    y = rawf_tmp * fs;
    y_tmp = rt_roundd_snf(wpts / 2.0) * fs;
  }
  emxInit_real32_T(&u, 2);
  emxInit_real32_T(&v, 2);
  emxInit_real32_T(&w, 2);
  emxInit_real32_T(&filtereddata, 2);
  emxInit_creal32_T(&b_u, 2);
  emxInit_creal32_T(&b_v, 2);
  emxInit_creal32_T(&b_w, 2);
  emxInit_real_T(&u_tmp, 1);
  emxInit_int32_T(&r, 2);
  emxInit_boolean_T(&b_f);
  emxInit_creal32_T(&c_u, 2);
  for (q = 0; q < i; q++) {
    Nyquist = (((double)q + 1.0) - 1.0) * (0.25 * wpts);
    k0 = u_tmp->size[0];
    u_tmp->size[0] = (int)(wpts - 1.0) + 1;
    emxEnsureCapacity_real_T(u_tmp, k0);
    taper_data = u_tmp->data;
    for (k0 = 0; k0 <= loop_ub; k0++) {
      taper_data[k0] = Nyquist + ((double)k0 + 1.0);
    }
    k0 = u->size[0] * u->size[1];
    u->size[0] = 1;
    u->size[1] = u_tmp->size[0];
    emxEnsureCapacity_real32_T(u, k0);
    u_data = u->data;
    nx = u_tmp->size[0];
    for (k0 = 0; k0 < nx; k0++) {
      u_data[k0] = east_data[(int)taper_data[k0] - 1];
    }
    k0 = v->size[0] * v->size[1];
    v->size[0] = 1;
    v->size[1] = u_tmp->size[0];
    emxEnsureCapacity_real32_T(v, k0);
    v_data = v->data;
    nx = u_tmp->size[0];
    for (k0 = 0; k0 < nx; k0++) {
      v_data[k0] = north_data[(int)taper_data[k0] - 1];
    }
    k0 = w->size[0] * w->size[1];
    w->size[0] = 1;
    w->size[1] = u_tmp->size[0];
    emxEnsureCapacity_real32_T(w, k0);
    w_data = w->data;
    nx = u_tmp->size[0];
    for (k0 = 0; k0 < nx; k0++) {
      w_data[k0] = down_data[(int)taper_data[k0] - 1];
    }
    /*  remove the mean */
    fe = combineVectorElements(u) / (float)u_tmp->size[0];
    k0 = u->size[0] * u->size[1];
    u->size[0] = 1;
    emxEnsureCapacity_real32_T(u, k0);
    u_data = u->data;
    nx = u->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      u_data[k0] -= fe;
    }
    fe = combineVectorElements(v) / (float)u_tmp->size[0];
    k0 = v->size[0] * v->size[1];
    v->size[0] = 1;
    emxEnsureCapacity_real32_T(v, k0);
    v_data = v->data;
    nx = v->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      v_data[k0] -= fe;
    }
    fe = combineVectorElements(w) / (float)u_tmp->size[0];
    k0 = w->size[0] * w->size[1];
    w->size[0] = 1;
    emxEnsureCapacity_real32_T(w, k0);
    w_data = w->data;
    nx = w->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      w_data[k0] -= fe;
    }
    /*  high-pass RC filter,  */
    k0 = filtereddata->size[0] * filtereddata->size[1];
    filtereddata->size[0] = 1;
    filtereddata->size[1] = u->size[1];
    emxEnsureCapacity_real32_T(filtereddata, k0);
    filtereddata_data = filtereddata->data;
    nx = u->size[1];
    for (k0 = 0; k0 < nx; k0++) {
      filtereddata_data[k0] = u_data[k0];
    }
    k0 = u->size[1];
    for (nx = 0; nx <= k0 - 2; nx++) {
      filtereddata_data[nx + 1] = (float)alpha * filtereddata_data[nx] +
                                  (float)alpha * (u_data[nx + 1] - u_data[nx]);
    }
    k0 = u->size[0] * u->size[1];
    u->size[0] = 1;
    u->size[1] = filtereddata->size[1];
    emxEnsureCapacity_real32_T(u, k0);
    u_data = u->data;
    nx = filtereddata->size[1];
    for (k0 = 0; k0 < nx; k0++) {
      u_data[k0] = filtereddata_data[k0];
    }
    k0 = filtereddata->size[0] * filtereddata->size[1];
    filtereddata->size[0] = 1;
    filtereddata->size[1] = v->size[1];
    emxEnsureCapacity_real32_T(filtereddata, k0);
    filtereddata_data = filtereddata->data;
    nx = v->size[1];
    for (k0 = 0; k0 < nx; k0++) {
      filtereddata_data[k0] = v_data[k0];
    }
    k0 = v->size[1];
    for (nx = 0; nx <= k0 - 2; nx++) {
      filtereddata_data[nx + 1] = (float)alpha * filtereddata_data[nx] +
                                  (float)alpha * (v_data[nx + 1] - v_data[nx]);
    }
    k0 = v->size[0] * v->size[1];
    v->size[0] = 1;
    v->size[1] = filtereddata->size[1];
    emxEnsureCapacity_real32_T(v, k0);
    v_data = v->data;
    nx = filtereddata->size[1];
    for (k0 = 0; k0 < nx; k0++) {
      v_data[k0] = filtereddata_data[k0];
    }
    k0 = filtereddata->size[0] * filtereddata->size[1];
    filtereddata->size[0] = 1;
    filtereddata->size[1] = w->size[1];
    emxEnsureCapacity_real32_T(filtereddata, k0);
    filtereddata_data = filtereddata->data;
    nx = w->size[1];
    for (k0 = 0; k0 < nx; k0++) {
      filtereddata_data[k0] = w_data[k0];
    }
    k0 = w->size[1];
    for (nx = 0; nx <= k0 - 2; nx++) {
      filtereddata_data[nx + 1] = (float)alpha * filtereddata_data[nx] +
                                  (float)alpha * (w_data[nx + 1] - w_data[nx]);
    }
    /*  taper and rescale (to preserve variance) */
    /*  get original variance of each  */
    fe = var(u);
    x = var(v);
    /*  define the taper */
    if (rtIsNaN(wpts)) {
      k0 = taper->size[0] * taper->size[1];
      taper->size[0] = 1;
      taper->size[1] = 1;
      emxEnsureCapacity_real_T(taper, k0);
      taper_data = taper->data;
      taper_data[0] = rtNaN;
    } else if (wpts < 1.0) {
      taper->size[1] = 0;
    } else {
      k0 = taper->size[0] * taper->size[1];
      taper->size[0] = 1;
      taper->size[1] = (int)(wpts - 1.0) + 1;
      emxEnsureCapacity_real_T(taper, k0);
      taper_data = taper->data;
      nx = (int)(wpts - 1.0);
      for (k0 = 0; k0 <= nx; k0++) {
        taper_data[k0] = (double)k0 + 1.0;
      }
    }
    k0 = taper->size[0] * taper->size[1];
    taper->size[0] = 1;
    emxEnsureCapacity_real_T(taper, k0);
    taper_data = taper->data;
    nx = taper->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      taper_data[k0] = taper_data[k0] * 3.1415926535897931 / wpts;
    }
    nx = taper->size[1];
    for (k = 0; k < nx; k++) {
      taper_data[k] = sin(taper_data[k]);
    }
    /*  apply the taper */
    if (u->size[1] == taper->size[1]) {
      nx = u->size[1] - 1;
      k0 = u->size[0] * u->size[1];
      u->size[0] = 1;
      emxEnsureCapacity_real32_T(u, k0);
      u_data = u->data;
      for (k0 = 0; k0 <= nx; k0++) {
        u_data[k0] *= (float)taper_data[k0];
      }
    } else {
      d_binary_expand_op(u, taper);
    }
    if (v->size[1] == taper->size[1]) {
      nx = v->size[1] - 1;
      k0 = v->size[0] * v->size[1];
      v->size[0] = 1;
      emxEnsureCapacity_real32_T(v, k0);
      v_data = v->data;
      for (k0 = 0; k0 <= nx; k0++) {
        v_data[k0] *= (float)taper_data[k0];
      }
    } else {
      d_binary_expand_op(v, taper);
    }
    if (filtereddata->size[1] == taper->size[1]) {
      k0 = w->size[0] * w->size[1];
      w->size[0] = 1;
      w->size[1] = filtereddata->size[1];
      emxEnsureCapacity_real32_T(w, k0);
      w_data = w->data;
      nx = filtereddata->size[1];
      for (k0 = 0; k0 < nx; k0++) {
        w_data[k0] = filtereddata_data[k0] * (float)taper_data[k0];
      }
    } else {
      c_binary_expand_op(w, filtereddata, taper);
    }
    /*  then rescale to regain the same original variance */
    fe = sqrtf(fe / var(u));
    k0 = u->size[0] * u->size[1];
    u->size[0] = 1;
    emxEnsureCapacity_real32_T(u, k0);
    u_data = u->data;
    nx = u->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      u_data[k0] *= fe;
    }
    fe = sqrtf(x / var(v));
    k0 = v->size[0] * v->size[1];
    v->size[0] = 1;
    emxEnsureCapacity_real32_T(v, k0);
    v_data = v->data;
    nx = v->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      v_data[k0] *= fe;
    }
    fe = sqrtf(var(filtereddata) / var(w));
    k0 = w->size[0] * w->size[1];
    w->size[0] = 1;
    emxEnsureCapacity_real32_T(w, k0);
    w_data = w->data;
    nx = w->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      w_data[k0] *= fe;
    }
    /*  FFT */
    /*  calculate Fourier coefs (complex values, double sided) */
    fft(u, b_u);
    fft(v, b_v);
    fft(w, b_w);
    /*  second half of Matlab's FFT is redundant, so throw it out */
    k0 = r->size[0] * r->size[1];
    r->size[0] = 1;
    r->size[1] = (int)(wpts - d) + 1;
    emxEnsureCapacity_int32_T(r, k0);
    r2 = r->data;
    for (k0 = 0; k0 <= loop_ub_tmp; k0++) {
      r2[k0] = (int)(d + (double)k0);
    }
    nullAssignment(b_u, r);
    b_u_data = b_u->data;
    k0 = r->size[0] * r->size[1];
    r->size[0] = 1;
    r->size[1] = (int)(wpts - d) + 1;
    emxEnsureCapacity_int32_T(r, k0);
    r2 = r->data;
    for (k0 = 0; k0 <= loop_ub_tmp; k0++) {
      r2[k0] = (int)(d + (double)k0);
    }
    nullAssignment(b_v, r);
    b_v_data = b_v->data;
    k0 = r->size[0] * r->size[1];
    r->size[0] = 1;
    r->size[1] = (int)(wpts - d) + 1;
    emxEnsureCapacity_int32_T(r, k0);
    r2 = r->data;
    for (k0 = 0; k0 <= loop_ub_tmp; k0++) {
      r2[k0] = (int)(d + (double)k0);
    }
    nullAssignment(b_w, r);
    b_w_data = b_w->data;
    /*  throw out the mean (first coef) and add a zero (to make it the right
     * length)   */
    nxin = b_u->size[1];
    nx = b_u->size[1] - 1;
    for (k = 0; k < nx; k++) {
      b_u_data[k] = b_u_data[k + 1];
    }
    k0 = b_u->size[0] * b_u->size[1];
    if (nx < 1) {
      b_u->size[1] = 0;
    } else {
      b_u->size[1] = nxin - 1;
    }
    emxEnsureCapacity_creal32_T(b_u, k0);
    b_u_data = b_u->data;
    nxin = b_v->size[1];
    nx = b_v->size[1] - 1;
    for (k = 0; k < nx; k++) {
      b_v_data[k] = b_v_data[k + 1];
    }
    k0 = b_v->size[0] * b_v->size[1];
    if (nx < 1) {
      b_v->size[1] = 0;
    } else {
      b_v->size[1] = nxin - 1;
    }
    emxEnsureCapacity_creal32_T(b_v, k0);
    b_v_data = b_v->data;
    nxin = b_w->size[1];
    nx = b_w->size[1] - 1;
    for (k = 0; k < nx; k++) {
      b_w_data[k] = b_w_data[k + 1];
    }
    k0 = b_w->size[0] * b_w->size[1];
    if (nx < 1) {
      b_w->size[1] = 0;
    } else {
      b_w->size[1] = nxin - 1;
    }
    emxEnsureCapacity_creal32_T(b_w, k0);
    b_w_data = b_w->data;
    b_u_data[(int)d1 - 1].re = 0.0F;
    b_u_data[(int)d1 - 1].im = 0.0F;
    b_v_data[(int)rawf_tmp - 1].re = 0.0F;
    b_v_data[(int)rawf_tmp - 1].im = 0.0F;
    b_w_data[(int)rawf_tmp - 1].re = 0.0F;
    b_w_data[(int)rawf_tmp - 1].im = 0.0F;
    /*  merge frequency bands (moved up to top of code) */
    /*  Nyquist = fs / 2;     % highest spectral frequency  */
    /*  f1 = 1./(wpts./fs);    % frequency resolution  */
    /*  rawf = linspace(f1, Nyquist, round(wpts/2)); % raw frequency bands */
    /*  n = (wpts/2) / merge;                         % number of f bands after
     * merging */
    /*  bandwidth = Nyquist/n ;                    % freq (Hz) bandwitdh after
     * merging */
    /*  % find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF
     * BANDS! */
    /*  f = 1/(wsecs) + bandwidth/2 + bandwidth.*(0:(n-1)) ;  */
    k0 = c_u->size[0] * c_u->size[1];
    c_u->size[0] = 1;
    c_u->size[1] = b_u->size[1];
    emxEnsureCapacity_creal32_T(c_u, k0);
    c_u_data = c_u->data;
    nx = b_u->size[0] * b_u->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      c_u_data[k0] = b_u_data[k0];
    }
    interp1(rawf, c_u, f, b_u);
    k0 = c_u->size[0] * c_u->size[1];
    c_u->size[0] = 1;
    c_u->size[1] = b_v->size[1];
    emxEnsureCapacity_creal32_T(c_u, k0);
    c_u_data = c_u->data;
    nx = b_v->size[0] * b_v->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      c_u_data[k0] = b_v_data[k0];
    }
    interp1(rawf, c_u, f, b_v);
    k0 = c_u->size[0] * c_u->size[1];
    c_u->size[0] = 1;
    c_u->size[1] = b_w->size[1];
    emxEnsureCapacity_creal32_T(c_u, k0);
    c_u_data = c_u->data;
    nx = b_w->size[0] * b_w->size[1] - 1;
    for (k0 = 0; k0 <= nx; k0++) {
      c_u_data[k0] = b_w_data[k0];
    }
    interp1(rawf, c_u, f, b_w);
    /*  remove the high frequency tail (to save memory) */
    k0 = b_f->size[0] * b_f->size[1];
    b_f->size[0] = 1;
    b_f->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(b_f, k0);
    b_f_data = b_f->data;
    nx = f->size[1];
    for (k0 = 0; k0 < nx; k0++) {
      b_f_data[k0] = (f_data[k0] > 0.5);
    }
    b_nullAssignment(b_u, b_f);
    b_u_data = b_u->data;
    k0 = b_f->size[0] * b_f->size[1];
    b_f->size[0] = 1;
    b_f->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(b_f, k0);
    b_f_data = b_f->data;
    nx = f->size[1];
    for (k0 = 0; k0 < nx; k0++) {
      b_f_data[k0] = (f_data[k0] > 0.5);
    }
    b_nullAssignment(b_v, b_f);
    b_v_data = b_v->data;
    k0 = b_f->size[0] * b_f->size[1];
    b_f->size[0] = 1;
    b_f->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(b_f, k0);
    b_f_data = b_f->data;
    nx = f->size[1];
    for (k0 = 0; k0 < nx; k0++) {
      b_f_data[k0] = (f_data[k0] > 0.5);
    }
    b_nullAssignment(b_w, b_f);
    b_w_data = b_w->data;
    k0 = b_f->size[0] * b_f->size[1];
    b_f->size[0] = 1;
    b_f->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(b_f, k0);
    b_f_data = b_f->data;
    nx = f->size[1];
    for (k0 = 0; k0 < nx; k0++) {
      b_f_data[k0] = (f_data[k0] > 0.5);
    }
    nxin = f->size[1];
    b_n = 0;
    k0 = b_f->size[1];
    for (k = 0; k < k0; k++) {
      b_n += b_f_data[k];
    }
    nx = f->size[1] - b_n;
    k0 = -1;
    for (k = 0; k < nxin; k++) {
      if ((k + 1 > b_f->size[1]) || (!b_f_data[k])) {
        k0++;
        f_data[k0] = f_data[k];
      }
    }
    k0 = f->size[0] * f->size[1];
    if (nx < 1) {
      f->size[1] = 0;
    } else {
      f->size[1] = nx;
    }
    emxEnsureCapacity_real_T(f, k0);
    f_data = f->data;
    /*  accumulate POWER SPECTRAL DENSITY (auto-spectra) from this window */
    if (b_u->size[1] == 42) {
      for (k0 = 0; k0 < 42; k0++) {
        u_re_tmp = b_u_data[k0].re;
        fe = b_u_data[k0].im;
        UU[k0] += (u_re_tmp * u_re_tmp - fe * -fe) / (float)y;
      }
    } else {
      b_binary_expand_op(UU, b_u, y);
    }
    if (b_v->size[1] == 42) {
      for (k0 = 0; k0 < 42; k0++) {
        x = b_v_data[k0].re;
        fe = b_v_data[k0].im;
        VV[k0] += (x * x - fe * -fe) / (float)y_tmp;
      }
    } else {
      b_binary_expand_op(VV, b_v, y_tmp);
    }
    if (b_w->size[1] == 42) {
      for (k0 = 0; k0 < 42; k0++) {
        fe = b_w_data[k0].re;
        x = b_w_data[k0].im;
        WW[k0] += (fe * fe - x * -x) / (float)y_tmp;
      }
    } else {
      b_binary_expand_op(WW, b_w, y_tmp);
    }
    /*  accumulate CROSS-SPECTRAL DENSITY from this window */
    if (b_u->size[1] == 1) {
      b_n = b_v->size[1];
    } else {
      b_n = b_u->size[1];
    }
    if ((b_u->size[1] == b_v->size[1]) && (b_n == 42)) {
      for (k0 = 0; k0 < 42; k0++) {
        v_re = b_v_data[k0].re;
        fe = -b_v_data[k0].im;
        u_re_tmp = b_u_data[k0].re;
        x = b_u_data[k0].im;
        u_re = u_re_tmp * v_re - x * fe;
        fe = u_re_tmp * fe + x * v_re;
        if (fe == 0.0F) {
          u_re /= (float)y_tmp;
          fe = 0.0F;
        } else if (u_re == 0.0F) {
          u_re = 0.0F;
          fe /= (float)y_tmp;
        } else {
          u_re /= (float)y_tmp;
          fe /= (float)y_tmp;
        }
        UV[k0].re += u_re;
        UV[k0].im += fe;
      }
    } else {
      binary_expand_op(UV, b_u, b_v, y_tmp);
    }
    if (b_u->size[1] == 1) {
      b_n = b_w->size[1];
    } else {
      b_n = b_u->size[1];
    }
    if ((b_u->size[1] == b_w->size[1]) && (b_n == 42)) {
      for (k0 = 0; k0 < 42; k0++) {
        w_re = b_w_data[k0].re;
        w_im = -b_w_data[k0].im;
        u_re_tmp = b_u_data[k0].re;
        x = b_u_data[k0].im;
        u_re = u_re_tmp * w_re - x * w_im;
        fe = u_re_tmp * w_im + x * w_re;
        if (fe == 0.0F) {
          u_re /= (float)y_tmp;
          fe = 0.0F;
        } else if (u_re == 0.0F) {
          u_re = 0.0F;
          fe /= (float)y_tmp;
        } else {
          u_re /= (float)y_tmp;
          fe /= (float)y_tmp;
        }
        UW[k0].re += u_re;
        UW[k0].im += fe;
      }
    } else {
      binary_expand_op(UW, b_u, b_w, y_tmp);
    }
    if (b_v->size[1] == 1) {
      b_n = b_w->size[1];
    } else {
      b_n = b_v->size[1];
    }
    if ((b_v->size[1] == b_w->size[1]) && (b_n == 42)) {
      for (k0 = 0; k0 < 42; k0++) {
        w_re = b_w_data[k0].re;
        w_im = -b_w_data[k0].im;
        x = b_v_data[k0].re;
        fe = b_v_data[k0].im;
        v_re = x * w_re - fe * w_im;
        fe = x * w_im + fe * w_re;
        if (fe == 0.0F) {
          v_re /= (float)y_tmp;
          fe = 0.0F;
        } else if (v_re == 0.0F) {
          v_re = 0.0F;
          fe /= (float)y_tmp;
        } else {
          v_re /= (float)y_tmp;
          fe /= (float)y_tmp;
        }
        VW[k0].re += v_re;
        VW[k0].im += fe;
      }
    } else {
      binary_expand_op(VW, b_v, b_w, y_tmp);
    }
  }
  emxFree_creal32_T(&c_u);
  emxFree_boolean_T(&b_f);
  emxFree_int32_T(&r);
  emxFree_real_T(&u_tmp);
  emxFree_creal32_T(&b_w);
  emxFree_creal32_T(&b_v);
  emxFree_creal32_T(&b_u);
  emxFree_real_T(&taper);
  emxFree_real32_T(&filtereddata);
  emxFree_real32_T(&w);
  /*  close window loop */
  /*  divide accumulated results by number of windows (effectively an ensemble
   * avg) */
  /*  wave spectral moments  */
  /*  see definitions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012,
   * Thomson et al, J Tech 2018 */
  /* Qxz = imag(UW); % quadspectrum of vertical and east horizontal motion */
  /* Cxz = real(UW); % cospectrum of vertical and east horizontal motion */
  /* Qyz = imag(VW); % quadspectrum of vertical and north horizontal motion */
  /* Cyz = real(VW); % cospectrum of vertical and north horizontal motion */
  /* Cxy = real(UV) ./ ( (2*pi*f).^2 );  % cospectrum of east and north motion
   */
  for (k = 0; k < 42; k++) {
    w_re = UU[k] / (float)windows * 3.0F;
    UU[k] = w_re;
    w_im = VV[k] / (float)windows * 3.0F;
    VV[k] = w_im;
    v_re = WW[k] / (float)windows * 3.0F;
    WW[k] = v_re;
    fe = UV[k].re;
    u_re_tmp = UV[k].im;
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
    UV[k].re = 3.0F * x;
    UV[k].im = 3.0F * fe;
    fe = UW[k].re;
    u_re_tmp = UW[k].im;
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
    u_re = 3.0F * fe;
    UW[k].re = 3.0F * x;
    UW[k].im = u_re;
    fe = VW[k].re;
    u_re_tmp = VW[k].im;
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
    fe *= 3.0F;
    VW[k].re = 3.0F * x;
    VW[k].im = fe;
    w_re += w_im;
    y_tmp_tmp[k] = w_re;
    w_re = sqrtf(w_re * v_re);
    b_a1[k] = u_re / w_re;
    w_re = fe / w_re;
    b_b1[k] = w_re;
  }
  /*  Scalar energy spectra (a0) */
  i = rawf->size[0] * rawf->size[1];
  rawf->size[0] = 1;
  rawf->size[1] = f->size[1];
  emxEnsureCapacity_real_T(rawf, i);
  taper_data = rawf->data;
  nx = f->size[1];
  for (i = 0; i < nx; i++) {
    Nyquist = 6.2831853071795862 * f_data[i];
    taper_data[i] = Nyquist * Nyquist;
  }
  if (rawf->size[1] == 42) {
    for (i = 0; i < 42; i++) {
      b_E[i] = y_tmp_tmp[i] / (float)taper_data[i];
    }
  } else {
    e_binary_expand_op(b_E, y_tmp_tmp, rawf);
  }
  emxFree_real_T(&rawf);
  /*  assumes perfectly circular deepwater orbits */
  /*  E = ( WW ) ./ ( (2*pi*f).^2 ); % arbitrary depth, but more noise? */
  /*  use orbit shape as check on quality (=1 in deep water) */
  /*  wave stats */
  /*  frequency cutoff for wave stats */
  /*  significant wave height */
  k0 = f->size[1] - 1;
  nx = 0;
  for (nxin = 0; nxin <= k0; nxin++) {
    if (f_data[nxin] > 0.05) {
      nx++;
    }
  }
  emxInit_int32_T(&r1, 2);
  i = r1->size[0] * r1->size[1];
  r1->size[0] = 1;
  r1->size[1] = nx;
  emxEnsureCapacity_int32_T(r1, i);
  r2 = r1->data;
  b_n = 0;
  for (nxin = 0; nxin <= k0; nxin++) {
    if (f_data[nxin] > 0.05) {
      r2[b_n] = nxin + 1;
      b_n++;
    }
  }
  /*   energy period */
  k0 = f->size[1] - 1;
  nx = 0;
  for (nxin = 0; nxin <= k0; nxin++) {
    if (f_data[nxin] > 0.05) {
      nx++;
    }
  }
  emxInit_int32_T(&r3, 2);
  i = r3->size[0] * r3->size[1];
  r3->size[0] = 1;
  r3->size[1] = nx;
  emxEnsureCapacity_int32_T(r3, i);
  r4 = r3->data;
  b_n = 0;
  for (nxin = 0; nxin <= k0; nxin++) {
    if (f_data[nxin] > 0.05) {
      r4[b_n] = nxin + 1;
      b_n++;
    }
  }
  i = u->size[0] * u->size[1];
  u->size[0] = 1;
  u->size[1] = r3->size[1];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  nx = r3->size[1];
  for (i = 0; i < nx; i++) {
    k0 = r4[i];
    u_data[i] = (float)f_data[k0 - 1] * b_E[k0 - 1];
  }
  i = v->size[0] * v->size[1];
  v->size[0] = 1;
  v->size[1] = r3->size[1];
  emxEnsureCapacity_real32_T(v, i);
  v_data = v->data;
  nx = r3->size[1];
  for (i = 0; i < nx; i++) {
    v_data[i] = b_E[r4[i] - 1];
  }
  emxFree_int32_T(&r3);
  fe = combineVectorElements(u) / combineVectorElements(v);
  i = v->size[0] * v->size[1];
  v->size[0] = 1;
  v->size[1] = f->size[1];
  emxEnsureCapacity_real32_T(v, i);
  v_data = v->data;
  nx = f->size[1];
  for (i = 0; i < nx; i++) {
    v_data[i] = (float)f_data[i] - fe;
  }
  nx = v->size[1];
  i = u->size[0] * u->size[1];
  u->size[0] = 1;
  u->size[1] = v->size[1];
  emxEnsureCapacity_real32_T(u, i);
  u_data = u->data;
  for (k = 0; k < nx; k++) {
    u_data[k] = fabsf(v_data[k]);
  }
  minimum(u, &x, &b_n);
  /*  peak period */
  /* [~ , fpindex] = max(UU+VV); % can use velocity (picks out more distint
   * peak) */
  maximum(b_E, &x, &nx);
  Nyquist = 1.0 / f_data[nx - 1];
  emxFree_real32_T(&u);
  if (Nyquist > 18.0) {
    /*  if reasonable peak not found, use centroid */
    Nyquist = 1.0F / fe;
    nx = b_n;
  }
  /*  wave directions */
  /*  peak wave direction, rotated to geographic conventions */
  /*  [rad], 4 quadrant */
  /*  switch from rad to deg, and CCW to CW (negate) */
  fe = -57.3248405F * rt_atan2f_snf(b_b1[nx - 1], b_a1[nx - 1]) + 90.0F;
  /*  rotate from eastward = 0 to northward  = 0 */
  if (fe < 0.0F) {
    fe += 360.0F;
  }
  /*  take NW quadrant from negative to 270-360 range */
  if (fe > 180.0F) {
    fe -= 180.0F;
  }
  /*  take reciprocal such wave direction is FROM, not TOWARDS */
  if (fe < 180.0F) {
    fe += 180.0F;
  }
  /*  take reciprocal such wave direction is FROM, not TOWARDS */
  /*  format for microSWIFT telemetry output (payload type 52) */
  i = v->size[0] * v->size[1];
  v->size[0] = 1;
  v->size[1] = r1->size[1];
  emxEnsureCapacity_real32_T(v, i);
  v_data = v->data;
  nx = r1->size[1];
  for (i = 0; i < nx; i++) {
    v_data[i] = b_E[r2[i] - 1];
  }
  emxFree_int32_T(&r1);
  *Hs = floatToHalf(
      4.0F * sqrtf(combineVectorElements(v) * (float)(f_data[1] - f_data[0])));
  *Tp = doubleToHalf(Nyquist);
  *Dp = floatToHalf(fe);
  *b_fmin = doubleToHalf(b_minimum(f));
  *b_fmax = doubleToHalf(b_maximum(f));
  emxFree_real32_T(&v);
  emxFree_real_T(&f);
  for (i = 0; i < 42; i++) {
    unsigned char d_u;
    signed char i1;
    E[i] = floatToHalf(b_E[i]);
    w_re = roundf(b_a1[i] * 100.0F);
    if (w_re < 128.0F) {
      if (w_re >= -128.0F) {
        i1 = (signed char)w_re;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (w_re >= 128.0F) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    a1[i] = i1;
    w_re = roundf(b_b1[i] * 100.0F);
    if (w_re < 128.0F) {
      if (w_re >= -128.0F) {
        i1 = (signed char)w_re;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (w_re >= 128.0F) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    b1[i] = i1;
    w_re = y_tmp_tmp[i];
    w_im = roundf((UU[i] - VV[i]) / w_re * 100.0F);
    if (w_im < 128.0F) {
      if (w_im >= -128.0F) {
        i1 = (signed char)w_im;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (w_im >= 128.0F) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    a2[i] = i1;
    w_im = roundf(2.0F * UV[i].re / w_re * 100.0F);
    if (w_im < 128.0F) {
      if (w_im >= -128.0F) {
        i1 = (signed char)w_im;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (w_im >= 128.0F) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    b2[i] = i1;
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
