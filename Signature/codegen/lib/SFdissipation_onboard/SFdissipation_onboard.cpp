//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// SFdissipation_onboard.cpp
//
// Code generation for function 'SFdissipation_onboard'
//

// Include files
#include "SFdissipation_onboard.h"
#include "SFdissipation_onboard_types.h"
#include "blockedSummation.h"
#include "combineVectorElements.h"
#include "diff.h"
#include "mean.h"
#include "meshgrid.h"
#include "mldivide.h"
#include "mpower.h"
#include "mtimes.h"
#include "permute.h"
#include "rt_nonfinite.h"
#include "sort.h"
#include "std.h"
#include "strcmp.h"
#include "var.h"
#include "coder_array.h"
#include <cmath>

// Function Declarations
static void b_binary_expand_op(coder::array<double, 1U> &in1,
                               const coder::array<double, 1U> &in2,
                               const short in3_data[], const int &in3_size,
                               const struct0_T *in4, int in5,
                               const coder::array<double, 1U> &in6);

static int binary_expand_op(bool in1_data[],
                            const coder::array<double, 1U> &in2,
                            const coder::array<double, 1U> &in3);

static int c_binary_expand_op(bool in1_data[], const bool in2_data[],
                              const int &in2_size,
                              const coder::array<double, 1U> &in3,
                              const short in4_data[], const int &in4_size);

static void minus(coder::array<double, 3U> &in1,
                  const coder::array<double, 3U> &in2);

static double rt_powd_snf(double u0, double u1);

// Function Definitions
static void b_binary_expand_op(coder::array<double, 1U> &in1,
                               const coder::array<double, 1U> &in2,
                               const short in3_data[], const int &in3_size,
                               const struct0_T *in4, int in5,
                               const coder::array<double, 1U> &in6)
{
  int loop_ub;
  int stride_0_0;
  int stride_1_0;
  if (in6.size(0) == 1) {
    loop_ub = in3_size;
  } else {
    loop_ub = in6.size(0);
  }
  in1.set_size(loop_ub);
  stride_0_0 = (in3_size != 1);
  stride_1_0 = (in6.size(0) != 1);
  for (int i{0}; i < loop_ub; i++) {
    in1[i] = in2[static_cast<int>(in3_data[i * stride_0_0])] -
             in4->B[in5] * in6[i * stride_1_0];
  }
}

static int binary_expand_op(bool in1_data[],
                            const coder::array<double, 1U> &in2,
                            const coder::array<double, 1U> &in3)
{
  int in1_size;
  int stride_0_0;
  int stride_1_0;
  if (in3.size(0) == 1) {
    in1_size = in2.size(0);
  } else {
    in1_size = in3.size(0);
  }
  stride_0_0 = (in2.size(0) != 1);
  stride_1_0 = (in3.size(0) != 1);
  for (int i{0}; i < in1_size; i++) {
    in1_data[i] = ((in2[i * stride_0_0] > 0.0) && (in3[i * stride_1_0] > 0.0));
  }
  return in1_size;
}

static int c_binary_expand_op(bool in1_data[], const bool in2_data[],
                              const int &in2_size,
                              const coder::array<double, 1U> &in3,
                              const short in4_data[], const int &in4_size)
{
  int in1_size;
  int stride_0_0;
  int stride_1_0;
  if (in4_size == 1) {
    in1_size = in2_size;
  } else {
    in1_size = in4_size;
  }
  stride_0_0 = (in2_size != 1);
  stride_1_0 = (in4_size != 1);
  for (int i{0}; i < in1_size; i++) {
    in1_data[i] = (in2_data[i * stride_0_0] &&
                   (in3[static_cast<int>(in4_data[i * stride_1_0])] > 0.0));
  }
  return in1_size;
}

