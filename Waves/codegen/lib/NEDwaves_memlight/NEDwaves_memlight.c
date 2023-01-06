/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves_memlight.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jan-2023 10:46:55
 */

/* Include Files */
#include "NEDwaves_memlight.h"
#include "NEDwaves_memlight_data.h"
#include "NEDwaves_memlight_emxutil.h"
#include "NEDwaves_memlight_types.h"
#include "fft.h"
#include "interp1.h"
#include "mean.h"
#include "nullAssignment.h"
#include "rt_nonfinite.h"
#include "rtwhalf.h"
#include "var.h"
#include "rt_defines.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Declarations */
static void b_binary_expand_op(emxArray_real32_T *in1,
                               const emxArray_real_T *in2);

static void binary_expand_op(creal32_T in1[42], const emxArray_real_T *in2,
                             const emxArray_creal32_T *in3,
                             const emxArray_creal32_T *in4, double in5);

static float rt_atan2f_snf(float u0, float u1);

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
 * Arguments    : creal32_T in1[42]
 *                const emxArray_real_T *in2
 *                const emxArray_creal32_T *in3
 *                const emxArray_creal32_T *in4
 *                double in5
 * Return Type  : void
 */
static void binary_expand_op(creal32_T in1[42], const emxArray_real_T *in2,
                             const emxArray_creal32_T *in3,
                             const emxArray_creal32_T *in4, double in5)
{
  emxArray_creal32_T *b_in3;
  const creal32_T *in3_data;
  const creal32_T *in4_data;
  creal32_T *b_in3_data;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in4_data = in4->data;
  in3_data = in3->data;
  emxInit_creal32_T(&b_in3, 2);
  i = b_in3->size[0] * b_in3->size[1];
  b_in3->size[0] = 1;
  if (in4->size[1] == 1) {
    b_in3->size[1] = in3->size[1];
  } else {
    b_in3->size[1] = in4->size[1];
  }
  emxEnsureCapacity_creal32_T(b_in3, i);
  b_in3_data = b_in3->data;
  stride_0_1 = (in3->size[1] != 1);
  stride_1_1 = (in4->size[1] != 1);
  if (in4->size[1] == 1) {
    loop_ub = in3->size[1];
  } else {
    loop_ub = in4->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    float in3_re;
    float in4_im;
    float in4_re;
    int in4_re_tmp;
    in4_re_tmp = i * stride_1_1;
    in4_re = in4_data[in4_re_tmp].re;
    in4_im = -in4_data[in4_re_tmp].im;
    in3_re = in3_data[i * stride_0_1].re * in4_re -
             in3_data[i * stride_0_1].im * in4_im;
    in4_re = in3_data[i * stride_0_1].re * in4_im +
             in3_data[i * stride_0_1].im * in4_re;
    if (in4_re == 0.0F) {
      b_in3_data[i].re = in3_re / (float)in5;
      b_in3_data[i].im = 0.0F;
    } else if (in3_re == 0.0F) {
      b_in3_data[i].re = 0.0F;
      b_in3_data[i].im = in4_re / (float)in5;
    } else {
      b_in3_data[i].re = in3_re / (float)in5;
      b_in3_data[i].im = in4_re / (float)in5;
    }
  }
  b_interp1(in2, b_in3, in1);
  emxFree_creal32_T(&b_in3);
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
  static const float fv[42] = {
      0.00394784193F, 0.0190229136F, 0.0453755222F, 0.0830056593F, 0.131913334F,
      0.192098558F,   0.263561308F,  0.346301585F,  0.440319389F,  0.545614719F,
      0.662187636F,   0.790038049F,  0.929166F,     1.07957149F,   1.24125457F,
      1.41421509F,    1.59845316F,   1.7939688F,    2.00076199F,   2.21883273F,
      2.44818091F,    2.68880677F,   2.94071F,      3.2038908F,    3.47834921F,
      3.76408505F,    4.06109858F,   4.36938953F,   4.68895817F,   5.019804F,
      5.36192751F,    5.71532869F,   6.08000755F,   6.45596361F,   6.84319735F,
      7.24170876F,    7.65149736F,   8.07256413F,   8.50490761F,   8.94852924F,
      9.40342808F,    9.86960411F};
  static const float fv2[42] = {
      0.01F,        0.0219512191F, 0.0339024402F, 0.0458536595F, 0.0578048788F,
      0.0697561F,   0.0817073137F, 0.0936585367F, 0.10560976F,   0.117560975F,
      0.129512191F, 0.141463414F,  0.153414637F,  0.16536586F,   0.177317068F,
      0.189268291F, 0.201219514F,  0.213170737F,  0.225121945F,  0.237073168F,
      0.249024391F, 0.260975599F,  0.272926837F,  0.284878045F,  0.296829253F,
      0.308780491F, 0.320731699F,  0.332682937F,  0.344634145F,  0.356585354F,
      0.368536592F, 0.3804878F,    0.392439038F,  0.404390246F,  0.416341454F,
      0.428292692F, 0.4402439F,    0.452195108F,  0.464146346F,  0.476097554F,
      0.488048792F, 0.5F};
  static const float fv1[38] = {
      0.0578048788F, 0.0697561F,   0.0817073137F, 0.0936585367F, 0.10560976F,
      0.117560975F,  0.129512191F, 0.141463414F,  0.153414637F,  0.16536586F,
      0.177317068F,  0.189268291F, 0.201219514F,  0.213170737F,  0.225121945F,
      0.237073168F,  0.249024391F, 0.260975599F,  0.272926837F,  0.284878045F,
      0.296829253F,  0.308780491F, 0.320731699F,  0.332682937F,  0.344634145F,
      0.356585354F,  0.368536592F, 0.3804878F,    0.392439038F,  0.404390246F,
      0.416341454F,  0.428292692F, 0.4402439F,    0.452195108F,  0.464146346F,
      0.476097554F,  0.488048792F, 0.5F};
  emxArray_boolean_T *b_taper;
  emxArray_creal32_T *U;
  emxArray_creal32_T *V;
  emxArray_creal32_T *W;
  emxArray_creal32_T *c_U;
  emxArray_int32_T *r;
  emxArray_real32_T *b_U;
  emxArray_real_T *taper;
  creal32_T fcv[42];
  creal32_T *U_data;
  creal32_T *V_data;
  creal32_T *W_data;
  creal32_T *b_U_data;
  double x_tmp_data[42];
  double d;
  double d1;
  double delta1;
  double delta2;
  double *taper_data;
  float UU[42];
  float VV[42];
  float WW[42];
  float b_E[42];
  float b_a1[42];
  float b_b1[42];
  float varargin_1[42];
  float x_tmp_tmp[42];
  float c_x[38];
  float U_re;
  float V_re;
  float W_im;
  float W_re;
  float b_x;
  float fe;
  float x;
  float *north_data;
  int i;
  int k;
  int nx;
  int nxin;
  int nxout;
  int pts;
  int *r1;
  signed char i1;
  bool exitg1;
  bool *b_taper_data;
  /*  parameters  */
  /* testing = true; */
  pts = east->size[1];
  /*  length of the input data (should be 2^N for efficiency) */
  /*  min frequecny for final output, Hz */
  /*  max frequecny for final output, Hz */
  /*  number of frequency bands in final result */
  /*  remove the mean */
  x = mean(north);
  nx = north->size[1] - 1;
  i = north->size[0] * north->size[1];
  north->size[0] = 1;
  emxEnsureCapacity_real32_T(north, i);
  north_data = north->data;
  for (i = 0; i <= nx; i++) {
    north_data[i] -= x;
  }
  x = mean(east);
  nx = east->size[1] - 1;
  i = east->size[0] * east->size[1];
  east->size[0] = 1;
  emxEnsureCapacity_real32_T(east, i);
  north_data = east->data;
  for (i = 0; i <= nx; i++) {
    north_data[i] -= x;
  }
  x = mean(down);
  nx = down->size[1] - 1;
  i = down->size[0] * down->size[1];
  down->size[0] = 1;
  emxEnsureCapacity_real32_T(down, i);
  north_data = down->data;
  for (i = 0; i <= nx; i++) {
    north_data[i] -= x;
  }
  emxInit_real_T(&taper);
  /*  taper and rescale (to preserve variance) */
  /*  get original variance of each  */
  b_x = var(north);
  fe = var(east);
  x = var(down);
  /*  define the taper */
  if (pts < 1) {
    taper->size[1] = 0;
  } else {
    i = taper->size[0] * taper->size[1];
    taper->size[0] = 1;
    taper->size[1] = pts;
    emxEnsureCapacity_real_T(taper, i);
    taper_data = taper->data;
    nx = pts - 1;
    for (i = 0; i <= nx; i++) {
      taper_data[i] = (double)i + 1.0;
    }
  }
  i = taper->size[0] * taper->size[1];
  taper->size[0] = 1;
  emxEnsureCapacity_real_T(taper, i);
  taper_data = taper->data;
  nx = taper->size[1] - 1;
  for (i = 0; i <= nx; i++) {
    taper_data[i] = taper_data[i] * 3.1415926535897931 / (double)pts;
  }
  nx = taper->size[1];
  for (k = 0; k < nx; k++) {
    taper_data[k] = sin(taper_data[k]);
  }
  /*  apply the taper */
  if (north->size[1] == taper->size[1]) {
    nx = north->size[1] - 1;
    i = north->size[0] * north->size[1];
    north->size[0] = 1;
    emxEnsureCapacity_real32_T(north, i);
    north_data = north->data;
    for (i = 0; i <= nx; i++) {
      north_data[i] *= (float)taper_data[i];
    }
  } else {
    b_binary_expand_op(north, taper);
  }
  if (east->size[1] == taper->size[1]) {
    nx = east->size[1] - 1;
    i = east->size[0] * east->size[1];
    east->size[0] = 1;
    emxEnsureCapacity_real32_T(east, i);
    north_data = east->data;
    for (i = 0; i <= nx; i++) {
      north_data[i] *= (float)taper_data[i];
    }
  } else {
    b_binary_expand_op(east, taper);
  }
  if (down->size[1] == taper->size[1]) {
    nx = down->size[1] - 1;
    i = down->size[0] * down->size[1];
    down->size[0] = 1;
    emxEnsureCapacity_real32_T(down, i);
    north_data = down->data;
    for (i = 0; i <= nx; i++) {
      north_data[i] *= (float)taper_data[i];
    }
  } else {
    b_binary_expand_op(down, taper);
  }
  /*  then rescale to regain the same original variance */
  b_x = sqrtf(b_x / var(north));
  i = north->size[0] * north->size[1];
  north->size[0] = 1;
  emxEnsureCapacity_real32_T(north, i);
  north_data = north->data;
  nx = north->size[1] - 1;
  for (i = 0; i <= nx; i++) {
    north_data[i] *= b_x;
  }
  b_x = sqrtf(fe / var(east));
  i = east->size[0] * east->size[1];
  east->size[0] = 1;
  emxEnsureCapacity_real32_T(east, i);
  north_data = east->data;
  nx = east->size[1] - 1;
  for (i = 0; i <= nx; i++) {
    north_data[i] *= b_x;
  }
  b_x = sqrtf(x / var(down));
  i = down->size[0] * down->size[1];
  down->size[0] = 1;
  emxEnsureCapacity_real32_T(down, i);
  north_data = down->data;
  nx = down->size[1] - 1;
  for (i = 0; i <= nx; i++) {
    north_data[i] *= b_x;
  }
  emxInit_creal32_T(&U, 2);
  emxInit_creal32_T(&V, 2);
  emxInit_creal32_T(&W, 2);
  emxInit_int32_T(&r, 2);
  /*  FFT, note convention for lower case as time-domain and upper case as freq
   * domain */
  /*  calculate Fourier coefs (complex values, double sided) */
  fft(east, U);
  fft(north, V);
  fft(down, W);
  /*  second half of Matlab's FFT is redundant, so throw it out */
  d = (double)pts / 2.0;
  i = (int)rt_roundd_snf(d + 1.0);
  nxout = r->size[0] * r->size[1];
  r->size[0] = 1;
  nx = pts - i;
  r->size[1] = nx + 1;
  emxEnsureCapacity_int32_T(r, nxout);
  r1 = r->data;
  for (nxout = 0; nxout <= nx; nxout++) {
    r1[nxout] = i + nxout;
  }
  nullAssignment(U, r);
  U_data = U->data;
  nxout = r->size[0] * r->size[1];
  r->size[0] = 1;
  nx = pts - i;
  r->size[1] = nx + 1;
  emxEnsureCapacity_int32_T(r, nxout);
  r1 = r->data;
  for (nxout = 0; nxout <= nx; nxout++) {
    r1[nxout] = i + nxout;
  }
  nullAssignment(V, r);
  V_data = V->data;
  nxout = r->size[0] * r->size[1];
  r->size[0] = 1;
  nx = pts - i;
  r->size[1] = nx + 1;
  emxEnsureCapacity_int32_T(r, nxout);
  r1 = r->data;
  for (nxout = 0; nxout <= nx; nxout++) {
    r1[nxout] = i + nxout;
  }
  nullAssignment(W, r);
  W_data = W->data;
  /*  throw out the mean (first coef) and add a zero (to make it the right
   * length)   */
  nxin = U->size[1];
  nxout = U->size[1] - 1;
  emxFree_int32_T(&r);
  for (k = 0; k < nxout; k++) {
    U_data[k] = U_data[k + 1];
  }
  i = U->size[0] * U->size[1];
  if (nxout < 1) {
    U->size[1] = 0;
  } else {
    U->size[1] = nxin - 1;
  }
  emxEnsureCapacity_creal32_T(U, i);
  U_data = U->data;
  nxin = V->size[1];
  nxout = V->size[1] - 1;
  for (k = 0; k < nxout; k++) {
    V_data[k] = V_data[k + 1];
  }
  i = V->size[0] * V->size[1];
  if (nxout < 1) {
    V->size[1] = 0;
  } else {
    V->size[1] = nxin - 1;
  }
  emxEnsureCapacity_creal32_T(V, i);
  V_data = V->data;
  nxin = W->size[1];
  nxout = W->size[1] - 1;
  for (k = 0; k < nxout; k++) {
    W_data[k] = W_data[k + 1];
  }
  i = W->size[0] * W->size[1];
  if (nxout < 1) {
    W->size[1] = 0;
  } else {
    W->size[1] = nxin - 1;
  }
  emxEnsureCapacity_creal32_T(W, i);
  W_data = W->data;
  d = rt_roundd_snf(d);
  i = (int)d;
  U_data[i - 1].re = 0.0F;
  U_data[i - 1].im = 0.0F;
  V_data[i - 1].re = 0.0F;
  V_data[i - 1].im = 0.0F;
  W_data[i - 1].re = 0.0F;
  W_data[i - 1].im = 0.0F;
  /*  determine the frequency vector */
  /*  highest spectral frequency  */
  /*  frequency resolution  */
  d1 = 1.0 / ((double)pts / fs);
  delta2 = fs / 2.0;
  nxout = taper->size[0] * taper->size[1];
  taper->size[0] = 1;
  taper->size[1] = i;
  emxEnsureCapacity_real_T(taper, nxout);
  taper_data = taper->data;
  if (i >= 1) {
    nx = i - 1;
    taper_data[i - 1] = delta2;
    if (taper->size[1] >= 2) {
      taper_data[0] = d1;
      if (taper->size[1] >= 3) {
        if ((d1 == -delta2) && (i > 2)) {
          delta2 /= (double)i - 1.0;
          for (k = 2; k <= nx; k++) {
            taper_data[k - 1] = ((double)((k << 1) - i) - 1.0) * delta2;
          }
          if ((i & 1) == 1) {
            taper_data[i >> 1] = 0.0;
          }
        } else if (((d1 < 0.0) != (delta2 < 0.0)) &&
                   ((fabs(d1) > 8.9884656743115785E+307) ||
                    (fabs(delta2) > 8.9884656743115785E+307))) {
          delta1 = d1 / ((double)taper->size[1] - 1.0);
          delta2 /= (double)taper->size[1] - 1.0;
          i = taper->size[1];
          for (k = 0; k <= i - 3; k++) {
            taper_data[k + 1] =
                (d1 + delta2 * ((double)k + 1.0)) - delta1 * ((double)k + 1.0);
          }
        } else {
          delta1 = (delta2 - d1) / ((double)taper->size[1] - 1.0);
          i = taper->size[1];
          for (k = 0; k <= i - 3; k++) {
            taper_data[k + 1] = d1 + ((double)k + 1.0) * delta1;
          }
        }
      }
    }
  }
  emxInit_boolean_T(&b_taper);
  /*  remove high frequency tail (to save memory) */
  i = b_taper->size[0] * b_taper->size[1];
  b_taper->size[0] = 1;
  b_taper->size[1] = taper->size[1];
  emxEnsureCapacity_boolean_T(b_taper, i);
  b_taper_data = b_taper->data;
  nx = taper->size[1];
  for (i = 0; i < nx; i++) {
    b_taper_data[i] = (taper_data[i] > 0.55);
  }
  b_nullAssignment(U, b_taper);
  U_data = U->data;
  i = b_taper->size[0] * b_taper->size[1];
  b_taper->size[0] = 1;
  b_taper->size[1] = taper->size[1];
  emxEnsureCapacity_boolean_T(b_taper, i);
  b_taper_data = b_taper->data;
  nx = taper->size[1];
  for (i = 0; i < nx; i++) {
    b_taper_data[i] = (taper_data[i] > 0.55);
  }
  b_nullAssignment(V, b_taper);
  V_data = V->data;
  i = b_taper->size[0] * b_taper->size[1];
  b_taper->size[0] = 1;
  b_taper->size[1] = taper->size[1];
  emxEnsureCapacity_boolean_T(b_taper, i);
  b_taper_data = b_taper->data;
  nx = taper->size[1];
  for (i = 0; i < nx; i++) {
    b_taper_data[i] = (taper_data[i] > 0.55);
  }
  b_nullAssignment(W, b_taper);
  W_data = W->data;
  i = b_taper->size[0] * b_taper->size[1];
  b_taper->size[0] = 1;
  b_taper->size[1] = taper->size[1];
  emxEnsureCapacity_boolean_T(b_taper, i);
  b_taper_data = b_taper->data;
  nx = taper->size[1];
  for (i = 0; i < nx; i++) {
    b_taper_data[i] = (taper_data[i] > 0.55);
  }
  nxin = taper->size[1];
  nx = 0;
  i = b_taper->size[1];
  for (k = 0; k < i; k++) {
    nx += b_taper_data[k];
  }
  nxout = taper->size[1] - nx;
  nx = -1;
  for (k = 0; k < nxin; k++) {
    if ((k + 1 > b_taper->size[1]) || (!b_taper_data[k])) {
      nx++;
      taper_data[nx] = taper_data[k];
    }
  }
  emxFree_boolean_T(&b_taper);
  emxInit_real32_T(&b_U, 2);
  i = taper->size[0] * taper->size[1];
  if (nxout < 1) {
    taper->size[1] = 0;
  } else {
    taper->size[1] = nxout;
  }
  emxEnsureCapacity_real_T(taper, i);
  /*  option to interp before... prob better to wait  */
  /*  f = linspace(fmin, fmax,nf); */
  /*  U = interp1(allf, U, f);  */
  /*  V = interp1(allf, V, f);  */
  /*  W = interp1(allf, W, f);  */
  /*  POWER SPECTRAL DENSITY (auto-spectra) */
  delta1 = d * fs;
  /*  CROSS-SPECTRAL DENSITY  */
  /*  interp onto output frequencies */
  i = b_U->size[0] * b_U->size[1];
  b_U->size[0] = 1;
  b_U->size[1] = U->size[1];
  emxEnsureCapacity_real32_T(b_U, i);
  north_data = b_U->data;
  nx = U->size[1];
  for (i = 0; i < nx; i++) {
    b_x = U_data[i].re;
    fe = U_data[i].im;
    north_data[i] = (b_x * b_x - fe * -fe) / (float)delta1;
  }
  interp1(taper, b_U, UU);
  i = b_U->size[0] * b_U->size[1];
  b_U->size[0] = 1;
  b_U->size[1] = V->size[1];
  emxEnsureCapacity_real32_T(b_U, i);
  north_data = b_U->data;
  nx = V->size[1];
  for (i = 0; i < nx; i++) {
    b_x = V_data[i].re;
    fe = V_data[i].im;
    north_data[i] = (b_x * b_x - fe * -fe) / (float)delta1;
  }
  interp1(taper, b_U, VV);
  i = b_U->size[0] * b_U->size[1];
  b_U->size[0] = 1;
  b_U->size[1] = W->size[1];
  emxEnsureCapacity_real32_T(b_U, i);
  north_data = b_U->data;
  nx = W->size[1];
  for (i = 0; i < nx; i++) {
    fe = W_data[i].re;
    b_x = W_data[i].im;
    north_data[i] = (fe * fe - b_x * -b_x) / (float)delta1;
  }
  interp1(taper, b_U, WW);
  /*  wave spectral moments  */
  /*  see definitions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012,
   * Thomson et al, J Tech 2018 */
  /* Qxz = imag(UW); % quadspectrum of vertical and east horizontal motion */
  /* Cxz = real(UW); % cospectrum of vertical and east horizontal motion */
  /* Qyz = imag(VW); % quadspectrum of vertical and north horizontal motion */
  /* Cyz = real(VW); % cospectrum of vertical and north horizontal motion */
  /* Cxy = real(UV) ./ ( (2*pi*f).^2 );  % cospectrum of east and north motion
   */
  emxFree_real32_T(&b_U);
  for (k = 0; k < 42; k++) {
    x = UU[k] + VV[k];
    x_tmp_tmp[k] = x;
    x *= WW[k];
    b_b1[k] = x;
    b_a1[k] = sqrtf(x);
  }
  emxInit_creal32_T(&c_U, 2);
  if (U->size[1] == W->size[1]) {
    i = c_U->size[0] * c_U->size[1];
    c_U->size[0] = 1;
    c_U->size[1] = U->size[1];
    emxEnsureCapacity_creal32_T(c_U, i);
    b_U_data = c_U->data;
    nx = U->size[1];
    for (i = 0; i < nx; i++) {
      W_re = W_data[i].re;
      W_im = -W_data[i].im;
      b_x = U_data[i].re;
      fe = U_data[i].im;
      U_re = b_x * W_re - fe * W_im;
      fe = b_x * W_im + fe * W_re;
      if (fe == 0.0F) {
        b_U_data[i].re = U_re / (float)delta1;
        b_U_data[i].im = 0.0F;
      } else if (U_re == 0.0F) {
        b_U_data[i].re = 0.0F;
        b_U_data[i].im = fe / (float)delta1;
      } else {
        b_U_data[i].re = U_re / (float)delta1;
        b_U_data[i].im = fe / (float)delta1;
      }
    }
    b_interp1(taper, c_U, fcv);
  } else {
    binary_expand_op(fcv, taper, U, W, delta1);
  }
  for (k = 0; k < 42; k++) {
    b_a1[k] = fcv[k].im / b_a1[k];
    b_b1[k] = sqrtf(b_b1[k]);
  }
  if (V->size[1] == W->size[1]) {
    i = c_U->size[0] * c_U->size[1];
    c_U->size[0] = 1;
    c_U->size[1] = V->size[1];
    emxEnsureCapacity_creal32_T(c_U, i);
    b_U_data = c_U->data;
    nx = V->size[1];
    for (i = 0; i < nx; i++) {
      W_re = W_data[i].re;
      W_im = -W_data[i].im;
      b_x = V_data[i].re;
      x = V_data[i].im;
      V_re = b_x * W_re - x * W_im;
      x = b_x * W_im + x * W_re;
      if (x == 0.0F) {
        b_U_data[i].re = V_re / (float)delta1;
        b_U_data[i].im = 0.0F;
      } else if (V_re == 0.0F) {
        b_U_data[i].re = 0.0F;
        b_U_data[i].im = x / (float)delta1;
      } else {
        b_U_data[i].re = V_re / (float)delta1;
        b_U_data[i].im = x / (float)delta1;
      }
    }
    b_interp1(taper, c_U, fcv);
  } else {
    binary_expand_op(fcv, taper, V, W, delta1);
  }
  emxFree_creal32_T(&W);
  /*  Scalar energy spectra (a0) */
  for (i = 0; i < 42; i++) {
    b_b1[i] = fcv[i].im / b_b1[i];
    b_E[i] = x_tmp_tmp[i] / fv[i];
  }
  /*  assumes perfectly circular deepwater orbits */
  /*  E = ( WW ) ./ ( (2*pi*f).^2 ); % arbitrary depth, but more noise? */
  /*  use orbit shape as check on quality (=1 in deep water) */
  /*  wave stats */
  /*  frequency cutoff for wave stats */
  /*  significant wave height */
  W_re = b_E[4];
  for (k = 0; k < 37; k++) {
    W_re += b_E[k + 5];
  }
  /*   energy period */
  for (i = 0; i < 38; i++) {
    c_x[i] = fv1[i] * b_E[i + 4];
  }
  b_x = c_x[0];
  fe = b_E[4];
  for (k = 0; k < 37; k++) {
    b_x += c_x[k + 1];
    fe += b_E[k + 5];
  }
  fe = b_x / fe;
  for (k = 0; k < 42; k++) {
    varargin_1[k] = fabsf(fv2[k] - fe);
  }
  if (!rtIsNaNF(varargin_1[0])) {
    nxout = 1;
  } else {
    nxout = 0;
    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k < 43)) {
      if (!rtIsNaNF(varargin_1[k - 1])) {
        nxout = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }
  if (nxout == 0) {
    nxout = 1;
  } else {
    b_x = varargin_1[nxout - 1];
    i = nxout + 1;
    for (k = i; k < 43; k++) {
      x = varargin_1[k - 1];
      if (b_x > x) {
        b_x = x;
        nxout = k;
      }
    }
  }
  /*  peak period */
  /* [~ , fpindex] = max(UU+VV); % can use velocity (picks out more distint
   * peak) */
  if (!rtIsNaNF(b_E[0])) {
    nx = 1;
  } else {
    nx = 0;
    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k < 43)) {
      if (!rtIsNaNF(b_E[k - 1])) {
        nx = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }
  if (nx == 0) {
    nxin = 0;
  } else {
    b_x = b_E[nx - 1];
    nxin = nx - 1;
    i = nx + 1;
    for (k = i; k < 43; k++) {
      x = b_E[k - 1];
      if (b_x < x) {
        b_x = x;
        nxin = k - 1;
      }
    }
  }
  delta2 = 1.0 / dv[nxin];
  if (delta2 > 18.0) {
    /*  if reasonable peak not found, use centroid */
    delta2 = 1.0F / fe;
    nxin = nxout - 1;
  }
  /*  wave directions */
  /*  peak wave direction, rotated to geographic conventions */
  /*  [rad], 4 quadrant */
  /*  switch from rad to deg, and CCW to CW (negate) */
  fe = -57.3248405F * rt_atan2f_snf(b_b1[nxin], b_a1[nxin]) + 90.0F;
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
  *Hs = floatToHalf(4.0F * sqrtf(W_re * 0.0119512193F));
  *Tp = doubleToHalf(delta2);
  *Dp = floatToHalf(fe);
  for (i = 0; i < 42; i++) {
    E[i] = floatToHalf(b_E[i]);
    x_tmp_data[i] = dv[i];
  }
  delta2 = x_tmp_data[0];
  d1 = x_tmp_data[0];
  for (k = 0; k < 41; k++) {
    d = x_tmp_data[k + 1];
    if (delta2 > d) {
      delta2 = d;
    }
    if (d1 < d) {
      d1 = d;
    }
  }
  *b_fmin = doubleToHalf(delta2);
  *b_fmax = doubleToHalf(d1);
  for (i = 0; i < 42; i++) {
    x = roundf(b_a1[i] * 100.0F);
    if (x < 128.0F) {
      if (x >= -128.0F) {
        i1 = (signed char)x;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (x >= 128.0F) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    a1[i] = i1;
    x = roundf(b_b1[i] * 100.0F);
    if (x < 128.0F) {
      if (x >= -128.0F) {
        i1 = (signed char)x;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (x >= 128.0F) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    b1[i] = i1;
    x = roundf((UU[i] - VV[i]) / x_tmp_tmp[i] * 100.0F);
    if (x < 128.0F) {
      if (x >= -128.0F) {
        i1 = (signed char)x;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (x >= 128.0F) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    a2[i] = i1;
  }
  if (U->size[1] == V->size[1]) {
    i = c_U->size[0] * c_U->size[1];
    c_U->size[0] = 1;
    c_U->size[1] = U->size[1];
    emxEnsureCapacity_creal32_T(c_U, i);
    b_U_data = c_U->data;
    nx = U->size[1];
    for (i = 0; i < nx; i++) {
      V_re = V_data[i].re;
      x = -V_data[i].im;
      b_x = U_data[i].re;
      fe = U_data[i].im;
      U_re = b_x * V_re - fe * x;
      fe = b_x * x + fe * V_re;
      if (fe == 0.0F) {
        b_U_data[i].re = U_re / (float)delta1;
        b_U_data[i].im = 0.0F;
      } else if (U_re == 0.0F) {
        b_U_data[i].re = 0.0F;
        b_U_data[i].im = fe / (float)delta1;
      } else {
        b_U_data[i].re = U_re / (float)delta1;
        b_U_data[i].im = fe / (float)delta1;
      }
    }
    b_interp1(taper, c_U, fcv);
  } else {
    binary_expand_op(fcv, taper, U, V, delta1);
  }
  emxFree_creal32_T(&c_U);
  emxFree_creal32_T(&V);
  emxFree_creal32_T(&U);
  emxFree_real_T(&taper);
  for (i = 0; i < 42; i++) {
    unsigned char u;
    x = x_tmp_tmp[i];
    b_x = roundf(2.0F * fcv[i].re / x * 100.0F);
    if (b_x < 128.0F) {
      if (b_x >= -128.0F) {
        i1 = (signed char)b_x;
      } else {
        i1 = MIN_int8_T;
      }
    } else if (b_x >= 128.0F) {
      i1 = MAX_int8_T;
    } else {
      i1 = 0;
    }
    b2[i] = i1;
    x = roundf(WW[i] / x * 10.0F);
    if (x < 256.0F) {
      if (x >= 0.0F) {
        u = (unsigned char)x;
      } else {
        u = 0U;
      }
    } else if (x >= 256.0F) {
      u = MAX_uint8_T;
    } else {
      u = 0U;
    }
    check[i] = u;
  }
  /*  plots during testing */
  /*  if testing */
  /*   */
  /*      figure(2), clf */
  /*      subplot(2,1,1) */
  /*      loglog(f,E,'k:'), hold on */
  /*      loglog(f,( UU + VV) ./ ( (2*pi*f).^2 ), f, ( WW ) ./ ( (2*pi*f).^2 ) )
   */
  /*      set(gca,'YLim',[1e-3 2e2]) */
  /*      legend('E','E=(UU+VV)/f^2','E=WW/f^2') */
  /*      ylabel('Energy [m^2/Hz]') */
  /*      title(['Hs = ' num2str(Hs,2) ', Tp = ' num2str(Tp,2) ', Dp = '
   * num2str(Dp,3)]) */
  /*      subplot(2,1,2) */
  /*      semilogx(f,double(a1)./100, f,double(b1)./100, f,double(a2)./100,
   * f,double(b2)./100) */
  /*      set(gca,'YLim',[-1 1]) */
  /*      legend('a1','b1','a2','b2') */
  /*      xlabel('frequency [Hz]') */
  /*      drawnow */
  /*   */
  /*  end */
}

/*
 * File trailer for NEDwaves_memlight.c
 *
 * [EOF]
 */
