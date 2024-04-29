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

// Function Definitions
namespace coder {
void diff(const double x[128], double y[127])
{
  double work;
  work = x[0];
  for (int m{0}; m < 127; m++) {
    double tmp2;
    tmp2 = work;
    work = x[m + 1];
    y[m] = work - tmp2;
  }
}

} // namespace coder

// End of code generation (diff.cpp)
