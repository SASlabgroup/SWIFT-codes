//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// meshgrid.cpp
//
// Code generation for function 'meshgrid'
//

// Include files
#include "meshgrid.h"
#include "rt_nonfinite.h"
#include <algorithm>

// Function Definitions
namespace coder {
void meshgrid(const double x[128], double xx[16384], double yy[16384])
{
  for (int j{0}; j < 128; j++) {
    std::copy(&x[0], &x[128], &yy[j * 128]);
    for (int i{0}; i < 128; i++) {
      int xx_tmp;
      xx_tmp = i + (j << 7);
      xx[xx_tmp] = x[j];
    }
  }
}

} // namespace coder

// End of code generation (meshgrid.cpp)
