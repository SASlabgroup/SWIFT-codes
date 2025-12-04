/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: XYZaccelerationspectra.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 03-Dec-2025 20:33:49
 */

/* Include Files */
#include "XYZaccelerationspectra.h"
#include "XYZaccelerationspectra_emxutil.h"
#include "XYZaccelerationspectra_types.h"
#include "colon.h"
#include "fft.h"
#include "mean.h"
#include "minOrMax.h"
#include "nullAssignment.h"
#include "rt_nonfinite.h"
#include "rtwhalf.h"
#include "var.h"
#include "rt_nonfinite.h"
#include <float.h>
#include <math.h>

/* Function Declarations */
static void binary_expand_op(emxArray_real32_T *in1,
                             const emxArray_real_T *in2);

static double rt_remd_snf(double u0, double u1);

static double rt_roundd_snf(double u);

/* Function Definitions */
/*
 * Arguments    : emxArray_real32_T *in1
 *                const emxArray_real_T *in2
 * Return Type  : void
 */
static void binary_expand_op(emxArray_real32_T *in1, const emxArray_real_T *in2)
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
 * matlab function to process linear accelerations (x,y,z) components
 *    following the spectral processing steps of microSWIFT wave processing with
 * "NEDwaves"
 *
 *
 *  input time series are linear acceleration components x [m/s^2], y [m/s^2], z
 * [m/s^2] and sampling rate [Hz], which must be at least 1 Hz Input time series
 * data must have at least 1024 points and all be the same size.
 *
 *  Outputs are minimum frequency, maximum frequency, X auto-spectra, Y
 * auto-spectra, Z auto-spectra the actual frequency bands are uniformly spaced
 * between [fmin, fmax] with length to match the auto-spectra
 *
 *  Outputs will be '9999' for invalid results.
 *
 *  Usage is as follows:
 *
 *    [ fmin, fmax, XX, YY, ZZ] =  XYZaccelerationspectra(x, y, z, fs);
 *
 *
 *  J. Thomson,  12/2025 (modified from NEDwaves_memlight, without RC filter,
 * without despike)
 *
 *
 * Arguments    : const emxArray_real32_T *x
 *                const emxArray_real32_T *y
 *                const emxArray_real32_T *z
 *                double fs
 *                real16_T *b_fmin
 *                real16_T *b_fmax
 *                emxArray_real16_T *XX
 *                emxArray_real16_T *YY
 *                emxArray_real16_T *ZZ
 * Return Type  : void
 */
