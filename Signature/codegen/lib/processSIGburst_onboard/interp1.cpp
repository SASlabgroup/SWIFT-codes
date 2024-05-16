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
#include "rt_nonfinite.h"

// Function Definitions
namespace coder {
void interp1(const ::coder::array<double, 1U> &varargin_1,
             const ::coder::array<double, 1U> &varargin_2,
             const ::coder::array<double, 2U> &varargin_3,
             ::coder::array<double, 2U> &Vq)
{
  array<double, 1U> x;
  array<double, 1U> y;
  int low_ip1;
  int nd2;
  int nx;
  int nyrows_tmp;
  bool b;
  y.set_size(varargin_2.size(0));
  nd2 = varargin_2.size(0);
  for (low_ip1 = 0; low_ip1 < nd2; low_ip1++) {
    y[low_ip1] = varargin_2[low_ip1];
  }
  x.set_size(varargin_1.size(0));
  nd2 = varargin_1.size(0);
  for (low_ip1 = 0; low_ip1 < nd2; low_ip1++) {
    x[low_ip1] = varargin_1[low_ip1];
  }
  nyrows_tmp = varargin_2.size(0) - 1;
  nx = varargin_1.size(0) - 1;
  Vq.set_size(1, varargin_3.size(1));
  nd2 = varargin_3.size(1);
  for (low_ip1 = 0; low_ip1 < nd2; low_ip1++) {
    Vq[low_ip1] = 0.0;
  }
  b = (varargin_3.size(1) == 0);
  if (!b) {
    int k;
    k = 0;
    int exitg1;
    do {
      exitg1 = 0;
      if (k <= nx) {
        if (rtIsNaN(varargin_1[k])) {
          exitg1 = 1;
        } else {
          k++;
        }
      } else {
        double maxx;
        double minx;
        double xtmp;
        int low_i;
        if (varargin_1[1] < varargin_1[0]) {
          low_ip1 = (nx + 1) >> 1;
          for (low_i = 0; low_i < low_ip1; low_i++) {
            xtmp = x[low_i];
            nd2 = nx - low_i;
            x[low_i] = x[nd2];
            x[nd2] = xtmp;
          }
          nd2 = varargin_2.size(0) >> 1;
          for (k = 0; k < nd2; k++) {
            xtmp = y[k];
            nx = nyrows_tmp - k;
            y[k] = y[nx];
            y[nx] = xtmp;
          }
        }
        minx = x[0];
        maxx = x[x.size(0) - 1];
        nd2 = varargin_3.size(1);
        for (k = 0; k < nd2; k++) {
          xtmp = varargin_3[k];
          if (rtIsNaN(xtmp)) {
            Vq[k] = rtNaN;
          } else if (xtmp > maxx) {
            Vq[k] = y[nyrows_tmp] + (xtmp - maxx) / (maxx - x[x.size(0) - 2]) *
                                        (y[nyrows_tmp] - y[nyrows_tmp - 1]);
          } else if (xtmp < minx) {
            Vq[k] = y[0] + (xtmp - minx) / (x[1] - minx) * (y[1] - y[0]);
          } else {
            nx = x.size(0);
            low_i = 1;
            low_ip1 = 2;
            while (nx > low_ip1) {
              int mid_i;
              mid_i = (low_i >> 1) + (nx >> 1);
              if (((low_i & 1) == 1) && ((nx & 1) == 1)) {
                mid_i++;
              }
              if (varargin_3[k] >= x[mid_i - 1]) {
                low_i = mid_i;
                low_ip1 = mid_i + 1;
              } else {
                nx = mid_i;
              }
            }
            xtmp = x[low_i - 1];
            xtmp = (varargin_3[k] - xtmp) / (x[low_i] - xtmp);
            if (xtmp == 0.0) {
              Vq[k] = y[low_i - 1];
            } else if (xtmp == 1.0) {
              Vq[k] = y[low_i];
            } else {
              double Vq_tmp;
              Vq_tmp = y[low_i - 1];
              if (Vq_tmp == y[low_i]) {
                Vq[k] = Vq_tmp;
              } else {
                Vq[k] = (1.0 - xtmp) * Vq_tmp + xtmp * y[low_i];
              }
            }
          }
        }
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
}

} // namespace coder

// End of code generation (interp1.cpp)