static void minus(coder::array<double, 3U> &in1,
                  const coder::array<double, 3U> &in2)
{
  coder::array<double, 3U> b_in1;
  int aux_0_2;
  int aux_1_2;
  int loop_ub;
  int stride_0_2;
  int stride_1_2;
  if (in2.size(2) == 1) {
    loop_ub = in1.size(2);
  } else {
    loop_ub = in2.size(2);
  }
  b_in1.set_size(128, 128, loop_ub);
  stride_0_2 = (in1.size(2) != 1);
  stride_1_2 = (in2.size(2) != 1);
  aux_0_2 = 0;
  aux_1_2 = 0;
  for (int i{0}; i < loop_ub; i++) {
    for (int i1{0}; i1 < 128; i1++) {
      for (int i2{0}; i2 < 128; i2++) {
        b_in1[(i2 + 128 * i1) + 16384 * i] =
            in1[(i2 + 128 * i1) + 16384 * aux_0_2] -
            in2[(i2 + 128 * i1) + 16384 * aux_1_2];
      }
    }
    aux_1_2 += stride_1_2;
    aux_0_2 += stride_0_2;
  }
  in1.set_size(128, 128, b_in1.size(2));
  loop_ub = b_in1.size(2);
  for (int i{0}; i < loop_ub; i++) {
    for (int i1{0}; i1 < 128; i1++) {
      for (int i2{0}; i2 < 128; i2++) {
        in1[(i2 + 128 * i1) + 16384 * i] = b_in1[(i2 + 128 * i1) + 16384 * i];
      }
    }
  }
}

static double rt_powd_snf(double u0, double u1)
{
  double y;
  if (std::isnan(u0) || std::isnan(u1)) {
    y = rtNaN;
  } else {
    double d;
    double d1;
    d = std::abs(u0);
    d1 = std::abs(u1);
    if (std::isinf(u1)) {
      if (d == 1.0) {
        y = 1.0;
      } else if (d > 1.0) {
        if (u1 > 0.0) {
          y = rtInf;
        } else {
          y = 0.0;
        }
      } else if (u1 > 0.0) {
        y = 0.0;
      } else {
        y = rtInf;
      }
    } else if (d1 == 0.0) {
      y = 1.0;
    } else if (d1 == 1.0) {
      if (u1 > 0.0) {
        y = u0;
      } else {
        y = 1.0 / u0;
      }
    } else if (u1 == 2.0) {
      y = u0 * u0;
    } else if ((u1 == 0.5) && (u0 >= 0.0)) {
      y = std::sqrt(u0);
    } else if ((u0 < 0.0) && (u1 > std::floor(u1))) {
      y = rtNaN;
    } else {
      y = std::pow(u0, u1);
    }
  }
  return y;
}

