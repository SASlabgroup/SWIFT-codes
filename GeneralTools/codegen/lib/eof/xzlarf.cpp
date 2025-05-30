//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzlarf.cpp
//
// Code generation for function 'xzlarf'
//

// Include files
#include "xzlarf.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
void xzlarf(int m, int n, int iv0, double tau, ::coder::array<double, 2U> &C,
            int ic0, int ldc, ::coder::array<double, 1U> &work)
{
  int i;
  int ia;
  int lastc;
  int lastv;
  if (tau != 0.0) {
    bool exitg2;
    lastv = m;
    i = iv0 + m;
    while ((lastv > 0) && (C[i - 2] == 0.0)) {
      lastv--;
      i--;
    }
    lastc = n - 1;
    exitg2 = false;
    while ((!exitg2) && (lastc + 1 > 0)) {
      int exitg1;
      i = ic0 + lastc * ldc;
      ia = i;
      do {
        exitg1 = 0;
        if (ia <= (i + lastv) - 1) {
          if (C[ia - 1] != 0.0) {
            exitg1 = 1;
          } else {
            ia++;
          }
        } else {
          lastc--;
          exitg1 = 2;
        }
      } while (exitg1 == 0);
      if (exitg1 == 1) {
        exitg2 = true;
      }
    }
  } else {
    lastv = 0;
    lastc = -1;
  }
  if (lastv > 0) {
    double c;
    int b_i;
    int iac;
    int iy;
    if (lastc + 1 != 0) {
      for (iy = 0; iy <= lastc; iy++) {
        work[iy] = 0.0;
      }
      iy = 0;
      b_i = ic0 + ldc * lastc;
      for (iac = ic0; ldc < 0 ? iac >= b_i : iac <= b_i; iac += ldc) {
        c = 0.0;
        i = (iac + lastv) - 1;
        for (ia = iac; ia <= i; ia++) {
          c += C[ia - 1] * C[((iv0 + ia) - iac) - 1];
        }
        work[iy] = work[iy] + c;
        iy++;
      }
    }
    if (!(-tau == 0.0)) {
      i = ic0;
      for (iy = 0; iy <= lastc; iy++) {
        if (work[iy] != 0.0) {
          c = work[iy] * -tau;
          b_i = lastv + i;
          for (iac = i; iac < b_i; iac++) {
            C[iac - 1] = C[iac - 1] + C[((iv0 + iac) - i) - 1] * c;
          }
        }
        i += ldc;
      }
    }
  }
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xzlarf.cpp)
