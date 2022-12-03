//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// nullAssignment.cpp
//
// Code generation for function 'nullAssignment'
//

// Include files
#include "nullAssignment.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
namespace internal {
void b_nullAssignment(::coder::array<double, 2U> &x,
                      const ::coder::array<bool, 2U> &idx)
{
  int k0;
  int nxin;
  int nxout;
  nxin = x.size(1);
  nxout = 0;
  k0 = idx.size(1);
  for (int k{0}; k < k0; k++) {
    nxout += idx[k];
  }
  nxout = x.size(1) - nxout;
  k0 = -1;
  for (int k{0}; k < nxin; k++) {
    if ((k + 1 > idx.size(1)) || (!idx[k])) {
      k0++;
      x[k0] = x[k];
    }
  }
  if (nxout < 1) {
    nxout = 0;
  }
  x.set_size(x.size(0), nxout);
}

void c_nullAssignment(::coder::array<creal_T, 2U> &x,
                      const ::coder::array<bool, 2U> &idx)
{
  int k0;
  int nxin;
  int nxout;
  nxin = x.size(1);
  nxout = 0;
  k0 = idx.size(1);
  for (int k{0}; k < k0; k++) {
    nxout += idx[k];
  }
  nxout = x.size(1) - nxout;
  k0 = -1;
  for (int k{0}; k < nxin; k++) {
    if ((k + 1 > idx.size(1)) || (!idx[k])) {
      k0++;
      x[k0] = x[k];
    }
  }
  if (nxout < 1) {
    nxout = 0;
  }
  x.set_size(x.size(0), nxout);
}

void nullAssignment(::coder::array<creal_T, 2U> &x,
                    const ::coder::array<int, 2U> &idx)
{
  array<bool, 2U> b;
  int b_i;
  int i;
  int ncolx;
  int nrows;
  int nrowx;
  nrowx = x.size(0);
  ncolx = x.size(1) - 1;
  if (idx.size(1) == 1) {
    nrows = x.size(0) - 1;
    for (int j{0}; j <= ncolx; j++) {
      b_i = idx[0];
      for (i = b_i; i <= nrows; i++) {
        x[(i + x.size(0) * j) - 1] = x[i + x.size(0) * j];
      }
    }
  } else {
    b.set_size(1, x.size(0));
    i = x.size(0);
    for (b_i = 0; b_i < i; b_i++) {
      b[b_i] = false;
    }
    b_i = idx.size(1);
    for (int k{0}; k < b_i; k++) {
      b[idx[k] - 1] = true;
    }
    nrows = 0;
    b_i = b.size(1);
    for (int k{0}; k < b_i; k++) {
      nrows += b[k];
    }
    nrows = x.size(0) - nrows;
    i = 0;
    for (int k{0}; k < nrowx; k++) {
      if ((k + 1 > b.size(1)) || (!b[k])) {
        for (int j{0}; j <= ncolx; j++) {
          x[i + x.size(0) * j] = x[k + x.size(0) * j];
        }
        i++;
      }
    }
  }
  if (nrows < 1) {
    i = 0;
  } else {
    i = nrows;
  }
  nrows = x.size(1) - 1;
  for (b_i = 0; b_i <= nrows; b_i++) {
    for (nrowx = 0; nrowx < i; nrowx++) {
      x[nrowx + i * b_i] = x[nrowx + x.size(0) * b_i];
    }
  }
  x.set_size(i, nrows + 1);
}

void nullAssignment(::coder::array<creal_T, 2U> &x)
{
  int ncolx;
  int nrows;
  int nrowx;
  nrowx = x.size(0) - 2;
  ncolx = x.size(1);
  nrows = x.size(0) - 1;
  for (int j{0}; j < ncolx; j++) {
    for (int i{0}; i < nrows; i++) {
      x[i + x.size(0) * j] = x[(i + x.size(0) * j) + 1];
    }
  }
  if (nrows < 1) {
    nrowx = 0;
  } else {
    nrowx++;
  }
  ncolx = x.size(1) - 1;
  for (nrows = 0; nrows <= ncolx; nrows++) {
    for (int j{0}; j < nrowx; j++) {
      x[j + nrowx * nrows] = x[j + x.size(0) * nrows];
    }
  }
  x.set_size(nrowx, ncolx + 1);
}

} // namespace internal
} // namespace coder

// End of code generation (nullAssignment.cpp)
