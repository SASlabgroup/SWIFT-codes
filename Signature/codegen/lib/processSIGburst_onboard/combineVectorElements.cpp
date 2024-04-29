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

// Function Definitions
namespace coder {
void combineVectorElements(const ::coder::array<bool, 2U> &x,
                           ::coder::array<int, 2U> &y)
{
  if (x.size(1) == 0) {
    y.set_size(1, 0);
  } else {
    int npages;
    npages = x.size(1);
    y.set_size(1, x.size(1));
    for (int i{0}; i < npages; i++) {
      int b_i;
      int xpageoffset;
      xpageoffset = i << 7;
      b_i = x[xpageoffset];
      for (int k{0}; k < 127; k++) {
        b_i += x[(xpageoffset + k) + 1];
      }
      y[i] = b_i;
    }
  }
}

} // namespace coder

// End of code generation (combineVectorElements.cpp)
