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
  int vlen;
  vlen = x.size(0);
  if ((x.size(0) == 0) || (x.size(1) == 0)) {
    y.set_size(1, x.size(1));
    vlen = x.size(1);
    for (int npages{0}; npages < vlen; npages++) {
      y[npages] = 0;
    }
  } else {
    int npages;
    npages = x.size(1);
    y.set_size(1, x.size(1));
    for (int i{0}; i < npages; i++) {
      int xpageoffset;
      xpageoffset = i * x.size(0);
      y[i] = x[xpageoffset];
      for (int k{2}; k <= vlen; k++) {
        y[i] = y[i] + x[(xpageoffset + k) - 1];
      }
    }
  }
}

} // namespace coder

// End of code generation (combineVectorElements.cpp)
