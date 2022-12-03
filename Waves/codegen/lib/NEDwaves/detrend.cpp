//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// detrend.cpp
//
// Code generation for function 'detrend'
//

// Include files
#include "detrend.h"
#include "qrsolve.h"
#include "rt_nonfinite.h"
#include "xnrm2.h"
#include "coder_array.h"
#include <cmath>

// Function Declarations
static void minus(coder::array<float, 1U> &in1,
                  const coder::array<float, 1U> &in2);

static double rt_hypotd_snf(double u0, double u1);

// Function Definitions
static void minus(coder::array<float, 1U> &in1,
                  const coder::array<float, 1U> &in2)
{
  coder::array<float, 1U> b_in1;
  int i;
  int loop_ub;
  int stride_0_0;
  int stride_1_0;
  if (in2.size(0) == 1) {
    i = in1.size(0);
  } else {
    i = in2.size(0);
  }
  b_in1.set_size(i);
  stride_0_0 = (in1.size(0) != 1);
  stride_1_0 = (in2.size(0) != 1);
  if (in2.size(0) == 1) {
    loop_ub = in1.size(0);
  } else {
    loop_ub = in2.size(0);
  }
  for (i = 0; i < loop_ub; i++) {
    b_in1[i] = in1[i * stride_0_0] - in2[i * stride_1_0];
  }
  in1.set_size(b_in1.size(0));
  loop_ub = b_in1.size(0);
  for (i = 0; i < loop_ub; i++) {
    in1[i] = b_in1[i];
  }
}

static double rt_hypotd_snf(double u0, double u1)
{
  double a;
  double y;
  a = std::abs(u0);
  y = std::abs(u1);
  if (a < y) {
    a /= y;
    y *= std::sqrt(a * a + 1.0);
  } else if (a > y) {
    y /= a;
    y = a * std::sqrt(y * y + 1.0);
  } else if (!std::isnan(y)) {
    y = a * 1.4142135623730951;
  }
  return y;
}

