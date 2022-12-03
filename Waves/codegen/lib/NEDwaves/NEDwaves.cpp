//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// NEDwaves.cpp
//
// Code generation for function 'NEDwaves'
//

// Include files
#include "NEDwaves.h"
#include "NEDwaves_data.h"
#include "NEDwaves_initialize.h"
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
#include "coder_array.h"
#include "rt_defines.h"
#include <cfloat>
#include <cmath>

// Function Declarations
static void binary_expand_op(coder::array<double, 2U> &in1, double in2,
                             const coder::array<double, 2U> &in3);

static void binary_expand_op(coder::array<creal_T, 2U> &in1,
                             const coder::array<creal_T, 2U> &in2,
                             const coder::array<creal_T, 2U> &in3);

static void plus(coder::array<double, 2U> &in1,
                 const coder::array<double, 2U> &in2,
                 const coder::array<double, 2U> &in3);

static double rt_atan2d_snf(double u0, double u1);

static double rt_remd_snf(double u0, double u1);

static void times(coder::array<double, 2U> &in1,
                  const coder::array<double, 2U> &in2);

static void times(coder::array<double, 2U> &in1,
                  const coder::array<double, 2U> &in2,
                  const coder::array<double, 2U> &in3);

// Function Definitions
static void binary_expand_op(coder::array<double, 2U> &in1, double in2,
                             const coder::array<double, 2U> &in3)
{
  coder::array<double, 2U> r;
  coder::array<double, 2U> r1;
  int aux_0_1;
  int aux_1_1;
  int b_loop_ub;
  int i;
  int loop_ub;
  int loop_ub_tmp;
  int stride_1_0;
  int stride_1_1;
  loop_ub_tmp = static_cast<int>(in2);
  r.set_size(loop_ub_tmp, in3.size(1));
  loop_ub = in3.size(1);
  for (i = 0; i < loop_ub; i++) {
    for (int i1{0}; i1 < loop_ub_tmp; i1++) {
      r[i1 + r.size(0) * i] = in3[i];
    }
  }
  if (in1.size(1) == 1) {
    i = r.size(1);
  } else {
    i = in1.size(1);
  }
  r1.set_size(r.size(0), i);
  loop_ub_tmp = (r.size(1) != 1);
  stride_1_0 = (in1.size(0) != 1);
  stride_1_1 = (in1.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  if (in1.size(1) == 1) {
    loop_ub = r.size(1);
  } else {
    loop_ub = in1.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = r.size(0);
    for (int i1{0}; i1 < b_loop_ub; i1++) {
      r1[i1 + r1.size(0) * i] = r[i1 + r.size(0) * aux_0_1] *
                                in1[i1 * stride_1_0 + in1.size(0) * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += loop_ub_tmp;
  }
  in1.set_size(r1.size(0), r1.size(1));
  loop_ub = r1.size(1);
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = r1.size(0);
    for (int i1{0}; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = r1[i1 + r1.size(0) * i];
    }
  }
}

static void binary_expand_op(coder::array<creal_T, 2U> &in1,
                             const coder::array<creal_T, 2U> &in2,
                             const coder::array<creal_T, 2U> &in3)
{
  int aux_0_1;
  int aux_1_1;
  int i;
  int i1;
  int loop_ub;
  int stride_0_0;
  int stride_0_1;
  int stride_1_0;
  int stride_1_1;
  if (in3.size(0) == 1) {
    i = in2.size(0);
  } else {
    i = in3.size(0);
  }
  if (in3.size(1) == 1) {
    i1 = in2.size(1);
  } else {
    i1 = in3.size(1);
  }
  in1.set_size(i, i1);
  stride_0_0 = (in2.size(0) != 1);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_0 = (in3.size(0) != 1);
  stride_1_1 = (in3.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  if (in3.size(1) == 1) {
    loop_ub = in2.size(1);
  } else {
    loop_ub = in3.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    int b_loop_ub;
    if (in3.size(0) == 1) {
      b_loop_ub = in2.size(0);
    } else {
      b_loop_ub = in3.size(0);
    }
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      double in3_im;
      double in3_re;
      int in3_re_tmp;
      in3_re_tmp = i1 * stride_1_0;
      in3_re = in3[in3_re_tmp + in3.size(0) * aux_1_1].re;
      in3_im = -in3[in3_re_tmp + in3.size(0) * aux_1_1].im;
      in1[i1 + in1.size(0) * i].re =
          in2[i1 * stride_0_0 + in2.size(0) * aux_0_1].re * in3_re -
          in2[i1 * stride_0_0 + in2.size(0) * aux_0_1].im * in3_im;
      in1[i1 + in1.size(0) * i].im =
          in2[i1 * stride_0_0 + in2.size(0) * aux_0_1].re * in3_im +
          in2[i1 * stride_0_0 + in2.size(0) * aux_0_1].im * in3_re;
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
}

static void plus(coder::array<double, 2U> &in1,
                 const coder::array<double, 2U> &in2,
                 const coder::array<double, 2U> &in3)
{
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in3.size(1) == 1) {
    i = in2.size(1);
  } else {
    i = in3.size(1);
  }
  in1.set_size(1, i);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_1 = (in3.size(1) != 1);
  if (in3.size(1) == 1) {
    loop_ub = in2.size(1);
  } else {
    loop_ub = in3.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    in1[i] = in2[i * stride_0_1] + in3[i * stride_1_1];
  }
}

static double rt_atan2d_snf(double u0, double u1)
{
  double y;
  if (std::isnan(u0) || std::isnan(u1)) {
    y = rtNaN;
  } else if (std::isinf(u0) && std::isinf(u1)) {
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
    y = std::atan2(static_cast<double>(b_u0), static_cast<double>(b_u1));
  } else if (u1 == 0.0) {
    if (u0 > 0.0) {
      y = RT_PI / 2.0;
    } else if (u0 < 0.0) {
      y = -(RT_PI / 2.0);
    } else {
      y = 0.0;
    }
  } else {
    y = std::atan2(u0, u1);
  }
  return y;
}

static double rt_remd_snf(double u0, double u1)
{
  double y;
  if (std::isnan(u0) || std::isnan(u1) || std::isinf(u0)) {
    y = rtNaN;
  } else if (std::isinf(u1)) {
    y = u0;
  } else if ((u1 != 0.0) && (u1 != std::trunc(u1))) {
    double q;
    q = std::abs(u0 / u1);
    if (!(std::abs(q - std::floor(q + 0.5)) > DBL_EPSILON * q)) {
      y = 0.0 * u0;
    } else {
      y = std::fmod(u0, u1);
    }
  } else {
    y = std::fmod(u0, u1);
  }
  return y;
}

static void times(coder::array<double, 2U> &in1,
                  const coder::array<double, 2U> &in2)
{
  coder::array<double, 2U> b_in1;
  int aux_0_1;
  int aux_1_1;
  int b_loop_ub;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in2.size(1) == 1) {
    i = in1.size(1);
  } else {
    i = in2.size(1);
  }
  b_in1.set_size(in1.size(0), i);
  stride_0_1 = (in1.size(1) != 1);
  stride_1_1 = (in2.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  if (in2.size(1) == 1) {
    loop_ub = in1.size(1);
  } else {
    loop_ub = in2.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = in1.size(0);
    for (int i1{0}; i1 < b_loop_ub; i1++) {
      b_in1[i1 + b_in1.size(0) * i] =
          in1[i1 + in1.size(0) * aux_0_1] * in2[i1 + in2.size(0) * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  in1.set_size(b_in1.size(0), b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1.size(0);
    for (int i1{0}; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in1[i1 + b_in1.size(0) * i];
    }
  }
}

static void times(coder::array<double, 2U> &in1,
                  const coder::array<double, 2U> &in2,
                  const coder::array<double, 2U> &in3)
{
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in3.size(1) == 1) {
    i = in2.size(1);
  } else {
    i = in3.size(1);
  }
  in1.set_size(1, i);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_1 = (in3.size(1) != 1);
  if (in3.size(1) == 1) {
    loop_ub = in2.size(1);
  } else {
    loop_ub = in3.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    in1[i] = in2[i * stride_0_1] * in3[i * stride_1_1];
  }
}

void NEDwaves(coder::array<float, 1U> &north, coder::array<float, 1U> &east,
              coder::array<float, 1U> &down, double fs, double *Hs, double *Tp,
              double *Dp, coder::array<double, 2U> &E,
              coder::array<double, 2U> &f, coder::array<double, 2U> &a1,
              coder::array<double, 2U> &b1, coder::array<double, 2U> &a2,
              coder::array<double, 2U> &b2, coder::array<double, 2U> &check)
{
  coder::array<creal_T, 2U> UV;
  coder::array<creal_T, 2U> UVwindow;
  coder::array<creal_T, 2U> UW;
  coder::array<creal_T, 2U> UWwindow;
  coder::array<creal_T, 2U> Uwindow;
  coder::array<creal_T, 2U> VW;
  coder::array<creal_T, 2U> VWwindow;
  coder::array<creal_T, 2U> Vwindow;
  coder::array<creal_T, 2U> Wwindow;
  coder::array<creal_T, 2U> b_UVwindow;
  coder::array<double, 2U> UUwindow;
  coder::array<double, 2U> VV;
  coder::array<double, 2U> VVwindow;
  coder::array<double, 2U> WWwindow;
  coder::array<double, 2U> b_UUwindow;
  coder::array<double, 2U> b_y;
  coder::array<double, 2U> r7;
  coder::array<double, 2U> r8;
  coder::array<double, 2U> taper;
  coder::array<double, 2U> uvar;
  coder::array<double, 2U> uwindow;
  coder::array<double, 2U> vvar;
  coder::array<double, 2U> vwindow;
  coder::array<double, 2U> wvar;
  coder::array<double, 2U> wwindow;
  coder::array<double, 1U> b_uwindow;
  coder::array<double, 1U> r6;
  coder::array<float, 1U> u;
  coder::array<float, 1U> v;
  coder::array<float, 1U> w;
  coder::array<int, 2U> Uwindow_tmp;
  coder::array<int, 2U> r10;
  coder::array<int, 2U> r11;
  coder::array<int, 1U> r;
  coder::array<int, 1U> r1;
  coder::array<int, 1U> r2;
  coder::array<int, 1U> r3;
  coder::array<int, 1U> r4;
  coder::array<int, 1U> r5;
  coder::array<bool, 2U> b_f;
  coder::array<bool, 2U> r9;
  coder::array<bool, 1U> bad;
  double alpha;
  float y;
  int end;
  int i;
  int k;
  int loop_ub;
  int nx;
  int vlen;
  int windows;
  bool guard1{false};
  if (!isInitialized_NEDwaves) {
    NEDwaves_initialize();
  }
  //  matlab function to process GPS velocity components north, east, down
  //    to estimate wave height, period, direction, and spectral moments
  //    assuming deep-water limit of surface gravity wave dispersion relation
  //
  //  input time series are velocity components north [m/s], east [m/s], down
  //  [m/s] and sampling rate [Hz], which must be at least 1 Hz Input time
  //  series data must have at least 512 points and all be the same size.
  //
  //  Outputs are significat wave height [m], dominant period [s], dominant
  //  direction [deg T, using meteorological from which waves are propagating],
  //  spectral energy density [m^2/Hz], frequency [Hz], and the normalized
  //  spectral moments a1, b1, a2, b2, and the check factor (ratio of vertical
  //  to horizontal motion)
  //
  //  Outputs will be '9999' for invalid results.
  //
  //  Usage is as follows:
  //
  //    [ Hs, Tp, Dp, E, f, a1, b1, a2, b2, check ] =
  //    NEDwaves(north,east,down,fs);
  //
  //  J. Thomson,  12/2022 (modified from GPSwaves)
  //
  //  tunable parameters
  //  standard deviations for despiking
  //  time constant [s] for high-pass filter (pass T < 2 pi * RC)
  //  fixed parameters (which will produce 42 frequency bands)
  //  windoz length in seconds, should make 2^N samples
  //  freq bands to merge, must be odd?
  //  frequency cutoff for telemetry Hz
  //  detrend
  coder::detrend(east);
  coder::detrend(north);
  coder::detrend(down);
  //  Despike the time series
  y = 4.0F * coder::b_std(east);
  nx = east.size(0);
  u.set_size(east.size(0));
  for (k = 0; k < nx; k++) {
    u[k] = std::abs(east[k]);
  }
  bad.set_size(u.size(0));
  loop_ub = u.size(0);
  for (i = 0; i < loop_ub; i++) {
    bad[i] = (u[i] >= y);
  }
  //  logical array of indices for bad points
  end = bad.size(0) - 1;
  nx = 0;
  for (windows = 0; windows <= end; windows++) {
    if (bad[windows]) {
      nx++;
    }
  }
  r.set_size(nx);
  vlen = 0;
  for (windows = 0; windows <= end; windows++) {
    if (bad[windows]) {
      r[vlen] = windows + 1;
      vlen++;
    }
  }
  end = bad.size(0) - 1;
  nx = 0;
  for (windows = 0; windows <= end; windows++) {
    if (!bad[windows]) {
      nx++;
    }
  }
  r1.set_size(nx);
  vlen = 0;
  for (windows = 0; windows <= end; windows++) {
    if (!bad[windows]) {
      r1[vlen] = windows + 1;
      vlen++;
    }
  }
  u.set_size(r1.size(0));
  loop_ub = r1.size(0);
  for (i = 0; i < loop_ub; i++) {
    u[i] = east[r1[i] - 1];
  }
  y = coder::blockedSummation(u, r1.size(0)) / static_cast<float>(r1.size(0));
  loop_ub = r.size(0);
  for (i = 0; i < loop_ub; i++) {
    east[r[i] - 1] = y;
  }
  y = 4.0F * coder::b_std(north);
  nx = north.size(0);
  u.set_size(north.size(0));
  for (k = 0; k < nx; k++) {
    u[k] = std::abs(north[k]);
  }
  bad.set_size(u.size(0));
  loop_ub = u.size(0);
  for (i = 0; i < loop_ub; i++) {
    bad[i] = (u[i] >= y);
  }
  //  logical array of indices for bad points
  end = bad.size(0) - 1;
  nx = 0;
  for (windows = 0; windows <= end; windows++) {
    if (bad[windows]) {
      nx++;
    }
  }
  r2.set_size(nx);
  vlen = 0;
  for (windows = 0; windows <= end; windows++) {
    if (bad[windows]) {
      r2[vlen] = windows + 1;
      vlen++;
    }
  }
  end = bad.size(0) - 1;
  nx = 0;
  for (windows = 0; windows <= end; windows++) {
    if (!bad[windows]) {
      nx++;
    }
  }
  r3.set_size(nx);
  vlen = 0;
  for (windows = 0; windows <= end; windows++) {
    if (!bad[windows]) {
      r3[vlen] = windows + 1;
      vlen++;
    }
  }
  u.set_size(r3.size(0));
  loop_ub = r3.size(0);
  for (i = 0; i < loop_ub; i++) {
    u[i] = north[r3[i] - 1];
  }
  y = coder::blockedSummation(u, r3.size(0)) / static_cast<float>(r3.size(0));
  loop_ub = r2.size(0);
  for (i = 0; i < loop_ub; i++) {
    north[r2[i] - 1] = y;
  }
  y = 4.0F * coder::b_std(down);
  nx = down.size(0);
  u.set_size(down.size(0));
  for (k = 0; k < nx; k++) {
    u[k] = std::abs(down[k]);
  }
  bad.set_size(u.size(0));
  loop_ub = u.size(0);
  for (i = 0; i < loop_ub; i++) {
    bad[i] = (u[i] >= y);
  }
  //  logical array of indices for bad points
  end = bad.size(0) - 1;
  nx = 0;
  for (windows = 0; windows <= end; windows++) {
    if (bad[windows]) {
      nx++;
    }
  }
  r4.set_size(nx);
  vlen = 0;
  for (windows = 0; windows <= end; windows++) {
    if (bad[windows]) {
      r4[vlen] = windows + 1;
      vlen++;
    }
  }
  end = bad.size(0) - 1;
  nx = 0;
  for (windows = 0; windows <= end; windows++) {
    if (!bad[windows]) {
      nx++;
    }
  }
  r5.set_size(nx);
  vlen = 0;
  for (windows = 0; windows <= end; windows++) {
    if (!bad[windows]) {
      r5[vlen] = windows + 1;
      vlen++;
    }
  }
  u.set_size(r5.size(0));
  loop_ub = r5.size(0);
  for (i = 0; i < loop_ub; i++) {
    u[i] = down[r5[i] - 1];
  }
  y = coder::blockedSummation(u, r5.size(0)) / static_cast<float>(r5.size(0));
  loop_ub = r4.size(0);
  for (i = 0; i < loop_ub; i++) {
    down[r4[i] - 1] = y;
  }
  //  begin processing, if data sufficient
  //  record length in data points
  guard1 = false;
  if ((east.size(0) >= 512) && (fs >= 1.0)) {
    vlen = bad.size(0);
    if (bad.size(0) == 0) {
      nx = 0;
    } else {
      nx = bad[0];
      for (k = 2; k <= vlen; k++) {
        nx += bad[k - 1];
      }
    }
    if (nx < 100) {
      double bandwidth;
      double fe;
      double win;
      double y_tmp;
      int i1;
      //  minimum length and quality for processing
      //  high-pass RC filter,
      // initialize and rename the variables (match original GPSwaves usage)
      u.set_size(east.size(0));
      loop_ub = east.size(0);
      for (i = 0; i < loop_ub; i++) {
        u[i] = east[i];
      }
      v.set_size(north.size(0));
      loop_ub = north.size(0);
      for (i = 0; i < loop_ub; i++) {
        v[i] = north[i];
      }
      w.set_size(down.size(0));
      loop_ub = down.size(0);
      for (i = 0; i < loop_ub; i++) {
        w[i] = down[i];
      }
      alpha = 3.5 / (1.0 / fs + 3.5);
      i = down.size(0);
      for (vlen = 0; vlen <= i - 2; vlen++) {
        u[vlen + 1] = static_cast<float>(alpha) * u[vlen] +
                      static_cast<float>(alpha) * (east[vlen + 1] - east[vlen]);
        v[vlen + 1] =
            static_cast<float>(alpha) * v[vlen] +
            static_cast<float>(alpha) * (north[vlen + 1] - north[vlen]);
        w[vlen + 1] = static_cast<float>(alpha) * w[vlen] +
                      static_cast<float>(alpha) * (down[vlen + 1] - down[vlen]);
      }
      //  break into windows (use 75 percent overlap)
      win = std::round(fs * 256.0);
      //  window length in data points
      if (rt_remd_snf(win, 2.0) != 0.0) {
        win--;
      }
      //  make win an even number
      windows = static_cast<int>(std::floor(
          4.0 * (static_cast<double>(east.size(0)) / win - 1.0) + 1.0));
      //  number of windows, the 4 comes from a 75% overlap
      //  degrees of freedom
      //  loop to create a matrix of time series, where COLUMN = WINDOw
      end = static_cast<int>(win);
      uwindow.set_size(end, windows);
      vwindow.set_size(end, windows);
      wwindow.set_size(end, windows);
      for (nx = 0; nx < windows; nx++) {
        alpha = ((static_cast<double>(nx) + 1.0) - 1.0) * (0.25 * win);
        VV.set_size(1, static_cast<int>(win - 1.0) + 1);
        loop_ub = static_cast<int>(win - 1.0);
        for (i = 0; i <= loop_ub; i++) {
          VV[i] = alpha + (static_cast<double>(i) + 1.0);
        }
        loop_ub = VV.size(1);
        for (i = 0; i < loop_ub; i++) {
          uwindow[i + uwindow.size(0) * nx] = u[static_cast<int>(VV[i]) - 1];
        }
        r6.set_size(static_cast<int>(win - 1.0) + 1);
        loop_ub = static_cast<int>(win - 1.0);
        for (i = 0; i <= loop_ub; i++) {
          r6[i] = alpha + (static_cast<double>(i) + 1.0);
        }
        loop_ub = r6.size(0);
        for (i = 0; i < loop_ub; i++) {
          vwindow[i + vwindow.size(0) * nx] = v[static_cast<int>(r6[i]) - 1];
        }
        loop_ub = r6.size(0);
        for (i = 0; i < loop_ub; i++) {
          wwindow[i + wwindow.size(0) * nx] = w[static_cast<int>(r6[i]) - 1];
        }
      }
      //  detrend individual windows (full series already detrended)
      for (nx = 0; nx < windows; nx++) {
        vlen = uwindow.size(0) - 1;
        b_uwindow.set_size(uwindow.size(0));
        for (i = 0; i <= vlen; i++) {
          b_uwindow[i] = uwindow[i + uwindow.size(0) * nx];
        }
        coder::detrend(b_uwindow, r6);
        loop_ub = r6.size(0);
        for (i = 0; i < loop_ub; i++) {
          uwindow[i + uwindow.size(0) * nx] = r6[i];
        }
        vlen = vwindow.size(0) - 1;
        b_uwindow.set_size(vwindow.size(0));
        for (i = 0; i <= vlen; i++) {
          b_uwindow[i] = vwindow[i + vwindow.size(0) * nx];
        }
        coder::detrend(b_uwindow, r6);
        loop_ub = r6.size(0);
        for (i = 0; i < loop_ub; i++) {
          vwindow[i + vwindow.size(0) * nx] = r6[i];
        }
        vlen = wwindow.size(0) - 1;
        b_uwindow.set_size(wwindow.size(0));
        for (i = 0; i <= vlen; i++) {
          b_uwindow[i] = wwindow[i + wwindow.size(0) * nx];
        }
        coder::detrend(b_uwindow, r6);
        loop_ub = r6.size(0);
        for (i = 0; i < loop_ub; i++) {
          wwindow[i + wwindow.size(0) * nx] = r6[i];
        }
      }
      //  taper and rescale (to preserve variance)
      //  get original variance of each window
      coder::var(uwindow, uvar);
      coder::var(vwindow, vvar);
      coder::var(wwindow, wvar);
      //  form taper matrix (columns of taper coef)
      VV.set_size(1, static_cast<int>(win - 1.0) + 1);
      loop_ub = static_cast<int>(win - 1.0);
      for (i = 0; i <= loop_ub; i++) {
        VV[i] = (static_cast<double>(i) + 1.0) * 3.1415926535897931 / win;
      }
      nx = VV.size(1);
      for (k = 0; k < nx; k++) {
        VV[k] = std::sin(VV[k]);
      }
      taper.set_size(VV.size(1), windows);
      for (i = 0; i < windows; i++) {
        loop_ub = VV.size(1);
        for (i1 = 0; i1 < loop_ub; i1++) {
          taper[i1 + taper.size(0) * i] = VV[i1];
        }
      }
      //  taper each window
      if (uwindow.size(1) == taper.size(1)) {
        loop_ub = uwindow.size(0) * uwindow.size(1);
        for (i = 0; i < loop_ub; i++) {
          uwindow[i] = uwindow[i] * taper[i];
        }
      } else {
        times(uwindow, taper);
      }
      if (vwindow.size(1) == taper.size(1)) {
        loop_ub = vwindow.size(0) * vwindow.size(1);
        for (i = 0; i < loop_ub; i++) {
          vwindow[i] = vwindow[i] * taper[i];
        }
      } else {
        times(vwindow, taper);
      }
      if (wwindow.size(1) == taper.size(1)) {
        loop_ub = wwindow.size(0) * wwindow.size(1);
        for (i = 0; i < loop_ub; i++) {
          wwindow[i] = wwindow[i] * taper[i];
        }
      } else {
        times(wwindow, taper);
      }
      //  now find the correction factor (comparing old/new variance)
      //  and correct for the change in variance
      //  (mult each window by it's variance ratio factor)
      coder::var(uwindow, r7);
      if (uvar.size(1) == r7.size(1)) {
        VV.set_size(1, uvar.size(1));
        loop_ub = uvar.size(1);
        for (i = 0; i < loop_ub; i++) {
          VV[i] = uvar[i] / r7[i];
        }
      } else {
        b_binary_expand_op(VV, uvar, r7);
      }
      nx = VV.size(1);
      for (k = 0; k < nx; k++) {
        VV[k] = std::sqrt(VV[k]);
      }
      taper.set_size(end, VV.size(1));
      loop_ub = VV.size(1);
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < end; i1++) {
          taper[i1 + taper.size(0) * i] = VV[i];
        }
      }
      r8.set_size(end, VV.size(1));
      loop_ub = VV.size(1);
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < end; i1++) {
          r8[i1 + r8.size(0) * i] = VV[i];
        }
      }
      if ((taper.size(0) == uwindow.size(0)) &&
          (r8.size(1) == uwindow.size(1))) {
        taper.set_size(end, VV.size(1));
        loop_ub = VV.size(1);
        for (i = 0; i < loop_ub; i++) {
          for (i1 = 0; i1 < end; i1++) {
            taper[i1 + taper.size(0) * i] = VV[i];
          }
        }
        loop_ub = taper.size(0) * taper.size(1);
        uwindow.set_size(taper.size(0), taper.size(1));
        for (i = 0; i < loop_ub; i++) {
          uwindow[i] = taper[i] * uwindow[i];
        }
      } else {
        binary_expand_op(uwindow, win, VV);
      }
      coder::var(vwindow, r7);
      if (vvar.size(1) == r7.size(1)) {
        VV.set_size(1, vvar.size(1));
        loop_ub = vvar.size(1);
        for (i = 0; i < loop_ub; i++) {
          VV[i] = vvar[i] / r7[i];
        }
      } else {
        b_binary_expand_op(VV, vvar, r7);
      }
      nx = VV.size(1);
      for (k = 0; k < nx; k++) {
        VV[k] = std::sqrt(VV[k]);
      }
      taper.set_size(end, VV.size(1));
      loop_ub = VV.size(1);
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < end; i1++) {
          taper[i1 + taper.size(0) * i] = VV[i];
        }
      }
      r8.set_size(end, VV.size(1));
      loop_ub = VV.size(1);
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < end; i1++) {
          r8[i1 + r8.size(0) * i] = VV[i];
        }
      }
      if ((taper.size(0) == vwindow.size(0)) &&
          (r8.size(1) == vwindow.size(1))) {
        taper.set_size(end, VV.size(1));
        loop_ub = VV.size(1);
        for (i = 0; i < loop_ub; i++) {
          for (i1 = 0; i1 < end; i1++) {
            taper[i1 + taper.size(0) * i] = VV[i];
          }
        }
        loop_ub = taper.size(0) * taper.size(1);
        vwindow.set_size(taper.size(0), taper.size(1));
        for (i = 0; i < loop_ub; i++) {
          vwindow[i] = taper[i] * vwindow[i];
        }
      } else {
        binary_expand_op(vwindow, win, VV);
      }
      coder::var(wwindow, r7);
      if (wvar.size(1) == r7.size(1)) {
        VV.set_size(1, wvar.size(1));
        loop_ub = wvar.size(1);
        for (i = 0; i < loop_ub; i++) {
          VV[i] = wvar[i] / r7[i];
        }
      } else {
        b_binary_expand_op(VV, wvar, r7);
      }
      nx = VV.size(1);
      for (k = 0; k < nx; k++) {
        VV[k] = std::sqrt(VV[k]);
      }
      taper.set_size(end, VV.size(1));
      loop_ub = VV.size(1);
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < end; i1++) {
          taper[i1 + taper.size(0) * i] = VV[i];
        }
      }
      r8.set_size(end, VV.size(1));
      loop_ub = VV.size(1);
      for (i = 0; i < loop_ub; i++) {
        for (i1 = 0; i1 < end; i1++) {
          r8[i1 + r8.size(0) * i] = VV[i];
        }
      }
      if ((taper.size(0) == wwindow.size(0)) &&
          (r8.size(1) == wwindow.size(1))) {
        taper.set_size(end, VV.size(1));
        loop_ub = VV.size(1);
        for (i = 0; i < loop_ub; i++) {
          for (i1 = 0; i1 < end; i1++) {
            taper[i1 + taper.size(0) * i] = VV[i];
          }
        }
        loop_ub = taper.size(0) * taper.size(1);
        wwindow.set_size(taper.size(0), taper.size(1));
        for (i = 0; i < loop_ub; i++) {
          wwindow[i] = taper[i] * wwindow[i];
        }
      } else {
        binary_expand_op(wwindow, win, VV);
      }
      //  FFT
      //  note convention for lower case as time-domain and upper case as freq
      //  domain calculate Fourier coefs
      coder::fft(uwindow, Uwindow);
      coder::fft(vwindow, Vwindow);
      coder::fft(wwindow, Wwindow);
      //  second half of fft is redundant, so throw it out
      fe = win / 2.0 + 1.0;
      loop_ub = static_cast<int>(win - fe);
      Uwindow_tmp.set_size(1, loop_ub + 1);
      for (i = 0; i <= loop_ub; i++) {
        Uwindow_tmp[i] = static_cast<int>(fe + static_cast<double>(i));
      }
      coder::internal::nullAssignment(Uwindow, Uwindow_tmp);
      coder::internal::nullAssignment(Vwindow, Uwindow_tmp);
      coder::internal::nullAssignment(Wwindow, Uwindow_tmp);
      //  throw out the mean (first coef) and add a zero (to make it the right
      //  length)
      coder::internal::nullAssignment(Uwindow);
      coder::internal::nullAssignment(Vwindow);
      coder::internal::nullAssignment(Wwindow);
      vlen = static_cast<int>(win / 2.0);
      loop_ub = Uwindow.size(1);
      for (i = 0; i < loop_ub; i++) {
        Uwindow[(vlen + Uwindow.size(0) * i) - 1].re = 0.0;
        Uwindow[(vlen + Uwindow.size(0) * i) - 1].im = 0.0;
      }
      loop_ub = Vwindow.size(1);
      for (i = 0; i < loop_ub; i++) {
        Vwindow[(vlen + Vwindow.size(0) * i) - 1].re = 0.0;
        Vwindow[(vlen + Vwindow.size(0) * i) - 1].im = 0.0;
      }
      loop_ub = Wwindow.size(1);
      for (i = 0; i < loop_ub; i++) {
        Wwindow[(vlen + Wwindow.size(0) * i) - 1].re = 0.0;
        Wwindow[(vlen + Wwindow.size(0) * i) - 1].im = 0.0;
      }
      //  POWER SPECTRA (auto-spectra)
      UUwindow.set_size(Uwindow.size(0), Uwindow.size(1));
      loop_ub = Uwindow.size(0) * Uwindow.size(1);
      for (i = 0; i < loop_ub; i++) {
        UUwindow[i] =
            Uwindow[i].re * Uwindow[i].re - Uwindow[i].im * -Uwindow[i].im;
      }
      VVwindow.set_size(Vwindow.size(0), Vwindow.size(1));
      loop_ub = Vwindow.size(0) * Vwindow.size(1);
      for (i = 0; i < loop_ub; i++) {
        VVwindow[i] =
            Vwindow[i].re * Vwindow[i].re - Vwindow[i].im * -Vwindow[i].im;
      }
      WWwindow.set_size(Wwindow.size(0), Wwindow.size(1));
      loop_ub = Wwindow.size(0) * Wwindow.size(1);
      for (i = 0; i < loop_ub; i++) {
        WWwindow[i] =
            Wwindow[i].re * Wwindow[i].re - Wwindow[i].im * -Wwindow[i].im;
      }
      //  CROSS-SPECTRA
      if ((Uwindow.size(0) == Vwindow.size(0)) &&
          (Uwindow.size(1) == Vwindow.size(1))) {
        UVwindow.set_size(Uwindow.size(0), Uwindow.size(1));
        loop_ub = Uwindow.size(0) * Uwindow.size(1);
        for (i = 0; i < loop_ub; i++) {
          alpha = Vwindow[i].re;
          fe = -Vwindow[i].im;
          UVwindow[i].re = Uwindow[i].re * alpha - Uwindow[i].im * fe;
          UVwindow[i].im = Uwindow[i].re * fe + Uwindow[i].im * alpha;
        }
      } else {
        binary_expand_op(UVwindow, Uwindow, Vwindow);
      }
      if ((Uwindow.size(0) == Wwindow.size(0)) &&
          (Uwindow.size(1) == Wwindow.size(1))) {
        UWwindow.set_size(Uwindow.size(0), Uwindow.size(1));
        loop_ub = Uwindow.size(0) * Uwindow.size(1);
        for (i = 0; i < loop_ub; i++) {
          alpha = Wwindow[i].re;
          fe = -Wwindow[i].im;
          UWwindow[i].re = Uwindow[i].re * alpha - Uwindow[i].im * fe;
          UWwindow[i].im = Uwindow[i].re * fe + Uwindow[i].im * alpha;
        }
      } else {
        binary_expand_op(UWwindow, Uwindow, Wwindow);
      }
      if ((Vwindow.size(0) == Wwindow.size(0)) &&
          (Vwindow.size(1) == Wwindow.size(1))) {
        VWwindow.set_size(Vwindow.size(0), Vwindow.size(1));
        loop_ub = Vwindow.size(0) * Vwindow.size(1);
        for (i = 0; i < loop_ub; i++) {
          alpha = Wwindow[i].re;
          fe = -Wwindow[i].im;
          VWwindow[i].re = Vwindow[i].re * alpha - Vwindow[i].im * fe;
          VWwindow[i].im = Vwindow[i].re * fe + Vwindow[i].im * alpha;
        }
      } else {
        binary_expand_op(VWwindow, Vwindow, Wwindow);
      }
      //  merge neighboring freq bands (number of bands to merge is a fixed
      //  parameter) initialize
      alpha = std::floor(win / 6.0);
      uwindow.set_size(static_cast<int>(alpha), windows);
      end = static_cast<int>(alpha) * windows;
      for (i = 0; i < end; i++) {
        uwindow[i] = 0.0;
      }
      vwindow.set_size(static_cast<int>(alpha), windows);
      for (i = 0; i < end; i++) {
        vwindow[i] = 0.0;
      }
      wwindow.set_size(static_cast<int>(alpha), windows);
      for (i = 0; i < end; i++) {
        wwindow[i] = 0.0;
      }
      Uwindow.set_size(static_cast<int>(alpha), windows);
      for (i = 0; i < end; i++) {
        Uwindow[i].re = 0.0;
        Uwindow[i].im = 1.0;
      }
      Vwindow.set_size(static_cast<int>(alpha), windows);
      for (i = 0; i < end; i++) {
        Vwindow[i].re = 0.0;
        Vwindow[i].im = 1.0;
      }
      Wwindow.set_size(static_cast<int>(alpha), windows);
      for (i = 0; i < end; i++) {
        Wwindow[i].re = 0.0;
        Wwindow[i].im = 1.0;
      }
      fe = win / 2.0 / 3.0;
      i = static_cast<int>(fe);
      loop_ub = UUwindow.size(1);
      vlen = VVwindow.size(1);
      nx = WWwindow.size(1);
      end = UVwindow.size(1);
      windows = UWwindow.size(1);
      k = VWwindow.size(1);
      for (int mi{0}; mi < i; mi++) {
        int b_loop_ub;
        int i2;
        int i3;
        alpha = static_cast<double>(mi) * 3.0 + 3.0;
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = static_cast<int>((alpha - 3.0) + 1.0) - 1;
          i2 = static_cast<int>(alpha);
        }
        i3 = static_cast<int>(alpha / 3.0) - 1;
        b_loop_ub = i2 - i1;
        b_UUwindow.set_size(b_loop_ub, loop_ub);
        for (i2 = 0; i2 < loop_ub; i2++) {
          for (int i4{0}; i4 < b_loop_ub; i4++) {
            b_UUwindow[i4 + b_UUwindow.size(0) * i2] =
                UUwindow[(i1 + i4) + UUwindow.size(0) * i2];
          }
        }
        coder::mean(b_UUwindow, VV);
        b_loop_ub = VV.size(1);
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          uwindow[i3 + uwindow.size(0) * i1] = VV[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = static_cast<int>((alpha - 3.0) + 1.0) - 1;
          i2 = static_cast<int>(alpha);
        }
        b_loop_ub = i2 - i1;
        b_UUwindow.set_size(b_loop_ub, vlen);
        for (i2 = 0; i2 < vlen; i2++) {
          for (int i4{0}; i4 < b_loop_ub; i4++) {
            b_UUwindow[i4 + b_UUwindow.size(0) * i2] =
                VVwindow[(i1 + i4) + VVwindow.size(0) * i2];
          }
        }
        coder::mean(b_UUwindow, VV);
        b_loop_ub = VV.size(1);
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          vwindow[i3 + vwindow.size(0) * i1] = VV[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = static_cast<int>((alpha - 3.0) + 1.0) - 1;
          i2 = static_cast<int>(alpha);
        }
        b_loop_ub = i2 - i1;
        b_UUwindow.set_size(b_loop_ub, nx);
        for (i2 = 0; i2 < nx; i2++) {
          for (int i4{0}; i4 < b_loop_ub; i4++) {
            b_UUwindow[i4 + b_UUwindow.size(0) * i2] =
                WWwindow[(i1 + i4) + WWwindow.size(0) * i2];
          }
        }
        coder::mean(b_UUwindow, VV);
        b_loop_ub = VV.size(1);
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          wwindow[i3 + wwindow.size(0) * i1] = VV[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = static_cast<int>((alpha - 3.0) + 1.0) - 1;
          i2 = static_cast<int>(alpha);
        }
        b_loop_ub = i2 - i1;
        b_UVwindow.set_size(b_loop_ub, end);
        for (i2 = 0; i2 < end; i2++) {
          for (int i4{0}; i4 < b_loop_ub; i4++) {
            b_UVwindow[i4 + b_UVwindow.size(0) * i2] =
                UVwindow[(i1 + i4) + UVwindow.size(0) * i2];
          }
        }
        coder::mean(b_UVwindow, UV);
        b_loop_ub = UV.size(1);
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          Uwindow[i3 + Uwindow.size(0) * i1] = UV[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = static_cast<int>((alpha - 3.0) + 1.0) - 1;
          i2 = static_cast<int>(alpha);
        }
        b_loop_ub = i2 - i1;
        b_UVwindow.set_size(b_loop_ub, windows);
        for (i2 = 0; i2 < windows; i2++) {
          for (int i4{0}; i4 < b_loop_ub; i4++) {
            b_UVwindow[i4 + b_UVwindow.size(0) * i2] =
                UWwindow[(i1 + i4) + UWwindow.size(0) * i2];
          }
        }
        coder::mean(b_UVwindow, UV);
        b_loop_ub = UV.size(1);
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          Vwindow[i3 + Vwindow.size(0) * i1] = UV[i1];
        }
        if ((alpha - 3.0) + 1.0 > alpha) {
          i1 = 0;
          i2 = 0;
        } else {
          i1 = static_cast<int>((alpha - 3.0) + 1.0) - 1;
          i2 = static_cast<int>(alpha);
        }
        b_loop_ub = i2 - i1;
        b_UVwindow.set_size(b_loop_ub, k);
        for (i2 = 0; i2 < k; i2++) {
          for (int i4{0}; i4 < b_loop_ub; i4++) {
            b_UVwindow[i4 + b_UVwindow.size(0) * i2] =
                VWwindow[(i1 + i4) + VWwindow.size(0) * i2];
          }
        }
        coder::mean(b_UVwindow, UV);
        b_loop_ub = UV.size(1);
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          Wwindow[i3 + Wwindow.size(0) * i1] = UV[i1];
        }
      }
      //  freq range and bandwidth
      //  number of f bands
      //  highest spectral frequency
      bandwidth = 0.5 * fs / fe;
      //  freq (Hz) bandwitdh
      //  find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF
      //  BANDS!
      alpha = bandwidth / 2.0 + 0.00390625;
      f.set_size(1, static_cast<int>(fe - 1.0) + 1);
      loop_ub = static_cast<int>(fe - 1.0);
      for (i = 0; i <= loop_ub; i++) {
        f[i] = alpha + bandwidth * static_cast<double>(i);
      }
      //  ensemble average windows together
      //  take the average of all windows at each freq-band
      //  and divide by N*samplerate to get power spectral density
      //  the two is b/c Matlab's fft output is the symmetric FFT,
      //  and we did not use the redundant half (so need to multiply the psd by
      //  2)
      y_tmp = win / 2.0 * fs;
      //  prune high frequency results
      b_UUwindow.set_size(uwindow.size(1), uwindow.size(0));
      loop_ub = uwindow.size(0);
      for (i = 0; i < loop_ub; i++) {
        vlen = uwindow.size(1);
        for (i1 = 0; i1 < vlen; i1++) {
          b_UUwindow[i1 + b_UUwindow.size(0) * i] =
              uwindow[i + uwindow.size(0) * i1];
        }
      }
      coder::mean(b_UUwindow, a2);
      a2.set_size(1, a2.size(1));
      loop_ub = a2.size(1) - 1;
      for (i = 0; i <= loop_ub; i++) {
        a2[i] = a2[i] / y_tmp;
      }
      b_f.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        b_f[i] = (f[i] > 0.5);
      }
      coder::internal::b_nullAssignment(a2, b_f);
      b_UUwindow.set_size(vwindow.size(1), vwindow.size(0));
      loop_ub = vwindow.size(0);
      for (i = 0; i < loop_ub; i++) {
        vlen = vwindow.size(1);
        for (i1 = 0; i1 < vlen; i1++) {
          b_UUwindow[i1 + b_UUwindow.size(0) * i] =
              vwindow[i + vwindow.size(0) * i1];
        }
      }
      coder::mean(b_UUwindow, VV);
      VV.set_size(1, VV.size(1));
      loop_ub = VV.size(1) - 1;
      for (i = 0; i <= loop_ub; i++) {
        VV[i] = VV[i] / y_tmp;
      }
      b_f.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        b_f[i] = (f[i] > 0.5);
      }
      coder::internal::b_nullAssignment(VV, b_f);
      b_UUwindow.set_size(wwindow.size(1), wwindow.size(0));
      loop_ub = wwindow.size(0);
      for (i = 0; i < loop_ub; i++) {
        vlen = wwindow.size(1);
        for (i1 = 0; i1 < vlen; i1++) {
          b_UUwindow[i1 + b_UUwindow.size(0) * i] =
              wwindow[i + wwindow.size(0) * i1];
        }
      }
      coder::mean(b_UUwindow, check);
      check.set_size(1, check.size(1));
      loop_ub = check.size(1) - 1;
      for (i = 0; i <= loop_ub; i++) {
        check[i] = check[i] / y_tmp;
      }
      b_f.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        b_f[i] = (f[i] > 0.5);
      }
      coder::internal::b_nullAssignment(check, b_f);
      b_UVwindow.set_size(Uwindow.size(1), Uwindow.size(0));
      loop_ub = Uwindow.size(0);
      for (i = 0; i < loop_ub; i++) {
        vlen = Uwindow.size(1);
        for (i1 = 0; i1 < vlen; i1++) {
          b_UVwindow[i1 + b_UVwindow.size(0) * i] =
              Uwindow[i + Uwindow.size(0) * i1];
        }
      }
      coder::mean(b_UVwindow, UV);
      UV.set_size(1, UV.size(1));
      loop_ub = UV.size(1) - 1;
      for (i = 0; i <= loop_ub; i++) {
        alpha = UV[i].re;
        win = UV[i].im;
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
        UV[i].re = fe;
        UV[i].im = alpha;
      }
      b_f.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        b_f[i] = (f[i] > 0.5);
      }
      coder::internal::c_nullAssignment(UV, b_f);
      b_UVwindow.set_size(Vwindow.size(1), Vwindow.size(0));
      loop_ub = Vwindow.size(0);
      for (i = 0; i < loop_ub; i++) {
        vlen = Vwindow.size(1);
        for (i1 = 0; i1 < vlen; i1++) {
          b_UVwindow[i1 + b_UVwindow.size(0) * i] =
              Vwindow[i + Vwindow.size(0) * i1];
        }
      }
      coder::mean(b_UVwindow, UW);
      UW.set_size(1, UW.size(1));
      loop_ub = UW.size(1) - 1;
      for (i = 0; i <= loop_ub; i++) {
        alpha = UW[i].re;
        win = UW[i].im;
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
        UW[i].re = fe;
        UW[i].im = alpha;
      }
      b_f.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        b_f[i] = (f[i] > 0.5);
      }
      coder::internal::c_nullAssignment(UW, b_f);
      b_UVwindow.set_size(Wwindow.size(1), Wwindow.size(0));
      loop_ub = Wwindow.size(0);
      for (i = 0; i < loop_ub; i++) {
        vlen = Wwindow.size(1);
        for (i1 = 0; i1 < vlen; i1++) {
          b_UVwindow[i1 + b_UVwindow.size(0) * i] =
              Wwindow[i + Wwindow.size(0) * i1];
        }
      }
      coder::mean(b_UVwindow, VW);
      VW.set_size(1, VW.size(1));
      loop_ub = VW.size(1) - 1;
      for (i = 0; i <= loop_ub; i++) {
        alpha = VW[i].re;
        win = VW[i].im;
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
        VW[i].re = fe;
        VW[i].im = alpha;
      }
      b_f.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        b_f[i] = (f[i] > 0.5);
      }
      coder::internal::c_nullAssignment(VW, b_f);
      b_f.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        b_f[i] = (f[i] > 0.5);
      }
      coder::internal::b_nullAssignment(f, b_f);
      //  wave spectral moments
      //  see definitions from Kuik et al, JPO, 1988 and Herbers et al, JTech,
      //  2012, Thomson et al, J Tech 2018
      // Qxz = imag(UW); % quadspectrum of vertical and east horizontal motion
      // Cxz = real(UW); % cospectrum of vertical and east horizontal motion
      // Qyz = imag(VW); % quadspectrum of vertical and north horizontal motion
      // Cyz = real(VW); % cospectrum of vertical and north horizontal motion
      // Cxy = real(UV) ./ ( (2*pi*f).^2 );  % cospectrum of east and north
      // motion
      if (a2.size(1) == VV.size(1)) {
        b_y.set_size(1, a2.size(1));
        loop_ub = a2.size(1);
        for (i = 0; i < loop_ub; i++) {
          b_y[i] = a2[i] + VV[i];
        }
      } else {
        plus(b_y, a2, VV);
      }
      if (b_y.size(1) == check.size(1)) {
        b1.set_size(1, b_y.size(1));
        loop_ub = b_y.size(1);
        for (i = 0; i < loop_ub; i++) {
          b1[i] = b_y[i] * check[i];
        }
      } else {
        times(b1, b_y, check);
      }
      nx = b1.size(1);
      for (k = 0; k < nx; k++) {
        b1[k] = std::sqrt(b1[k]);
      }
      if (UW.size(1) == b1.size(1)) {
        a1.set_size(1, UW.size(1));
        loop_ub = UW.size(1);
        for (i = 0; i < loop_ub; i++) {
          a1[i] = UW[i].im / b1[i];
        }
      } else {
        b_binary_expand_op(a1, UW, b1);
      }
      if (VW.size(1) == b1.size(1)) {
        loop_ub = VW.size(1) - 1;
        b1.set_size(1, VW.size(1));
        for (i = 0; i <= loop_ub; i++) {
          b1[i] = VW[i].im / b1[i];
        }
      } else {
        binary_expand_op(b1, VW);
      }
      if (a2.size(1) == 1) {
        i = VV.size(1);
      } else {
        i = a2.size(1);
      }
      if ((a2.size(1) == VV.size(1)) && (i == b_y.size(1))) {
        loop_ub = a2.size(1) - 1;
        a2.set_size(1, a2.size(1));
        for (i = 0; i <= loop_ub; i++) {
          a2[i] = (a2[i] - VV[i]) / b_y[i];
        }
      } else {
        binary_expand_op(a2, VV, b_y);
      }
      if (UV.size(1) == b_y.size(1)) {
        b2.set_size(1, UV.size(1));
        loop_ub = UV.size(1);
        for (i = 0; i < loop_ub; i++) {
          b2[i] = 2.0 * UV[i].re / b_y[i];
        }
      } else {
        binary_expand_op(b2, UV, b_y);
      }
      //  Scalar energy spectra (a0)
      E.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        alpha = 6.2831853071795862 * f[i];
        E[i] = alpha * alpha;
      }
      if (b_y.size(1) == E.size(1)) {
        loop_ub = b_y.size(1) - 1;
        E.set_size(1, b_y.size(1));
        for (i = 0; i <= loop_ub; i++) {
          E[i] = b_y[i] / E[i];
        }
      } else {
        b_rdivide(E, b_y);
      }
      //  assumes perfectly circular deepwater orbits
      //  E = ( WW ) ./ ( (2*pi*f).^2 ); % arbitrary depth, but more noise?
      //  use orbit shape as check on quality (=1 in deep water)
      if (check.size(1) == b_y.size(1)) {
        loop_ub = check.size(1) - 1;
        check.set_size(1, check.size(1));
        for (i = 0; i <= loop_ub; i++) {
          check[i] = check[i] / b_y[i];
        }
      } else {
        rdivide(check, b_y);
      }
      //  wave stats
      b_f.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        b_f[i] = (f[i] > 0.05);
      }
      r9.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        r9[i] = (f[i] < 0.5);
      }
      //  frequency cutoff for wave stats, 0.4 is specific to SWIFT hull
      end = b_f.size(1);
      for (windows = 0; windows < end; windows++) {
        if ((!b_f[windows]) || (!r9[windows])) {
          E[windows] = 0.0;
        }
      }
      //  significant wave height
      end = b_f.size(1) - 1;
      nx = 0;
      for (windows = 0; windows <= end; windows++) {
        if (b_f[windows] && r9[windows]) {
          nx++;
        }
      }
      r10.set_size(1, nx);
      vlen = 0;
      for (windows = 0; windows <= end; windows++) {
        if (b_f[windows] && r9[windows]) {
          r10[vlen] = windows + 1;
          vlen++;
        }
      }
      VV.set_size(1, r10.size(1));
      loop_ub = r10.size(1);
      for (i = 0; i < loop_ub; i++) {
        VV[i] = E[r10[i] - 1];
      }
      *Hs = 4.0 * std::sqrt(coder::sum(VV) * bandwidth);
      //   energy period
      end = b_f.size(1) - 1;
      nx = 0;
      for (windows = 0; windows <= end; windows++) {
        if (b_f[windows] && r9[windows]) {
          nx++;
        }
      }
      r11.set_size(1, nx);
      vlen = 0;
      for (windows = 0; windows <= end; windows++) {
        if (b_f[windows] && r9[windows]) {
          r11[vlen] = windows + 1;
          vlen++;
        }
      }
      b_y.set_size(1, r11.size(1));
      loop_ub = r11.size(1);
      for (i = 0; i < loop_ub; i++) {
        i1 = r11[i];
        b_y[i] = f[i1 - 1] * E[i1 - 1];
      }
      VV.set_size(1, r11.size(1));
      loop_ub = r11.size(1);
      for (i = 0; i < loop_ub; i++) {
        VV[i] = E[r11[i] - 1];
      }
      fe = coder::sum(b_y) / coder::sum(VV);
      VV.set_size(1, f.size(1));
      loop_ub = f.size(1);
      for (i = 0; i < loop_ub; i++) {
        VV[i] = f[i] - fe;
      }
      nx = VV.size(1);
      b_y.set_size(1, VV.size(1));
      for (k = 0; k < nx; k++) {
        b_y[k] = std::abs(VV[k]);
      }
      coder::internal::minimum(b_y, &alpha, &nx);
      //  peak period
      // [~ , fpindex] = max(UU+VV); % can use velocity (picks out more distint
      // peak)
      coder::internal::maximum(E, &alpha, &vlen);
      *Tp = 1.0 / f[vlen - 1];
      if (*Tp > 18.0) {
        //  if peak not found, use centroid
        *Tp = 1.0 / fe;
        vlen = nx;
      }
      //  wave directions
      //  begin with cartesian, 0 deg is for waves headed towards positive x
      //  (EAST, right hand system)
      // dir1 = atan2(b1,a1) ;  % [rad], 4 quadrant
      // dir2 = atan2(b2,a2)/2 ; % [rad], only 2 quadrant
      // spread1 = sqrt( 2 * ( 1 - sqrt(a1.^2 + b2.^2) ) );
      // spread2 = sqrt( abs( 0.5 - 0.5 .* ( a2.*cos(2.*dir2) + b2.*cos(2.*dir2)
      // )  ));
      //  peak wave direction, rotated to geographic conventions
      //  [rad], 4 quadrant
      //  switch from rad to deg, and CCW to CW (negate)
      *Dp = -57.324840764331206 * rt_atan2d_snf(b1[vlen - 1], a1[vlen - 1]) +
            90.0;
      //  rotate from eastward = 0 to northward  = 0
      if (*Dp < 0.0) {
        *Dp += 360.0;
      }
      //  take NW quadrant from negative to 270-360 range
      if (*Dp > 180.0) {
        *Dp -= 180.0;
      }
      //  take reciprocal such wave direction is FROM, not TOWARDS
      if (*Dp < 180.0) {
        *Dp += 180.0;
      }
      //  take reciprocal such wave direction is FROM, not TOWARDS
    } else {
      guard1 = true;
    }
  } else {
    guard1 = true;
  }
  if (guard1) {
    //  if not enough points or insufficent sampling rate give 9999
    *Hs = 9999.0;
    *Tp = 9999.0;
    *Dp = 9999.0;
    E.set_size(1, 1);
    E[0] = 9999.0;
    f.set_size(1, 1);
    f[0] = 9999.0;
    a1.set_size(1, 1);
    a1[0] = 9999.0;
    b1.set_size(1, 1);
    b1[0] = 9999.0;
    a2.set_size(1, 1);
    a2[0] = 9999.0;
    b2.set_size(1, 1);
    b2[0] = 9999.0;
    check.set_size(1, 1);
    check[0] = 9999.0;
  }
  //  quality control for excessive low frequency problems
  if (*Tp > 20.0) {
    *Hs = 9999.0;
    *Tp = 9999.0;
    *Dp = 9999.0;
  }
  //  testing bits
  //  if testing
  //
  //      figure(1), clf
  //      subplot(2,1,1)
  //      loglog(f,( UU + VV) ./ ( (2*pi*f).^2 ), f, ( WW ) ./ ( (2*pi*f).^2 ) )
  //      set(gca,'YLim',[1e-3 2e2])
  //      legend('E=(UU+VV)/f^2','E=WW/f^2')
  //      ylabel('Energy [m^2/Hz]')
  //      title(['Hs = ' num2str(Hs,2) ', Tp = ' num2str(Tp,2) ', Dp = '
  //      num2str(Dp,3)]) subplot(2,1,2) semilogx(f,a1, f,b1, f,a2,  f,b2)
  //      set(gca,'YLim',[-1 1])
  //      legend('a1','b1','a2','b2')
  //      xlabel('frequency [Hz]')
  //      drawnow
  //
  //  end
}

// End of code generation (NEDwaves.cpp)