void SFdissipation_onboard(const coder::array<double, 2U> &w,
                           const double z[128], double rmin, double rmax,
                           double nzfit, const coder::array<char, 2U> &fittype,
                           const coder::array<char, 2U> &avgtype,
                           double eps[128], struct0_T *qual)
{
  static double D[16384];
  static double Derr[16384];
  static double R[16384];
  static double Z0[16384];
  static int iv[16384];
  static short b_tmp_data[16384];
  static const char cv1[6]{'l', 'i', 'n', 'e', 'a', 'r'};
  static const char cv[5]{'c', 'u', 'b', 'i', 'c'};
  coder::array<double, 3U> b_dW;
  coder::array<double, 3U> b_y;
  coder::array<double, 3U> dW;
  coder::array<double, 2U> A;
  coder::array<double, 2U> G;
  coder::array<double, 2U> b_A;
  coder::array<double, 2U> b_G;
  coder::array<double, 2U> b_w;
  coder::array<double, 2U> c_G;
  coder::array<double, 2U> d_G;
  coder::array<double, 1U> Di;
  coder::array<double, 1U> b_Derr;
  coder::array<double, 1U> dm;
  coder::array<double, 1U> dmod;
  coder::array<double, 1U> x1;
  coder::array<double, 1U> x3;
  coder::array<int, 1U> iidx;
  coder::array<bool, 3U> r1;
  coder::array<bool, 1U> r;
  int i;
  int ncols;
  short c_tmp_data[16384];
  short e_tmp_data[16384];
  short f_tmp_data[16384];
  short h_tmp_data[16384];
  unsigned char tmp_data[128];
  bool d_tmp_data[16384];
  bool g_tmp_data[16384];
  bool exitg1;
  bool y;
  //  This function applies Taylor cascade theory to estimate dissipation from
  //  the second order velocity structure function computed from vertical
  //  profiles of turbulent velocity (see Wiles et al. 2006). SFdissipation was
  //  formulated with data from the Nortek Signature 1000 ADCP operating in
  //  pulse-coherent (HR) mode, but can be applied to any ensemble of velocity
  //  profiles.
  //
  //    in:     w (or dW)  nbin x nping ensemble of velocity profiles. Ensemble
  //    averaging
  //                            occurs across the 'ping' dimension. Can
  //                            alternatively input the velocity difference
  //                            matrix (dW).
  //            z           1 x nbin
  //            rmin        minimum separation distance allowed in the fit
  //            rmax        maximum separation distance, assumed to be within
  //            the
  //                            inerital subrange
  //            nzfit       number of vertical bins to include in fit at each
  //                        depth, e.g. for nzfit = 1 , fit all pairs with
  //                        mean pair depth <= z0 +\- dz/2, i.e. vertical
  //                        smoothing
  //            fittype     either 'linear' or 'cubic', determines whether the
  //                            structure function is fit to a theoretical curve
  //                            which is linear or cubic in R^(2/3). The latter
  //                            should be used if there is likely significant
  //                            profile-scale shear in the profiles, such as
  //                            surface waves (Scannell et al. 2017) 12/2022:
  //                            Added 'log', which does the linear fit in log
  //                            space instead. Assumes noise term is very low.
  //            avgtype     either 'mean' or 'logmean', determines whether the
  //                            mean-of-squares or mean-of-the-log-of-squares
  //                            is taken to determine the expected value of the
  //                            squared velocity difference
  //
  //    out:    eps         1 x nbin profile of dissipation
  //            qual        structure with metrics for evaluating quality of eps
  //            including:
  //                        - mean square percent error of the fit (mspe),
  //                        - propagated error of the fit (epserr),
  //                        - ADCP error inferred from the SF intercept (N),
  //                        - slope of the SF (slope),
  //                        - wave term coefficient (B, if modified r^2 fit
  //                        used).
  //            K.Zeiden Summer/Fall 2022
  //  ONBOARD NOTES:
  //  Using 'mean' instead of 'median' to get dz, as a result,
  //  must expand fit window by 10%, i.e. z = +/- 1.1*nfilt*dz/2.
  //  Eliminate 'median' as an averaging option.
  //  Remove "warning"
  //  Return control to calling function/script if all NaN data
  ncols = w.size(1) << 7;
  r.set_size(ncols);
  for (i = 0; i < ncols; i++) {
    r[i] = !std::isnan(w[i]);
  }
  y = false;
  ncols = 1;
  exitg1 = false;
  while ((!exitg1) && (ncols <= r.size(0))) {
    if (r[ncols - 1]) {
      y = true;
      exitg1 = true;
    } else {
      ncols++;
    }
  }
  if (!y) {
    for (i = 0; i < 128; i++) {
      eps[i] = rtNaN;
      qual->mspe[i] = rtNaN;
      qual->slope[i] = rtNaN;
      qual->epserr[i] = rtNaN;
      qual->A[i] = rtNaN;
      qual->B[i] = rtNaN;
      qual->N[i] = rtNaN;
    }
  } else {
    double Aerr[128];
    double dv[127];
    double d;
    double dz;
    double m_idx_1;
    int iacol_tmp;
    int ibmat;
    int ibtile;
    int jcol;
    int jtilecol;
    //  Matrices of all possible data pair separation distances (R), and
    //  corresponding mean vertical position (Z0)
    coder::diff(z, dv);
    dz = coder::mean(dv);
    // R = round(R,2);
    for (i = 0; i < 128; i++) {
      for (ncols = 0; ncols < 128; ncols++) {
        R[ncols + (i << 7)] = (z[i] - z[ncols]) * 100.0;
      }
    }
    coder::meshgrid(z, Z0, Derr);
    for (int k{0}; k < 16384; k++) {
      R[k] = std::round(R[k]) / 100.0;
      Z0[k] = (Z0[k] + Derr[k]) / 2.0;
    }
    //  Matrices of all possible data pair velocity differences for each ping.
    //    Points greater than +/- 5 standard deviation are removed from each
    //    dist.
    coder::mean(w, qual->A);
    b_w.set_size(128, w.size(1));
    ibmat = w.size(1);
    for (i = 0; i < ibmat; i++) {
      for (ncols = 0; ncols < 128; ncols++) {
        b_w[ncols + 128 * i] = w[ncols + 128 * i] - qual->A[ncols];
      }
    }
    dW.set_size(128, b_w.size(1), 128);
    ncols = b_w.size(1);
    for (jtilecol = 0; jtilecol < 128; jtilecol++) {
      ibtile = jtilecol * (ncols << 7) - 1;
      for (jcol = 0; jcol < ncols; jcol++) {
        iacol_tmp = jcol << 7;
        ibmat = ibtile + iacol_tmp;
        for (int k{0}; k < 128; k++) {
          dW[(ibmat + k) + 1] = b_w[iacol_tmp + k];
        }
      }
    }
    coder::permute(dW, b_dW);
    coder::b_permute(dW, b_y);
    if (b_dW.size(2) == b_y.size(2)) {
      ibmat = b_dW.size(2) << 14;
      b_dW.set_size(128, 128, b_dW.size(2));
      for (i = 0; i < ibmat; i++) {
        b_dW[i] = b_dW[i] - b_y[i];
      }
    } else {
      minus(b_dW, b_y);
    }
    coder::b_std(b_dW, Derr);
    for (i = 0; i < 16384; i++) {
      Derr[i] *= 5.0;
    }
    ibtile = b_dW.size(2) << 14;
    b_y.set_size(128, 128, b_dW.size(2));
    for (int k{0}; k < ibtile; k++) {
      b_y[k] = std::abs(b_dW[k]);
    }
    r1.set_size(128, 128, b_y.size(2));
    ibmat = b_y.size(2);
    for (i = 0; i < ibmat; i++) {
      for (ncols = 0; ncols < 128; ncols++) {
        for (iacol_tmp = 0; iacol_tmp < 128; iacol_tmp++) {
          r1[(iacol_tmp + 128 * ncols) + 16384 * i] =
              (b_y[(iacol_tmp + 128 * ncols) + 16384 * i] >
               Derr[iacol_tmp + (ncols << 7)]);
        }
      }
    }
    iacol_tmp = ibtile - 1;
    for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
      if (r1[ibmat]) {
        b_dW[ibmat] = rtNaN;
      }
    }
    //  Take mean (or median, or mean-of-the-logs) squared velocity difference
    //  to get D(z,r)
    if (coder::internal::b_strcmp(avgtype)) {
      b_y.set_size(128, 128, b_dW.size(2));
      for (i = 0; i < ibtile; i++) {
        m_idx_1 = b_dW[i];
        b_y[i] = m_idx_1 * m_idx_1;
      }
      coder::mean(b_y, D);
    } else if (coder::internal::d_strcmp(avgtype)) {
      b_y.set_size(128, 128, b_dW.size(2));
      for (i = 0; i < ibtile; i++) {
        m_idx_1 = b_dW[i];
        b_y[i] = m_idx_1 * m_idx_1;
      }
      for (int k{0}; k < ibtile; k++) {
        b_y[k] = std::log10(b_y[k]);
      }
      coder::mean(b_y, Derr);
      for (int k{0}; k < 16384; k++) {
        D[k] = rt_powd_snf(10.0, Derr[k]);
      }
    }
    // Standard Error on the mean
    b_y.set_size(128, 128, b_dW.size(2));
    for (i = 0; i < ibtile; i++) {
      m_idx_1 = b_dW[i];
      b_y[i] = m_idx_1 * m_idx_1;
    }
    coder::var(b_y, Derr);
    r1.set_size(128, 128, b_dW.size(2));
    for (i = 0; i < ibtile; i++) {
      r1[i] = !std::isnan(b_dW[i]);
    }
    coder::combineVectorElements(r1, iv);
    for (int k{0}; k < 16384; k++) {
      Derr[k] = std::sqrt(Derr[k] / static_cast<double>(iv[k]));
    }
    // Fit structure function to theoretical curve
    for (i = 0; i < 128; i++) {
      eps[i] = rtNaN;
      qual->epserr[i] = rtNaN;
      qual->A[i] = rtNaN;
      qual->B[i] = rtNaN;
      Aerr[i] = rtNaN;
      qual->N[i] = rtNaN;
      qual->mspe[i] = rtNaN;
      qual->slope[i] = rtNaN;
    }
    d = 1.1 * nzfit * dz / 2.0;
    for (int ibin{0}; ibin < 128; ibin++) {
      int c_y;
      bool ifit_data[16384];
      // Find points in z0 bin
      jtilecol = 0;
      ncols = 0;
      dz = z[ibin];
      for (ibmat = 0; ibmat < 16384; ibmat++) {
        m_idx_1 = Z0[ibmat];
        if ((m_idx_1 >= dz - d) && (m_idx_1 <= dz + d)) {
          jtilecol++;
          b_tmp_data[ncols] = static_cast<short>(ibmat);
          ncols++;
        }
      }
      x3.set_size(jtilecol);
      for (i = 0; i < jtilecol; i++) {
        x3[i] = R[b_tmp_data[i]];
      }
      coder::internal::sort(x3, iidx);
      dm.set_size(iidx.size(0));
      ibmat = iidx.size(0);
      for (i = 0; i < ibmat; i++) {
        dm[i] = iidx[i];
      }
      Di.set_size(dm.size(0));
      ibmat = dm.size(0);
      for (i = 0; i < ibmat; i++) {
        Di[i] = D[b_tmp_data[static_cast<int>(dm[i]) - 1]];
      }
      // Select points within specified separation scale range
      jcol = x3.size(0);
      ibmat = x3.size(0);
      for (i = 0; i < ibmat; i++) {
        ifit_data[i] = ((x3[i] <= rmax) && (x3[i] >= rmin));
      }
      if (jcol == 0) {
        c_y = 0;
        ncols = 0;
      } else {
        c_y = ifit_data[0];
        for (int k{2}; k <= jcol; k++) {
          c_y += ifit_data[k - 1];
        }
        ncols = ifit_data[0];
        for (int k{2}; k <= jcol; k++) {
          ncols += ifit_data[k - 1];
        }
      }
      if (ncols >= 3) {
        double y_tmp[4];
        double m[2];
        double derr;
        int exitg2;
        iacol_tmp = jcol - 1;
        jtilecol = 0;
        ncols = 0;
        for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
          if (ifit_data[ibmat]) {
            jtilecol++;
            c_tmp_data[ncols] = static_cast<short>(ibmat);
            ncols++;
          }
        }
        x1.set_size(jtilecol);
        for (i = 0; i < jtilecol; i++) {
          m_idx_1 = x3[static_cast<int>(c_tmp_data[i])];
          x1[i] = rt_powd_snf(m_idx_1, 0.66666666666666663);
        }
        x3.set_size(x1.size(0));
        ibmat = x1.size(0);
        b_Derr.set_size(jtilecol);
        // Best-fit power-law to the structure function
        jcol = x1.size(0);
        for (i = 0; i < ibmat; i++) {
          m_idx_1 = x1[i];
          x3[i] = rt_powd_snf(m_idx_1, 3.0);
          b_Derr[i] = Derr[b_tmp_data[static_cast<short>(
                                          dm[static_cast<int>(c_tmp_data[i])]) -
                                      1]];
          ifit_data[i] = (x1[i] > 0.0);
        }
        derr = coder::mean(b_Derr);
        //  log(0) = -Inf
        if (jcol == jtilecol) {
          ncols = jcol;
          for (i = 0; i < jcol; i++) {
            d_tmp_data[i] =
                (ifit_data[i] && (Di[static_cast<int>(c_tmp_data[i])] > 0.0));
          }
        } else {
          ncols = c_binary_expand_op(d_tmp_data, ifit_data, jcol, Di,
                                     c_tmp_data, jtilecol);
        }
        iacol_tmp = ncols - 1;
        ibtile = 0;
        ncols = 0;
        for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
          if (d_tmp_data[ibmat]) {
            ibtile++;
            e_tmp_data[ncols] = static_cast<short>(ibmat);
            ncols++;
          }
        }
        //      xlog = log10(x(ilog));
        dm.set_size(ibtile);
        for (int k{0}; k < ibtile; k++) {
          dm[k] = std::log10(x1[static_cast<int>(e_tmp_data[k])]);
        }
        G.set_size(dm.size(0), 2);
        ibmat = dm.size(0);
        for (i = 0; i < ibmat; i++) {
          G[i] = dm[i];
          G[i + G.size(0)] = 1.0;
        }
        dm.set_size(ibtile);
        b_G.set_size(2, G.size(0));
        for (int k{0}; k < ibtile; k++) {
          dm[k] = std::log10(Di[static_cast<int>(c_tmp_data[e_tmp_data[k]])]);
          b_G[2 * k] = G[k];
          b_G[2 * k + 1] = G[k + G.size(0)];
        }
        coder::internal::blas::mtimes(G, G, y_tmp);
        coder::mldivide(y_tmp, b_G, A);
        i = A.size(1);
        m[0] = 0.0;
        for (int k{0}; k < i; k++) {
          m[0] += A[k << 1] * dm[k];
        }
        qual->slope[ibin] = m[0];
        // Fit Structure function to theoretical curves
        y = false;
        if (fittype.size(1) == 5) {
          ncols = 0;
          do {
            exitg2 = 0;
            if (ncols < 5) {
              if (fittype[ncols] != cv[ncols]) {
                exitg2 = 1;
              } else {
                ncols++;
              }
            } else {
              y = true;
              exitg2 = 1;
            }
          } while (exitg2 == 0);
        }
        if (y) {
          //  Fit structure function to D(z,r) = Br^2 + Ar^(2/3) + N
          c_G.set_size(x3.size(0), 3);
          ibmat = x3.size(0);
          for (i = 0; i < ibmat; i++) {
            c_G[i] = x3[i];
            c_G[i + c_G.size(0)] = x1[i];
          }
          for (i = 0; i < c_y; i++) {
            c_G[i + c_G.size(0) * 2] = 1.0;
          }
          d_G.set_size(3, c_G.size(0));
          ibmat = c_G.size(0);
          for (i = 0; i < ibmat; i++) {
            d_G[3 * i] = c_G[i];
            d_G[3 * i + 1] = c_G[i + c_G.size(0)];
            d_G[3 * i + 2] = c_G[i + c_G.size(0) * 2];
          }
          double dv1[9];
          coder::internal::blas::b_mtimes(c_G, c_G, dv1);
          coder::b_mldivide(dv1, d_G, b_A);
          i = b_A.size(1);
          dz = 0.0;
          m_idx_1 = 0.0;
          for (int k{0}; k < i; k++) {
            double m_idx_0_tmp;
            ncols = k * 3;
            m_idx_0_tmp = Di[static_cast<int>(c_tmp_data[k])];
            dz += b_A[ncols] * m_idx_0_tmp;
            m_idx_1 += b_A[ncols + 1] * m_idx_0_tmp;
          }
          qual->B[ibin] = dz;
          qual->A[ibin] = m_idx_1;
          // Remove model shear term & fit Ar^(2/3) to residual (to get mspe)
          if (jtilecol == x3.size(0)) {
            dmod.set_size(jtilecol);
            for (i = 0; i < jtilecol; i++) {
              dmod[i] = Di[static_cast<int>(c_tmp_data[i])] - dz * x3[i];
            }
          } else {
            b_binary_expand_op(dmod, Di, c_tmp_data, jtilecol, qual, ibin, x3);
          }
          G.set_size(x1.size(0), 2);
          ibmat = x1.size(0);
          for (i = 0; i < ibmat; i++) {
            G[i] = x1[i];
          }
          for (i = 0; i < c_y; i++) {
            G[i + G.size(0)] = 1.0;
          }
          coder::internal::blas::mtimes(G, G, y_tmp);
          b_G.set_size(2, G.size(0));
          ibmat = G.size(0);
          for (i = 0; i < ibmat; i++) {
            b_G[2 * i] = G[i];
            b_G[2 * i + 1] = G[i + G.size(0)];
          }
          coder::mldivide(y_tmp, b_G, A);
          i = A.size(1);
          m[0] = 0.0;
          m[1] = 0.0;
          for (int k{0}; k < i; k++) {
            ncols = k << 1;
            m[0] += A[ncols] * dmod[k];
            m[1] += A[ncols + 1] * dmod[k];
          }
          coder::internal::blas::mtimes(G, m, dm);
          i = dm.size(0);
          x3.set_size(dm.size(0));
          for (int k{0}; k < i; k++) {
            x3[k] = std::abs(dm[k]);
          }
          iacol_tmp = x3.size(0) - 1;
          jtilecol = 0;
          for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
            if (x3[ibmat] > 1.0E-8) {
              jtilecol++;
            }
          }
          x3.set_size(jtilecol);
          ncols = 0;
          for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
            if (x3[ibmat] > 1.0E-8) {
              m_idx_1 = (dm[ibmat] - dmod[ibmat]) / dm[ibmat];
              x3[ncols] = rt_powd_snf(m_idx_1, 2.0);
              ncols++;
            }
          }
          double dv2[4];
          qual->mspe[ibin] = coder::blockedSummation(x3, x3.size(0)) /
                             static_cast<double>(x3.size(0));
          //          A(ibin) = m(1);
          qual->N[ibin] = m[1];
          coder::mpower(y_tmp, dv2);
          Aerr[ibin] = std::sqrt(derr * derr * dv2[0]);
          //  update w/slope of residual structure function
          //  log(0) = -Inf
          if (x1.size(0) == dmod.size(0)) {
            ncols = x1.size(0);
            ibmat = x1.size(0);
            for (i = 0; i < ibmat; i++) {
              g_tmp_data[i] = ((x1[i] > 0.0) && (dmod[i] > 0.0));
            }
          } else {
            ncols = binary_expand_op(g_tmp_data, x1, dmod);
          }
          iacol_tmp = ncols - 1;
          jtilecol = 0;
          ncols = 0;
          for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
            if (g_tmp_data[ibmat]) {
              jtilecol++;
              h_tmp_data[ncols] = static_cast<short>(ibmat);
              ncols++;
            }
          }
          dm.set_size(jtilecol);
          for (int k{0}; k < jtilecol; k++) {
            dm[k] = std::log10(x1[static_cast<int>(h_tmp_data[k])]);
          }
          G.set_size(dm.size(0), 2);
          ibmat = dm.size(0);
          for (i = 0; i < ibmat; i++) {
            G[i] = dm[i];
            G[i + G.size(0)] = 1.0;
          }
          dm.set_size(jtilecol);
          b_G.set_size(2, G.size(0));
          for (int k{0}; k < jtilecol; k++) {
            dm[k] = std::log10(dmod[static_cast<int>(h_tmp_data[k])]);
            b_G[2 * k] = G[k];
            b_G[2 * k + 1] = G[k + G.size(0)];
          }
          coder::internal::blas::mtimes(G, G, y_tmp);
          coder::mldivide(y_tmp, b_G, A);
          i = A.size(1);
          m[0] = 0.0;
          for (int k{0}; k < i; k++) {
            m[0] += A[k << 1] * dm[k];
          }
          qual->slope[ibin] = m[0];
        } else {
          y = false;
          if (fittype.size(1) == 6) {
            ncols = 0;
            do {
              exitg2 = 0;
              if (ncols < 6) {
                if (fittype[ncols] != cv1[ncols]) {
                  exitg2 = 1;
                } else {
                  ncols++;
                }
              } else {
                y = true;
                exitg2 = 1;
              }
            } while (exitg2 == 0);
          }
          if (y) {
            //  Fit structure function to D(z,r) = Ar^(2/3) + N
            G.set_size(x1.size(0), 2);
            ibmat = x1.size(0);
            for (i = 0; i < ibmat; i++) {
              G[i] = x1[i];
            }
            for (i = 0; i < c_y; i++) {
              G[i + G.size(0)] = 1.0;
            }
            b_G.set_size(2, G.size(0));
            ibmat = G.size(0);
            for (i = 0; i < ibmat; i++) {
              b_G[2 * i] = G[i];
              b_G[2 * i + 1] = G[i + G.size(0)];
            }
            coder::internal::blas::mtimes(G, G, y_tmp);
            coder::mldivide(y_tmp, b_G, A);
            i = A.size(1);
            m[0] = 0.0;
            m[1] = 0.0;
            for (int k{0}; k < i; k++) {
              ncols = k << 1;
              dz = Di[static_cast<int>(c_tmp_data[k])];
              m[0] += A[ncols] * dz;
              m[1] += A[ncols + 1] * dz;
            }
            coder::internal::blas::mtimes(G, m, dm);
            i = dm.size(0);
            x3.set_size(dm.size(0));
            for (int k{0}; k < i; k++) {
              x3[k] = std::abs(dm[k]);
            }
            iacol_tmp = x3.size(0) - 1;
            jtilecol = 0;
            for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
              if (x3[ibmat] > 1.0E-8) {
                jtilecol++;
              }
            }
            x3.set_size(jtilecol);
            ncols = 0;
            for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
              if (x3[ibmat] > 1.0E-8) {
                m_idx_1 =
                    (dm[ibmat] - Di[static_cast<int>(c_tmp_data[ibmat])]) /
                    dm[ibmat];
                x3[ncols] = rt_powd_snf(m_idx_1, 2.0);
                ncols++;
              }
            }
            double dv2[4];
            qual->mspe[ibin] = coder::blockedSummation(x3, x3.size(0)) /
                               static_cast<double>(x3.size(0));
            qual->A[ibin] = m[0];
            qual->N[ibin] = m[1];
            coder::internal::blas::mtimes(G, G, y_tmp);
            coder::mpower(y_tmp, dv2);
            Aerr[ibin] = std::sqrt(derr * derr * dv2[0]);
          } else if (coder::internal::c_strcmp(fittype)) {
            //  Don't presume a slope
            iacol_tmp = jcol - 1;
            jtilecol = 0;
            ncols = 0;
            for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
              if (ifit_data[ibmat]) {
                jtilecol++;
                f_tmp_data[ncols] = static_cast<short>(ibmat);
                ncols++;
              }
            }
            dm.set_size(jtilecol);
            for (i = 0; i < jtilecol; i++) {
              dm[i] = x1[static_cast<int>(f_tmp_data[i])];
            }
            x1.set_size(dm.size(0));
            ibmat = dm.size(0);
            for (i = 0; i < ibmat; i++) {
              x1[i] = dm[i];
            }
            i = x1.size(0);
            for (int k{0}; k < i; k++) {
              x1[k] = std::log10(x1[k]);
            }
            G.set_size(x1.size(0), 2);
            ibmat = x1.size(0);
            dm.set_size(jtilecol);
            for (int k{0}; k < ibmat; k++) {
              G[k] = x1[k];
              G[k + G.size(0)] = 1.0;
              dm[k] =
                  std::log10(Di[static_cast<int>(c_tmp_data[f_tmp_data[k]])]);
            }
            b_G.set_size(2, G.size(0));
            ibmat = G.size(0);
            for (i = 0; i < ibmat; i++) {
              b_G[2 * i] = G[i];
              b_G[2 * i + 1] = G[i + G.size(0)];
            }
            coder::internal::blas::mtimes(G, G, y_tmp);
            coder::mldivide(y_tmp, b_G, A);
            i = A.size(1);
            m[0] = 0.0;
            m[1] = 0.0;
            for (int k{0}; k < i; k++) {
              ncols = k << 1;
              m[0] += A[ncols] * dm[k];
              m[1] += A[ncols + 1] * dm[k];
            }
            coder::internal::blas::mtimes(G, m, dm);
            i = dm.size(0);
            x3.set_size(dm.size(0));
            for (int k{0}; k < i; k++) {
              x3[k] = std::abs(dm[k]);
            }
            iacol_tmp = x3.size(0) - 1;
            jtilecol = 0;
            for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
              if (x3[ibmat] > 1.0E-8) {
                jtilecol++;
              }
            }
            x3.set_size(jtilecol);
            ncols = 0;
            for (ibmat = 0; ibmat <= iacol_tmp; ibmat++) {
              if (x3[ibmat] > 1.0E-8) {
                m_idx_1 =
                    (dm[ibmat] -
                     Di[static_cast<int>(c_tmp_data[f_tmp_data[ibmat]])]) /
                    dm[ibmat];
                x3[ncols] = rt_powd_snf(m_idx_1, 2.0);
                ncols++;
              }
            }
            double dv2[4];
            qual->mspe[ibin] = coder::blockedSummation(x3, x3.size(0)) /
                               static_cast<double>(x3.size(0));
            qual->slope[ibin] = m[0];
            qual->A[ibin] = rt_powd_snf(10.0, m[1]);
            coder::internal::blas::mtimes(G, G, y_tmp);
            coder::mpower(y_tmp, dv2);
            Aerr[ibin] = std::sqrt(derr * derr * dv2[3]);
          }
        }
        dz = qual->A[ibin];
        m_idx_1 = rt_powd_snf(dz / 2.1, 1.5);
        eps[ibin] = m_idx_1;
        qual->epserr[ibin] = Aerr[ibin] * 1.5 * m_idx_1 / dz;
      } else {
        //  Must contain more than 3 points
      }
    }
    //  Remove unphysical values
    jtilecol = 0;
    ncols = 0;
    for (ibmat = 0; ibmat < 128; ibmat++) {
      if (qual->A[ibmat] < 0.0) {
        jtilecol++;
        tmp_data[ncols] = static_cast<unsigned char>(ibmat);
        ncols++;
      }
    }
    for (i = 0; i < jtilecol; i++) {
      unsigned char u;
      u = tmp_data[i];
      eps[u] = rtNaN;
      qual->epserr[u] = rtNaN;
    }
    //  Save quality metrics
    // %%%% End function
  }
}

// End of code generation (SFdissipation_onboard.cpp)
