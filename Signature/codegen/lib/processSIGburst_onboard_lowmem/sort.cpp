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
#include "sortIdx.h"
#include "sortLE.h"
#include "coder_array.h"
#include "rt_nonfinite.h"

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
  int vlen_tmp;
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
  vlen_tmp = i - 1;
  vwork.set_size(i);
  idx.set_size(x.size(0));
  vstride = 1;
  for (k = 0; k <= dim; k++) {
    vstride *= x.size(0);
  }
  for (int j = 0; j < vstride; j++) {
    int i1;
    int n_tmp;
    for (k = 0; k <= vlen_tmp; k++) {
      vwork[k] = x[j + k * vstride];
    }
    i = vwork.size(0);
    n_tmp = vwork.size(0) + 1;
    iidx.set_size(vwork.size(0));
    dim = vwork.size(0);
    for (i1 = 0; i1 < dim; i1++) {
      iidx[i1] = 0;
    }
    if (vwork.size(0) != 0) {
      iwork.set_size(vwork.size(0));
      for (k = 1; k <= vlen_tmp; k += 2) {
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
        for (int pEnd = dim + 1; pEnd < i + 1; pEnd = qEnd + dim) {
          int kEnd;
          int p;
          int q;
          p = b_j;
          q = pEnd;
          qEnd = b_j + i2;
          if (qEnd > i + 1) {
            qEnd = n_tmp;
          }
          k = 0;
          kEnd = qEnd - b_j;
          while (k + 1 <= kEnd) {
            int b_i2;
            i1 = iidx[p - 1];
            b_i2 = iidx[q - 1];
            if (sortLE(vwork, i1, b_i2)) {
              iwork[k] = i1;
              p++;
              if (p == pEnd) {
                while (q < qEnd) {
                  k++;
                  iwork[k] = iidx[q - 1];
                  q++;
                }
              }
            } else {
              iwork[k] = b_i2;
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
      for (k = 0; k <= n_tmp - 2; k++) {
        xwork[k] = vwork[k];
      }
      for (k = 0; k <= n_tmp - 2; k++) {
        vwork[k] = xwork[iidx[k] - 1];
      }
    }
    for (k = 0; k <= vlen_tmp; k++) {
      i = j + k * vstride;
      x[i] = vwork[k];
      idx[i] = iidx[k];
    }
  }
}

void sort(::coder::array<double, 1U> &x, ::coder::array<int, 1U> &idx)
{
  array<double, 1U> b_xwork;
  array<double, 1U> vwork;
  array<double, 1U> xwork;
  array<int, 1U> b_iwork;
  array<int, 1U> iidx;
  array<int, 1U> iwork;
  int dim;
  int i;
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
  for (int k = 0; k <= dim; k++) {
    vstride *= x.size(0);
  }
  for (int b_i = 0; b_i < 1; b_i++) {
    for (int j = 0; j < vstride; j++) {
      for (int k = 0; k <= vlen; k++) {
        vwork[k] = x[j + k * vstride];
      }
      iidx.set_size(vwork.size(0));
      dim = vwork.size(0);
      for (i = 0; i < dim; i++) {
        iidx[i] = 0;
      }
      if (vwork.size(0) != 0) {
        double x4[4];
        int idx4[4];
        int bLen;
        int i1;
        int i2;
        int i3;
        int i4;
        int iidx_tmp;
        int n;
        int wOffset_tmp;
        n = vwork.size(0);
        x4[0] = 0.0;
        idx4[0] = 0;
        x4[1] = 0.0;
        idx4[1] = 0;
        x4[2] = 0.0;
        idx4[2] = 0;
        x4[3] = 0.0;
        idx4[3] = 0;
        iwork.set_size(vwork.size(0));
        dim = vwork.size(0);
        for (i = 0; i < dim; i++) {
          iwork[i] = 0;
        }
        xwork.set_size(vwork.size(0));
        dim = vwork.size(0);
        for (i = 0; i < dim; i++) {
          xwork[i] = 0.0;
        }
        bLen = 0;
        dim = 0;
        for (int k = 0; k < n; k++) {
          if (rtIsNaN(vwork[k])) {
            iidx_tmp = (n - bLen) - 1;
            iidx[iidx_tmp] = k + 1;
            xwork[iidx_tmp] = vwork[k];
            bLen++;
          } else {
            dim++;
            idx4[dim - 1] = k + 1;
            x4[dim - 1] = vwork[k];
            if (dim == 4) {
              double d;
              double d1;
              signed char b_i1;
              signed char b_i2;
              signed char b_i3;
              signed char b_i4;
              dim = k - bLen;
              if (x4[0] <= x4[1]) {
                i1 = 1;
                i2 = 2;
              } else {
                i1 = 2;
                i2 = 1;
              }
              if (x4[2] <= x4[3]) {
                i3 = 3;
                i4 = 4;
              } else {
                i3 = 4;
                i4 = 3;
              }
              d = x4[i3 - 1];
              d1 = x4[i1 - 1];
              if (d1 <= d) {
                d1 = x4[i2 - 1];
                if (d1 <= d) {
                  b_i1 = static_cast<signed char>(i1);
                  b_i2 = static_cast<signed char>(i2);
                  b_i3 = static_cast<signed char>(i3);
                  b_i4 = static_cast<signed char>(i4);
                } else if (d1 <= x4[i4 - 1]) {
                  b_i1 = static_cast<signed char>(i1);
                  b_i2 = static_cast<signed char>(i3);
                  b_i3 = static_cast<signed char>(i2);
                  b_i4 = static_cast<signed char>(i4);
                } else {
                  b_i1 = static_cast<signed char>(i1);
                  b_i2 = static_cast<signed char>(i3);
                  b_i3 = static_cast<signed char>(i4);
                  b_i4 = static_cast<signed char>(i2);
                }
              } else {
                d = x4[i4 - 1];
                if (d1 <= d) {
                  if (x4[i2 - 1] <= d) {
                    b_i1 = static_cast<signed char>(i3);
                    b_i2 = static_cast<signed char>(i1);
                    b_i3 = static_cast<signed char>(i2);
                    b_i4 = static_cast<signed char>(i4);
                  } else {
                    b_i1 = static_cast<signed char>(i3);
                    b_i2 = static_cast<signed char>(i1);
                    b_i3 = static_cast<signed char>(i4);
                    b_i4 = static_cast<signed char>(i2);
                  }
                } else {
                  b_i1 = static_cast<signed char>(i3);
                  b_i2 = static_cast<signed char>(i4);
                  b_i3 = static_cast<signed char>(i1);
                  b_i4 = static_cast<signed char>(i2);
                }
              }
              iidx[dim - 3] = idx4[b_i1 - 1];
              iidx[dim - 2] = idx4[b_i2 - 1];
              iidx[dim - 1] = idx4[b_i3 - 1];
              iidx[dim] = idx4[b_i4 - 1];
              vwork[dim - 3] = x4[b_i1 - 1];
              vwork[dim - 2] = x4[b_i2 - 1];
              vwork[dim - 1] = x4[b_i3 - 1];
              vwork[dim] = x4[b_i4 - 1];
              dim = 0;
            }
          }
        }
        wOffset_tmp = vwork.size(0) - bLen;
        if (dim > 0) {
          signed char perm[4];
          perm[1] = 0;
          perm[2] = 0;
          perm[3] = 0;
          if (dim == 1) {
            perm[0] = 1;
          } else if (dim == 2) {
            if (x4[0] <= x4[1]) {
              perm[0] = 1;
              perm[1] = 2;
            } else {
              perm[0] = 2;
              perm[1] = 1;
            }
          } else if (x4[0] <= x4[1]) {
            if (x4[1] <= x4[2]) {
              perm[0] = 1;
              perm[1] = 2;
              perm[2] = 3;
            } else if (x4[0] <= x4[2]) {
              perm[0] = 1;
              perm[1] = 3;
              perm[2] = 2;
            } else {
              perm[0] = 3;
              perm[1] = 1;
              perm[2] = 2;
            }
          } else if (x4[0] <= x4[2]) {
            perm[0] = 2;
            perm[1] = 1;
            perm[2] = 3;
          } else if (x4[1] <= x4[2]) {
            perm[0] = 2;
            perm[1] = 3;
            perm[2] = 1;
          } else {
            perm[0] = 3;
            perm[1] = 2;
            perm[2] = 1;
          }
          i = static_cast<unsigned char>(dim);
          for (int k = 0; k < i; k++) {
            iidx_tmp = perm[k] - 1;
            i1 = (wOffset_tmp - dim) + k;
            iidx[i1] = idx4[iidx_tmp];
            vwork[i1] = x4[iidx_tmp];
          }
        }
        dim = bLen >> 1;
        for (int k = 0; k < dim; k++) {
          i1 = wOffset_tmp + k;
          i2 = iidx[i1];
          iidx_tmp = (n - k) - 1;
          iidx[i1] = iidx[iidx_tmp];
          iidx[iidx_tmp] = i2;
          vwork[i1] = xwork[iidx_tmp];
          vwork[iidx_tmp] = xwork[i1];
        }
        if ((bLen & 1) != 0) {
          dim += wOffset_tmp;
          vwork[dim] = xwork[dim];
        }
        i1 = 2;
        if (wOffset_tmp > 1) {
          if (vwork.size(0) >= 256) {
            int nBlocks;
            nBlocks = wOffset_tmp >> 8;
            if (nBlocks > 0) {
              for (int b = 0; b < nBlocks; b++) {
                double c_xwork[256];
                int c_iwork[256];
                i4 = (b << 8) - 1;
                for (int b_b = 0; b_b < 6; b_b++) {
                  bLen = 1 << (b_b + 2);
                  n = bLen << 1;
                  i = 256 >> (b_b + 3);
                  for (int k = 0; k < i; k++) {
                    i2 = (i4 + k * n) + 1;
                    for (i1 = 0; i1 < n; i1++) {
                      dim = i2 + i1;
                      c_iwork[i1] = iidx[dim];
                      c_xwork[i1] = vwork[dim];
                    }
                    i3 = 0;
                    i1 = bLen;
                    dim = i2 - 1;
                    int exitg1;
                    do {
                      exitg1 = 0;
                      dim++;
                      if (c_xwork[i3] <= c_xwork[i1]) {
                        iidx[dim] = c_iwork[i3];
                        vwork[dim] = c_xwork[i3];
                        if (i3 + 1 < bLen) {
                          i3++;
                        } else {
                          exitg1 = 1;
                        }
                      } else {
                        iidx[dim] = c_iwork[i1];
                        vwork[dim] = c_xwork[i1];
                        if (i1 + 1 < n) {
                          i1++;
                        } else {
                          dim -= i3;
                          for (i1 = i3 + 1; i1 <= bLen; i1++) {
                            iidx_tmp = dim + i1;
                            iidx[iidx_tmp] = c_iwork[i1 - 1];
                            vwork[iidx_tmp] = c_xwork[i1 - 1];
                          }
                          exitg1 = 1;
                        }
                      }
                    } while (exitg1 == 0);
                  }
                }
              }
              dim = nBlocks << 8;
              i1 = wOffset_tmp - dim;
              if (i1 > 0) {
                merge_block(iidx, vwork, dim, i1, 2, iwork, xwork);
              }
              i1 = 8;
            }
          }
          dim = iwork.size(0);
          b_iwork.set_size(iwork.size(0));
          for (i = 0; i < dim; i++) {
            b_iwork[i] = iwork[i];
          }
          b_xwork.set_size(xwork.size(0));
          dim = xwork.size(0);
          for (i = 0; i < dim; i++) {
            b_xwork[i] = xwork[i];
          }
          merge_block(iidx, vwork, 0, wOffset_tmp, i1, b_iwork, b_xwork);
        }
      }
      for (int k = 0; k <= vlen; k++) {
        i = j + k * vstride;
        x[i] = vwork[k];
        idx[i] = iidx[k];
      }
    }
  }
}

} // namespace internal
} // namespace coder

// End of code generation (sort.cpp)
