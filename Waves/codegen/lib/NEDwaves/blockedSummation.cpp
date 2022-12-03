//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// blockedSummation.cpp
//
// Code generation for function 'blockedSummation'
//

// Include files
#include "blockedSummation.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
float blockedSummation(const ::coder::array<float, 1U> &x, int vlen)
{
  float y;
  if ((x.size(0) == 0) || (vlen == 0)) {
    y = 0.0F;
  } else {
    int firstBlockLength;
    int lastBlockLength;
    int nblocks;
    if (vlen <= 1024) {
      firstBlockLength = vlen;
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = vlen >> 10;
      lastBlockLength = vlen - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    y = x[0];
    for (int k{2}; k <= firstBlockLength; k++) {
      y += x[k - 1];
    }
    for (int ib{2}; ib <= nblocks; ib++) {
      float bsum;
      int hi;
      firstBlockLength = (ib - 1) << 10;
      bsum = x[firstBlockLength];
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (int k{2}; k <= hi; k++) {
        bsum += x[(firstBlockLength + k) - 1];
      }
      y += bsum;
    }
  }
  return y;
}

} // namespace coder

// End of code generation (blockedSummation.cpp)
