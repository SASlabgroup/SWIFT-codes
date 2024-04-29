//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// interp1.cpp
//
// Code generation for function 'interp1'
//

// Include files
#include "interp1.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "omp.h"
#include <cmath>

// Function Declarations
namespace coder {
static void interp1Linear(const ::coder::array<double, 1U> &y, int nyrows,
                          const ::coder::array<double, 2U> &xi,
                          ::coder::array<double, 2U> &yi,
                          const ::coder::array<double, 1U> &varargin_1);

}

// Function Definitions
namespace coder {
static void interp1Linear(const ::coder::array<double, 1U> &y, int nyrows,
                          const ::coder::array<double, 2U> &xi,
                          ::coder::array<double, 2U> &yi,
                          const ::coder::array<double, 1U> &varargin_1)
{
  double d;
  double maxx;
  double minx;
  double penx;
  double r;
  int high_i;
  int low_i;
  int low_ip1;
  int mid_i;
  int ub_loop;
  minx = varargin_1[0];
  penx = varargin_1[varargin_1.size(0) - 2];
  maxx = varargin_1[varargin_1.size(0) - 1];
  ub_loop = xi.size(1) - 1;
#pragma omp parallel for num_threads(omp_get_max_threads()) private(           \
    d, r, high_i, low_i, low_ip1, mid_i)

  for (int k = 0; k <= ub_loop; k++) {
    d = xi[k];
    if (std::isnan(d)) {
      yi[k] = rtNaN;
    } else if (d > maxx) {
      r = y[nyrows - 1];
      yi[k] = r + (d - maxx) / (maxx - penx) * (r - y[nyrows - 2]);
    } else if (d < minx) {
      yi[k] = y[0] + (d - minx) / (varargin_1[1] - minx) * (y[1] - y[0]);
    } else {
      high_i = varargin_1.size(0);
      low_i = 1;
      low_ip1 = 2;
      while (high_i > low_ip1) {
        mid_i = (low_i >> 1) + (high_i >> 1);
        if (((low_i & 1) == 1) && ((high_i & 1) == 1)) {
          mid_i++;
        }
        if (xi[k] >= varargin_1[mid_i - 1]) {
          low_i = mid_i;
          low_ip1 = mid_i + 1;
        } else {
          high_i = mid_i;
        }
      }
      r = varargin_1[low_i - 1];
      r = (xi[k] - r) / (varargin_1[low_i] - r);
      if (r == 0.0) {
        yi[k] = y[low_i - 1];
      } else if (r == 1.0) {
        yi[k] = y[low_i];
      } else {
        d = y[low_i - 1];
        if (d == y[low_i]) {
          yi[k] = d;
        } else {
          yi[k] = (1.0 - r) * d + r * y[low_i];
        }
      }
    }
  }
}

void interp1(const ::coder::array<double, 1U> &varargin_1,
             const ::coder::array<double, 1U> &varargin_2,
             const ::coder::array<double, 2U> &varargin_3,
             ::coder::array<double, 2U> &Vq)
{
  array<double, 1U> x;
  array<double, 1U> y;
  int k;
  int n;
  int nx;
  bool b;
  y.set_size(varargin_2.size(0));
  n = varargin_2.size(0);
  for (k = 0; k < n; k++) {
    y[k] = varargin_2[k];
  }
  x.set_size(varargin_1.size(0));
  n = varargin_1.size(0);
  for (k = 0; k < n; k++) {
    x[k] = varargin_1[k];
  }
  nx = varargin_1.size(0) - 1;
  Vq.set_size(1, varargin_3.size(1));
  n = varargin_3.size(1);
  for (k = 0; k < n; k++) {
    Vq[k] = 0.0;
  }
  b = (varargin_3.size(1) == 0);
  if (!b) {
    k = 0;
    int exitg1;
    do {
      exitg1 = 0;
      if (k <= nx) {
        if (std::isnan(varargin_1[k])) {
          exitg1 = 1;
        } else {
          k++;
        }
      } else {
        if (varargin_1[1] < varargin_1[0]) {
          double xtmp;
          int b_j1;
          k = (nx + 1) >> 1;
          for (b_j1 = 0; b_j1 < k; b_j1++) {
            xtmp = x[b_j1];
            n = nx - b_j1;
            x[b_j1] = x[n];
            x[n] = xtmp;
          }
          n = varargin_2.size(0) - 1;
          nx = varargin_2.size(0) >> 1;
          for (k = 0; k < nx; k++) {
            xtmp = y[k];
            b_j1 = n - k;
            y[k] = y[b_j1];
            y[b_j1] = xtmp;
          }
        }
        interp1Linear(y, varargin_2.size(0), varargin_3, Vq, x);
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
}

} // namespace coder

// End of code generation (interp1.cpp)
