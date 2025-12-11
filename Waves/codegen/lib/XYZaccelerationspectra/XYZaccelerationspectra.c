/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: XYZaccelerationspectra.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 11-Dec-2025 06:39:36
 */

/* Include Files */
#include "XYZaccelerationspectra.h"
#include "XYZaccelerationspectra_emxutil.h"
#include "XYZaccelerationspectra_types.h"
#include "colon.h"
#include "div.h"
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
#include <string.h>

/* Function Declarations */
static void b_binary_expand_op(emxArray_real32_T *in1,
                               const emxArray_real_T *in2);

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
 *                real16_T XX_data[]
 *                int XX_size[2]
 *                real16_T YY_data[]
 *                int YY_size[2]
 *                real16_T ZZ_data[]
 *                int ZZ_size[2]
 * Return Type  : void
 */
void XYZaccelerationspectra(const emxArray_real32_T *x,
                            const emxArray_real32_T *y,
                            const emxArray_real32_T *z, double fs,
                            real16_T *b_fmin, real16_T *b_fmax,
                            real16_T XX_data[], int XX_size[2],
                            real16_T YY_data[], int YY_size[2],
                            real16_T ZZ_data[], int ZZ_size[2])
{
  emxArray_boolean_T *r6;
  emxArray_creal32_T *b_xwin;
  emxArray_creal32_T *b_ywin;
  emxArray_creal32_T *b_zwin;
  emxArray_creal32_T *c_xwin;
  emxArray_creal32_T *r;
  emxArray_creal32_T *r1;
  emxArray_creal32_T *r2;
  emxArray_creal32_T *r3;
  emxArray_creal32_T *r4;
  emxArray_creal32_T *r5;
  emxArray_int32_T *b_taper;
  emxArray_real32_T e_xwin_data;
  emxArray_real32_T f_xwin_data;
  emxArray_real32_T g_xwin_data;
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
  creal32_T *r8;
  double windows;
  double wpts;
  double wsecs;
  double *f_data;
  double *rawf_data;
  float d_xwin_data[235];
  float b_XX_data[48];
  float b_YY_data[48];
  float b_ZZ_data[48];
  const float *x_data;
  const float *y_data;
  const float *z_data;
  float *xwin_data;
  float *ywin_data;
  float *zwin_data;
  int xwin_size[2];
  int b_i;
  int i;
  int i2;
  int i3;
  int k;
  int mi;
  int q;
  int *taper_data;
  bool *r7;
  z_data = z->data;
  y_data = y->data;
  x_data = x->data;
  /*  parameters */
  /*  length of the input data (should be 2^N for efficiency) */
  wsecs = 4096.0 / rt_roundd_snf(fs) / 2.0;
  /*  window length in seconds, usually 512 for wave processing ** now dynamic
   * ** */
  /*  freq bands to merge, must be odd */
  /* maxf = .5;   % frequency cutoff for telemetry Hz ** NO LONGER USED...  USE
   * "nfbands" INSTEAD ** */
  /*  number of frequency bands */
  wpts = rt_roundd_snf(fs * wsecs);
  /*  window length in data points */
  if (rt_remd_snf(wpts, 2.0) != 0.0) {
    wpts--;
    /*  make wpts an even number */
  }
  windows = floor(4.0 * ((double)x->size[1] / wpts - 1.0) + 1.0);
  /*  number of windows, the 4 comes from a 75% overlap */
  /*  degrees of freedom */
  if (windows > 1.0) {
    double Nyquist;
    double bandwidth;
    int XX_size_idx_1;
    int YY_size_idx_1;
    int ZZ_size_idx_1;
    int b_loop_ub;
    int b_loop_ub_tmp_tmp;
    int c_loop_ub;
    int d_loop_ub;
    int e_loop_ub;
    int f_loop_ub;
    int i1;
    int loop_ub;
    int loop_ub_tmp_tmp;
    /*  only proceed if enough data */
    /*     %% frequency resolution */
    Nyquist = fs / 2.0;
    /*  highest spectral frequency */
    wsecs = 1.0 / wsecs;
    /*  frequency resolution */
    emxInit_real_T(&rawf);
    rawf_data = rawf->data;
    if (rtIsNaN(wsecs) || rtIsNaN(wsecs) || rtIsNaN(Nyquist)) {
      i = rawf->size[0] * rawf->size[1];
      rawf->size[0] = 1;
      rawf->size[1] = 1;
      emxEnsureCapacity_real_T(rawf, i);
      rawf_data = rawf->data;
      rawf_data[0] = rtNaN;
    } else if ((wsecs == 0.0) || ((wsecs < Nyquist) && (wsecs < 0.0)) ||
               ((Nyquist < wsecs) && (wsecs > 0.0))) {
      rawf->size[0] = 1;
      rawf->size[1] = 0;
    } else if ((rtIsInf(wsecs) || rtIsInf(Nyquist)) &&
               (rtIsInf(wsecs) || (wsecs == Nyquist))) {
      i = rawf->size[0] * rawf->size[1];
      rawf->size[0] = 1;
      rawf->size[1] = 1;
      emxEnsureCapacity_real_T(rawf, i);
      rawf_data = rawf->data;
      rawf_data[0] = rtNaN;
    } else if (rtIsInf(wsecs)) {
      i = rawf->size[0] * rawf->size[1];
      rawf->size[0] = 1;
      rawf->size[1] = 1;
      emxEnsureCapacity_real_T(rawf, i);
      rawf_data = rawf->data;
      rawf_data[0] = wsecs;
    } else if (floor(wsecs) == wsecs) {
      i = rawf->size[0] * rawf->size[1];
      rawf->size[0] = 1;
      loop_ub = (int)((Nyquist - wsecs) / wsecs);
      rawf->size[1] = loop_ub + 1;
      emxEnsureCapacity_real_T(rawf, i);
      rawf_data = rawf->data;
      for (i = 0; i <= loop_ub; i++) {
        rawf_data[i] = wsecs + wsecs * (double)i;
      }
    } else {
      eml_float_colon(wsecs, wsecs, Nyquist, rawf);
      rawf_data = rawf->data;
    }
    /*  raw frequency bands */
    bandwidth = wsecs * 5.0;
    /*  freq (Hz) bandwitdh after merging */
    wsecs += bandwidth / 2.0;
    emxInit_real_T(&f);
    if (rtIsNaN(wsecs) || rtIsNaN(bandwidth) || rtIsNaN(Nyquist)) {
      i = f->size[0] * f->size[1];
      f->size[0] = 1;
      f->size[1] = 1;
      emxEnsureCapacity_real_T(f, i);
      f_data = f->data;
      f_data[0] = rtNaN;
    } else if ((bandwidth == 0.0) || ((wsecs < Nyquist) && (bandwidth < 0.0)) ||
               ((Nyquist < wsecs) && (bandwidth > 0.0))) {
      f->size[0] = 1;
      f->size[1] = 0;
    } else if ((rtIsInf(wsecs) || rtIsInf(Nyquist)) &&
               (rtIsInf(bandwidth) || (wsecs == Nyquist))) {
      i = f->size[0] * f->size[1];
      f->size[0] = 1;
      f->size[1] = 1;
      emxEnsureCapacity_real_T(f, i);
      f_data = f->data;
      f_data[0] = rtNaN;
    } else if (rtIsInf(bandwidth)) {
      i = f->size[0] * f->size[1];
      f->size[0] = 1;
      f->size[1] = 1;
      emxEnsureCapacity_real_T(f, i);
      f_data = f->data;
      f_data[0] = wsecs;
    } else if ((floor(wsecs) == wsecs) && (floor(bandwidth) == bandwidth)) {
      i = f->size[0] * f->size[1];
      f->size[0] = 1;
      loop_ub = (int)((Nyquist - wsecs) / bandwidth);
      f->size[1] = loop_ub + 1;
      emxEnsureCapacity_real_T(f, i);
      f_data = f->data;
      for (i = 0; i <= loop_ub; i++) {
        f_data[i] = wsecs + bandwidth * (double)i;
      }
    } else {
      eml_float_colon(wsecs, bandwidth, Nyquist, f);
    }
    /*  frequency vector after merging */
    if (f->size[1] > 48) {
      i = f->size[0] * f->size[1];
      f->size[0] = 1;
      f->size[1] = 48;
      emxEnsureCapacity_real_T(f, i);
      /*  prume the higher frequencies */
    }
    /*     %% initialize spectral ouput, which will accumulate as windows are
     * processed */
    /*  length will only be 42 if wsecs = 256, merge = 3, maxf = 0.5 (params
     * above) */
    XX_size_idx_1 = f->size[1];
    loop_ub = f->size[1];
    if (loop_ub - 1 >= 0) {
      memset(&b_XX_data[0], 0, loop_ub * sizeof(float));
    }
    YY_size_idx_1 = f->size[1];
    loop_ub = f->size[1];
    if (loop_ub - 1 >= 0) {
      memset(&b_YY_data[0], 0, loop_ub * sizeof(float));
    }
    ZZ_size_idx_1 = f->size[1];
    loop_ub = f->size[1];
    if (loop_ub - 1 >= 0) {
      memset(&b_ZZ_data[0], 0, loop_ub * sizeof(float));
    }
    emxInit_real_T(&taper);
    /*     %% loop thru windows, accumulating spectral results */
    i = (int)windows;
    loop_ub_tmp_tmp = (int)(wpts - 1.0);
    wsecs = rt_roundd_snf(wpts / 2.0 + 1.0);
    b_loop_ub_tmp_tmp = (int)(wpts - wsecs);
    bandwidth = maximum((double *)f->data, *(int(*)[2])f->size);
    loop_ub = rawf->size[1];
    b_loop_ub = rawf->size[1];
    Nyquist = rt_roundd_snf(wpts / 2.0) * fs;
    c_loop_ub = rawf->size[1];
    d_loop_ub = rawf->size[1];
    e_loop_ub = rawf->size[1];
    f_loop_ub = rawf->size[1];
    i1 = (int)(((double)f->size[1] - 1.0) * 5.0 / 5.0);
    emxInit_real32_T(&xwin, 2);
    emxInit_real32_T(&ywin, 2);
    emxInit_real32_T(&zwin, 2);
    emxInit_creal32_T(&b_xwin, 2);
    emxInit_creal32_T(&b_ywin, 2);
    emxInit_creal32_T(&b_zwin, 2);
    emxInit_creal32_T(&r, 2);
    emxInit_creal32_T(&r1, 2);
    emxInit_creal32_T(&r2, 2);
    emxInit_creal32_T(&r3, 2);
    emxInit_creal32_T(&r4, 2);
    emxInit_creal32_T(&r5, 2);
    emxInit_boolean_T(&r6);
    emxInit_int32_T(&b_taper, 2);
    emxInit_creal32_T(&c_xwin, 2);
    for (q = 0; q < i; q++) {
      double d;
      float b_x;
      float c_x;
      float d_x;
      int nx;
      d = (((double)q + 1.0) - 1.0) * floor(0.25 * wpts);
      i2 = xwin->size[0] * xwin->size[1];
      xwin->size[0] = 1;
      xwin->size[1] = (int)(wpts - 1.0) + 1;
      emxEnsureCapacity_real32_T(xwin, i2);
      xwin_data = xwin->data;
      for (i2 = 0; i2 <= loop_ub_tmp_tmp; i2++) {
        xwin_data[i2] = x_data[(int)(d + (double)(i2 + 1)) - 1];
      }
      i2 = ywin->size[0] * ywin->size[1];
      ywin->size[0] = 1;
      ywin->size[1] = (int)(wpts - 1.0) + 1;
      emxEnsureCapacity_real32_T(ywin, i2);
      ywin_data = ywin->data;
      for (i2 = 0; i2 <= loop_ub_tmp_tmp; i2++) {
        ywin_data[i2] = y_data[(int)(d + (double)(i2 + 1)) - 1];
      }
      i2 = zwin->size[0] * zwin->size[1];
      zwin->size[0] = 1;
      zwin->size[1] = (int)(wpts - 1.0) + 1;
      emxEnsureCapacity_real32_T(zwin, i2);
      zwin_data = zwin->data;
      for (i2 = 0; i2 <= loop_ub_tmp_tmp; i2++) {
        zwin_data[i2] = z_data[(int)(d + (double)(i2 + 1)) - 1];
      }
      /*         %% remove the mean */
      b_x = mean(xwin);
      nx = xwin->size[1] - 1;
      i2 = xwin->size[0] * xwin->size[1];
      xwin->size[0] = 1;
      emxEnsureCapacity_real32_T(xwin, i2);
      xwin_data = xwin->data;
      for (i2 = 0; i2 <= nx; i2++) {
        xwin_data[i2] -= b_x;
      }
      b_x = mean(ywin);
      nx = ywin->size[1] - 1;
      i2 = ywin->size[0] * ywin->size[1];
      ywin->size[0] = 1;
      emxEnsureCapacity_real32_T(ywin, i2);
      ywin_data = ywin->data;
      for (i2 = 0; i2 <= nx; i2++) {
        ywin_data[i2] -= b_x;
      }
      b_x = mean(zwin);
      nx = zwin->size[1] - 1;
      i2 = zwin->size[0] * zwin->size[1];
      zwin->size[0] = 1;
      emxEnsureCapacity_real32_T(zwin, i2);
      zwin_data = zwin->data;
      for (i2 = 0; i2 <= nx; i2++) {
        zwin_data[i2] -= b_x;
      }
      /*         %% taper and rescale (to preserve variance) */
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
        f_data = taper->data;
        f_data[0] = rtNaN;
      } else if (wpts < 1.0) {
        taper->size[1] = 0;
      } else {
        i2 = taper->size[0] * taper->size[1];
        taper->size[0] = 1;
        taper->size[1] = (int)(wpts - 1.0) + 1;
        emxEnsureCapacity_real_T(taper, i2);
        f_data = taper->data;
        for (i2 = 0; i2 <= loop_ub_tmp_tmp; i2++) {
          f_data[i2] = (double)i2 + 1.0;
        }
      }
      i2 = taper->size[0] * taper->size[1];
      taper->size[0] = 1;
      emxEnsureCapacity_real_T(taper, i2);
      f_data = taper->data;
      nx = taper->size[1] - 1;
      for (i2 = 0; i2 <= nx; i2++) {
        f_data[i2] = f_data[i2] * 3.1415926535897931 / wpts;
      }
      nx = taper->size[1];
      for (k = 0; k < nx; k++) {
        f_data[k] = sin(f_data[k]);
      }
      /*  apply the taper */
      if (xwin->size[1] == taper->size[1]) {
        nx = xwin->size[1] - 1;
        i2 = xwin->size[0] * xwin->size[1];
        xwin->size[0] = 1;
        emxEnsureCapacity_real32_T(xwin, i2);
        xwin_data = xwin->data;
        for (i2 = 0; i2 <= nx; i2++) {
          xwin_data[i2] *= (float)f_data[i2];
        }
      } else {
        b_binary_expand_op(xwin, taper);
      }
      if (ywin->size[1] == taper->size[1]) {
        nx = ywin->size[1] - 1;
        i2 = ywin->size[0] * ywin->size[1];
        ywin->size[0] = 1;
        emxEnsureCapacity_real32_T(ywin, i2);
        ywin_data = ywin->data;
        for (i2 = 0; i2 <= nx; i2++) {
          ywin_data[i2] *= (float)f_data[i2];
        }
      } else {
        b_binary_expand_op(ywin, taper);
      }
      if (zwin->size[1] == taper->size[1]) {
        nx = zwin->size[1] - 1;
        i2 = zwin->size[0] * zwin->size[1];
        zwin->size[0] = 1;
        emxEnsureCapacity_real32_T(zwin, i2);
        zwin_data = zwin->data;
        for (i2 = 0; i2 <= nx; i2++) {
          zwin_data[i2] *= (float)f_data[i2];
        }
      } else {
        b_binary_expand_op(zwin, taper);
      }
      /*  then rescale to regain the same original variance */
      b_x = sqrtf(b_x / var(xwin));
      i2 = xwin->size[0] * xwin->size[1];
      xwin->size[0] = 1;
      emxEnsureCapacity_real32_T(xwin, i2);
      xwin_data = xwin->data;
      nx = xwin->size[1] - 1;
      for (i2 = 0; i2 <= nx; i2++) {
        xwin_data[i2] *= b_x;
      }
      b_x = sqrtf(c_x / var(ywin));
      i2 = ywin->size[0] * ywin->size[1];
      ywin->size[0] = 1;
      emxEnsureCapacity_real32_T(ywin, i2);
      ywin_data = ywin->data;
      nx = ywin->size[1] - 1;
      for (i2 = 0; i2 <= nx; i2++) {
        ywin_data[i2] *= b_x;
      }
      b_x = sqrtf(d_x / var(zwin));
      i2 = zwin->size[0] * zwin->size[1];
      zwin->size[0] = 1;
      emxEnsureCapacity_real32_T(zwin, i2);
      zwin_data = zwin->data;
      nx = zwin->size[1] - 1;
      for (i2 = 0; i2 <= nx; i2++) {
        zwin_data[i2] *= b_x;
      }
      /*         %% FFT */
      /*  calculate Fourier coefs (complex values, double sided) */
      /*  overnight the time series variables (to save memory) */
      fft(xwin, b_xwin);
      fft(ywin, b_ywin);
      fft(zwin, b_zwin);
      /*  second half of Matlab's FFT is redundant, so throw it out */
      i2 = b_taper->size[0] * b_taper->size[1];
      b_taper->size[0] = 1;
      b_taper->size[1] = b_loop_ub_tmp_tmp + 1;
      emxEnsureCapacity_int32_T(b_taper, i2);
      taper_data = b_taper->data;
      for (i2 = 0; i2 <= b_loop_ub_tmp_tmp; i2++) {
        taper_data[i2] = (int)(wsecs + (double)i2);
      }
      nullAssignment(b_xwin, b_taper);
      b_xwin_data = b_xwin->data;
      i2 = b_taper->size[0] * b_taper->size[1];
      b_taper->size[0] = 1;
      b_taper->size[1] = b_loop_ub_tmp_tmp + 1;
      emxEnsureCapacity_int32_T(b_taper, i2);
      taper_data = b_taper->data;
      for (i2 = 0; i2 <= b_loop_ub_tmp_tmp; i2++) {
        taper_data[i2] = (int)(wsecs + (double)i2);
      }
      nullAssignment(b_ywin, b_taper);
      b_ywin_data = b_ywin->data;
      i2 = b_taper->size[0] * b_taper->size[1];
      b_taper->size[0] = 1;
      b_taper->size[1] = b_loop_ub_tmp_tmp + 1;
      emxEnsureCapacity_int32_T(b_taper, i2);
      taper_data = b_taper->data;
      for (i2 = 0; i2 <= b_loop_ub_tmp_tmp; i2++) {
        taper_data[i2] = (int)(wsecs + (double)i2);
      }
      nullAssignment(b_zwin, b_taper);
      b_zwin_data = b_zwin->data;
      /*  throw out the mean (first coef) by moving to the end and making it
       * zero */
      if (b_xwin->size[1] < 2) {
        taper->size[0] = 1;
        taper->size[1] = 0;
      } else {
        i2 = taper->size[0] * taper->size[1];
        taper->size[0] = 1;
        taper->size[1] = b_xwin->size[1] - 1;
        emxEnsureCapacity_real_T(taper, i2);
        f_data = taper->data;
        nx = b_xwin->size[1] - 2;
        for (i2 = 0; i2 <= nx; i2++) {
          f_data[i2] = (double)i2 + 2.0;
        }
      }
      i2 = b_taper->size[0] * b_taper->size[1];
      b_taper->size[0] = 1;
      b_taper->size[1] = taper->size[1] + 1;
      emxEnsureCapacity_int32_T(b_taper, i2);
      taper_data = b_taper->data;
      nx = taper->size[1];
      for (i2 = 0; i2 < nx; i2++) {
        taper_data[i2] = (int)f_data[i2] - 1;
      }
      taper_data[taper->size[1]] = 0;
      i2 = c_xwin->size[0] * c_xwin->size[1];
      c_xwin->size[0] = 1;
      c_xwin->size[1] = b_taper->size[1];
      emxEnsureCapacity_creal32_T(c_xwin, i2);
      c_xwin_data = c_xwin->data;
      nx = b_taper->size[1];
      for (i2 = 0; i2 < nx; i2++) {
        c_xwin_data[i2] = b_xwin_data[taper_data[i2]];
      }
      i2 = b_xwin->size[0] * b_xwin->size[1];
      b_xwin->size[0] = 1;
      b_xwin->size[1] = c_xwin->size[1];
      emxEnsureCapacity_creal32_T(b_xwin, i2);
      b_xwin_data = b_xwin->data;
      nx = c_xwin->size[1];
      for (i2 = 0; i2 < nx; i2++) {
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
        f_data = taper->data;
        nx = b_ywin->size[1] - 2;
        for (i2 = 0; i2 <= nx; i2++) {
          f_data[i2] = (double)i2 + 2.0;
        }
      }
      i2 = b_taper->size[0] * b_taper->size[1];
      b_taper->size[0] = 1;
      b_taper->size[1] = taper->size[1] + 1;
      emxEnsureCapacity_int32_T(b_taper, i2);
      taper_data = b_taper->data;
      nx = taper->size[1];
      for (i2 = 0; i2 < nx; i2++) {
        taper_data[i2] = (int)f_data[i2] - 1;
      }
      taper_data[taper->size[1]] = 0;
      i2 = c_xwin->size[0] * c_xwin->size[1];
      c_xwin->size[0] = 1;
      c_xwin->size[1] = b_taper->size[1];
      emxEnsureCapacity_creal32_T(c_xwin, i2);
      c_xwin_data = c_xwin->data;
      nx = b_taper->size[1];
      for (i2 = 0; i2 < nx; i2++) {
        c_xwin_data[i2] = b_ywin_data[taper_data[i2]];
      }
      i2 = b_ywin->size[0] * b_ywin->size[1];
      b_ywin->size[0] = 1;
      b_ywin->size[1] = c_xwin->size[1];
      emxEnsureCapacity_creal32_T(b_ywin, i2);
      b_ywin_data = b_ywin->data;
      nx = c_xwin->size[1];
      for (i2 = 0; i2 < nx; i2++) {
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
        f_data = taper->data;
        nx = b_zwin->size[1] - 2;
        for (i2 = 0; i2 <= nx; i2++) {
          f_data[i2] = (double)i2 + 2.0;
        }
      }
      i2 = b_taper->size[0] * b_taper->size[1];
      b_taper->size[0] = 1;
      b_taper->size[1] = taper->size[1] + 1;
      emxEnsureCapacity_int32_T(b_taper, i2);
      taper_data = b_taper->data;
      nx = taper->size[1];
      for (i2 = 0; i2 < nx; i2++) {
        taper_data[i2] = (int)f_data[i2] - 1;
      }
      taper_data[taper->size[1]] = 0;
      i2 = c_xwin->size[0] * c_xwin->size[1];
      c_xwin->size[0] = 1;
      c_xwin->size[1] = b_taper->size[1];
      emxEnsureCapacity_creal32_T(c_xwin, i2);
      c_xwin_data = c_xwin->data;
      nx = b_taper->size[1];
      for (i2 = 0; i2 < nx; i2++) {
        c_xwin_data[i2] = b_zwin_data[taper_data[i2]];
      }
      i2 = b_zwin->size[0] * b_zwin->size[1];
      b_zwin->size[0] = 1;
      b_zwin->size[1] = c_xwin->size[1];
      emxEnsureCapacity_creal32_T(b_zwin, i2);
      b_zwin_data = b_zwin->data;
      nx = c_xwin->size[1];
      for (i2 = 0; i2 < nx; i2++) {
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
      /*  only compute for raw frequencies less than the max frequency of
       * interest (to save memory) */
      i2 = r6->size[0] * r6->size[1];
      r6->size[0] = 1;
      r6->size[1] = rawf->size[1];
      emxEnsureCapacity_boolean_T(r6, i2);
      r7 = r6->data;
      for (i2 = 0; i2 < loop_ub; i2++) {
        r7[i2] = (rawf_data[i2] < bandwidth);
      }
      k = r6->size[1] - 1;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          nx++;
        }
      }
      i2 = r->size[0] * r->size[1];
      r->size[0] = 1;
      r->size[1] = nx;
      emxEnsureCapacity_creal32_T(r, i2);
      c_xwin_data = r->data;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          c_xwin_data[nx] = b_xwin_data[b_i];
          nx++;
        }
      }
      i2 = r6->size[0] * r6->size[1];
      r6->size[0] = 1;
      r6->size[1] = rawf->size[1];
      emxEnsureCapacity_boolean_T(r6, i2);
      r7 = r6->data;
      for (i2 = 0; i2 < b_loop_ub; i2++) {
        r7[i2] = (rawf_data[i2] < bandwidth);
      }
      k = r6->size[1] - 1;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          nx++;
        }
      }
      i2 = r1->size[0] * r1->size[1];
      r1->size[0] = 1;
      r1->size[1] = nx;
      emxEnsureCapacity_creal32_T(r1, i2);
      r8 = r1->data;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          r8[nx].re = b_xwin_data[b_i].re;
          r8[nx].im = -b_xwin_data[b_i].im;
          nx++;
        }
      }
      if (r->size[1] == r1->size[1]) {
        i2 = xwin->size[0] * xwin->size[1];
        xwin->size[0] = 1;
        xwin->size[1] = r->size[1];
        emxEnsureCapacity_real32_T(xwin, i2);
        xwin_data = xwin->data;
        nx = r->size[1];
        for (i2 = 0; i2 < nx; i2++) {
          xwin_data[i2] = (c_xwin_data[i2].re * r8[i2].re -
                           c_xwin_data[i2].im * r8[i2].im) /
                          (float)Nyquist;
        }
      } else {
        binary_expand_op(xwin, r, r1, Nyquist);
        xwin_data = xwin->data;
      }
      i2 = r6->size[0] * r6->size[1];
      r6->size[0] = 1;
      r6->size[1] = rawf->size[1];
      emxEnsureCapacity_boolean_T(r6, i2);
      r7 = r6->data;
      for (i2 = 0; i2 < c_loop_ub; i2++) {
        r7[i2] = (rawf_data[i2] < bandwidth);
      }
      k = r6->size[1] - 1;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          nx++;
        }
      }
      i2 = r2->size[0] * r2->size[1];
      r2->size[0] = 1;
      r2->size[1] = nx;
      emxEnsureCapacity_creal32_T(r2, i2);
      c_xwin_data = r2->data;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          c_xwin_data[nx] = b_ywin_data[b_i];
          nx++;
        }
      }
      i2 = r6->size[0] * r6->size[1];
      r6->size[0] = 1;
      r6->size[1] = rawf->size[1];
      emxEnsureCapacity_boolean_T(r6, i2);
      r7 = r6->data;
      for (i2 = 0; i2 < d_loop_ub; i2++) {
        r7[i2] = (rawf_data[i2] < bandwidth);
      }
      k = r6->size[1] - 1;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          nx++;
        }
      }
      i2 = r3->size[0] * r3->size[1];
      r3->size[0] = 1;
      r3->size[1] = nx;
      emxEnsureCapacity_creal32_T(r3, i2);
      r8 = r3->data;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          r8[nx].re = b_ywin_data[b_i].re;
          r8[nx].im = -b_ywin_data[b_i].im;
          nx++;
        }
      }
      if (r2->size[1] == r3->size[1]) {
        i2 = ywin->size[0] * ywin->size[1];
        ywin->size[0] = 1;
        ywin->size[1] = r2->size[1];
        emxEnsureCapacity_real32_T(ywin, i2);
        ywin_data = ywin->data;
        nx = r2->size[1];
        for (i2 = 0; i2 < nx; i2++) {
          ywin_data[i2] = (c_xwin_data[i2].re * r8[i2].re -
                           c_xwin_data[i2].im * r8[i2].im) /
                          (float)Nyquist;
        }
      } else {
        binary_expand_op(ywin, r2, r3, Nyquist);
        ywin_data = ywin->data;
      }
      i2 = r6->size[0] * r6->size[1];
      r6->size[0] = 1;
      r6->size[1] = rawf->size[1];
      emxEnsureCapacity_boolean_T(r6, i2);
      r7 = r6->data;
      for (i2 = 0; i2 < e_loop_ub; i2++) {
        r7[i2] = (rawf_data[i2] < bandwidth);
      }
      k = r6->size[1] - 1;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          nx++;
        }
      }
      i2 = r4->size[0] * r4->size[1];
      r4->size[0] = 1;
      r4->size[1] = nx;
      emxEnsureCapacity_creal32_T(r4, i2);
      c_xwin_data = r4->data;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          c_xwin_data[nx] = b_zwin_data[b_i];
          nx++;
        }
      }
      i2 = r6->size[0] * r6->size[1];
      r6->size[0] = 1;
      r6->size[1] = rawf->size[1];
      emxEnsureCapacity_boolean_T(r6, i2);
      r7 = r6->data;
      for (i2 = 0; i2 < f_loop_ub; i2++) {
        r7[i2] = (rawf_data[i2] < bandwidth);
      }
      k = r6->size[1] - 1;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          nx++;
        }
      }
      i2 = r5->size[0] * r5->size[1];
      r5->size[0] = 1;
      r5->size[1] = nx;
      emxEnsureCapacity_creal32_T(r5, i2);
      r8 = r5->data;
      nx = 0;
      for (b_i = 0; b_i <= k; b_i++) {
        if (r7[b_i]) {
          r8[nx].re = b_zwin_data[b_i].re;
          r8[nx].im = -b_zwin_data[b_i].im;
          nx++;
        }
      }
      if (r4->size[1] == r5->size[1]) {
        i2 = zwin->size[0] * zwin->size[1];
        zwin->size[0] = 1;
        zwin->size[1] = r4->size[1];
        emxEnsureCapacity_real32_T(zwin, i2);
        zwin_data = zwin->data;
        nx = r4->size[1];
        for (i2 = 0; i2 < nx; i2++) {
          zwin_data[i2] = (c_xwin_data[i2].re * r8[i2].re -
                           c_xwin_data[i2].im * r8[i2].im) /
                          (float)Nyquist;
        }
      } else {
        binary_expand_op(zwin, r4, r5, Nyquist);
        zwin_data = zwin->data;
      }
      /*  accumulate window results and merge neighboring frequency bands (to
       * increase DOFs) */
      for (mi = 0; mi < i1; mi++) {
        k = mi * 5 + 5;
        if (k - 4 > k) {
          i2 = 0;
          i3 = 0;
        } else {
          i2 = k - 5;
          i3 = k;
        }
        xwin_size[0] = 1;
        nx = i3 - i2;
        xwin_size[1] = nx;
        for (i3 = 0; i3 < nx; i3++) {
          d_xwin_data[i3] = xwin_data[i2 + i3];
        }
        b_i = (int)((double)k / 5.0) - 1;
        e_xwin_data.data = &d_xwin_data[0];
        e_xwin_data.size = &xwin_size[0];
        e_xwin_data.allocatedSize = 235;
        e_xwin_data.numDimensions = 2;
        e_xwin_data.canFreeData = false;
        b_XX_data[b_i] += mean(&e_xwin_data);
        if (k - 4 > k) {
          i2 = 0;
          i3 = 0;
        } else {
          i2 = k - 5;
          i3 = k;
        }
        xwin_size[0] = 1;
        nx = i3 - i2;
        xwin_size[1] = nx;
        for (i3 = 0; i3 < nx; i3++) {
          d_xwin_data[i3] = ywin_data[i2 + i3];
        }
        f_xwin_data.data = &d_xwin_data[0];
        f_xwin_data.size = &xwin_size[0];
        f_xwin_data.allocatedSize = 235;
        f_xwin_data.numDimensions = 2;
        f_xwin_data.canFreeData = false;
        b_YY_data[b_i] += mean(&f_xwin_data);
        if (k - 4 > k) {
          i2 = 0;
          k = 0;
        } else {
          i2 = k - 5;
        }
        xwin_size[0] = 1;
        nx = k - i2;
        xwin_size[1] = nx;
        for (i3 = 0; i3 < nx; i3++) {
          d_xwin_data[i3] = zwin_data[i2 + i3];
        }
        g_xwin_data.data = &d_xwin_data[0];
        g_xwin_data.size = &xwin_size[0];
        g_xwin_data.allocatedSize = 235;
        g_xwin_data.numDimensions = 2;
        g_xwin_data.canFreeData = false;
        b_ZZ_data[b_i] += mean(&g_xwin_data);
      }
    }
    emxFree_creal32_T(&c_xwin);
    emxFree_int32_T(&b_taper);
    emxFree_boolean_T(&r6);
    emxFree_creal32_T(&r5);
    emxFree_creal32_T(&r4);
    emxFree_creal32_T(&r3);
    emxFree_creal32_T(&r2);
    emxFree_creal32_T(&r1);
    emxFree_creal32_T(&r);
    emxFree_creal32_T(&b_zwin);
    emxFree_creal32_T(&b_ywin);
    emxFree_creal32_T(&b_xwin);
    emxFree_real_T(&taper);
    emxFree_real32_T(&zwin);
    emxFree_real32_T(&ywin);
    emxFree_real32_T(&xwin);
    emxFree_real_T(&rawf);
    /*  close window loop */
    /*     %% divide accumulated results by number of windows (effectively an
     * ensemble avg) */
    /*     %% format for microSWIFT telemetry output (payload type 52) */
    *b_fmin = doubleToHalf(minimum((double *)f->data, *(int(*)[2])f->size));
    *b_fmax = doubleToHalf(bandwidth);
    XX_size[0] = 1;
    XX_size[1] = XX_size_idx_1;
    emxFree_real_T(&f);
    for (i = 0; i < XX_size_idx_1; i++) {
      XX_data[i] = floatToHalf(b_XX_data[i] / (float)windows);
    }
    YY_size[0] = 1;
    YY_size[1] = YY_size_idx_1;
    for (i = 0; i < YY_size_idx_1; i++) {
      YY_data[i] = floatToHalf(b_YY_data[i] / (float)windows);
    }
    ZZ_size[0] = 1;
    ZZ_size[1] = ZZ_size_idx_1;
    for (i = 0; i < ZZ_size_idx_1; i++) {
      ZZ_data[i] = floatToHalf(b_ZZ_data[i] / (float)windows);
    }
  } else {
    *b_fmin = floatToHalf(10000.0F);
    *b_fmax = floatToHalf(10000.0F);
    XX_size[0] = 1;
    XX_size[1] = 48;
    YY_size[0] = 1;
    YY_size[1] = 48;
    ZZ_size[0] = 1;
    ZZ_size[1] = 48;
    for (i = 0; i < 48; i++) {
      XX_data[i] = floatToHalf(10000.0F);
      YY_data[i] = floatToHalf(10000.0F);
      ZZ_data[i] = floatToHalf(10000.0F);
    }
  }
}

/*
 * File trailer for XYZaccelerationspectra.c
 *
 * [EOF]
 */
