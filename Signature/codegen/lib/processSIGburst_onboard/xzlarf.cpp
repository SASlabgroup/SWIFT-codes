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
void b_xzlarf(int m, int n, int iv0, double tau, ::coder::array<double, 2U> &C,
              int ic0, int ldc, ::coder::array<double, 1U> &work)
{
  int i;
  int lastc;
  int lastv;
  int rowright;
  if (tau != 0.0) {
    bool exitg2;
    lastv = n;
    i = iv0 + n;
    while ((lastv > 0) && (C[i - 2] == 0.0)) {
      lastv--;
      i--;
    }
    lastc = m;
    exitg2 = false;
    while ((!exitg2) && (lastc > 0)) {
      int exitg1;
      i = (ic0 + lastc) - 1;
      rowright = i + (lastv - 1) * ldc;
      do {
        exitg1 = 0;
        if (((ldc > 0) && (i <= rowright)) || ((ldc < 0) && (i >= rowright))) {
          if (C[i - 1] != 0.0) {
            exitg1 = 1;
          } else {
            i += ldc;
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
    lastc = 0;
  }
  if (lastv > 0) {
    int b_i;
    int ijA;
    if (lastc != 0) {
      for (i = 0; i < lastc; i++) {
        work[i] = 0.0;
      }
      i = iv0;
      b_i = ic0 + ldc * (lastv - 1);
      for (int iac = ic0; ldc < 0 ? iac >= b_i : iac <= b_i; iac += ldc) {
        rowright = (iac + lastc) - 1;
        for (int ia = iac; ia <= rowright; ia++) {
          ijA = ia - iac;
          work[ijA] = work[ijA] + C[ia - 1] * C[i - 1];
        }
        i++;
      }
    }
    if (!(-tau == 0.0)) {
      i = ic0;
      for (rowright = 0; rowright < lastv; rowright++) {
        double temp;
        temp = C[(iv0 + rowright) - 1];
        if (temp != 0.0) {
          temp *= -tau;
          b_i = lastc + i;
          for (ijA = i; ijA < b_i; ijA++) {
            C[ijA - 1] = C[ijA - 1] + work[ijA - i] * temp;
          }
        }
        i += ldc;
      }
    }
  }
}

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
    int iy;
    if (lastc + 1 != 0) {
      for (iy = 0; iy <= lastc; iy++) {
        work[iy] = 0.0;
      }
      iy = 0;
      b_i = ic0 + ldc * lastc;
      for (int iac = ic0; ldc < 0 ? iac >= b_i : iac <= b_i; iac += ldc) {
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
        c = work[iy];
        if (c != 0.0) {
          c *= -tau;
          b_i = lastv + i;
          for (int iac = i; iac < b_i; iac++) {
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
