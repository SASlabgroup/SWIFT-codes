//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// despikeSIG_onboard.cpp
//
// Code generation for function 'despikeSIG_onboard'
//

// Include files
#include "despikeSIG_onboard.h"
#include "movmedian.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
void despikeSIG_onboard(const coder::array<double, 2U> &wraw, double nfilt,
                        double dspikemax,
                        const coder::array<char, 2U> &filltype,
                        coder::array<double, 2U> &wclean,
                        coder::array<bool, 2U> &ispike)
{
  static const char cv1[6]{'i', 'n', 't', 'e', 'r', 'p'};
  static const char cv[4]{'n', 'o', 'n', 'e'};
  coder::array<double, 2U> wfilt;
  coder::array<double, 2U> y;
  coder::array<int, 1U> r;
  double varargin_2_data[128];
  int exitg1;
  int i;
  int k;
  int nx;
  unsigned char ii_data[128];
  bool x[128];
  bool b_bool;
  //  Function to de-spike Signature 1000 HR velocity data using a median
  //  filter
  //                wraw        raw HR velocity data, assumed size is nbin x
  //                nping nfilt       size of median filter (in vertical bins)
  //                dwmax       threshold velocity deviation from median
  //                                profiles, points that exceed are spikes
  //                filltype    string, either 'none' which discards spikes, or
  //                                'interp' which filles spikes with linear
  //                                interpolation
  //                wclean      de-spiked data
  //                ispike      indices of spikes that were filled
  //  ONBOARD NOTE: Only change was using movmedian instead of medfilt1
  wclean.set_size(128, wraw.size(1));
  nx = wraw.size(1) << 7;
  for (i = 0; i < nx; i++) {
    wclean[i] = rtNaN;
  }
  //  Identify Spikes
  coder::movmedian(wraw, nfilt, wfilt);
  //  was medfilt1
  nx = 128 * wraw.size(1);
  wfilt.set_size(128, wraw.size(1));
  for (i = 0; i < nx; i++) {
    wfilt[i] = wraw[i] - wfilt[i];
  }
  nx = wfilt.size(1) << 7;
  y.set_size(128, wfilt.size(1));
  for (k = 0; k < nx; k++) {
    y[k] = std::abs(wfilt[k]);
  }
  ispike.set_size(128, y.size(1));
  nx = 128 * y.size(1);
  for (i = 0; i < nx; i++) {
    ispike[i] = (y[i] > dspikemax);
  }
  //  Fill with linear interpolation
  b_bool = false;
  if (filltype.size(1) == 4) {
    nx = 0;
    do {
      exitg1 = 0;
      if (nx < 4) {
        if (filltype[nx] != cv[nx]) {
          exitg1 = 1;
        } else {
          nx++;
        }
      } else {
        b_bool = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  if (b_bool) {
    int low_ip1;
    int mid_i;
    wclean.set_size(128, wraw.size(1));
    nx = 128 * wraw.size(1);
    for (i = 0; i < nx; i++) {
      wclean[i] = wraw[i];
    }
    low_ip1 = (ispike.size(1) << 7) - 1;
    nx = 0;
    for (mid_i = 0; mid_i <= low_ip1; mid_i++) {
      if (ispike[mid_i]) {
        nx++;
      }
    }
    r.set_size(nx);
    nx = 0;
    for (mid_i = 0; mid_i <= low_ip1; mid_i++) {
      if (ispike[mid_i]) {
        r[nx] = mid_i + 1;
        nx++;
      }
    }
    nx = r.size(0);
    for (i = 0; i < nx; i++) {
      wclean[r[i] - 1] = rtNaN;
    }
  } else {
    b_bool = false;
    if (filltype.size(1) == 6) {
      nx = 0;
      do {
        exitg1 = 0;
        if (nx < 6) {
          if (filltype[nx] != cv1[nx]) {
            exitg1 = 1;
          } else {
            nx++;
          }
        } else {
          b_bool = true;
          exitg1 = 1;
        }
      } while (exitg1 == 0);
    }
    if (b_bool) {
      i = wraw.size(1);
      for (int iping{0}; iping < i; iping++) {
        int ii_size;
        int low_ip1;
        int mid_i;
        bool exitg2;
        for (mid_i = 0; mid_i < 128; mid_i++) {
          x[mid_i] = !ispike[mid_i + 128 * iping];
        }
        nx = 0;
        low_ip1 = 0;
        exitg2 = false;
        while ((!exitg2) && (low_ip1 < 128)) {
          if (x[low_ip1]) {
            nx++;
            ii_data[nx - 1] = static_cast<unsigned char>(low_ip1 + 1);
            if (nx >= 128) {
              exitg2 = true;
            } else {
              low_ip1++;
            }
          } else {
            low_ip1++;
          }
        }
        if (1 > nx) {
          ii_size = 0;
        } else {
          ii_size = nx;
        }
        if (ii_size > 3) {
          double tmp;
          int maxx;
          int minx;
          for (mid_i = 0; mid_i < ii_size; mid_i++) {
            varargin_2_data[mid_i] = wraw[(ii_data[mid_i] + 128 * iping) - 1];
          }
          if (ii_data[1] < ii_data[0]) {
            mid_i = ii_size >> 1;
            for (minx = 0; minx < mid_i; minx++) {
              nx = ii_data[minx];
              low_ip1 = (ii_size - minx) - 1;
              ii_data[minx] = ii_data[low_ip1];
              ii_data[low_ip1] = static_cast<unsigned char>(nx);
            }
            nx = ii_size >> 1;
            for (k = 0; k < nx; k++) {
              tmp = varargin_2_data[k];
              low_ip1 = (ii_size - k) - 1;
              varargin_2_data[k] = varargin_2_data[low_ip1];
              varargin_2_data[low_ip1] = tmp;
            }
          }
          minx = ii_data[0];
          maxx = ii_data[ii_size - 1];
          for (k = 0; k < 128; k++) {
            double d;
            if (k + 1 > maxx) {
              d = varargin_2_data[ii_size - 1] +
                  (static_cast<double>(k - maxx) + 1.0) /
                      static_cast<double>(maxx - ii_data[ii_size - 2]) *
                      (varargin_2_data[ii_size - 1] -
                       varargin_2_data[ii_size - 2]);
            } else if (k + 1 < minx) {
              d = varargin_2_data[0] +
                  (static_cast<double>(k - minx) + 1.0) /
                      static_cast<double>(ii_data[1] - minx) *
                      (varargin_2_data[1] - varargin_2_data[0]);
            } else {
              int low_i;
              nx = ii_size;
              low_i = 1;
              low_ip1 = 2;
              while (nx > low_ip1) {
                mid_i = (low_i >> 1) + (nx >> 1);
                if (((low_i & 1) == 1) && ((nx & 1) == 1)) {
                  mid_i++;
                }
                if (k + 1 >= ii_data[mid_i - 1]) {
                  low_i = mid_i;
                  low_ip1 = mid_i + 1;
                } else {
                  nx = mid_i;
                }
              }
              nx = ii_data[low_i - 1];
              tmp = (static_cast<double>(k - nx) + 1.0) /
                    static_cast<double>(ii_data[low_i] - nx);
              if (tmp == 0.0) {
                d = varargin_2_data[low_i - 1];
              } else if (tmp == 1.0) {
                d = varargin_2_data[low_i];
              } else {
                d = varargin_2_data[low_i - 1];
                if (!(d == varargin_2_data[low_i])) {
                  d = (1.0 - tmp) * d + tmp * varargin_2_data[low_i];
                }
              }
            }
            wclean[k + 128 * iping] = d;
          }
        }
      }
    }
  }
}

// End of code generation (despikeSIG_onboard.cpp)
