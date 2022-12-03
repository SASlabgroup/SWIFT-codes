//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// minOrMax.cpp
//
// Code generation for function 'minOrMax'
//

// Include files
#include "minOrMax.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
void maximum(const ::coder::array<double, 2U> &x, double *ex, int *idx)
{
  int last;
  last = x.size(1);
  if (x.size(1) <= 2) {
    if (x.size(1) == 1) {
      *ex = x[0];
      *idx = 1;
    } else if ((x[0] < x[x.size(1) - 1]) ||
               (std::isnan(x[0]) && (!std::isnan(x[x.size(1) - 1])))) {
      *ex = x[x.size(1) - 1];
      *idx = x.size(1);
    } else {
      *ex = x[0];
      *idx = 1;
    }
  } else {
    int k;
    if (!std::isnan(x[0])) {
      *idx = 1;
    } else {
      bool exitg1;
      *idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= last)) {
        if (!std::isnan(x[k - 1])) {
          *idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (*idx == 0) {
      *ex = x[0];
      *idx = 1;
    } else {
      int i;
      *ex = x[*idx - 1];
      i = *idx + 1;
      for (k = i; k <= last; k++) {
        double d;
        d = x[k - 1];
        if (*ex < d) {
          *ex = d;
          *idx = k;
        }
      }
    }
  }
}

void minimum(const ::coder::array<double, 2U> &x, double *ex, int *idx)
{
  int last;
  last = x.size(1);
  if (x.size(1) <= 2) {
    if (x.size(1) == 1) {
      *ex = x[0];
      *idx = 1;
    } else if ((x[0] > x[x.size(1) - 1]) ||
               (std::isnan(x[0]) && (!std::isnan(x[x.size(1) - 1])))) {
      *ex = x[x.size(1) - 1];
      *idx = x.size(1);
    } else {
      *ex = x[0];
      *idx = 1;
    }
  } else {
    int k;
    if (!std::isnan(x[0])) {
      *idx = 1;
    } else {
      bool exitg1;
      *idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= last)) {
        if (!std::isnan(x[k - 1])) {
          *idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (*idx == 0) {
      *ex = x[0];
      *idx = 1;
    } else {
      int i;
      *ex = x[*idx - 1];
      i = *idx + 1;
      for (k = i; k <= last; k++) {
        double d;
        d = x[k - 1];
        if (*ex > d) {
          *ex = d;
          *idx = k;
        }
      }
    }
  }
}

} // namespace internal
} // namespace coder

// End of code generation (minOrMax.cpp)