namespace coder {
void detrend(::coder::array<float, 1U> &x)
{
  array<double, 1U> a;
  array<float, 2U> W;
  array<float, 1U> r;
  array<int, 2U> y;
  array<int, 1U> s;
  int n;
  int ns;
  int yk;
  if (x.size(0) - 1 < 0) {
    n = 0;
  } else {
    n = x.size(0);
  }
  y.set_size(1, n);
  if (n > 0) {
    y[0] = 0;
    yk = 0;
    for (ns = 2; ns <= n; ns++) {
      yk++;
      y[ns - 1] = yk;
    }
  }
  s.set_size(y.size(1));
  n = y.size(1);
  for (yk = 0; yk < n; yk++) {
    s[yk] = y[yk];
  }
  if (x.size(0) != 0) {
    if (x.size(0) == 1) {
      n = x.size(0);
      for (yk = 0; yk < n; yk++) {
        x[yk] = x[yk] * 0.0F;
      }
    } else {
      float p[2];
      ns = s.size(0) - 1;
      a.set_size(s.size(0));
      for (yk = 0; yk <= ns; yk++) {
        a[yk] = static_cast<double>(s[yk]) - static_cast<double>(s[0]);
      }
      n = a.size(0);
      for (yk = 0; yk < n; yk++) {
        a[yk] = a[yk] / static_cast<double>(s[s.size(0) - 1]);
      }
      n = a.size(0);
      for (yk = 0; yk < n; yk++) {
        double varargin_1;
        varargin_1 = a[yk];
        a[yk] = std::fmax(varargin_1, 0.0);
      }
      W.set_size(s.size(0), 2);
      for (yk = 0; yk <= ns; yk++) {
        W[yk] = static_cast<float>(a[yk]);
        W[yk + W.size(0)] = 1.0F;
      }
      internal::qrsolve(W, x, p, &n);
      n = W.size(0);
      r.set_size(W.size(0));
      for (yk = 0; yk < n; yk++) {
        r[yk] = W[yk] * p[0] + W[W.size(0) + yk] * p[1];
      }
      if (x.size(0) == r.size(0)) {
        n = x.size(0);
        for (yk = 0; yk < n; yk++) {
          x[yk] = x[yk] - r[yk];
        }
      } else {
        minus(x, r);
      }
    }
  }
}

void detrend(const ::coder::array<double, 1U> &x, ::coder::array<double, 1U> &y)
{
  array<double, 2U> A;
  array<double, 2U> W;
  array<double, 1U> a;
  array<double, 1U> s;
  array<int, 2U> b_y;
  double tau_data[2];
  double vn1[2];
  double vn2[2];
  double work[2];
  double temp;
  int i;
  int ii_tmp;
  int lastv;
  int m;
  int ma;
  int n;
  int yk;
  signed char jpvt[2];
  if (x.size(0) - 1 < 0) {
    n = 0;
  } else {
    n = x.size(0);
  }
  b_y.set_size(1, n);
  if (n > 0) {
    b_y[0] = 0;
    yk = 0;
    for (lastv = 2; lastv <= n; lastv++) {
      yk++;
      b_y[lastv - 1] = yk;
    }
  }
  s.set_size(b_y.size(1));
  n = b_y.size(1);
  for (i = 0; i < n; i++) {
    s[i] = b_y[i];
  }
  yk = s.size(0) - 1;
  a.set_size(s.size(0));
  for (int b_i{0}; b_i <= yk; b_i++) {
    a[b_i] = s[b_i] - s[0];
  }
  n = a.size(0);
  for (i = 0; i < n; i++) {
    a[i] = a[i] / s[s.size(0) - 1];
  }
  n = a.size(0);
  for (i = 0; i < n; i++) {
    temp = a[i];
    a[i] = std::fmax(temp, 0.0);
  }
  W.set_size(s.size(0), 2);
  for (int b_i{0}; b_i <= yk; b_i++) {
    W[b_i] = a[b_i];
    W[b_i + W.size(0)] = 1.0;
  }
  A.set_size(W.size(0), 2);
  n = W.size(0) * 2;
  for (i = 0; i < n; i++) {
    A[i] = W[i];
  }
  m = W.size(0) - 1;
  ma = W.size(0);
  tau_data[0] = 0.0;
  jpvt[0] = 1;
  work[0] = 0.0;
  temp = internal::blas::xnrm2(W.size(0), W, 1);
  vn1[0] = temp;
  vn2[0] = temp;
  tau_data[1] = 0.0;
  jpvt[1] = 2;
  work[1] = 0.0;
  temp = internal::blas::xnrm2(W.size(0), W, W.size(0) + 1);
  vn1[1] = temp;
  vn2[1] = temp;
  for (int b_i{0}; b_i < 2; b_i++) {
    double atmp;
    double beta1;
    int ii;
    int ip1;
    int mmi;
    int pvt;
    ip1 = b_i + 2;
    ii_tmp = b_i * ma;
    ii = ii_tmp + b_i;
    mmi = m - b_i;
    n = 0;
    if ((2 - b_i > 1) && (std::abs(vn1[b_i + 1]) > std::abs(vn1[b_i]))) {
      n = 1;
    }
    pvt = b_i + n;
    if (pvt != b_i) {
      n = pvt * ma;
      for (lastv = 0; lastv <= m; lastv++) {
        yk = n + lastv;
        temp = A[yk];
        i = ii_tmp + lastv;
        A[yk] = A[i];
        A[i] = temp;
      }
      n = jpvt[pvt];
      jpvt[pvt] = jpvt[b_i];
      jpvt[b_i] = static_cast<signed char>(n);
      vn1[pvt] = vn1[b_i];
      vn2[pvt] = vn2[b_i];
    }
    atmp = A[ii];
    n = ii + 2;
    tau_data[b_i] = 0.0;
    temp = internal::blas::xnrm2(mmi, A, ii + 2);
    if (temp != 0.0) {
      beta1 = rt_hypotd_snf(A[ii], temp);
      if (A[ii] >= 0.0) {
        beta1 = -beta1;
      }
      if (std::abs(beta1) < 1.0020841800044864E-292) {
        yk = 0;
        i = ii + mmi;
        do {
          yk++;
          for (lastv = n; lastv <= i + 1; lastv++) {
            A[lastv - 1] = 9.9792015476736E+291 * A[lastv - 1];
          }
          beta1 *= 9.9792015476736E+291;
          atmp *= 9.9792015476736E+291;
        } while ((std::abs(beta1) < 1.0020841800044864E-292) && (yk < 20));
        beta1 = rt_hypotd_snf(atmp, internal::blas::xnrm2(mmi, A, ii + 2));
        if (atmp >= 0.0) {
          beta1 = -beta1;
        }
        tau_data[b_i] = (beta1 - atmp) / beta1;
        temp = 1.0 / (atmp - beta1);
        for (lastv = n; lastv <= i + 1; lastv++) {
          A[lastv - 1] = temp * A[lastv - 1];
        }
        for (lastv = 0; lastv < yk; lastv++) {
          beta1 *= 1.0020841800044864E-292;
        }
        atmp = beta1;
      } else {
        tau_data[b_i] = (beta1 - A[ii]) / beta1;
        temp = 1.0 / (A[ii] - beta1);
        i = ii + mmi;
        for (lastv = n; lastv <= i + 1; lastv++) {
          A[lastv - 1] = temp * A[lastv - 1];
        }
        atmp = beta1;
      }
    }
    A[ii] = atmp;
    if (b_i + 1 < 2) {
      int jA;
      atmp = A[ii];
      A[ii] = 1.0;
      jA = (ii + ma) + 1;
      if (tau_data[0] != 0.0) {
        lastv = mmi;
        n = ii + mmi;
        while ((lastv + 1 > 0) && (A[n] == 0.0)) {
          lastv--;
          n--;
        }
        yk = 1;
        ii_tmp = jA;
        int exitg1;
        do {
          exitg1 = 0;
          if (ii_tmp <= jA + lastv) {
            if (A[ii_tmp - 1] != 0.0) {
              exitg1 = 1;
            } else {
              ii_tmp++;
            }
          } else {
            yk = 0;
            exitg1 = 1;
          }
        } while (exitg1 == 0);
      } else {
        lastv = -1;
        yk = 0;
      }
      if (lastv + 1 > 0) {
        if (yk != 0) {
          work[0] = 0.0;
          n = 0;
          for (pvt = jA; ma < 0 ? pvt >= jA : pvt <= jA; pvt += ma) {
            temp = 0.0;
            i = pvt + lastv;
            for (ii_tmp = pvt; ii_tmp <= i; ii_tmp++) {
              temp += A[ii_tmp - 1] * A[(ii + ii_tmp) - pvt];
            }
            work[n] += temp;
            n++;
          }
        }
        if (!(-tau_data[0] == 0.0)) {
          for (ii_tmp = 0; ii_tmp < yk; ii_tmp++) {
            if (work[0] != 0.0) {
              temp = work[0] * -tau_data[0];
              i = lastv + jA;
              for (n = jA; n <= i; n++) {
                A[n - 1] = A[n - 1] + A[(ii + n) - jA] * temp;
              }
            }
            jA += ma;
          }
        }
      }
      A[ii] = atmp;
    }
    for (ii_tmp = ip1; ii_tmp < 3; ii_tmp++) {
      n = b_i + ma;
      if (vn1[1] != 0.0) {
        temp = std::abs(A[n]) / vn1[1];
        temp = 1.0 - temp * temp;
        if (temp < 0.0) {
          temp = 0.0;
        }
        beta1 = vn1[1] / vn2[1];
        beta1 = temp * (beta1 * beta1);
        if (beta1 <= 1.4901161193847656E-8) {
          temp = internal::blas::xnrm2(mmi, A, n + 2);
          vn1[1] = temp;
          vn2[1] = temp;
        } else {
          vn1[1] *= std::sqrt(temp);
        }
      }
    }
  }
  yk = 0;
  temp = std::fmin(1.4901161193847656E-8,
                   2.2204460492503131E-15 * static_cast<double>(A.size(0))) *
         std::abs(A[0]);
  while ((yk < 2) && (!(std::abs(A[yk + A.size(0) * yk]) <= temp))) {
    yk++;
  }
  s.set_size(x.size(0));
  n = x.size(0);
  for (i = 0; i < n; i++) {
    s[i] = x[i];
  }
  m = A.size(0);
  for (ii_tmp = 0; ii_tmp < 2; ii_tmp++) {
    work[ii_tmp] = 0.0;
    if (tau_data[ii_tmp] != 0.0) {
      temp = s[ii_tmp];
      i = ii_tmp + 2;
      for (int b_i{i}; b_i <= m; b_i++) {
        temp += A[(b_i + A.size(0) * ii_tmp) - 1] * s[b_i - 1];
      }
      temp *= tau_data[ii_tmp];
      if (temp != 0.0) {
        s[ii_tmp] = s[ii_tmp] - temp;
        for (int b_i{i}; b_i <= m; b_i++) {
          s[b_i - 1] = s[b_i - 1] - A[(b_i + A.size(0) * ii_tmp) - 1] * temp;
        }
      }
    }
  }
  for (int b_i{0}; b_i < yk; b_i++) {
    work[jpvt[b_i] - 1] = s[b_i];
  }
  for (ii_tmp = yk; ii_tmp >= 1; ii_tmp--) {
    n = jpvt[ii_tmp - 1] - 1;
    work[n] /= A[(ii_tmp + A.size(0) * (ii_tmp - 1)) - 1];
    for (int b_i{0}; b_i <= ii_tmp - 2; b_i++) {
      work[jpvt[0] - 1] -= work[n] * A[A.size(0) * (ii_tmp - 1)];
    }
  }
  m = W.size(0);
  y.set_size(W.size(0));
  for (int b_i{0}; b_i < m; b_i++) {
    y[b_i] = W[b_i] * work[0] + W[W.size(0) + b_i] * work[1];
  }
  y.set_size(x.size(0));
  n = x.size(0);
  for (i = 0; i < n; i++) {
    y[i] = x[i] - y[i];
  }
}

} // namespace coder

// End of code generation (detrend.cpp)
