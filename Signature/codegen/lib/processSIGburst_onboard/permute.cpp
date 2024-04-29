//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// permute.cpp
//
// Code generation for function 'permute'
//

// Include files
#include "permute.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Declarations
namespace coder {
static bool nomovement(const double perm[3],
                       const ::coder::array<double, 3U> &a);

}

// Function Definitions
namespace coder {
static bool nomovement(const double perm[3],
                       const ::coder::array<double, 3U> &a)
{
  bool b;
  b = true;
  if (a.size(1) != 0) {
    double plast;
    int k;
    bool exitg1;
    plast = 0.0;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 3)) {
      if (a.size(static_cast<int>(perm[k]) - 1) != 1) {
        if (plast > perm[k]) {
          b = false;
          exitg1 = true;
        } else {
          plast = perm[k];
          k++;
        }
      } else {
        k++;
      }
    }
  }
  return b;
}

void b_permute(const ::coder::array<double, 3U> &a,
               ::coder::array<double, 3U> &b)
{
  static const double dv[3]{3.0, 1.0, 2.0};
  int subsa_idx_2;
  if (nomovement(dv, a)) {
    b.set_size(128, 128, a.size(1));
    subsa_idx_2 = a.size(1) << 14;
    for (int i{0}; i < subsa_idx_2; i++) {
      b[i] = a[i];
    }
  } else {
    int i;
    b.set_size(128, 128, a.size(1));
    i = a.size(1);
    for (int k{0}; k < 128; k++) {
      if (i - 1 >= 0) {
        subsa_idx_2 = k + 1;
      }
      for (int b_k{0}; b_k < i; b_k++) {
        for (int c_k{0}; c_k < 128; c_k++) {
          b[((subsa_idx_2 + 128 * c_k) + 16384 * b_k) - 1] =
              a[(c_k + 128 * b_k) + 128 * a.size(1) * (subsa_idx_2 - 1)];
        }
      }
    }
  }
}

void permute(const ::coder::array<double, 3U> &a, ::coder::array<double, 3U> &b)
{
  static const double dv[3]{1.0, 3.0, 2.0};
  int subsa_idx_2;
  if (nomovement(dv, a)) {
    b.set_size(128, 128, a.size(1));
    subsa_idx_2 = a.size(1) << 14;
    for (int i{0}; i < subsa_idx_2; i++) {
      b[i] = a[i];
    }
  } else {
    int i;
    b.set_size(128, 128, a.size(1));
    i = a.size(1);
    for (int k{0}; k < 128; k++) {
      if (i - 1 >= 0) {
        subsa_idx_2 = k + 1;
      }
      for (int b_k{0}; b_k < i; b_k++) {
        for (int c_k{0}; c_k < 128; c_k++) {
          b[(c_k + 128 * (subsa_idx_2 - 1)) + 16384 * b_k] =
              a[(c_k + 128 * b_k) + 128 * a.size(1) * (subsa_idx_2 - 1)];
        }
      }
    }
  }
}

} // namespace coder

// End of code generation (permute.cpp)
