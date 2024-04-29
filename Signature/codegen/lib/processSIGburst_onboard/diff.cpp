//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// diff.cpp
//
// Code generation for function 'diff'
//

// Include files
#include "diff.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
void diff(const ::coder::array<double, 2U> &x, ::coder::array<double, 2U> &y)
{
  int dimSize;
  dimSize = x.size(1);
  if (x.size(1) == 0) {
    y.set_size(1, 0);
  } else {
    int u0;
    u0 = x.size(1) - 1;
    if (u0 > 1) {
      u0 = 1;
    }
    if (u0 < 1) {
      y.set_size(1, 0);
    } else {
      y.set_size(1, x.size(1) - 1);
      if (x.size(1) - 1 != 0) {
        double work_data;
        work_data = x[0];
        for (u0 = 2; u0 <= dimSize; u0++) {
          double d;
          double tmp1;
          tmp1 = x[u0 - 1];
          d = tmp1;
          tmp1 -= work_data;
          work_data = d;
          y[u0 - 2] = tmp1;
        }
      }
    }
  }
}

} // namespace coder

// End of code generation (diff.cpp)
