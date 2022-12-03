//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// fft.cpp
//
// Code generation for function 'fft'
//

// Include files
#include "fft.h"
#include "FFTImplementationCallback.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
void fft(const ::coder::array<double, 2U> &x, ::coder::array<creal_T, 2U> &y)
{
  array<double, 2U> costab;
  array<double, 2U> costab1q;
  array<double, 2U> sintab;
  array<double, 2U> sintabinv;
  if ((x.size(0) == 0) || (x.size(1) == 0)) {
    int pmax;
    y.set_size(x.size(0), x.size(1));
    pmax = x.size(0) * x.size(1);
    for (int pow2p{0}; pow2p < pmax; pow2p++) {
      y[pow2p].re = 0.0;
      y[pow2p].im = 0.0;
    }
  } else {
    double e;
    int k;
    int n;
    int pmax;
    int pmin;
    int pow2p;
    bool useRadix2;
    useRadix2 = ((x.size(0) & (x.size(0) - 1)) == 0);
    pmin = 1;
    if (useRadix2) {
      pmax = x.size(0);
    } else {
      n = (x.size(0) + x.size(0)) - 1;
      pmax = 31;
      if (n <= 1) {
        pmax = 0;
      } else {
        bool exitg1;
        pmin = 0;
        exitg1 = false;
        while ((!exitg1) && (pmax - pmin > 1)) {
          k = (pmin + pmax) >> 1;
          pow2p = 1 << k;
          if (pow2p == n) {
            pmax = k;
            exitg1 = true;
          } else if (pow2p > n) {
            pmax = k;
          } else {
            pmin = k;
          }
        }
      }
      pmin = 1 << pmax;
      pmax = pmin;
    }
    e = 6.2831853071795862 / static_cast<double>(pmax);
    pow2p = (pmax + (pmax < 0)) >> 1;
    n = (pow2p + (pow2p < 0)) >> 1;
    costab1q.set_size(1, n + 1);
    costab1q[0] = 1.0;
    pmax = ((n + (n < 0)) >> 1) - 1;
    for (k = 0; k <= pmax; k++) {
      costab1q[k + 1] = std::cos(e * (static_cast<double>(k) + 1.0));
    }
    pow2p = pmax + 2;
    pmax = n - 1;
    for (k = pow2p; k <= pmax; k++) {
      costab1q[k] = std::sin(e * static_cast<double>(n - k));
    }
    costab1q[n] = 0.0;
    if (!useRadix2) {
      n = costab1q.size(1) - 1;
      pmax = (costab1q.size(1) - 1) << 1;
      costab.set_size(1, pmax + 1);
      sintab.set_size(1, pmax + 1);
      costab[0] = 1.0;
      sintab[0] = 0.0;
      sintabinv.set_size(1, pmax + 1);
      for (k = 0; k < n; k++) {
        sintabinv[k + 1] = costab1q[(n - k) - 1];
      }
      pow2p = costab1q.size(1);
      for (k = pow2p; k <= pmax; k++) {
        sintabinv[k] = costab1q[k - n];
      }
      for (k = 0; k < n; k++) {
        costab[k + 1] = costab1q[k + 1];
        sintab[k + 1] = -costab1q[(n - k) - 1];
      }
      pow2p = costab1q.size(1);
      for (k = pow2p; k <= pmax; k++) {
        costab[k] = -costab1q[pmax - k];
        sintab[k] = -costab1q[k - n];
      }
    } else {
      n = costab1q.size(1) - 1;
      pmax = (costab1q.size(1) - 1) << 1;
      costab.set_size(1, pmax + 1);
      sintab.set_size(1, pmax + 1);
      costab[0] = 1.0;
      sintab[0] = 0.0;
      for (k = 0; k < n; k++) {
        costab[k + 1] = costab1q[k + 1];
        sintab[k + 1] = -costab1q[(n - k) - 1];
      }
      pow2p = costab1q.size(1);
      for (k = pow2p; k <= pmax; k++) {
        costab[k] = -costab1q[pmax - k];
        sintab[k] = -costab1q[k - n];
      }
      sintabinv.set_size(1, 0);
    }
    if (useRadix2) {
      internal::fft::FFTImplementationCallback::r2br_r2dit_trig(
          x, x.size(0), costab, sintab, y);
    } else {
      internal::fft::FFTImplementationCallback::dobluesteinfft(
          x, pmin, x.size(0), costab, sintab, sintabinv, y);
    }
  }
}

} // namespace coder

// End of code generation (fft.cpp)
