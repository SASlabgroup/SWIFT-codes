/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: GPSwaves.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "GPSwaves_emxutil.h"
#include "detrend.h"
#include "mean.h"
#include "nullAssignment.h"
#include "abs.h"
#include "sum.h"
#include "sqrt.h"
#include "cos.h"
#include "power.h"
#include "atan2.h"
#include "rdivide.h"
#include "fft.h"
#include "var.h"
#include "sin.h"
#include "std.h"

/* Function Declarations */
static double rt_remd_snf(double u0, double u1);
static double rt_roundd_snf(double u);

/* Function Definitions */

/*
 * Arguments    : double u0
 *                double u1
 * Return Type  : double
 */
static double rt_remd_snf(double u0, double u1)
{
  double y;
  double b_u1;
  double q;
  if (!((!rtIsNaN(u0)) && (!rtIsInf(u0)) && ((!rtIsNaN(u1)) && (!rtIsInf(u1)))))
  {
    y = rtNaN;
  } else {
    if (u1 < 0.0) {
      b_u1 = ceil(u1);
    } else {
      b_u1 = floor(u1);
    }

    if ((u1 != 0.0) && (u1 != b_u1)) {
      q = fabs(u0 / u1);
      if (fabs(q - floor(q + 0.5)) <= DBL_EPSILON * q) {
        y = 0.0 * u0;
      } else {
        y = fmod(u0, u1);
      }
    } else {
      y = fmod(u0, u1);
    }
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
 * matlab function to read and process GPS data
 *    to estimate wave height, period, direction, and spectral moments
 *    assuming deep-water limit of surface gravity wave dispersion relation
 *
 *  Inputs are east velocity [m/s], north velocity [m/s], vertical
 *  elevation relative to MSL [m], and sampling rate [Hz]
 *
 *  Some inputs can be empty variables, in which case the algorithm will use
 *  whatever non-empty inputs are available, with preference for GPS
 *  velocities
 *
 *  Required input is sampling rate, which must be at least 1 Hz and the same
 *  for all variables.  Additionaly, non-empty input time series data must
 *  have at least 512 points and all be the same size.
 *
 *  Outputs are significat wave height [m], dominant period [s], dominant direction
 *  [deg T, using meteorological from which waves are propagating], spectral
 *  energy density [m^2/Hz], frequency [Hz], and
 *  the normalized spectral moments a1, b1, a2, b2,
 *
 *  Outputs will be '9999' for invalid results.
 *
 *  Outputs can be supressed, in order, thus full usage is as follows:
 *
 *    [ Hs, Tp, Dp, E, f, a1, b1, a2, b2 ] = GPSwaves(u,v,z,fs);
 *
 *  and minimal usage is:
 *
 *    [ Hs, Tp ] = GPSwaves(u,v,[],[],[],fs);
 *
 *
 *  J. Thomson,  12/2013, v1, modified from PUVspectra.m (2003)
 *               10/2015, v2, include vertical GPS estimate to get all four directional moments
 *               10/2017, v3, change the RC filter parameter to 3.5, after
 *                            realizing that the cuttoff period is 2 pi * RC, not RC
 *               11/2018, v4, force velocity spectra as source for scalar energy spectra
 *                            remove LFNR usage
 *                            correct sign of a1, b1
 *                8/2019  force use of Tp from velocity spectra, increase max f to 1 Hz
 * Arguments    : emxArray_real_T *u
 *                emxArray_real_T *v
 *                emxArray_real_T *z
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
 * Return Type  : void
 */
void GPSwaves(emxArray_real_T *u, emxArray_real_T *v, emxArray_real_T *z, double
              fs, double *Hs, double *Tp, double *Dp, emxArray_real_T *E,
              emxArray_real_T *f, emxArray_real_T *a1, emxArray_real_T *b1,
              emxArray_real_T *a2, emxArray_real_T *b2)
{
  int zdummy;
  int i0;
  emxArray_real_T *vfiltered;
  unsigned int uv0[2];
  int loop_ub;
  emxArray_real_T *ufiltered;
  emxArray_boolean_T *badu;
  emxArray_real_T *r0;
  double alpha;
  emxArray_boolean_T *badv;
  emxArray_boolean_T *badz;
  int windows;
  int n;
  int pts;
  emxArray_int32_T *win;
  emxArray_int32_T *r1;
  emxArray_real_T *b_u;
  emxArray_int32_T *r2;
  emxArray_int32_T *r3;
  emxArray_int32_T *r4;
  emxArray_int32_T *r5;
  emxArray_real_T *b_vfiltered;
  emxArray_real_T *zfiltered;
  emxArray_real_T *uwindow;
  emxArray_real_T *vwindow;
  emxArray_real_T *zwindow;
  emxArray_real_T *taper;
  emxArray_real_T *uwindowtaper;
  emxArray_real_T *vwindowtaper;
  emxArray_real_T *factu;
  emxArray_real_T *factv;
  emxArray_real_T *factz;
  emxArray_creal_T *Uwindow;
  emxArray_creal_T *Vwindow;
  emxArray_creal_T *Zwindow;
  emxArray_real_T *UUwindow;
  emxArray_real_T *VVwindow;
  emxArray_real_T *ZZwindow;
  emxArray_creal_T *UVwindow;
  emxArray_creal_T *UZwindow;
  emxArray_creal_T *VZwindow;
  emxArray_real_T *UU;
  emxArray_real_T *VV;
  emxArray_real_T *ZZ;
  emxArray_creal_T *UZ;
  emxArray_creal_T *VZ;
  emxArray_real_T *Eyy;
  emxArray_real_T *check;
  emxArray_int32_T *r6;
  emxArray_creal_T *r7;
  emxArray_int32_T *r8;
  emxArray_int32_T *r9;
  emxArray_int32_T *r10;
  emxArray_int32_T *r11;
  emxArray_int32_T *r12;
  emxArray_creal_T *A;
  emxArray_real_T *r13;
  emxArray_creal_T *b_Uwindow;
  emxArray_real_T *b_uwindow;
  emxArray_real_T *r14;
  emxArray_creal_T *b_UVwindow;
  emxArray_real_T *b_UUwindow;
  emxArray_real_T *r15;
  emxArray_real_T *r16;
  emxArray_real_T *b_ZZ;
  emxArray_real_T *c_vfiltered;
  emxArray_real_T *b_badv;
  emxArray_real_T *b_check;
  double b_Hs;
  double b_Tp;
  double b_win;
  int fpindex;
  int b_loop_ub;
  double fe;
  double bandwidth;
  double Zwindow_im;
  int mi;
  boolean_T exitg1;

  /*  tunable parameters */
  /*  low frequency noise ratio tolerance (not applied as of Nov 2018) */
  /*  standard deviations for despiking         */
  /*  time constant [s] for high-pass filter  */
  /*  energy ratios (unused as of Oct 2017) */
  /* maxEratio = 5; % max allowed ratio of Ezz to Exx + Eyy, default is 5 */
  /* minEratio = .1; % min allowed ratio of Ezz to Exx + Eyy, default is 0.1 */
  /*  fixed parameters (which will produce 42 frequency bands) */
  /*  windoz length in seconds, should make 2^N samples */
  /*  freq bands to merge, must be odd? */
  /*  frequency cutoff for telemetry Hz */
  /*  deal with variable input data, with priority for GPS velocity */
  /*  if no vertical, asign a dummy, but then void the a1,a2 result later */
  if (z->size[1] == 0) {
    /*  check for accelerations */
    for (i0 = 0; i0 < 2; i0++) {
      uv0[i0] = (unsigned int)u->size[i0];
    }

    i0 = z->size[0] * z->size[1];
    z->size[0] = 1;
    z->size[1] = (int)uv0[1];
    emxEnsureCapacity_real_T1(z, i0);
    loop_ub = (int)uv0[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      z->data[i0] = 0.0;
    }

    zdummy = 1;
  } else {
    zdummy = 0;
  }

  emxInit_real_T1(&vfiltered, 1);

  /*  Quality control inputs (despike) */
  i0 = vfiltered->size[0];
  vfiltered->size[0] = u->size[1];
  emxEnsureCapacity_real_T(vfiltered, i0);
  loop_ub = u->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    vfiltered->data[i0] = u->data[u->size[0] * i0];
  }

  emxInit_real_T(&ufiltered, 2);
  detrend(vfiltered);
  i0 = ufiltered->size[0] * ufiltered->size[1];
  ufiltered->size[0] = 1;
  ufiltered->size[1] = vfiltered->size[0];
  emxEnsureCapacity_real_T1(ufiltered, i0);
  loop_ub = vfiltered->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ufiltered->data[ufiltered->size[0] * i0] = vfiltered->data[i0];
  }

  emxInit_boolean_T(&badu, 2);
  emxInit_real_T(&r0, 2);
  b_abs(ufiltered, r0);
  i0 = badu->size[0] * badu->size[1];
  badu->size[0] = 1;
  badu->size[1] = r0->size[1];
  emxEnsureCapacity_boolean_T(badu, i0);
  alpha = 10.0 * b_std(u);
  loop_ub = r0->size[0] * r0->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    badu->data[i0] = (r0->data[i0] >= alpha);
  }

  /*  logical array of indices for bad points */
  i0 = vfiltered->size[0];
  vfiltered->size[0] = v->size[1];
  emxEnsureCapacity_real_T(vfiltered, i0);
  loop_ub = v->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    vfiltered->data[i0] = v->data[v->size[0] * i0];
  }

  detrend(vfiltered);
  i0 = ufiltered->size[0] * ufiltered->size[1];
  ufiltered->size[0] = 1;
  ufiltered->size[1] = vfiltered->size[0];
  emxEnsureCapacity_real_T1(ufiltered, i0);
  loop_ub = vfiltered->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ufiltered->data[ufiltered->size[0] * i0] = vfiltered->data[i0];
  }

  emxInit_boolean_T(&badv, 2);
  b_abs(ufiltered, r0);
  i0 = badv->size[0] * badv->size[1];
  badv->size[0] = 1;
  badv->size[1] = r0->size[1];
  emxEnsureCapacity_boolean_T(badv, i0);
  alpha = 10.0 * b_std(v);
  loop_ub = r0->size[0] * r0->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    badv->data[i0] = (r0->data[i0] >= alpha);
  }

  /*  logical array of indices for bad points */
  i0 = vfiltered->size[0];
  vfiltered->size[0] = z->size[1];
  emxEnsureCapacity_real_T(vfiltered, i0);
  loop_ub = z->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    vfiltered->data[i0] = z->data[z->size[0] * i0];
  }

  detrend(vfiltered);
  i0 = ufiltered->size[0] * ufiltered->size[1];
  ufiltered->size[0] = 1;
  ufiltered->size[1] = vfiltered->size[0];
  emxEnsureCapacity_real_T1(ufiltered, i0);
  loop_ub = vfiltered->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ufiltered->data[ufiltered->size[0] * i0] = vfiltered->data[i0];
  }

  emxInit_boolean_T(&badz, 2);
  b_abs(ufiltered, r0);
  i0 = badz->size[0] * badz->size[1];
  badz->size[0] = 1;
  badz->size[1] = r0->size[1];
  emxEnsureCapacity_boolean_T(badz, i0);
  alpha = 10.0 * b_std(z);
  loop_ub = r0->size[0] * r0->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    badz->data[i0] = (r0->data[i0] >= alpha);
  }

  /*  logical array of indices for bad points */
  windows = badu->size[1] - 1;
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (badu->data[pts]) {
      n++;
    }
  }

  emxInit_int32_T1(&win, 2);
  i0 = win->size[0] * win->size[1];
  win->size[0] = 1;
  win->size[1] = n;
  emxEnsureCapacity_int32_T(win, i0);
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (badu->data[pts]) {
      win->data[n] = pts + 1;
      n++;
    }
  }

  windows = badu->size[1] - 1;
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (!badu->data[pts]) {
      n++;
    }
  }

  emxInit_int32_T1(&r1, 2);
  i0 = r1->size[0] * r1->size[1];
  r1->size[0] = 1;
  r1->size[1] = n;
  emxEnsureCapacity_int32_T(r1, i0);
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (!badu->data[pts]) {
      r1->data[n] = pts + 1;
      n++;
    }
  }

  emxInit_real_T(&b_u, 2);
  i0 = b_u->size[0] * b_u->size[1];
  b_u->size[0] = 1;
  b_u->size[1] = r1->size[1];
  emxEnsureCapacity_real_T1(b_u, i0);
  loop_ub = r1->size[0] * r1->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    b_u->data[i0] = u->data[r1->data[i0] - 1];
  }

  emxFree_int32_T(&r1);
  alpha = mean(b_u);
  loop_ub = win->size[0] * win->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    u->data[win->data[i0] - 1] = alpha;
  }

  windows = badv->size[1] - 1;
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (badv->data[pts]) {
      n++;
    }
  }

  emxInit_int32_T1(&r2, 2);
  i0 = r2->size[0] * r2->size[1];
  r2->size[0] = 1;
  r2->size[1] = n;
  emxEnsureCapacity_int32_T(r2, i0);
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (badv->data[pts]) {
      r2->data[n] = pts + 1;
      n++;
    }
  }

  windows = badv->size[1] - 1;
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (!badv->data[pts]) {
      n++;
    }
  }

  emxInit_int32_T1(&r3, 2);
  i0 = r3->size[0] * r3->size[1];
  r3->size[0] = 1;
  r3->size[1] = n;
  emxEnsureCapacity_int32_T(r3, i0);
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (!badv->data[pts]) {
      r3->data[n] = pts + 1;
      n++;
    }
  }

  i0 = b_u->size[0] * b_u->size[1];
  b_u->size[0] = 1;
  b_u->size[1] = r3->size[1];
  emxEnsureCapacity_real_T1(b_u, i0);
  loop_ub = r3->size[0] * r3->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    b_u->data[i0] = v->data[r3->data[i0] - 1];
  }

  emxFree_int32_T(&r3);
  alpha = mean(b_u);
  loop_ub = r2->size[0] * r2->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    v->data[r2->data[i0] - 1] = alpha;
  }

  emxFree_int32_T(&r2);
  windows = badz->size[1] - 1;
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (badz->data[pts]) {
      n++;
    }
  }

  emxInit_int32_T1(&r4, 2);
  i0 = r4->size[0] * r4->size[1];
  r4->size[0] = 1;
  r4->size[1] = n;
  emxEnsureCapacity_int32_T(r4, i0);
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (badz->data[pts]) {
      r4->data[n] = pts + 1;
      n++;
    }
  }

  windows = badz->size[1] - 1;
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (!badz->data[pts]) {
      n++;
    }
  }

  emxInit_int32_T1(&r5, 2);
  i0 = r5->size[0] * r5->size[1];
  r5->size[0] = 1;
  r5->size[1] = n;
  emxEnsureCapacity_int32_T(r5, i0);
  n = 0;
  for (pts = 0; pts <= windows; pts++) {
    if (!badz->data[pts]) {
      r5->data[n] = pts + 1;
      n++;
    }
  }

  emxFree_boolean_T(&badz);
  i0 = b_u->size[0] * b_u->size[1];
  b_u->size[0] = 1;
  b_u->size[1] = r5->size[1];
  emxEnsureCapacity_real_T1(b_u, i0);
  loop_ub = r5->size[0] * r5->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    b_u->data[i0] = z->data[r5->data[i0] - 1];
  }

  emxFree_int32_T(&r5);
  alpha = mean(b_u);
  loop_ub = r4->size[0] * r4->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    z->data[r4->data[i0] - 1] = alpha;
  }

  emxFree_int32_T(&r4);

  /*  begin processing, if data sufficient */
  pts = u->size[1];

  /*  record length in data points */
  emxInit_real_T(&b_vfiltered, 2);
  emxInit_real_T(&zfiltered, 2);
  emxInit_real_T(&uwindow, 2);
  emxInit_real_T(&vwindow, 2);
  emxInit_real_T(&zwindow, 2);
  emxInit_real_T(&taper, 2);
  emxInit_real_T(&uwindowtaper, 2);
  emxInit_real_T(&vwindowtaper, 2);
  emxInit_real_T(&factu, 2);
  emxInit_real_T(&factv, 2);
  emxInit_real_T(&factz, 2);
  emxInit_creal_T(&Uwindow, 2);
  emxInit_creal_T(&Vwindow, 2);
  emxInit_creal_T(&Zwindow, 2);
  emxInit_real_T(&UUwindow, 2);
  emxInit_real_T(&VVwindow, 2);
  emxInit_real_T(&ZZwindow, 2);
  emxInit_creal_T(&UVwindow, 2);
  emxInit_creal_T(&UZwindow, 2);
  emxInit_creal_T(&VZwindow, 2);
  emxInit_real_T(&UU, 2);
  emxInit_real_T(&VV, 2);
  emxInit_real_T(&ZZ, 2);
  emxInit_creal_T(&UZ, 2);
  emxInit_creal_T(&VZ, 2);
  emxInit_real_T(&Eyy, 2);
  emxInit_real_T(&check, 2);
  emxInit_int32_T(&r6, 1);
  emxInit_creal_T(&r7, 2);
  emxInit_int32_T1(&r8, 2);
  emxInit_int32_T1(&r9, 2);
  emxInit_int32_T1(&r10, 2);
  emxInit_int32_T1(&r11, 2);
  emxInit_int32_T1(&r12, 2);
  emxInit_creal_T(&A, 2);
  emxInit_real_T(&r13, 2);
  emxInit_creal_T(&b_Uwindow, 2);
  emxInit_real_T(&b_uwindow, 2);
  emxInit_real_T(&r14, 2);
  emxInit_creal_T(&b_UVwindow, 2);
  emxInit_real_T(&b_UUwindow, 2);
  emxInit_real_T(&r15, 2);
  emxInit_real_T(&r16, 2);
  emxInit_real_T(&b_ZZ, 2);
  emxInit_real_T(&c_vfiltered, 2);
  emxInit_real_T(&b_badv, 2);
  emxInit_real_T(&b_check, 2);
  if ((u->size[1] >= 512) && (fs >= 1.0) && (sum(badu) < 100.0) && (sum(badv) <
       100.0)) {
    /*  minimum length and quality for processing */
    /*  high-pass RC filter, detrend first */
    i0 = vfiltered->size[0];
    vfiltered->size[0] = u->size[1];
    emxEnsureCapacity_real_T(vfiltered, i0);
    loop_ub = u->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      vfiltered->data[i0] = u->data[u->size[0] * i0];
    }

    detrend(vfiltered);
    i0 = u->size[0] * u->size[1];
    u->size[0] = 1;
    u->size[1] = vfiltered->size[0];
    emxEnsureCapacity_real_T1(u, i0);
    loop_ub = vfiltered->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      u->data[u->size[0] * i0] = vfiltered->data[i0];
    }

    i0 = vfiltered->size[0];
    vfiltered->size[0] = v->size[1];
    emxEnsureCapacity_real_T(vfiltered, i0);
    loop_ub = v->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      vfiltered->data[i0] = v->data[v->size[0] * i0];
    }

    detrend(vfiltered);
    i0 = v->size[0] * v->size[1];
    v->size[0] = 1;
    v->size[1] = vfiltered->size[0];
    emxEnsureCapacity_real_T1(v, i0);
    loop_ub = vfiltered->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      v->data[v->size[0] * i0] = vfiltered->data[i0];
    }

    i0 = vfiltered->size[0];
    vfiltered->size[0] = z->size[1];
    emxEnsureCapacity_real_T(vfiltered, i0);
    loop_ub = z->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      vfiltered->data[i0] = z->data[z->size[0] * i0];
    }

    detrend(vfiltered);
    i0 = z->size[0] * z->size[1];
    z->size[0] = 1;
    z->size[1] = vfiltered->size[0];
    emxEnsureCapacity_real_T1(z, i0);
    loop_ub = vfiltered->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      z->data[z->size[0] * i0] = vfiltered->data[i0];
    }

    /* initialize */
    i0 = ufiltered->size[0] * ufiltered->size[1];
    ufiltered->size[0] = 1;
    ufiltered->size[1] = u->size[1];
    emxEnsureCapacity_real_T1(ufiltered, i0);
    loop_ub = u->size[0] * u->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      ufiltered->data[i0] = u->data[i0];
    }

    i0 = b_vfiltered->size[0] * b_vfiltered->size[1];
    b_vfiltered->size[0] = 1;
    b_vfiltered->size[1] = v->size[1];
    emxEnsureCapacity_real_T1(b_vfiltered, i0);
    loop_ub = v->size[0] * v->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_vfiltered->data[i0] = v->data[i0];
    }

    i0 = zfiltered->size[0] * zfiltered->size[1];
    zfiltered->size[0] = 1;
    zfiltered->size[1] = z->size[1];
    emxEnsureCapacity_real_T1(zfiltered, i0);
    loop_ub = z->size[0] * z->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      zfiltered->data[i0] = z->data[i0];
    }

    alpha = 3.5 / (3.5 + 1.0 / fs);
    for (n = 0; n <= z->size[1] - 2; n++) {
      ufiltered->data[1 + n] = alpha * ufiltered->data[n] + alpha * (u->data[1 +
        n] - u->data[n]);
      b_vfiltered->data[1 + n] = alpha * b_vfiltered->data[n] + alpha * (v->
        data[1 + n] - v->data[n]);
      zfiltered->data[1 + n] = alpha * zfiltered->data[n] + alpha * (z->data[1 +
        n] - z->data[n]);
    }

    /*  break into windows (use 75 percent overlap) */
    b_win = rt_roundd_snf(fs * 256.0);

    /*  windoz length in data points */
    if (rt_remd_snf(b_win, 2.0) != 0.0) {
      b_win--;
    }

    /*  make z an even number */
    windows = (int)floor(4.0 * ((double)pts / b_win - 1.0) + 1.0);

    /*  number of windows, the 4 comes from a 75% overlap */
    /*  degrees of freedom */
    /*  loop to create a matrix of time series, where COLUMN = WINDOz  */
    i0 = uwindow->size[0] * uwindow->size[1];
    uwindow->size[0] = (int)b_win;
    uwindow->size[1] = windows;
    emxEnsureCapacity_real_T1(uwindow, i0);
    i0 = vwindow->size[0] * vwindow->size[1];
    vwindow->size[0] = (int)b_win;
    vwindow->size[1] = windows;
    emxEnsureCapacity_real_T1(vwindow, i0);
    i0 = zwindow->size[0] * zwindow->size[1];
    zwindow->size[0] = (int)b_win;
    zwindow->size[1] = windows;
    emxEnsureCapacity_real_T1(zwindow, i0);
    for (pts = 0; pts < windows; pts++) {
      loop_ub = uwindow->size[0];
      i0 = r6->size[0];
      r6->size[0] = loop_ub;
      emxEnsureCapacity_int32_T1(r6, i0);
      for (i0 = 0; i0 < loop_ub; i0++) {
        r6->data[i0] = i0;
      }

      alpha = ((1.0 + (double)pts) - 1.0) * (0.25 * b_win);
      i0 = r0->size[0] * r0->size[1];
      r0->size[0] = 1;
      r0->size[1] = (int)(b_win - 1.0) + 1;
      emxEnsureCapacity_real_T1(r0, i0);
      loop_ub = (int)(b_win - 1.0);
      for (i0 = 0; i0 <= loop_ub; i0++) {
        r0->data[r0->size[0] * i0] = ufiltered->data[(int)(alpha + (double)(i0 +
          1)) - 1];
      }

      n = r6->size[0];
      for (i0 = 0; i0 < n; i0++) {
        uwindow->data[r6->data[i0] + uwindow->size[0] * pts] = r0->data[i0];
      }

      loop_ub = vwindow->size[0];
      i0 = r6->size[0];
      r6->size[0] = loop_ub;
      emxEnsureCapacity_int32_T1(r6, i0);
      for (i0 = 0; i0 < loop_ub; i0++) {
        r6->data[i0] = i0;
      }

      alpha = ((1.0 + (double)pts) - 1.0) * (0.25 * b_win);
      i0 = r0->size[0] * r0->size[1];
      r0->size[0] = 1;
      r0->size[1] = (int)(b_win - 1.0) + 1;
      emxEnsureCapacity_real_T1(r0, i0);
      loop_ub = (int)(b_win - 1.0);
      for (i0 = 0; i0 <= loop_ub; i0++) {
        r0->data[r0->size[0] * i0] = b_vfiltered->data[(int)(alpha + (double)(i0
          + 1)) - 1];
      }

      n = r6->size[0];
      for (i0 = 0; i0 < n; i0++) {
        vwindow->data[r6->data[i0] + vwindow->size[0] * pts] = r0->data[i0];
      }

      loop_ub = zwindow->size[0];
      i0 = r6->size[0];
      r6->size[0] = loop_ub;
      emxEnsureCapacity_int32_T1(r6, i0);
      for (i0 = 0; i0 < loop_ub; i0++) {
        r6->data[i0] = i0;
      }

      alpha = ((1.0 + (double)pts) - 1.0) * (0.25 * b_win);
      i0 = r0->size[0] * r0->size[1];
      r0->size[0] = 1;
      r0->size[1] = (int)(b_win - 1.0) + 1;
      emxEnsureCapacity_real_T1(r0, i0);
      loop_ub = (int)(b_win - 1.0);
      for (i0 = 0; i0 <= loop_ub; i0++) {
        r0->data[r0->size[0] * i0] = zfiltered->data[(int)(alpha + (double)(i0 +
          1)) - 1];
      }

      n = r6->size[0];
      for (i0 = 0; i0 < n; i0++) {
        zwindow->data[r6->data[i0] + zwindow->size[0] * pts] = r0->data[i0];
      }
    }

    /*  detrend individual windows (full series already detrended) */
    for (pts = 0; pts < windows; pts++) {
      loop_ub = uwindow->size[0];
      i0 = vfiltered->size[0];
      vfiltered->size[0] = loop_ub;
      emxEnsureCapacity_real_T(vfiltered, i0);
      for (i0 = 0; i0 < loop_ub; i0++) {
        vfiltered->data[i0] = uwindow->data[i0 + uwindow->size[0] * pts];
      }

      detrend(vfiltered);
      loop_ub = vfiltered->size[0];
      for (i0 = 0; i0 < loop_ub; i0++) {
        uwindow->data[i0 + uwindow->size[0] * pts] = vfiltered->data[i0];
      }

      loop_ub = vwindow->size[0];
      i0 = vfiltered->size[0];
      vfiltered->size[0] = loop_ub;
      emxEnsureCapacity_real_T(vfiltered, i0);
      for (i0 = 0; i0 < loop_ub; i0++) {
        vfiltered->data[i0] = vwindow->data[i0 + vwindow->size[0] * pts];
      }

      detrend(vfiltered);
      loop_ub = vfiltered->size[0];
      for (i0 = 0; i0 < loop_ub; i0++) {
        vwindow->data[i0 + vwindow->size[0] * pts] = vfiltered->data[i0];
      }

      loop_ub = zwindow->size[0];
      i0 = vfiltered->size[0];
      vfiltered->size[0] = loop_ub;
      emxEnsureCapacity_real_T(vfiltered, i0);
      for (i0 = 0; i0 < loop_ub; i0++) {
        vfiltered->data[i0] = zwindow->data[i0 + zwindow->size[0] * pts];
      }

      detrend(vfiltered);
      loop_ub = vfiltered->size[0];
      for (i0 = 0; i0 < loop_ub; i0++) {
        zwindow->data[i0 + zwindow->size[0] * pts] = vfiltered->data[i0];
      }
    }

    /*  taper and rescale (to preserve variance) */
    /*  form taper matrix (columns of taper coef) */
    i0 = ufiltered->size[0] * ufiltered->size[1];
    ufiltered->size[0] = 1;
    ufiltered->size[1] = (int)(b_win - 1.0) + 1;
    emxEnsureCapacity_real_T1(ufiltered, i0);
    loop_ub = (int)(b_win - 1.0);
    for (i0 = 0; i0 <= loop_ub; i0++) {
      ufiltered->data[ufiltered->size[0] * i0] = 1.0 + (double)i0;
    }

    i0 = ufiltered->size[0] * ufiltered->size[1];
    ufiltered->size[0] = 1;
    emxEnsureCapacity_real_T1(ufiltered, i0);
    n = ufiltered->size[0];
    pts = ufiltered->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      ufiltered->data[i0] = ufiltered->data[i0] * 3.1415926535897931 / b_win;
    }

    b_sin(ufiltered);
    i0 = taper->size[0] * taper->size[1];
    taper->size[0] = ufiltered->size[1];
    taper->size[1] = windows;
    emxEnsureCapacity_real_T1(taper, i0);
    loop_ub = ufiltered->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      for (fpindex = 0; fpindex < windows; fpindex++) {
        taper->data[i0 + taper->size[0] * fpindex] = ufiltered->data
          [ufiltered->size[0] * i0];
      }
    }

    /*  taper each window */
    i0 = uwindowtaper->size[0] * uwindowtaper->size[1];
    uwindowtaper->size[0] = uwindow->size[0];
    uwindowtaper->size[1] = uwindow->size[1];
    emxEnsureCapacity_real_T1(uwindowtaper, i0);
    loop_ub = uwindow->size[0] * uwindow->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      uwindowtaper->data[i0] = uwindow->data[i0] * taper->data[i0];
    }

    i0 = vwindowtaper->size[0] * vwindowtaper->size[1];
    vwindowtaper->size[0] = vwindow->size[0];
    vwindowtaper->size[1] = vwindow->size[1];
    emxEnsureCapacity_real_T1(vwindowtaper, i0);
    loop_ub = vwindow->size[0] * vwindow->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      vwindowtaper->data[i0] = vwindow->data[i0] * taper->data[i0];
    }

    i0 = taper->size[0] * taper->size[1];
    taper->size[0] = zwindow->size[0];
    taper->size[1] = zwindow->size[1];
    emxEnsureCapacity_real_T1(taper, i0);
    loop_ub = zwindow->size[0] * zwindow->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      taper->data[i0] *= zwindow->data[i0];
    }

    /*  noz find the correction factor (comparing old/nez variance) */
    var(uwindow, factz);
    var(uwindowtaper, r13);
    rdivide(factz, r13, r0);
    d_sqrt(r0);
    i0 = factu->size[0] * factu->size[1];
    factu->size[0] = 1;
    factu->size[1] = r0->size[1];
    emxEnsureCapacity_real_T1(factu, i0);
    loop_ub = r0->size[0] * r0->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      factu->data[i0] = r0->data[i0];
    }

    var(vwindow, factz);
    var(vwindowtaper, r13);
    rdivide(factz, r13, r0);
    d_sqrt(r0);
    i0 = factv->size[0] * factv->size[1];
    factv->size[0] = 1;
    factv->size[1] = r0->size[1];
    emxEnsureCapacity_real_T1(factv, i0);
    loop_ub = r0->size[0] * r0->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      factv->data[i0] = r0->data[i0];
    }

    var(zwindow, factz);
    var(taper, r13);
    rdivide(factz, r13, r0);
    d_sqrt(r0);
    i0 = factz->size[0] * factz->size[1];
    factz->size[0] = 1;
    factz->size[1] = r0->size[1];
    emxEnsureCapacity_real_T1(factz, i0);
    loop_ub = r0->size[0] * r0->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      factz->data[i0] = r0->data[i0];
    }

    /*  and correct for the change in variance */
    /*  (mult each windoz by it's variance ratio factor) */
    /*  FFT */
    /*  calculate Fourier coefs */
    i0 = r15->size[0] * r15->size[1];
    r15->size[0] = (int)b_win;
    r15->size[1] = factu->size[1];
    emxEnsureCapacity_real_T1(r15, i0);
    loop_ub = (int)b_win;
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = factu->size[1];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        r15->data[i0 + r15->size[0] * fpindex] = factu->data[factu->size[0] *
          fpindex];
      }
    }

    i0 = r14->size[0] * r14->size[1];
    r14->size[0] = r15->size[0];
    r14->size[1] = r15->size[1];
    emxEnsureCapacity_real_T1(r14, i0);
    loop_ub = r15->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = r15->size[0];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        r14->data[fpindex + r14->size[0] * i0] = r15->data[fpindex + r15->size[0]
          * i0] * uwindowtaper->data[fpindex + uwindowtaper->size[0] * i0];
      }
    }

    fft(r14, Uwindow);
    i0 = r15->size[0] * r15->size[1];
    r15->size[0] = (int)b_win;
    r15->size[1] = factv->size[1];
    emxEnsureCapacity_real_T1(r15, i0);
    loop_ub = (int)b_win;
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = factv->size[1];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        r15->data[i0 + r15->size[0] * fpindex] = factv->data[factv->size[0] *
          fpindex];
      }
    }

    i0 = r14->size[0] * r14->size[1];
    r14->size[0] = r15->size[0];
    r14->size[1] = r15->size[1];
    emxEnsureCapacity_real_T1(r14, i0);
    loop_ub = r15->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = r15->size[0];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        r14->data[fpindex + r14->size[0] * i0] = r15->data[fpindex + r15->size[0]
          * i0] * vwindowtaper->data[fpindex + vwindowtaper->size[0] * i0];
      }
    }

    fft(r14, Vwindow);
    i0 = r15->size[0] * r15->size[1];
    r15->size[0] = (int)b_win;
    r15->size[1] = factz->size[1];
    emxEnsureCapacity_real_T1(r15, i0);
    loop_ub = (int)b_win;
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = factz->size[1];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        r15->data[i0 + r15->size[0] * fpindex] = factz->data[factz->size[0] *
          fpindex];
      }
    }

    i0 = r14->size[0] * r14->size[1];
    r14->size[0] = r15->size[0];
    r14->size[1] = r15->size[1];
    emxEnsureCapacity_real_T1(r14, i0);
    loop_ub = r15->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = r15->size[0];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        r14->data[fpindex + r14->size[0] * i0] = r15->data[fpindex + r15->size[0]
          * i0] * taper->data[fpindex + taper->size[0] * i0];
      }
    }

    fft(r14, Zwindow);

    /*  second half of fft is redundant, so throz it out */
    alpha = b_win / 2.0 + 1.0;
    i0 = win->size[0] * win->size[1];
    win->size[0] = 1;
    win->size[1] = (int)floor(b_win - alpha) + 1;
    emxEnsureCapacity_int32_T(win, i0);
    loop_ub = (int)floor(b_win - alpha);
    for (i0 = 0; i0 <= loop_ub; i0++) {
      win->data[win->size[0] * i0] = (int)(alpha + (double)i0);
    }

    b_nullAssignment(Uwindow, win);
    alpha = b_win / 2.0 + 1.0;
    i0 = win->size[0] * win->size[1];
    win->size[0] = 1;
    win->size[1] = (int)floor(b_win - alpha) + 1;
    emxEnsureCapacity_int32_T(win, i0);
    loop_ub = (int)floor(b_win - alpha);
    for (i0 = 0; i0 <= loop_ub; i0++) {
      win->data[win->size[0] * i0] = (int)(alpha + (double)i0);
    }

    b_nullAssignment(Vwindow, win);
    alpha = b_win / 2.0 + 1.0;
    i0 = win->size[0] * win->size[1];
    win->size[0] = 1;
    win->size[1] = (int)floor(b_win - alpha) + 1;
    emxEnsureCapacity_int32_T(win, i0);
    loop_ub = (int)floor(b_win - alpha);
    for (i0 = 0; i0 <= loop_ub; i0++) {
      win->data[win->size[0] * i0] = (int)(alpha + (double)i0);
    }

    b_nullAssignment(Zwindow, win);

    /*  throz out the mean (first coef) and add a zero (to make it the right length)   */
    c_nullAssignment(Uwindow);
    c_nullAssignment(Vwindow);
    c_nullAssignment(Zwindow);
    loop_ub = Uwindow->size[1];
    n = (int)(b_win / 2.0);
    for (i0 = 0; i0 < loop_ub; i0++) {
      Uwindow->data[(n + Uwindow->size[0] * i0) - 1].re = 0.0;
      Uwindow->data[(n + Uwindow->size[0] * i0) - 1].im = 0.0;
    }

    loop_ub = Vwindow->size[1];
    n = (int)(b_win / 2.0);
    for (i0 = 0; i0 < loop_ub; i0++) {
      Vwindow->data[(n + Vwindow->size[0] * i0) - 1].re = 0.0;
      Vwindow->data[(n + Vwindow->size[0] * i0) - 1].im = 0.0;
    }

    loop_ub = Zwindow->size[1];
    n = (int)(b_win / 2.0);
    for (i0 = 0; i0 < loop_ub; i0++) {
      Zwindow->data[(n + Zwindow->size[0] * i0) - 1].re = 0.0;
      Zwindow->data[(n + Zwindow->size[0] * i0) - 1].im = 0.0;
    }

    /*  POWER SPECTRA (auto-spectra) */
    i0 = UUwindow->size[0] * UUwindow->size[1];
    UUwindow->size[0] = Uwindow->size[0];
    UUwindow->size[1] = Uwindow->size[1];
    emxEnsureCapacity_real_T1(UUwindow, i0);
    loop_ub = Uwindow->size[0] * Uwindow->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      alpha = Uwindow->data[i0].re;
      b_Tp = -Uwindow->data[i0].im;
      alpha = Uwindow->data[i0].re * alpha - Uwindow->data[i0].im * b_Tp;
      UUwindow->data[i0] = alpha;
    }

    i0 = VVwindow->size[0] * VVwindow->size[1];
    VVwindow->size[0] = Vwindow->size[0];
    VVwindow->size[1] = Vwindow->size[1];
    emxEnsureCapacity_real_T1(VVwindow, i0);
    loop_ub = Vwindow->size[0] * Vwindow->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      fe = Vwindow->data[i0].re;
      b_Hs = -Vwindow->data[i0].im;
      fe = Vwindow->data[i0].re * fe - Vwindow->data[i0].im * b_Hs;
      VVwindow->data[i0] = fe;
    }

    i0 = ZZwindow->size[0] * ZZwindow->size[1];
    ZZwindow->size[0] = Zwindow->size[0];
    ZZwindow->size[1] = Zwindow->size[1];
    emxEnsureCapacity_real_T1(ZZwindow, i0);
    loop_ub = Zwindow->size[0] * Zwindow->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      bandwidth = Zwindow->data[i0].re;
      Zwindow_im = -Zwindow->data[i0].im;
      bandwidth = Zwindow->data[i0].re * bandwidth - Zwindow->data[i0].im *
        Zwindow_im;
      ZZwindow->data[i0] = bandwidth;
    }

    /*  CROSS-SPECTRA  */
    i0 = UVwindow->size[0] * UVwindow->size[1];
    UVwindow->size[0] = Uwindow->size[0];
    UVwindow->size[1] = Uwindow->size[1];
    emxEnsureCapacity_creal_T(UVwindow, i0);
    loop_ub = Uwindow->size[0] * Uwindow->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      fe = Vwindow->data[i0].re;
      b_Hs = -Vwindow->data[i0].im;
      alpha = Uwindow->data[i0].re;
      b_Tp = Uwindow->data[i0].im;
      UVwindow->data[i0].re = alpha * fe - b_Tp * b_Hs;
      UVwindow->data[i0].im = alpha * b_Hs + b_Tp * fe;
    }

    i0 = UZwindow->size[0] * UZwindow->size[1];
    UZwindow->size[0] = Uwindow->size[0];
    UZwindow->size[1] = Uwindow->size[1];
    emxEnsureCapacity_creal_T(UZwindow, i0);
    loop_ub = Uwindow->size[0] * Uwindow->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      bandwidth = Zwindow->data[i0].re;
      Zwindow_im = -Zwindow->data[i0].im;
      alpha = Uwindow->data[i0].re;
      b_Tp = Uwindow->data[i0].im;
      UZwindow->data[i0].re = alpha * bandwidth - b_Tp * Zwindow_im;
      UZwindow->data[i0].im = alpha * Zwindow_im + b_Tp * bandwidth;
    }

    i0 = VZwindow->size[0] * VZwindow->size[1];
    VZwindow->size[0] = Vwindow->size[0];
    VZwindow->size[1] = Vwindow->size[1];
    emxEnsureCapacity_creal_T(VZwindow, i0);
    loop_ub = Vwindow->size[0] * Vwindow->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      bandwidth = Zwindow->data[i0].re;
      Zwindow_im = -Zwindow->data[i0].im;
      fe = Vwindow->data[i0].re;
      b_Hs = Vwindow->data[i0].im;
      VZwindow->data[i0].re = fe * bandwidth - b_Hs * Zwindow_im;
      VZwindow->data[i0].im = fe * Zwindow_im + b_Hs * bandwidth;
    }

    /*  merge neighboring freq bands (number of bands to merge is a fixed parameter) */
    /*  initialize */
    alpha = floor(b_win / 6.0);
    i0 = uwindow->size[0] * uwindow->size[1];
    uwindow->size[0] = (int)alpha;
    uwindow->size[1] = windows;
    emxEnsureCapacity_real_T1(uwindow, i0);
    loop_ub = (int)alpha * windows;
    for (i0 = 0; i0 < loop_ub; i0++) {
      uwindow->data[i0] = 0.0;
    }

    alpha = floor(b_win / 6.0);
    i0 = vwindow->size[0] * vwindow->size[1];
    vwindow->size[0] = (int)alpha;
    vwindow->size[1] = windows;
    emxEnsureCapacity_real_T1(vwindow, i0);
    loop_ub = (int)alpha * windows;
    for (i0 = 0; i0 < loop_ub; i0++) {
      vwindow->data[i0] = 0.0;
    }

    alpha = floor(b_win / 6.0);
    i0 = zwindow->size[0] * zwindow->size[1];
    zwindow->size[0] = (int)alpha;
    zwindow->size[1] = windows;
    emxEnsureCapacity_real_T1(zwindow, i0);
    loop_ub = (int)alpha * windows;
    for (i0 = 0; i0 < loop_ub; i0++) {
      zwindow->data[i0] = 0.0;
    }

    alpha = floor(b_win / 6.0);
    i0 = Uwindow->size[0] * Uwindow->size[1];
    Uwindow->size[0] = (int)alpha;
    Uwindow->size[1] = windows;
    emxEnsureCapacity_creal_T(Uwindow, i0);
    loop_ub = (int)alpha * windows;
    for (i0 = 0; i0 < loop_ub; i0++) {
      Uwindow->data[i0].re = 0.0;
      Uwindow->data[i0].im = 1.0;
    }

    alpha = floor(b_win / 6.0);
    i0 = Vwindow->size[0] * Vwindow->size[1];
    Vwindow->size[0] = (int)alpha;
    Vwindow->size[1] = windows;
    emxEnsureCapacity_creal_T(Vwindow, i0);
    loop_ub = (int)alpha * windows;
    for (i0 = 0; i0 < loop_ub; i0++) {
      Vwindow->data[i0].re = 0.0;
      Vwindow->data[i0].im = 1.0;
    }

    alpha = floor(b_win / 6.0);
    i0 = Zwindow->size[0] * Zwindow->size[1];
    Zwindow->size[0] = (int)alpha;
    Zwindow->size[1] = windows;
    emxEnsureCapacity_creal_T(Zwindow, i0);
    loop_ub = (int)alpha * windows;
    for (i0 = 0; i0 < loop_ub; i0++) {
      Zwindow->data[i0].re = 0.0;
      Zwindow->data[i0].im = 1.0;
    }

    i0 = (int)(b_win / 2.0 / 3.0);
    for (mi = 0; mi < i0; mi++) {
      alpha = 3.0 + (double)mi * 3.0;
      if ((alpha - 3.0) + 1.0 > alpha) {
        fpindex = 0;
        pts = 0;
      } else {
        fpindex = (int)((alpha - 3.0) + 1.0) - 1;
        pts = (int)alpha;
      }

      loop_ub = UUwindow->size[1];
      n = b_UUwindow->size[0] * b_UUwindow->size[1];
      b_UUwindow->size[0] = pts - fpindex;
      b_UUwindow->size[1] = loop_ub;
      emxEnsureCapacity_real_T1(b_UUwindow, n);
      for (n = 0; n < loop_ub; n++) {
        b_loop_ub = pts - fpindex;
        for (windows = 0; windows < b_loop_ub; windows++) {
          b_UUwindow->data[windows + b_UUwindow->size[0] * n] = UUwindow->data
            [(fpindex + windows) + UUwindow->size[0] * n];
        }
      }

      b_mean(b_UUwindow, r0);
      fpindex = factz->size[0] * factz->size[1];
      factz->size[0] = 1;
      factz->size[1] = r0->size[1];
      emxEnsureCapacity_real_T1(factz, fpindex);
      loop_ub = r0->size[0] * r0->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        factz->data[fpindex] = r0->data[fpindex];
      }

      pts = (int)(alpha / 3.0);
      loop_ub = factz->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        uwindow->data[(pts + uwindow->size[0] * fpindex) - 1] = factz->
          data[factz->size[0] * fpindex];
      }

      if ((alpha - 3.0) + 1.0 > alpha) {
        fpindex = 0;
        pts = 0;
      } else {
        fpindex = (int)((alpha - 3.0) + 1.0) - 1;
        pts = (int)alpha;
      }

      loop_ub = VVwindow->size[1];
      n = b_UUwindow->size[0] * b_UUwindow->size[1];
      b_UUwindow->size[0] = pts - fpindex;
      b_UUwindow->size[1] = loop_ub;
      emxEnsureCapacity_real_T1(b_UUwindow, n);
      for (n = 0; n < loop_ub; n++) {
        b_loop_ub = pts - fpindex;
        for (windows = 0; windows < b_loop_ub; windows++) {
          b_UUwindow->data[windows + b_UUwindow->size[0] * n] = VVwindow->data
            [(fpindex + windows) + VVwindow->size[0] * n];
        }
      }

      b_mean(b_UUwindow, r0);
      fpindex = factz->size[0] * factz->size[1];
      factz->size[0] = 1;
      factz->size[1] = r0->size[1];
      emxEnsureCapacity_real_T1(factz, fpindex);
      loop_ub = r0->size[0] * r0->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        factz->data[fpindex] = r0->data[fpindex];
      }

      pts = (int)(alpha / 3.0);
      loop_ub = factz->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        vwindow->data[(pts + vwindow->size[0] * fpindex) - 1] = factz->
          data[factz->size[0] * fpindex];
      }

      if ((alpha - 3.0) + 1.0 > alpha) {
        fpindex = 0;
        pts = 0;
      } else {
        fpindex = (int)((alpha - 3.0) + 1.0) - 1;
        pts = (int)alpha;
      }

      loop_ub = ZZwindow->size[1];
      n = b_UUwindow->size[0] * b_UUwindow->size[1];
      b_UUwindow->size[0] = pts - fpindex;
      b_UUwindow->size[1] = loop_ub;
      emxEnsureCapacity_real_T1(b_UUwindow, n);
      for (n = 0; n < loop_ub; n++) {
        b_loop_ub = pts - fpindex;
        for (windows = 0; windows < b_loop_ub; windows++) {
          b_UUwindow->data[windows + b_UUwindow->size[0] * n] = ZZwindow->data
            [(fpindex + windows) + ZZwindow->size[0] * n];
        }
      }

      b_mean(b_UUwindow, r0);
      fpindex = factz->size[0] * factz->size[1];
      factz->size[0] = 1;
      factz->size[1] = r0->size[1];
      emxEnsureCapacity_real_T1(factz, fpindex);
      loop_ub = r0->size[0] * r0->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        factz->data[fpindex] = r0->data[fpindex];
      }

      pts = (int)(alpha / 3.0);
      loop_ub = factz->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        zwindow->data[(pts + zwindow->size[0] * fpindex) - 1] = factz->
          data[factz->size[0] * fpindex];
      }

      if ((alpha - 3.0) + 1.0 > alpha) {
        fpindex = 0;
        pts = 0;
      } else {
        fpindex = (int)((alpha - 3.0) + 1.0) - 1;
        pts = (int)alpha;
      }

      loop_ub = UVwindow->size[1];
      n = b_UVwindow->size[0] * b_UVwindow->size[1];
      b_UVwindow->size[0] = pts - fpindex;
      b_UVwindow->size[1] = loop_ub;
      emxEnsureCapacity_creal_T(b_UVwindow, n);
      for (n = 0; n < loop_ub; n++) {
        b_loop_ub = pts - fpindex;
        for (windows = 0; windows < b_loop_ub; windows++) {
          b_UVwindow->data[windows + b_UVwindow->size[0] * n] = UVwindow->data
            [(fpindex + windows) + UVwindow->size[0] * n];
        }
      }

      c_mean(b_UVwindow, A);
      fpindex = r7->size[0] * r7->size[1];
      r7->size[0] = 1;
      r7->size[1] = A->size[1];
      emxEnsureCapacity_creal_T(r7, fpindex);
      loop_ub = A->size[0] * A->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        r7->data[fpindex] = A->data[fpindex];
      }

      pts = (int)(alpha / 3.0);
      loop_ub = r7->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        Uwindow->data[(pts + Uwindow->size[0] * fpindex) - 1] = r7->data
          [r7->size[0] * fpindex];
      }

      if ((alpha - 3.0) + 1.0 > alpha) {
        fpindex = 0;
        pts = 0;
      } else {
        fpindex = (int)((alpha - 3.0) + 1.0) - 1;
        pts = (int)alpha;
      }

      loop_ub = UZwindow->size[1];
      n = b_UVwindow->size[0] * b_UVwindow->size[1];
      b_UVwindow->size[0] = pts - fpindex;
      b_UVwindow->size[1] = loop_ub;
      emxEnsureCapacity_creal_T(b_UVwindow, n);
      for (n = 0; n < loop_ub; n++) {
        b_loop_ub = pts - fpindex;
        for (windows = 0; windows < b_loop_ub; windows++) {
          b_UVwindow->data[windows + b_UVwindow->size[0] * n] = UZwindow->data
            [(fpindex + windows) + UZwindow->size[0] * n];
        }
      }

      c_mean(b_UVwindow, A);
      fpindex = r7->size[0] * r7->size[1];
      r7->size[0] = 1;
      r7->size[1] = A->size[1];
      emxEnsureCapacity_creal_T(r7, fpindex);
      loop_ub = A->size[0] * A->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        r7->data[fpindex] = A->data[fpindex];
      }

      pts = (int)(alpha / 3.0);
      loop_ub = r7->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        Vwindow->data[(pts + Vwindow->size[0] * fpindex) - 1] = r7->data
          [r7->size[0] * fpindex];
      }

      if ((alpha - 3.0) + 1.0 > alpha) {
        fpindex = 0;
        pts = 0;
      } else {
        fpindex = (int)((alpha - 3.0) + 1.0) - 1;
        pts = (int)alpha;
      }

      loop_ub = VZwindow->size[1];
      n = b_UVwindow->size[0] * b_UVwindow->size[1];
      b_UVwindow->size[0] = pts - fpindex;
      b_UVwindow->size[1] = loop_ub;
      emxEnsureCapacity_creal_T(b_UVwindow, n);
      for (n = 0; n < loop_ub; n++) {
        b_loop_ub = pts - fpindex;
        for (windows = 0; windows < b_loop_ub; windows++) {
          b_UVwindow->data[windows + b_UVwindow->size[0] * n] = VZwindow->data
            [(fpindex + windows) + VZwindow->size[0] * n];
        }
      }

      c_mean(b_UVwindow, A);
      fpindex = r7->size[0] * r7->size[1];
      r7->size[0] = 1;
      r7->size[1] = A->size[1];
      emxEnsureCapacity_creal_T(r7, fpindex);
      loop_ub = A->size[0] * A->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        r7->data[fpindex] = A->data[fpindex];
      }

      pts = (int)(alpha / 3.0);
      loop_ub = r7->size[1];
      for (fpindex = 0; fpindex < loop_ub; fpindex++) {
        Zwindow->data[(pts + Zwindow->size[0] * fpindex) - 1] = r7->data
          [r7->size[0] * fpindex];
      }
    }

    /*  freq range and bandwidth */
    alpha = b_win / 2.0 / 3.0;

    /*  number of f bands */
    /*  highest spectral frequency  */
    bandwidth = 0.5 * fs / alpha;

    /*  freq (Hz) bandwitdh */
    /*  find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF BANDS! */
    b_Tp = bandwidth / 2.0;
    i0 = f->size[0] * f->size[1];
    f->size[0] = 1;
    f->size[1] = (int)floor(alpha - 1.0) + 1;
    emxEnsureCapacity_real_T1(f, i0);
    loop_ub = (int)floor(alpha - 1.0);
    for (i0 = 0; i0 <= loop_ub; i0++) {
      f->data[f->size[0] * i0] = i0;
    }

    i0 = f->size[0] * f->size[1];
    f->size[0] = 1;
    emxEnsureCapacity_real_T1(f, i0);
    n = f->size[0];
    pts = f->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      f->data[i0] = (0.00390625 + b_Tp) + bandwidth * f->data[i0];
    }

    /*  ensemble average windows together */
    /*  take the average of all windows at each freq-band */
    /*  and divide by N*samplerate to get power spectral density */
    /*  the two is b/c Matlab's fft output is the symmetric FFT,  */
    /*  and we did not use the redundant half (so need to multiply the psd by 2) */
    i0 = b_uwindow->size[0] * b_uwindow->size[1];
    b_uwindow->size[0] = uwindow->size[1];
    b_uwindow->size[1] = uwindow->size[0];
    emxEnsureCapacity_real_T1(b_uwindow, i0);
    loop_ub = uwindow->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = uwindow->size[1];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        b_uwindow->data[fpindex + b_uwindow->size[0] * i0] = uwindow->data[i0 +
          uwindow->size[0] * fpindex];
      }
    }

    b_mean(b_uwindow, UU);
    b_Hs = b_win / 2.0 * fs;
    i0 = UU->size[0] * UU->size[1];
    UU->size[0] = 1;
    emxEnsureCapacity_real_T1(UU, i0);
    n = UU->size[0];
    pts = UU->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      UU->data[i0] /= b_Hs;
    }

    i0 = b_uwindow->size[0] * b_uwindow->size[1];
    b_uwindow->size[0] = vwindow->size[1];
    b_uwindow->size[1] = vwindow->size[0];
    emxEnsureCapacity_real_T1(b_uwindow, i0);
    loop_ub = vwindow->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = vwindow->size[1];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        b_uwindow->data[fpindex + b_uwindow->size[0] * i0] = vwindow->data[i0 +
          vwindow->size[0] * fpindex];
      }
    }

    b_mean(b_uwindow, VV);
    b_Hs = b_win / 2.0 * fs;
    i0 = VV->size[0] * VV->size[1];
    VV->size[0] = 1;
    emxEnsureCapacity_real_T1(VV, i0);
    n = VV->size[0];
    pts = VV->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      VV->data[i0] /= b_Hs;
    }

    i0 = b_uwindow->size[0] * b_uwindow->size[1];
    b_uwindow->size[0] = zwindow->size[1];
    b_uwindow->size[1] = zwindow->size[0];
    emxEnsureCapacity_real_T1(b_uwindow, i0);
    loop_ub = zwindow->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = zwindow->size[1];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        b_uwindow->data[fpindex + b_uwindow->size[0] * i0] = zwindow->data[i0 +
          zwindow->size[0] * fpindex];
      }
    }

    b_mean(b_uwindow, ZZ);
    b_Hs = b_win / 2.0 * fs;
    i0 = ZZ->size[0] * ZZ->size[1];
    ZZ->size[0] = 1;
    emxEnsureCapacity_real_T1(ZZ, i0);
    n = ZZ->size[0];
    pts = ZZ->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      ZZ->data[i0] /= b_Hs;
    }

    i0 = b_Uwindow->size[0] * b_Uwindow->size[1];
    b_Uwindow->size[0] = Uwindow->size[1];
    b_Uwindow->size[1] = Uwindow->size[0];
    emxEnsureCapacity_creal_T(b_Uwindow, i0);
    loop_ub = Uwindow->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = Uwindow->size[1];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        b_Uwindow->data[fpindex + b_Uwindow->size[0] * i0] = Uwindow->data[i0 +
          Uwindow->size[0] * fpindex];
      }
    }

    c_mean(b_Uwindow, A);
    b_Hs = b_win / 2.0 * fs;
    i0 = b_Uwindow->size[0] * b_Uwindow->size[1];
    b_Uwindow->size[0] = Vwindow->size[1];
    b_Uwindow->size[1] = Vwindow->size[0];
    emxEnsureCapacity_creal_T(b_Uwindow, i0);
    loop_ub = Vwindow->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = Vwindow->size[1];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        b_Uwindow->data[fpindex + b_Uwindow->size[0] * i0] = Vwindow->data[i0 +
          Vwindow->size[0] * fpindex];
      }
    }

    c_mean(b_Uwindow, UZ);
    fe = b_win / 2.0 * fs;
    i0 = UZ->size[0] * UZ->size[1];
    UZ->size[0] = 1;
    emxEnsureCapacity_creal_T(UZ, i0);
    n = UZ->size[0];
    pts = UZ->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      alpha = UZ->data[i0].re;
      b_Tp = UZ->data[i0].im;
      if (b_Tp == 0.0) {
        UZ->data[i0].re = alpha / fe;
        UZ->data[i0].im = 0.0;
      } else if (alpha == 0.0) {
        UZ->data[i0].re = 0.0;
        UZ->data[i0].im = b_Tp / fe;
      } else {
        UZ->data[i0].re = alpha / fe;
        UZ->data[i0].im = b_Tp / fe;
      }
    }

    i0 = b_Uwindow->size[0] * b_Uwindow->size[1];
    b_Uwindow->size[0] = Zwindow->size[1];
    b_Uwindow->size[1] = Zwindow->size[0];
    emxEnsureCapacity_creal_T(b_Uwindow, i0);
    loop_ub = Zwindow->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = Zwindow->size[1];
      for (fpindex = 0; fpindex < b_loop_ub; fpindex++) {
        b_Uwindow->data[fpindex + b_Uwindow->size[0] * i0] = Zwindow->data[i0 +
          Zwindow->size[0] * fpindex];
      }
    }

    c_mean(b_Uwindow, VZ);
    fe = b_win / 2.0 * fs;
    i0 = VZ->size[0] * VZ->size[1];
    VZ->size[0] = 1;
    emxEnsureCapacity_creal_T(VZ, i0);
    n = VZ->size[0];
    pts = VZ->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      alpha = VZ->data[i0].re;
      b_Tp = VZ->data[i0].im;
      if (b_Tp == 0.0) {
        VZ->data[i0].re = alpha / fe;
        VZ->data[i0].im = 0.0;
      } else if (alpha == 0.0) {
        VZ->data[i0].re = 0.0;
        VZ->data[i0].im = b_Tp / fe;
      } else {
        VZ->data[i0].re = alpha / fe;
        VZ->data[i0].im = b_Tp / fe;
      }
    }

    /*  convert to displacement spectra (from velocity and heave) */
    /*  assumes perfectly circular deepwater orbits */
    /*  could be extended to finite depth by calling wavenumber.m  */
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = f->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = 6.2831853071795862 * f->data[i0];
    }

    power(b_u, r0);
    rdivide(UU, r0, E);

    /* [m^2/Hz] */
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = f->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = 6.2831853071795862 * f->data[i0];
    }

    power(b_u, r0);
    rdivide(VV, r0, Eyy);

    /* [m^2/Hz] */
    /* [m^2/Hz] */
    /*  use orbit shape as check on quality, expect this to be < 1, b/c SWIFT wobbles */
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = Eyy->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = Eyy->size[0] * Eyy->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = Eyy->data[i0] + E->data[i0];
    }

    rdivide(ZZ, b_u, check);

    /* [m^2/Hz], quadspectrum of vertical displacement and horizontal velocities */
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = f->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = 6.2831853071795862 * f->data[i0];
    }

    b_power(b_u, r0);
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = UZ->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = UZ->size[0] * UZ->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = UZ->data[i0].re;
    }

    rdivide(b_u, r0, ufiltered);

    /* [m^2/Hz], cospectrum of vertical displacement and horizontal velocities */
    /* [m^2/Hz], quadspectrum of vertical displacement and horizontal velocities */
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = f->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = 6.2831853071795862 * f->data[i0];
    }

    b_power(b_u, r0);
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = VZ->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = VZ->size[0] * VZ->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = VZ->data[i0].re;
    }

    rdivide(b_u, r0, b_vfiltered);

    /* [m^2/Hz], cospectrum of vertical displacement and horizontal velocities */
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = f->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = 6.2831853071795862 * f->data[i0];
    }

    power(b_u, r0);
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = A->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = A->size[0] * A->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      alpha = A->data[i0].re;
      b_Tp = A->data[i0].im;
      if (b_Tp == 0.0) {
        alpha /= b_Hs;
      } else if (alpha == 0.0) {
        alpha = 0.0;
      } else {
        alpha /= b_Hs;
      }

      b_u->data[i0] = alpha;
    }

    rdivide(b_u, r0, zfiltered);

    /* [m^2/Hz] */
    /*  wave spectral moments  */
    /*  wave directions from Kuik et al, JPO, 1988 and Herbers et al, JTech, 2012 */
    /*  NOTE THAT THIS USES COSPECTRA OF Z AND U OR V, WHICH DIFFS FROM QUADSPECTRA OF Z AND X OR Y */
    /*  note also that normalization is skewed by the bias of Exx + Eyy over Ezz */
    /*  (non-unity check factor) */
    i0 = r0->size[0] * r0->size[1];
    r0->size[0] = 1;
    r0->size[1] = E->size[1];
    emxEnsureCapacity_real_T1(r0, i0);
    loop_ub = E->size[0] * E->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      r0->data[i0] = (E->data[i0] + Eyy->data[i0]) * ZZ->data[i0];
    }

    d_sqrt(r0);
    rdivide(ufiltered, r0, a1);

    /* [], would use Qxz for actual displacements */
    i0 = r0->size[0] * r0->size[1];
    r0->size[0] = 1;
    r0->size[1] = E->size[1];
    emxEnsureCapacity_real_T1(r0, i0);
    loop_ub = E->size[0] * E->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      r0->data[i0] = (E->data[i0] + Eyy->data[i0]) * ZZ->data[i0];
    }

    d_sqrt(r0);
    rdivide(b_vfiltered, r0, b1);

    /* [], would use Qyz for actual displacements */
    i0 = ufiltered->size[0] * ufiltered->size[1];
    ufiltered->size[0] = 1;
    ufiltered->size[1] = E->size[1];
    emxEnsureCapacity_real_T1(ufiltered, i0);
    loop_ub = E->size[0] * E->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      ufiltered->data[i0] = E->data[i0] - Eyy->data[i0];
    }

    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = E->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = E->size[0] * E->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = E->data[i0] + Eyy->data[i0];
    }

    rdivide(ufiltered, b_u, a2);
    i0 = r0->size[0] * r0->size[1];
    r0->size[0] = 1;
    r0->size[1] = zfiltered->size[1];
    emxEnsureCapacity_real_T1(r0, i0);
    loop_ub = zfiltered->size[0] * zfiltered->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      r0->data[i0] = 2.0 * zfiltered->data[i0];
    }

    i0 = ufiltered->size[0] * ufiltered->size[1];
    ufiltered->size[0] = 1;
    ufiltered->size[1] = E->size[1];
    emxEnsureCapacity_real_T1(ufiltered, i0);
    loop_ub = E->size[0] * E->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      ufiltered->data[i0] = E->data[i0] + Eyy->data[i0];
    }

    rdivide(r0, ufiltered, b2);

    /*  discount a2 and b2 according to the check factor (non-circular orbits) */
    /* a2 = check.*a2; */
    /* b2 = check.*b2; */
    /*  wave directions */
    /*  note that 0 deg is for waves headed towards positive x (EAST, right hand system) */
    b_atan2(b1, a1, b_vfiltered);

    /*  [rad], 4 quadrant */
    b_atan2(b2, a2, ufiltered);
    i0 = ufiltered->size[0] * ufiltered->size[1];
    ufiltered->size[0] = 1;
    emxEnsureCapacity_real_T1(ufiltered, i0);
    n = ufiltered->size[0];
    pts = ufiltered->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      ufiltered->data[i0] /= 2.0;
    }

    /*  [rad], only 2 quadrant */
    power(a1, zfiltered);
    power(b2, r0);
    i0 = zfiltered->size[0] * zfiltered->size[1];
    zfiltered->size[0] = 1;
    emxEnsureCapacity_real_T1(zfiltered, i0);
    n = zfiltered->size[0];
    pts = zfiltered->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      zfiltered->data[i0] += r0->data[i0];
    }

    d_sqrt(zfiltered);
    i0 = zfiltered->size[0] * zfiltered->size[1];
    zfiltered->size[0] = 1;
    emxEnsureCapacity_real_T1(zfiltered, i0);
    n = zfiltered->size[0];
    pts = zfiltered->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      zfiltered->data[i0] = 1.0 - zfiltered->data[i0];
    }

    i0 = zfiltered->size[0] * zfiltered->size[1];
    zfiltered->size[0] = 1;
    emxEnsureCapacity_real_T1(zfiltered, i0);
    n = zfiltered->size[0];
    pts = zfiltered->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      zfiltered->data[i0] *= 2.0;
    }

    d_sqrt(zfiltered);
    i0 = r0->size[0] * r0->size[1];
    r0->size[0] = 1;
    r0->size[1] = ufiltered->size[1];
    emxEnsureCapacity_real_T1(r0, i0);
    loop_ub = ufiltered->size[0] * ufiltered->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      r0->data[i0] = 2.0 * ufiltered->data[i0];
    }

    b_cos(r0);
    i0 = ufiltered->size[0] * ufiltered->size[1];
    ufiltered->size[0] = 1;
    emxEnsureCapacity_real_T1(ufiltered, i0);
    n = ufiltered->size[0];
    pts = ufiltered->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      ufiltered->data[i0] *= 2.0;
    }

    b_cos(ufiltered);
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = a2->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = a2->size[0] * a2->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = 0.5 - 0.5 * (a2->data[i0] * r0->data[i0] + b2->data[i0] *
        ufiltered->data[i0]);
    }

    b_abs(b_u, r0);
    b_sqrt(r0, r16);

    /*  screen for presence/absence of vertical data */
    if (zdummy == 1) {
      i0 = ZZ->size[0] * ZZ->size[1];
      ZZ->size[0] = 1;
      emxEnsureCapacity_real_T1(ZZ, i0);
      loop_ub = ZZ->size[1];
      for (i0 = 0; i0 < loop_ub; i0++) {
        ZZ->data[ZZ->size[0] * i0] = 0.0;
      }

      i0 = a1->size[0] * a1->size[1];
      a1->size[0] = 1;
      emxEnsureCapacity_real_T1(a1, i0);
      loop_ub = a1->size[1];
      for (i0 = 0; i0 < loop_ub; i0++) {
        a1->data[a1->size[0] * i0] = 9999.0;
      }

      i0 = b1->size[0] * b1->size[1];
      b1->size[0] = 1;
      emxEnsureCapacity_real_T1(b1, i0);
      loop_ub = b1->size[1];
      for (i0 = 0; i0 < loop_ub; i0++) {
        b1->data[b1->size[0] * i0] = 9999.0;
      }

      i0 = b_vfiltered->size[0] * b_vfiltered->size[1];
      b_vfiltered->size[0] = 1;
      emxEnsureCapacity_real_T1(b_vfiltered, i0);
      loop_ub = b_vfiltered->size[1];
      for (i0 = 0; i0 < loop_ub; i0++) {
        b_vfiltered->data[b_vfiltered->size[0] * i0] = 9999.0;
      }

      i0 = zfiltered->size[0] * zfiltered->size[1];
      zfiltered->size[0] = 1;
      emxEnsureCapacity_real_T1(zfiltered, i0);
      loop_ub = zfiltered->size[1];
      for (i0 = 0; i0 < loop_ub; i0++) {
        zfiltered->data[zfiltered->size[0] * i0] = 9999.0;
      }
    }

    /*  apply LFNR tolerance  */
    /* Exx(LFNR*(UU) < Exx ) = 0;  % quality control based on LFNR of swell */
    /* Eyy(LFNR*(VV) < Eyy ) = 0;  % quality control based on LFNR of swell */
    /* Ezz(LFNR*(ZZ) < Ezz ) = 0;  % quality control based on LFNR of swell */
    /*  Scalar energy spectra (a0) */
    /* if zdummy == 1, */
    i0 = E->size[0] * E->size[1];
    E->size[0] = 1;
    emxEnsureCapacity_real_T1(E, i0);
    n = E->size[0];
    pts = E->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      E->data[i0] += Eyy->data[i0];
    }

    /* else */
    /*     E = Ezz; */
    /* end */
    /* E = zeros(1,length(f)); */
    /* if wdummy ==1, */
    /*     E = Exx + Eyy; */
    /* else */
    /* fchange = 0.1;  */
    /* E(f>fchange) = Exx(f>fchange) +Eyy(f>fchange) ; % use GPS for scalar energy of wind waves */
    /* E(f<=fchange) = Ezz(f<=fchange); % use heave acceleratiosn for scalar energy of swell */
    /* end */
    /*  testing bits */
    /* E = nanmean([Ezz' (Exx+Eyy)'],2)'; */
    /* E = Eyy+Exx; % pure GPS version (for testing) */
    /* E( check > maxEratio | check < minEratio ) = 0;  */
    /* figure, loglog(f,check) */
    /* clf, loglog(f,UU+VV,'g',f,Exx+Eyy,'b',f,Ezz,'r'),legend('UU+VV','XX+YY','ZZ') % for testing */
    /* loglog(f,abs(Cxz),f,abs(Cyz)) */
    /*  wave stats */
    i0 = badu->size[0] * badu->size[1];
    badu->size[0] = 1;
    badu->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badu, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badu->data[i0] = (f->data[i0] > 0.05);
    }

    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] < 1.0);
    }

    /*  frequency cutoff for wave stats, 0.4 is specific to SWIFT hull */
    windows = badu->size[1];
    for (pts = 0; pts < windows; pts++) {
      if (!(badu->data[pts] && badv->data[pts])) {
        E->data[pts] = 0.0;
      }
    }

    /*  significant wave height */
    windows = badu->size[1] - 1;
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (badu->data[pts] && badv->data[pts]) {
        n++;
      }
    }

    i0 = r8->size[0] * r8->size[1];
    r8->size[0] = 1;
    r8->size[1] = n;
    emxEnsureCapacity_int32_T(r8, i0);
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (badu->data[pts] && badv->data[pts]) {
        r8->data[n] = pts + 1;
        n++;
      }
    }

    i0 = ufiltered->size[0] * ufiltered->size[1];
    ufiltered->size[0] = 1;
    ufiltered->size[1] = r8->size[1];
    emxEnsureCapacity_real_T1(ufiltered, i0);
    loop_ub = r8->size[0] * r8->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      ufiltered->data[i0] = E->data[r8->data[i0] - 1];
    }

    alpha = b_sum(ufiltered) * bandwidth;
    c_sqrt(&alpha);
    b_Hs = 4.0 * alpha;

    /*   energy period */
    windows = badu->size[1] - 1;
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (badu->data[pts] && badv->data[pts]) {
        n++;
      }
    }

    i0 = r9->size[0] * r9->size[1];
    r9->size[0] = 1;
    r9->size[1] = n;
    emxEnsureCapacity_int32_T(r9, i0);
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (badu->data[pts] && badv->data[pts]) {
        r9->data[n] = pts + 1;
        n++;
      }
    }

    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = r9->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = r9->size[0] * r9->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = f->data[r9->data[i0] - 1] * E->data[r9->data[i0] - 1];
    }

    alpha = b_sum(b_u);
    i0 = ufiltered->size[0] * ufiltered->size[1];
    ufiltered->size[0] = 1;
    ufiltered->size[1] = r9->size[1];
    emxEnsureCapacity_real_T1(ufiltered, i0);
    loop_ub = r9->size[0] * r9->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      ufiltered->data[i0] = E->data[r9->data[i0] - 1];
    }

    b_Tp = b_sum(ufiltered);
    fe = alpha / b_Tp;
    i0 = b_u->size[0] * b_u->size[1];
    b_u->size[0] = 1;
    b_u->size[1] = f->size[1];
    emxEnsureCapacity_real_T1(b_u, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_u->data[i0] = f->data[i0] - fe;
    }

    b_abs(b_u, ufiltered);
    pts = 1;
    n = ufiltered->size[1];
    alpha = ufiltered->data[0];
    mi = 1;
    if (ufiltered->size[1] > 1) {
      if (rtIsNaN(ufiltered->data[0])) {
        windows = 2;
        exitg1 = false;
        while ((!exitg1) && (windows <= n)) {
          pts = windows;
          if (!rtIsNaN(ufiltered->data[windows - 1])) {
            alpha = ufiltered->data[windows - 1];
            mi = windows;
            exitg1 = true;
          } else {
            windows++;
          }
        }
      }

      if (pts < ufiltered->size[1]) {
        while (pts + 1 <= n) {
          if (ufiltered->data[pts] < alpha) {
            alpha = ufiltered->data[pts];
            mi = pts + 1;
          }

          pts++;
        }
      }
    }

    /*  peak period */
    i0 = UU->size[0] * UU->size[1];
    UU->size[0] = 1;
    emxEnsureCapacity_real_T1(UU, i0);
    n = UU->size[0];
    pts = UU->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      UU->data[i0] += VV->data[i0];
    }

    pts = 1;
    n = UU->size[1];
    alpha = UU->data[0];
    b_loop_ub = 0;
    if (rtIsNaN(UU->data[0])) {
      windows = 2;
      exitg1 = false;
      while ((!exitg1) && (windows <= n)) {
        pts = windows;
        if (!rtIsNaN(UU->data[windows - 1])) {
          alpha = UU->data[windows - 1];
          b_loop_ub = windows - 1;
          exitg1 = true;
        } else {
          windows++;
        }
      }
    }

    if (pts < UU->size[1]) {
      while (pts + 1 <= n) {
        if (UU->data[pts] > alpha) {
          alpha = UU->data[pts];
          b_loop_ub = pts;
        }

        pts++;
      }
    }

    fpindex = b_loop_ub + 1;

    /*  can use velocity (picks out more distint peak) */
    /* [~ , fpindex] = max(E); */
    b_Tp = 1.0 / f->data[b_loop_ub];
    if (b_Tp > 20.0) {
      /*  if peak not found, use centroid */
      b_Tp = 1.0 / fe;
      fpindex = mi;
    }

    /*  spectral directions */
    /*  switch from rad to deg, and CCz to Cz (negate) */
    i0 = b_vfiltered->size[0] * b_vfiltered->size[1];
    b_vfiltered->size[0] = 1;
    emxEnsureCapacity_real_T1(b_vfiltered, i0);
    n = b_vfiltered->size[0];
    pts = b_vfiltered->size[1];
    loop_ub = n * pts;
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_vfiltered->data[i0] = -57.324840764331206 * b_vfiltered->data[i0] + 90.0;
    }

    /*  rotate from eastward = 0 to northward  = 0 */
    windows = b_vfiltered->size[1] - 1;
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (b_vfiltered->data[pts] < 0.0) {
        n++;
      }
    }

    i0 = r10->size[0] * r10->size[1];
    r10->size[0] = 1;
    r10->size[1] = n;
    emxEnsureCapacity_int32_T(r10, i0);
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (b_vfiltered->data[pts] < 0.0) {
        r10->data[n] = pts + 1;
        n++;
      }
    }

    i0 = vfiltered->size[0];
    vfiltered->size[0] = r10->size[0] * r10->size[1];
    emxEnsureCapacity_real_T(vfiltered, i0);
    loop_ub = r10->size[0] * r10->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      vfiltered->data[i0] = b_vfiltered->data[r10->data[i0] - 1] + 360.0;
    }

    loop_ub = vfiltered->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_vfiltered->data[r10->data[i0] - 1] = vfiltered->data[i0];
    }

    /*  take Nz quadrant from negative to 270-360 range */
    i0 = badu->size[0] * badu->size[1];
    badu->size[0] = 1;
    badu->size[1] = b_vfiltered->size[1];
    emxEnsureCapacity_boolean_T(badu, i0);
    loop_ub = b_vfiltered->size[0] * b_vfiltered->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badu->data[i0] = (b_vfiltered->data[i0] < 180.0);
    }

    windows = b_vfiltered->size[1] - 1;
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (b_vfiltered->data[pts] > 180.0) {
        n++;
      }
    }

    i0 = r11->size[0] * r11->size[1];
    r11->size[0] = 1;
    r11->size[1] = n;
    emxEnsureCapacity_int32_T(r11, i0);
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (b_vfiltered->data[pts] > 180.0) {
        r11->data[n] = pts + 1;
        n++;
      }
    }

    i0 = vfiltered->size[0];
    vfiltered->size[0] = r11->size[0] * r11->size[1];
    emxEnsureCapacity_real_T(vfiltered, i0);
    loop_ub = r11->size[0] * r11->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      vfiltered->data[i0] = b_vfiltered->data[r11->data[i0] - 1] - 180.0;
    }

    loop_ub = vfiltered->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_vfiltered->data[r11->data[i0] - 1] = vfiltered->data[i0];
    }

    /*  take reciprocal such wave direction is FROM, not TOWARDS */
    windows = badu->size[1] - 1;
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (badu->data[pts]) {
        n++;
      }
    }

    i0 = r12->size[0] * r12->size[1];
    r12->size[0] = 1;
    r12->size[1] = n;
    emxEnsureCapacity_int32_T(r12, i0);
    n = 0;
    for (pts = 0; pts <= windows; pts++) {
      if (badu->data[pts]) {
        r12->data[n] = pts + 1;
        n++;
      }
    }

    i0 = vfiltered->size[0];
    vfiltered->size[0] = r12->size[0] * r12->size[1];
    emxEnsureCapacity_real_T(vfiltered, i0);
    loop_ub = r12->size[0] * r12->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      vfiltered->data[i0] = b_vfiltered->data[r12->data[i0] - 1] + 180.0;
    }

    loop_ub = vfiltered->size[0];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_vfiltered->data[r12->data[i0] - 1] = vfiltered->data[i0];
    }

    /*  take reciprocal such wave direction is FROM, not TOWARDS */
    /*  directional spread */
    /*  dominant direction */
    /*  or peak direction (very noisy) */
    /* Dp = dir(fpindex); % dominant (peak) direction, use peak f */
    /*  or average */
    alpha = b_vfiltered->data[fpindex - 1];

    /*  dominant (peak) direction, use peak f */
    if (zdummy == 1) {
      alpha = 9999.0;
    }

    /*  screen for bad direction estimate, or no heave data     */
    /*  inds = fpindex + [-1:1]; % pick neighboring bands */
    /*  if all(inds>0) & all(inds<42),  */
    /*       */
    /*    dirnoise = std( dir(inds) ); */
    /*   */
    /*    if dirnoise > 45  |  zdummy == 1, */
    /*        Dp = 9999; */
    /*    else */
    /*        Dp = Dp; */
    /*    end */
    /*     */
    /*  else */
    /*      Dp =9999; */
    /*  end */
    /*  prune high frequency results */
    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] > 0.5);
    }

    d_nullAssignment(E, badv);
    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] > 0.5);
    }

    nullAssignment(ZZ, badv, b_ZZ);
    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] > 0.5);
    }

    nullAssignment(b_vfiltered, badv, c_vfiltered);
    i0 = r0->size[0] * r0->size[1];
    r0->size[0] = 1;
    r0->size[1] = zfiltered->size[1];
    emxEnsureCapacity_real_T1(r0, i0);
    loop_ub = zfiltered->size[0] * zfiltered->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      r0->data[i0] = 57.324840764331206 * zfiltered->data[i0];
    }

    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] > 0.5);
    }

    nullAssignment(r0, badv, b_badv);
    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] > 0.5);
    }

    d_nullAssignment(a1, badv);
    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] > 0.5);
    }

    d_nullAssignment(b1, badv);
    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] > 0.5);
    }

    d_nullAssignment(a2, badv);
    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] > 0.5);
    }

    d_nullAssignment(b2, badv);
    i0 = badv->size[0] * badv->size[1];
    badv->size[0] = 1;
    badv->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badv, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badv->data[i0] = (f->data[i0] > 0.5);
    }

    nullAssignment(check, badv, b_check);
    i0 = badu->size[0] * badu->size[1];
    badu->size[0] = 1;
    badu->size[1] = f->size[1];
    emxEnsureCapacity_boolean_T(badu, i0);
    loop_ub = f->size[0] * f->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      badu->data[i0] = (f->data[i0] > 0.5);
    }

    d_nullAssignment(f, badu);
  } else {
    /*  if not enough points or sufficent sampling rate or data, give 9999 */
    b_Hs = 9999.0;
    b_Tp = 9999.0;
    alpha = 9999.0;
    i0 = E->size[0] * E->size[1];
    E->size[0] = 1;
    E->size[1] = 1;
    emxEnsureCapacity_real_T1(E, i0);
    E->data[0] = 9999.0;
    i0 = f->size[0] * f->size[1];
    f->size[0] = 1;
    f->size[1] = 1;
    emxEnsureCapacity_real_T1(f, i0);
    f->data[0] = 9999.0;
    i0 = a1->size[0] * a1->size[1];
    a1->size[0] = 1;
    a1->size[1] = 1;
    emxEnsureCapacity_real_T1(a1, i0);
    a1->data[0] = 9999.0;
    i0 = b1->size[0] * b1->size[1];
    b1->size[0] = 1;
    b1->size[1] = 1;
    emxEnsureCapacity_real_T1(b1, i0);
    b1->data[0] = 9999.0;
    i0 = a2->size[0] * a2->size[1];
    a2->size[0] = 1;
    a2->size[1] = 1;
    emxEnsureCapacity_real_T1(a2, i0);
    a2->data[0] = 9999.0;
    i0 = b2->size[0] * b2->size[1];
    b2->size[0] = 1;
    b2->size[1] = 1;
    emxEnsureCapacity_real_T1(b2, i0);
    b2->data[0] = 9999.0;
  }

  emxFree_real_T(&b_check);
  emxFree_real_T(&b_badv);
  emxFree_real_T(&c_vfiltered);
  emxFree_real_T(&b_ZZ);
  emxFree_real_T(&r16);
  emxFree_real_T(&vfiltered);
  emxFree_real_T(&r15);
  emxFree_real_T(&b_UUwindow);
  emxFree_creal_T(&b_UVwindow);
  emxFree_real_T(&b_u);
  emxFree_real_T(&r14);
  emxFree_int32_T(&win);
  emxFree_real_T(&b_uwindow);
  emxFree_creal_T(&b_Uwindow);
  emxFree_real_T(&r13);
  emxFree_real_T(&r0);
  emxFree_creal_T(&A);
  emxFree_int32_T(&r12);
  emxFree_int32_T(&r11);
  emxFree_int32_T(&r10);
  emxFree_int32_T(&r9);
  emxFree_int32_T(&r8);
  emxFree_creal_T(&r7);
  emxFree_int32_T(&r6);
  emxFree_real_T(&check);
  emxFree_real_T(&Eyy);
  emxFree_creal_T(&VZ);
  emxFree_creal_T(&UZ);
  emxFree_real_T(&ZZ);
  emxFree_real_T(&VV);
  emxFree_real_T(&UU);
  emxFree_creal_T(&VZwindow);
  emxFree_creal_T(&UZwindow);
  emxFree_creal_T(&UVwindow);
  emxFree_real_T(&ZZwindow);
  emxFree_real_T(&VVwindow);
  emxFree_real_T(&UUwindow);
  emxFree_creal_T(&Zwindow);
  emxFree_creal_T(&Vwindow);
  emxFree_creal_T(&Uwindow);
  emxFree_real_T(&factz);
  emxFree_real_T(&factv);
  emxFree_real_T(&factu);
  emxFree_real_T(&vwindowtaper);
  emxFree_real_T(&uwindowtaper);
  emxFree_real_T(&taper);
  emxFree_real_T(&zwindow);
  emxFree_real_T(&vwindow);
  emxFree_real_T(&uwindow);
  emxFree_real_T(&zfiltered);
  emxFree_real_T(&b_vfiltered);
  emxFree_real_T(&ufiltered);
  emxFree_boolean_T(&badv);
  emxFree_boolean_T(&badu);

  /*  quality control */
  if (b_Tp > 20.0) {
    b_Hs = 9999.0;
    b_Tp = 9999.0;
    alpha = 9999.0;
  }

  *Hs = b_Hs;
  *Tp = b_Tp;
  *Dp = alpha;
}

/*
 * File trailer for GPSwaves.c
 *
 * [EOF]
 */