void XYZaccelerationspectra(const emxArray_real32_T *x,
                            const emxArray_real32_T *y,
                            const emxArray_real32_T *z, double fs,
                            real16_T *b_fmin, real16_T *b_fmax,
                            emxArray_real16_T *XX, emxArray_real16_T *YY,
                            emxArray_real16_T *ZZ)
{
  emxArray_boolean_T *idx;
  emxArray_creal32_T *b_xwin;
  emxArray_creal32_T *b_ywin;
  emxArray_creal32_T *b_zwin;
  emxArray_creal32_T *c_xwin;
  emxArray_int32_T *b_taper;
  emxArray_int32_T *r;
  emxArray_int32_T *r1;
  emxArray_int32_T *r2;
  emxArray_real32_T *b_XX;
  emxArray_real32_T *b_YY;
  emxArray_real32_T *b_ZZ;
  emxArray_real32_T *d_xwin;
  emxArray_real32_T *xwin;
  emxArray_real32_T *ywin;
  emxArray_real32_T *zwin;
  emxArray_real_T *f;
  emxArray_real_T *rawf;
  emxArray_real_T *taper;
  creal32_T *b_xwin_data;
  creal32_T *b_ywin_data;
  creal32_T *b_zwin_data;
  creal32_T *c_xwin_data;
  double Nyquist;
  double d;
  double windows;
  double wpts;
  double y_tmp;
  double *f_data;
  double *rawf_data;
  double *taper_data;
  const float *x_data;
  const float *y_data;
  const float *z_data;
  float *XX_data;
  float *YY_data;
  float *ZZ_data;
  float *d_xwin_data;
  float *xwin_data;
  float *ywin_data;
  float *zwin_data;
  int b_end;
  int b_loop_ub;
  int c_end;
  int c_loop_ub;
  int end;
  int i;
  int i1;
  int i2;
  int i3;
  int k;
  int k0;
  int loop_ub;
  int loop_ub_tmp;
  int nxin;
  int nxout;
  int q;
  int *b_taper_data;
  real16_T *b_XX_data;
  bool *idx_data;
  z_data = z->data;
  y_data = y->data;
  x_data = x->data;
  /*  parameters */
  /*  length of the input data (should be 2^N for efficiency) */
  /*  window length in seconds, should make 2^N samples if sampling rate is even
   * integer */
  /*  freq bands to merge, must be odd? */
  /*  frequency cutoff for telemetry Hz */
  wpts = rt_roundd_snf(fs * 512.0);
  /*  window length in data points */
  if (rt_remd_snf(wpts, 2.0) != 0.0) {
    wpts--;
  }
  /*  make wpts an even number */
  windows = floor(4.0 * ((double)x->size[1] / wpts - 1.0) + 1.0);
  /*  number of windows, the 4 comes from a 75% overlap */
  /* dof = 2*windows*merge; % degrees of freedom */
  /*  frequency resolution */
  Nyquist = fs / 2.0;
  /*  highest spectral frequency */
  /*  frequency resolution */
  emxInit_real_T(&rawf);
  rawf_data = rawf->data;
  emxInit_real_T(&f);
  f_data = f->data;
  if (rtIsNaN(Nyquist)) {
    i = rawf->size[0] * rawf->size[1];
    rawf->size[0] = 1;
    rawf->size[1] = 1;
    emxEnsureCapacity_real_T(rawf, i);
    rawf_data = rawf->data;
    rawf_data[0] = rtNaN;
    i = f->size[0] * f->size[1];
    f->size[0] = 1;
    f->size[1] = 1;
    emxEnsureCapacity_real_T(f, i);
    f_data = f->data;
    f_data[0] = rtNaN;
  } else {
    if (Nyquist < 0.001953125) {
      rawf->size[0] = 1;
      rawf->size[1] = 0;
    } else {
      eml_float_colon(Nyquist, rawf);
      rawf_data = rawf->data;
    }
    if (Nyquist < 0.0068359375) {
      f->size[0] = 1;
      f->size[1] = 0;
    } else {
      b_eml_float_colon(Nyquist, f);
      f_data = f->data;
    }
  }
  emxInit_boolean_T(&idx);
  /*  raw frequency bands */
  /*  freq (Hz) bandwitdh after merging */
  /*  frequency vector after merging */
  i = idx->size[0] * idx->size[1];
  idx->size[0] = 1;
  idx->size[1] = f->size[1];
  emxEnsureCapacity_boolean_T(idx, i);
  idx_data = idx->data;
  k0 = f->size[1];
  for (i = 0; i < k0; i++) {
    idx_data[i] = (f_data[i] > 0.5);
  }
  nxin = f->size[1];
  k0 = 0;
  i = idx->size[1];
  for (k = 0; k < i; k++) {
    k0 += idx_data[k];
  }
  nxout = f->size[1] - k0;
  k0 = -1;
  for (k = 0; k < nxin; k++) {
    if ((k + 1 > idx->size[1]) || (!idx_data[k])) {
      k0++;
      f_data[k0] = f_data[k];
    }
  }
  emxFree_boolean_T(&idx);
  emxInit_real32_T(&b_XX, 2);
  i = f->size[0] * f->size[1];
  if (nxout < 1) {
    f->size[1] = 0;
  } else {
    f->size[1] = nxout;
  }
  emxEnsureCapacity_real_T(f, i);
  f_data = f->data;
  /*  should end up with length(f) = 51 with maxf=0.5, merge=5, and wsecs = 512
   */
  /*  initialize spectral ouput, which will accumulate as windows are processed
   */
  /*  length will only be 42 if wsecs = 256, merge = 3, maxf = 0.5 (params
   * above) */
  i = b_XX->size[0] * b_XX->size[1];
  b_XX->size[0] = 1;
  b_XX->size[1] = f->size[1];
  emxEnsureCapacity_real32_T(b_XX, i);
  XX_data = b_XX->data;
  k0 = f->size[1];
  for (i = 0; i < k0; i++) {
    XX_data[i] = 0.0F;
  }
  emxInit_real32_T(&b_YY, 2);
  i = b_YY->size[0] * b_YY->size[1];
  b_YY->size[0] = 1;
  b_YY->size[1] = f->size[1];
  emxEnsureCapacity_real32_T(b_YY, i);
  YY_data = b_YY->data;
  k0 = f->size[1];
  for (i = 0; i < k0; i++) {
    YY_data[i] = 0.0F;
  }
  emxInit_real32_T(&b_ZZ, 2);
  i = b_ZZ->size[0] * b_ZZ->size[1];
  b_ZZ->size[0] = 1;
  b_ZZ->size[1] = f->size[1];
  emxEnsureCapacity_real32_T(b_ZZ, i);
  ZZ_data = b_ZZ->data;
  k0 = f->size[1];
  for (i = 0; i < k0; i++) {
    ZZ_data[i] = 0.0F;
  }
  /*  loop thru windows, accumulating spectral results */
  i = (int)windows;
  emxInit_real_T(&taper);
  if ((int)windows - 1 >= 0) {
    loop_ub = (int)(wpts - 1.0);
    b_loop_ub = (int)(wpts - 1.0);
    c_loop_ub = (int)(wpts - 1.0);
    d = rt_roundd_snf(wpts / 2.0 + 1.0);
    loop_ub_tmp = (int)(wpts - d);
    end = rawf->size[1] - 1;
    y_tmp = rt_roundd_snf(wpts / 2.0) * fs;
    b_end = rawf->size[1] - 1;
    c_end = rawf->size[1] - 1;
    i1 = (int)((double)f->size[1] * 5.0 / 5.0);
  }
  emxInit_real32_T(&xwin, 2);
  emxInit_real32_T(&ywin, 2);
  emxInit_real32_T(&zwin, 2);
  emxInit_creal32_T(&b_xwin, 2);
  emxInit_creal32_T(&b_ywin, 2);
  emxInit_creal32_T(&b_zwin, 2);
  emxInit_int32_T(&r, 2);
  emxInit_int32_T(&r1, 2);
  emxInit_int32_T(&r2, 2);
  emxInit_int32_T(&b_taper, 2);
  emxInit_creal32_T(&c_xwin, 2);
  emxInit_real32_T(&d_xwin, 2);
  for (q = 0; q < i; q++) {
    float b;
    float b_x;
    float c_x;
    float d_x;
    Nyquist = (((double)q + 1.0) - 1.0) * floor(0.25 * wpts);
    i2 = xwin->size[0] * xwin->size[1];
    xwin->size[0] = 1;
    xwin->size[1] = (int)(wpts - 1.0) + 1;
    emxEnsureCapacity_real32_T(xwin, i2);
    xwin_data = xwin->data;
    for (i2 = 0; i2 <= loop_ub; i2++) {
      xwin_data[i2] = x_data[(int)(Nyquist + (double)(i2 + 1)) - 1];
    }
    i2 = ywin->size[0] * ywin->size[1];
    ywin->size[0] = 1;
    ywin->size[1] = (int)(wpts - 1.0) + 1;
    emxEnsureCapacity_real32_T(ywin, i2);
    ywin_data = ywin->data;
    for (i2 = 0; i2 <= b_loop_ub; i2++) {
      ywin_data[i2] = y_data[(int)(Nyquist + (double)(i2 + 1)) - 1];
    }
    i2 = zwin->size[0] * zwin->size[1];
    zwin->size[0] = 1;
    zwin->size[1] = (int)(wpts - 1.0) + 1;
    emxEnsureCapacity_real32_T(zwin, i2);
    zwin_data = zwin->data;
    for (i2 = 0; i2 <= c_loop_ub; i2++) {
      zwin_data[i2] = z_data[(int)(Nyquist + (double)(i2 + 1)) - 1];
    }
    /*     %% remove the mean */
    b_x = mean(xwin);
    k0 = xwin->size[1] - 1;
    i2 = xwin->size[0] * xwin->size[1];
    xwin->size[0] = 1;
    emxEnsureCapacity_real32_T(xwin, i2);
    xwin_data = xwin->data;
    for (i2 = 0; i2 <= k0; i2++) {
      xwin_data[i2] -= b_x;
    }
    b_x = mean(ywin);
    k0 = ywin->size[1] - 1;
    i2 = ywin->size[0] * ywin->size[1];
    ywin->size[0] = 1;
    emxEnsureCapacity_real32_T(ywin, i2);
    ywin_data = ywin->data;
    for (i2 = 0; i2 <= k0; i2++) {
      ywin_data[i2] -= b_x;
    }
    b_x = mean(zwin);
    k0 = zwin->size[1] - 1;
    i2 = zwin->size[0] * zwin->size[1];
    zwin->size[0] = 1;
    emxEnsureCapacity_real32_T(zwin, i2);
    zwin_data = zwin->data;
    for (i2 = 0; i2 <= k0; i2++) {
      zwin_data[i2] -= b_x;
    }
    /*     %% taper and rescale (to preserve variance) */
    /*  get original variance of each window */
    b_x = var(xwin);
    c_x = var(ywin);
    d_x = var(zwin);
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
      k0 = (int)(wpts - 1.0);
      for (i2 = 0; i2 <= k0; i2++) {
        taper_data[i2] = (double)i2 + 1.0;
      }
    }
    i2 = taper->size[0] * taper->size[1];
    taper->size[0] = 1;
    emxEnsureCapacity_real_T(taper, i2);
    taper_data = taper->data;
    k0 = taper->size[1] - 1;
    for (i2 = 0; i2 <= k0; i2++) {
      taper_data[i2] = taper_data[i2] * 3.1415926535897931 / wpts;
    }
    nxout = taper->size[1];
    for (k = 0; k < nxout; k++) {
      taper_data[k] = sin(taper_data[k]);
    }
    /*  apply the taper */
    if (xwin->size[1] == taper->size[1]) {
      k0 = xwin->size[1] - 1;
      i2 = xwin->size[0] * xwin->size[1];
      xwin->size[0] = 1;
      emxEnsureCapacity_real32_T(xwin, i2);
      xwin_data = xwin->data;
      for (i2 = 0; i2 <= k0; i2++) {
        xwin_data[i2] *= (float)taper_data[i2];
      }
    } else {
      binary_expand_op(xwin, taper);
    }
    if (ywin->size[1] == taper->size[1]) {
      k0 = ywin->size[1] - 1;
      i2 = ywin->size[0] * ywin->size[1];
      ywin->size[0] = 1;
      emxEnsureCapacity_real32_T(ywin, i2);
      ywin_data = ywin->data;
      for (i2 = 0; i2 <= k0; i2++) {
        ywin_data[i2] *= (float)taper_data[i2];
      }
    } else {
      binary_expand_op(ywin, taper);
    }
    if (zwin->size[1] == taper->size[1]) {
      k0 = zwin->size[1] - 1;
      i2 = zwin->size[0] * zwin->size[1];
      zwin->size[0] = 1;
      emxEnsureCapacity_real32_T(zwin, i2);
      zwin_data = zwin->data;
      for (i2 = 0; i2 <= k0; i2++) {
        zwin_data[i2] *= (float)taper_data[i2];
      }
    } else {
      binary_expand_op(zwin, taper);
    }
    /*  then rescale to regain the same original variance */
    b = sqrtf(b_x / var(xwin));
    i2 = xwin->size[0] * xwin->size[1];
    xwin->size[0] = 1;
    emxEnsureCapacity_real32_T(xwin, i2);
    xwin_data = xwin->data;
    k0 = xwin->size[1] - 1;
    for (i2 = 0; i2 <= k0; i2++) {
      xwin_data[i2] *= b;
    }
    b = sqrtf(c_x / var(ywin));
    i2 = ywin->size[0] * ywin->size[1];
    ywin->size[0] = 1;
    emxEnsureCapacity_real32_T(ywin, i2);
    ywin_data = ywin->data;
    k0 = ywin->size[1] - 1;
    for (i2 = 0; i2 <= k0; i2++) {
      ywin_data[i2] *= b;
    }
    b = sqrtf(d_x / var(zwin));
    i2 = zwin->size[0] * zwin->size[1];
    zwin->size[0] = 1;
    emxEnsureCapacity_real32_T(zwin, i2);
    zwin_data = zwin->data;
    k0 = zwin->size[1] - 1;
    for (i2 = 0; i2 <= k0; i2++) {
      zwin_data[i2] *= b;
    }
    /*     %% FFT */
    /*  calculate Fourier coefs (complex values, double sided) */
    /*  overnight the time series variables (to save memory) */
    fft(xwin, b_xwin);
    fft(ywin, b_ywin);
    fft(zwin, b_zwin);
    /*  second half of Matlab's FFT is redundant, so throw it out */
    i2 = b_taper->size[0] * b_taper->size[1];
    b_taper->size[0] = 1;
    b_taper->size[1] = (int)(wpts - d) + 1;
    emxEnsureCapacity_int32_T(b_taper, i2);
    b_taper_data = b_taper->data;
    for (i2 = 0; i2 <= loop_ub_tmp; i2++) {
      b_taper_data[i2] = (int)(d + (double)i2);
    }
    nullAssignment(b_xwin, b_taper);
    b_xwin_data = b_xwin->data;
    i2 = b_taper->size[0] * b_taper->size[1];
    b_taper->size[0] = 1;
    b_taper->size[1] = (int)(wpts - d) + 1;
    emxEnsureCapacity_int32_T(b_taper, i2);
    b_taper_data = b_taper->data;
    for (i2 = 0; i2 <= loop_ub_tmp; i2++) {
      b_taper_data[i2] = (int)(d + (double)i2);
    }
    nullAssignment(b_ywin, b_taper);
    b_ywin_data = b_ywin->data;
    i2 = b_taper->size[0] * b_taper->size[1];
    b_taper->size[0] = 1;
    b_taper->size[1] = (int)(wpts - d) + 1;
    emxEnsureCapacity_int32_T(b_taper, i2);
    b_taper_data = b_taper->data;
    for (i2 = 0; i2 <= loop_ub_tmp; i2++) {
      b_taper_data[i2] = (int)(d + (double)i2);
    }
    nullAssignment(b_zwin, b_taper);
    b_zwin_data = b_zwin->data;
    /*  throw out the mean (first coef) by moving to the end and making it zero
     */
    if (b_xwin->size[1] < 2) {
      taper->size[0] = 1;
      taper->size[1] = 0;
    } else {
      i2 = taper->size[0] * taper->size[1];
      taper->size[0] = 1;
      taper->size[1] = b_xwin->size[1] - 1;
      emxEnsureCapacity_real_T(taper, i2);
      taper_data = taper->data;
      k0 = b_xwin->size[1] - 2;
      for (i2 = 0; i2 <= k0; i2++) {
        taper_data[i2] = (double)i2 + 2.0;
      }
    }
    i2 = b_taper->size[0] * b_taper->size[1];
    b_taper->size[0] = 1;
    b_taper->size[1] = taper->size[1] + 1;
    emxEnsureCapacity_int32_T(b_taper, i2);
    b_taper_data = b_taper->data;
    k0 = taper->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      b_taper_data[i2] = (int)taper_data[i2] - 1;
    }
    b_taper_data[taper->size[1]] = 0;
    i2 = c_xwin->size[0] * c_xwin->size[1];
    c_xwin->size[0] = 1;
    c_xwin->size[1] = b_taper->size[1];
    emxEnsureCapacity_creal32_T(c_xwin, i2);
    c_xwin_data = c_xwin->data;
    k0 = b_taper->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      c_xwin_data[i2] = b_xwin_data[b_taper_data[i2]];
    }
    i2 = b_xwin->size[0] * b_xwin->size[1];
    b_xwin->size[0] = 1;
    b_xwin->size[1] = c_xwin->size[1];
    emxEnsureCapacity_creal32_T(b_xwin, i2);
    b_xwin_data = b_xwin->data;
    k0 = c_xwin->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      b_xwin_data[i2] = c_xwin_data[i2];
    }
    if (b_ywin->size[1] < 2) {
      taper->size[0] = 1;
      taper->size[1] = 0;
    } else {
      i2 = taper->size[0] * taper->size[1];
      taper->size[0] = 1;
      taper->size[1] = b_ywin->size[1] - 1;
      emxEnsureCapacity_real_T(taper, i2);
      taper_data = taper->data;
      k0 = b_ywin->size[1] - 2;
      for (i2 = 0; i2 <= k0; i2++) {
        taper_data[i2] = (double)i2 + 2.0;
      }
    }
    i2 = b_taper->size[0] * b_taper->size[1];
    b_taper->size[0] = 1;
    b_taper->size[1] = taper->size[1] + 1;
    emxEnsureCapacity_int32_T(b_taper, i2);
    b_taper_data = b_taper->data;
    k0 = taper->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      b_taper_data[i2] = (int)taper_data[i2] - 1;
    }
    b_taper_data[taper->size[1]] = 0;
    i2 = c_xwin->size[0] * c_xwin->size[1];
    c_xwin->size[0] = 1;
    c_xwin->size[1] = b_taper->size[1];
    emxEnsureCapacity_creal32_T(c_xwin, i2);
    c_xwin_data = c_xwin->data;
    k0 = b_taper->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      c_xwin_data[i2] = b_ywin_data[b_taper_data[i2]];
    }
    i2 = b_ywin->size[0] * b_ywin->size[1];
    b_ywin->size[0] = 1;
    b_ywin->size[1] = c_xwin->size[1];
    emxEnsureCapacity_creal32_T(b_ywin, i2);
    b_ywin_data = b_ywin->data;
    k0 = c_xwin->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      b_ywin_data[i2] = c_xwin_data[i2];
    }
    if (b_zwin->size[1] < 2) {
      taper->size[0] = 1;
      taper->size[1] = 0;
    } else {
      i2 = taper->size[0] * taper->size[1];
      taper->size[0] = 1;
      taper->size[1] = b_zwin->size[1] - 1;
      emxEnsureCapacity_real_T(taper, i2);
      taper_data = taper->data;
      k0 = b_zwin->size[1] - 2;
      for (i2 = 0; i2 <= k0; i2++) {
        taper_data[i2] = (double)i2 + 2.0;
      }
    }
    i2 = b_taper->size[0] * b_taper->size[1];
    b_taper->size[0] = 1;
    b_taper->size[1] = taper->size[1] + 1;
    emxEnsureCapacity_int32_T(b_taper, i2);
    b_taper_data = b_taper->data;
    k0 = taper->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      b_taper_data[i2] = (int)taper_data[i2] - 1;
    }
    b_taper_data[taper->size[1]] = 0;
    i2 = c_xwin->size[0] * c_xwin->size[1];
    c_xwin->size[0] = 1;
    c_xwin->size[1] = b_taper->size[1];
    emxEnsureCapacity_creal32_T(c_xwin, i2);
    c_xwin_data = c_xwin->data;
    k0 = b_taper->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      c_xwin_data[i2] = b_zwin_data[b_taper_data[i2]];
    }
    i2 = b_zwin->size[0] * b_zwin->size[1];
    b_zwin->size[0] = 1;
    b_zwin->size[1] = c_xwin->size[1];
    emxEnsureCapacity_creal32_T(b_zwin, i2);
    b_zwin_data = b_zwin->data;
    k0 = c_xwin->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      b_zwin_data[i2] = c_xwin_data[i2];
    }
    b_xwin_data[b_xwin->size[1] - 1].re = 0.0F;
    b_xwin_data[b_xwin->size[1] - 1].im = 0.0F;
    b_ywin_data[b_ywin->size[1] - 1].re = 0.0F;
    b_ywin_data[b_ywin->size[1] - 1].im = 0.0F;
    b_zwin_data[b_zwin->size[1] - 1].re = 0.0F;
    b_zwin_data[b_zwin->size[1] - 1].im = 0.0F;
    /*  Calculate the auto-spectra and cross-spectra from this window */
    /*  ** do this before merging frequency bands or ensemble averging windows
     * ** */
    /*  only compute for raw frequencies less than the max frequency of interest
     * (to save memory) */
    k0 = 0;
    for (nxout = 0; nxout <= end; nxout++) {
      if (rawf_data[nxout] < 0.5) {
        k0++;
      }
    }
    i2 = r->size[0] * r->size[1];
    r->size[0] = 1;
    r->size[1] = k0;
    emxEnsureCapacity_int32_T(r, i2);
    b_taper_data = r->data;
    k0 = 0;
    for (nxout = 0; nxout <= end; nxout++) {
      if (rawf_data[nxout] < 0.5) {
        b_taper_data[k0] = nxout + 1;
        k0++;
      }
    }
    i2 = xwin->size[0] * xwin->size[1];
    xwin->size[0] = 1;
    xwin->size[1] = r->size[1];
    emxEnsureCapacity_real32_T(xwin, i2);
    xwin_data = xwin->data;
    k0 = r->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      b_x = b_xwin_data[b_taper_data[i2] - 1].re;
      b = b_xwin_data[b_taper_data[i2] - 1].im;
      xwin_data[i2] = (b_x * b_x - b * -b) / (float)y_tmp;
    }
    k0 = 0;
    for (nxout = 0; nxout <= b_end; nxout++) {
      if (rawf_data[nxout] < 0.5) {
        k0++;
      }
    }
    i2 = r1->size[0] * r1->size[1];
    r1->size[0] = 1;
    r1->size[1] = k0;
    emxEnsureCapacity_int32_T(r1, i2);
    b_taper_data = r1->data;
    k0 = 0;
    for (nxout = 0; nxout <= b_end; nxout++) {
      if (rawf_data[nxout] < 0.5) {
        b_taper_data[k0] = nxout + 1;
        k0++;
      }
    }
    i2 = ywin->size[0] * ywin->size[1];
    ywin->size[0] = 1;
    ywin->size[1] = r1->size[1];
    emxEnsureCapacity_real32_T(ywin, i2);
    ywin_data = ywin->data;
    k0 = r1->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      b_x = b_ywin_data[b_taper_data[i2] - 1].re;
      b = b_ywin_data[b_taper_data[i2] - 1].im;
      ywin_data[i2] = (b_x * b_x - b * -b) / (float)y_tmp;
    }
    k0 = 0;
    for (nxout = 0; nxout <= c_end; nxout++) {
      if (rawf_data[nxout] < 0.5) {
        k0++;
      }
    }
    i2 = r2->size[0] * r2->size[1];
    r2->size[0] = 1;
    r2->size[1] = k0;
    emxEnsureCapacity_int32_T(r2, i2);
    b_taper_data = r2->data;
    k0 = 0;
    for (nxout = 0; nxout <= c_end; nxout++) {
      if (rawf_data[nxout] < 0.5) {
        b_taper_data[k0] = nxout + 1;
        k0++;
      }
    }
    i2 = zwin->size[0] * zwin->size[1];
    zwin->size[0] = 1;
    zwin->size[1] = r2->size[1];
    emxEnsureCapacity_real32_T(zwin, i2);
    zwin_data = zwin->data;
    k0 = r2->size[1];
    for (i2 = 0; i2 < k0; i2++) {
      b_x = b_zwin_data[b_taper_data[i2] - 1].re;
      b = b_zwin_data[b_taper_data[i2] - 1].im;
      zwin_data[i2] = (b_x * b_x - b * -b) / (float)y_tmp;
    }
    /*  accumulate window results and merge neighboring frequency bands (to
     * increase DOFs) */
    for (k = 0; k < i1; k++) {
      Nyquist = (double)k * 5.0 + 5.0;
      if ((Nyquist - 5.0) + 1.0 > Nyquist) {
        i2 = 0;
        i3 = 0;
      } else {
        i2 = (int)((Nyquist - 5.0) + 1.0) - 1;
        i3 = (int)Nyquist;
      }
      nxout = d_xwin->size[0] * d_xwin->size[1];
      d_xwin->size[0] = 1;
      k0 = i3 - i2;
      d_xwin->size[1] = k0;
      emxEnsureCapacity_real32_T(d_xwin, nxout);
      d_xwin_data = d_xwin->data;
      for (i3 = 0; i3 < k0; i3++) {
        d_xwin_data[i3] = xwin_data[i2 + i3];
      }
      nxin = (int)(Nyquist / 5.0) - 1;
      XX_data[nxin] += mean(d_xwin);
      if ((Nyquist - 5.0) + 1.0 > Nyquist) {
        i2 = 0;
        i3 = 0;
      } else {
        i2 = (int)((Nyquist - 5.0) + 1.0) - 1;
        i3 = (int)Nyquist;
      }
      nxout = d_xwin->size[0] * d_xwin->size[1];
      d_xwin->size[0] = 1;
      k0 = i3 - i2;
      d_xwin->size[1] = k0;
      emxEnsureCapacity_real32_T(d_xwin, nxout);
      d_xwin_data = d_xwin->data;
      for (i3 = 0; i3 < k0; i3++) {
        d_xwin_data[i3] = ywin_data[i2 + i3];
      }
      YY_data[nxin] += mean(d_xwin);
      if ((Nyquist - 5.0) + 1.0 > Nyquist) {
        i2 = 0;
        i3 = 0;
      } else {
        i2 = (int)((Nyquist - 5.0) + 1.0) - 1;
        i3 = (int)Nyquist;
      }
      nxout = d_xwin->size[0] * d_xwin->size[1];
      d_xwin->size[0] = 1;
      k0 = i3 - i2;
      d_xwin->size[1] = k0;
      emxEnsureCapacity_real32_T(d_xwin, nxout);
      d_xwin_data = d_xwin->data;
      for (i3 = 0; i3 < k0; i3++) {
        d_xwin_data[i3] = zwin_data[i2 + i3];
      }
      ZZ_data[nxin] += mean(d_xwin);
    }
  }
  emxFree_real32_T(&d_xwin);
  emxFree_creal32_T(&c_xwin);
  emxFree_int32_T(&b_taper);
  emxFree_int32_T(&r2);
  emxFree_int32_T(&r1);
  emxFree_int32_T(&r);
  emxFree_creal32_T(&b_zwin);
  emxFree_creal32_T(&b_ywin);
  emxFree_creal32_T(&b_xwin);
  emxFree_real_T(&taper);
  emxFree_real32_T(&zwin);
  emxFree_real32_T(&ywin);
  emxFree_real32_T(&xwin);
  emxFree_real_T(&rawf);
  /*  close window loop */
  /*  divide accumulated results by number of windows (effectively an ensemble
   * avg) */
  i = b_XX->size[0] * b_XX->size[1];
  b_XX->size[0] = 1;
  emxEnsureCapacity_real32_T(b_XX, i);
  XX_data = b_XX->data;
  k0 = b_XX->size[1] - 1;
  for (i = 0; i <= k0; i++) {
    XX_data[i] /= (float)windows;
  }
  i = b_YY->size[0] * b_YY->size[1];
  b_YY->size[0] = 1;
  emxEnsureCapacity_real32_T(b_YY, i);
  YY_data = b_YY->data;
  k0 = b_YY->size[1] - 1;
  for (i = 0; i <= k0; i++) {
    YY_data[i] /= (float)windows;
  }
  i = b_ZZ->size[0] * b_ZZ->size[1];
  b_ZZ->size[0] = 1;
  emxEnsureCapacity_real32_T(b_ZZ, i);
  ZZ_data = b_ZZ->data;
  k0 = b_ZZ->size[1] - 1;
  for (i = 0; i <= k0; i++) {
    ZZ_data[i] /= (float)windows;
  }
  /*  format for microSWIFT telemetry output (payload type 52) */
  *b_fmin = doubleToHalf(minimum(f));
  nxout = f->size[1];
  if (f->size[1] <= 2) {
    if (f->size[1] == 1) {
      Nyquist = f_data[0];
    } else if ((f_data[0] < f_data[f->size[1] - 1]) ||
               (rtIsNaN(f_data[0]) && (!rtIsNaN(f_data[f->size[1] - 1])))) {
      Nyquist = f_data[f->size[1] - 1];
    } else {
      Nyquist = f_data[0];
    }
  } else {
    if (!rtIsNaN(f_data[0])) {
      k0 = 1;
    } else {
      bool exitg1;
      k0 = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= nxout)) {
        if (!rtIsNaN(f_data[k - 1])) {
          k0 = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (k0 == 0) {
      Nyquist = f_data[0];
    } else {
      Nyquist = f_data[k0 - 1];
      i = k0 + 1;
      for (k = i; k <= nxout; k++) {
        d = f_data[k - 1];
        if (Nyquist < d) {
          Nyquist = d;
        }
      }
    }
  }
  emxFree_real_T(&f);
  i = XX->size[0] * XX->size[1];
  XX->size[0] = 1;
  XX->size[1] = b_XX->size[1];
  emxEnsureCapacity_real16_T(XX, i);
  b_XX_data = XX->data;
  k0 = b_XX->size[1];
  for (i = 0; i < k0; i++) {
    b_XX_data[i] = floatToHalf(XX_data[i]);
  }
  emxFree_real32_T(&b_XX);
  i = YY->size[0] * YY->size[1];
  YY->size[0] = 1;
  YY->size[1] = b_YY->size[1];
  emxEnsureCapacity_real16_T(YY, i);
  b_XX_data = YY->data;
  k0 = b_YY->size[1];
  for (i = 0; i < k0; i++) {
    b_XX_data[i] = floatToHalf(YY_data[i]);
  }
  emxFree_real32_T(&b_YY);
  i = ZZ->size[0] * ZZ->size[1];
  ZZ->size[0] = 1;
  ZZ->size[1] = b_ZZ->size[1];
  emxEnsureCapacity_real16_T(ZZ, i);
  b_XX_data = ZZ->data;
  k0 = b_ZZ->size[1];
  for (i = 0; i < k0; i++) {
    b_XX_data[i] = floatToHalf(ZZ_data[i]);
  }
  emxFree_real32_T(&b_ZZ);
  *b_fmax = doubleToHalf(Nyquist);
}

/*
 * File trailer for XYZaccelerationspectra.c
 *
 * [EOF]
 */
