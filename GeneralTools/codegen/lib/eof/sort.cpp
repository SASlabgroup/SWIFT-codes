//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// sort.cpp
//
// Code generation for function 'sort'
//

// Include files
#include "sort.h"
#include "rt_nonfinite.h"
#include "sortLE.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
namespace internal {
void sort(::coder::array<creal_T, 1U> &x, ::coder::array<int, 1U> &idx)
{
  array<creal_T, 1U> vwork;
  array<creal_T, 1U> xwork;
  array<int, 1U> iidx;
  array<int, 1U> iwork;
  int dim;
  int i;
  int k;
  int qEnd;
  int vlen;
  int vstride;
  dim = 0;
  if (x.size(0) != 1) {
    dim = -1;
  }
  if (dim + 2 <= 1) {
    i = x.size(0);
  } else {
    i = 1;
  }
  vlen = i - 1;
  vwork.set_size(i);
  idx.set_size(x.size(0));
  vstride = 1;
  for (k = 0; k <= dim; k++) {
    vstride *= x.size(0);
  }
  for (int j{0}; j < vstride; j++) {
    int i1;
    int n;
    for (k = 0; k <= vlen; k++) {
      vwork[k] = x[j + k * vstride];
    }
    i = vwork.size(0);
    n = vwork.size(0) + 1;
    iidx.set_size(vwork.size(0));
    dim = vwork.size(0);
    for (i1 = 0; i1 < dim; i1++) {
      iidx[i1] = 0;
    }
    if (vwork.size(0) != 0) {
      iwork.set_size(vwork.size(0));
      i1 = vwork.size(0) - 1;
      for (k = 1; k <= i1; k += 2) {
        if (sortLE(vwork, k, k + 1)) {
          iidx[k - 1] = k;
          iidx[k] = k + 1;
        } else {
          iidx[k - 1] = k + 1;
          iidx[k] = k;
        }
      }
      if ((vwork.size(0) & 1) != 0) {
        iidx[vwork.size(0) - 1] = vwork.size(0);
      }
      dim = 2;
      while (dim < i) {
        int b_j;
        int i2;
        i2 = dim << 1;
        b_j = 1;
        for (int pEnd{dim + 1}; pEnd < i + 1; pEnd = qEnd + dim) {
          int kEnd;
          int p;
          int q;
          p = b_j;
          q = pEnd;
          qEnd = b_j + i2;
          if (qEnd > i + 1) {
            qEnd = i + 1;
          }
          k = 0;
          kEnd = qEnd - b_j;
          while (k + 1 <= kEnd) {
            int b_i2;
            i1 = iidx[q - 1];
            b_i2 = iidx[p - 1];
            if (sortLE(vwork, b_i2, i1)) {
              iwork[k] = b_i2;
              p++;
              if (p == pEnd) {
                while (q < qEnd) {
                  k++;
                  iwork[k] = iidx[q - 1];
                  q++;
                }
              }
            } else {
              iwork[k] = i1;
              q++;
              if (q == qEnd) {
                while (p < pEnd) {
                  k++;
                  iwork[k] = iidx[p - 1];
                  p++;
                }
              }
            }
            k++;
          }
          for (k = 0; k < kEnd; k++) {
            iidx[(b_j + k) - 1] = iwork[k];
          }
          b_j = qEnd;
        }
        dim = i2;
      }
      xwork.set_size(vwork.size(0));
      for (k = 0; k <= n - 2; k++) {
        xwork[k] = vwork[k];
      }
      for (k = 0; k <= n - 2; k++) {
        vwork[k] = xwork[iidx[k] - 1];
      }
    }
    for (k = 0; k <= vlen; k++) {
      i = j + k * vstride;
      x[i] = vwork[k];
      idx[i] = iidx[k];
    }
  }
}

} // namespace internal
} // namespace coder

// End of code generation (sort.cpp)
