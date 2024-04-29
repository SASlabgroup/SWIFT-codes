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
#include <algorithm>
#include <cmath>

// Function Definitions
namespace coder {
void interp1(const double varargin_1_data[], int varargin_1_size,
             const double varargin_2_data[], int varargin_2_size,
             double Vq[128])
{
  double x_data[128];
  double y_data[128];
  int k;
  if (varargin_2_size - 1 >= 0) {
    std::copy(&varargin_2_data[0], &varargin_2_data[varargin_2_size],
              &y_data[0]);
  }
  if (varargin_1_size - 1 >= 0) {
    std::copy(&varargin_1_data[0], &varargin_1_data[varargin_1_size],
              &x_data[0]);
  }
  k = 0;
  int exitg1;
  do {
    exitg1 = 0;
    if (k <= varargin_1_size - 1) {
      if (std::isnan(varargin_1_data[k])) {
        exitg1 = 1;
      } else {
        k++;
      }
    } else {
      double maxx;
      double minx;
      double xtmp;
      int high_i;
      int low_i;
      int low_ip1;
      if (varargin_1_data[1] < varargin_1_data[0]) {
        low_i = varargin_1_size >> 1;
        for (low_ip1 = 0; low_ip1 < low_i; low_ip1++) {
          xtmp = x_data[low_ip1];
          high_i = (varargin_1_size - low_ip1) - 1;
          x_data[low_ip1] = x_data[high_i];
          x_data[high_i] = xtmp;
        }
        low_i = varargin_2_size >> 1;
        for (k = 0; k < low_i; k++) {
          xtmp = y_data[k];
          high_i = (varargin_2_size - k) - 1;
          y_data[k] = y_data[high_i];
          y_data[high_i] = xtmp;
        }
      }
      minx = x_data[0];
      maxx = x_data[varargin_1_size - 1];
      for (k = 0; k < 128; k++) {
        if (((static_cast<double>(k) + 1.0) - 1.0) + 1.0 > maxx) {
          Vq[k] =
              y_data[varargin_2_size - 1] +
              ((((static_cast<double>(k) + 1.0) - 1.0) + 1.0) - maxx) /
                  (maxx - x_data[varargin_1_size - 2]) *
                  (y_data[varargin_2_size - 1] - y_data[varargin_2_size - 2]);
        } else if (((static_cast<double>(k) + 1.0) - 1.0) + 1.0 < minx) {
          Vq[k] = y_data[0] +
                  ((((static_cast<double>(k) + 1.0) - 1.0) + 1.0) - minx) /
                      (x_data[1] - minx) * (y_data[1] - y_data[0]);
        } else {
          high_i = varargin_1_size;
          low_i = 1;
          low_ip1 = 2;
          while (high_i > low_ip1) {
            int mid_i;
            mid_i = (low_i >> 1) + (high_i >> 1);
            if (((low_i & 1) == 1) && ((high_i & 1) == 1)) {
              mid_i++;
            }
            if (((static_cast<double>(k) + 1.0) - 1.0) + 1.0 >=
                x_data[mid_i - 1]) {
              low_i = mid_i;
              low_ip1 = mid_i + 1;
            } else {
              high_i = mid_i;
            }
          }
          xtmp = x_data[low_i - 1];
          xtmp = ((((static_cast<double>(k) + 1.0) - 1.0) + 1.0) - xtmp) /
                 (x_data[low_i] - xtmp);
          if (xtmp == 0.0) {
            Vq[k] = y_data[low_i - 1];
          } else if (xtmp == 1.0) {
            Vq[k] = y_data[low_i];
          } else {
            double Vq_tmp;
            Vq_tmp = y_data[low_i - 1];
            if (Vq_tmp == y_data[low_i]) {
              Vq[k] = Vq_tmp;
            } else {
              Vq[k] = (1.0 - xtmp) * Vq_tmp + xtmp * y_data[low_i];
            }
          }
        }
      }
      exitg1 = 1;
    }
  } while (exitg1 == 0);
}

} // namespace coder

// End of code generation (interp1.cpp)
