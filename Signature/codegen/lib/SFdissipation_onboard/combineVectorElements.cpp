//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// combineVectorElements.cpp
//
// Code generation for function 'combineVectorElements'
//

// Include files
#include "combineVectorElements.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cstring>

// Function Definitions
namespace coder {
void combineVectorElements(const ::coder::array<bool, 3U> &x, int y[16384])
{
  int vlen;
  vlen = x.size(2);
  if (x.size(2) == 0) {
    std::memset(&y[0], 0, 16384U * sizeof(int));
  } else {
    for (int j{0}; j < 16384; j++) {
      y[j] = x[j];
    }
    for (int k{2}; k <= vlen; k++) {
      int xoffset;
      xoffset = (k - 1) << 14;
      for (int j{0}; j < 16384; j++) {
        y[j] += x[xoffset + j];
      }
    }
  }
}

} // namespace coder

// End of code generation (combineVectorElements.cpp)
