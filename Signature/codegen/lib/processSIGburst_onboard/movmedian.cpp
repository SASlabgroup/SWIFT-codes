//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// movmedian.cpp
//
// Code generation for function 'movmedian'
//

// Include files
#include "movmedian.h"
#include "SortedBuffer.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
void movmedian(const ::coder::array<double, 2U> &x, double k,
               ::coder::array<double, 2U> &y)
{
  internal::SortedBuffer s;
  double xold;
  int i;
  int k0;
  int kleft;
  int kright;
  int npages;
  if (k >= 2.147483647E+9) {
    kleft = 128;
    kright = 128;
  } else {
    xold = std::floor(k / 2.0);
    kleft = static_cast<int>(xold);
    kright = static_cast<int>(xold);
    if (static_cast<int>(xold) << 1 == k) {
      kright = static_cast<int>(xold) - 1;
    }
    if (static_cast<int>(xold) > 128) {
      kleft = 128;
    }
    if (kright > 128) {
      kright = 128;
    }
  }
  y.set_size(128, x.size(1));
  k0 = x.size(1) << 7;
  for (i = 0; i < k0; i++) {
    y[i] = 0.0;
  }
  npages = x.size(1);
  for (int p{0}; p < npages; p++) {
    int workspace_ixfirst_tmp;
    workspace_ixfirst_tmp = p << 7;
    if (y.size(1) != 0) {
      double d;
      double xnew;
      int iLeftLast;
      int iRightLast;
      int mid;
      xold = 0.0;
      xnew = 0.0;
      k0 = kleft + kright;
      s.buf.set_size(k0 + 1);
      for (i = 0; i <= k0; i++) {
        s.buf[i] = 0.0;
      }
      s.nbuf = 0;
      s.includenans = false;
      s.nnans = 0;
      if (kleft >= 1) {
        iLeftLast = 1;
      } else {
        iLeftLast = 1 - kleft;
      }
      if (kright + 1 > 128) {
        iRightLast = 128;
      } else {
        iRightLast = kright + 1;
      }
      for (int b_k{iLeftLast}; b_k <= iRightLast; b_k++) {
        s.insert(x[(workspace_ixfirst_tmp + b_k) - 1]);
      }
      if (s.nbuf == 0) {
        y[workspace_ixfirst_tmp] = rtNaN;
      } else {
        mid = s.nbuf >> 1;
        if ((s.nbuf & 1) == 1) {
          y[workspace_ixfirst_tmp] = s.buf[mid];
        } else {
          d = s.buf[mid - 1];
          if (((d < 0.0) != (s.buf[mid] < 0.0)) || std::isinf(d)) {
            y[workspace_ixfirst_tmp] = (d + s.buf[mid]) / 2.0;
          } else {
            y[workspace_ixfirst_tmp] = d + (s.buf[mid] - d) / 2.0;
          }
        }
      }
      if (k0 + 1 > 128) {
        for (int b_k{0}; b_k < 127; b_k++) {
          int k1;
          bool b_remove;
          bool guard1;
          bool insert;
          if (b_k + 2 <= kleft) {
            k1 = 1;
          } else {
            k1 = (b_k - kleft) + 2;
          }
          k0 = (b_k + kright) + 2;
          if (k0 > 128) {
            k0 = 128;
          }
          if (k1 > iLeftLast) {
            xold = x[(workspace_ixfirst_tmp + iLeftLast) - 1];
            b_remove = true;
            iLeftLast = k1;
          } else {
            b_remove = false;
          }
          guard1 = false;
          if (k0 > iRightLast) {
            xnew = x[(workspace_ixfirst_tmp + k0) - 1];
            insert = true;
            iRightLast = k0;
            if (b_remove) {
              s.replace(xold, xnew);
            } else {
              guard1 = true;
            }
          } else {
            insert = false;
            guard1 = true;
          }
          if (guard1) {
            if (insert) {
              s.insert(xnew);
            } else if (b_remove && (!std::isnan(xold))) {
              if (s.nbuf == 1) {
                if (xold == s.buf[0]) {
                  s.nbuf = 0;
                }
              } else {
                k0 = s.locateElement(xold);
                if ((k0 > 0) && (xold == s.buf[k0 - 1])) {
                  int i1;
                  i = k0 + 1;
                  i1 = s.nbuf;
                  for (mid = i; mid <= i1; mid++) {
                    s.buf[mid - 2] = s.buf[mid - 1];
                  }
                  s.nbuf--;
                }
              }
            }
          }
          i = (workspace_ixfirst_tmp + b_k) + 1;
          if (s.nbuf == 0) {
            y[i] = rtNaN;
          } else {
            mid = s.nbuf >> 1;
            if ((s.nbuf & 1) == 1) {
              y[i] = s.buf[mid];
            } else {
              d = s.buf[mid - 1];
              if (((d < 0.0) != (s.buf[mid] < 0.0)) || std::isinf(d)) {
                y[i] = (d + s.buf[mid]) / 2.0;
              } else {
                y[i] = d + (s.buf[mid] - d) / 2.0;
              }
            }
          }
        }
      } else {
        int i1;
        int k1;
        k0 = kleft + 2;
        k1 = 128 - kright;
        i = kleft + 1;
        for (int b_k{2}; b_k <= i; b_k++) {
          s.insert(x[((workspace_ixfirst_tmp + b_k) + kright) - 1]);
          i1 = (workspace_ixfirst_tmp + b_k) - 1;
          if (s.nbuf == 0) {
            y[i1] = rtNaN;
          } else {
            mid = s.nbuf >> 1;
            if ((s.nbuf & 1) == 1) {
              y[i1] = s.buf[mid];
            } else {
              d = s.buf[mid - 1];
              if (((d < 0.0) != (s.buf[mid] < 0.0)) || std::isinf(d)) {
                y[i1] = (d + s.buf[mid]) / 2.0;
              } else {
                y[i1] = d + (s.buf[mid] - d) / 2.0;
              }
            }
          }
        }
        for (int b_k{k0}; b_k <= k1; b_k++) {
          i = (workspace_ixfirst_tmp + b_k) - 1;
          s.replace(x[(i - kleft) - 1], x[i + kright]);
          if (s.nbuf == 0) {
            y[i] = rtNaN;
          } else {
            mid = s.nbuf >> 1;
            if ((s.nbuf & 1) == 1) {
              y[i] = s.buf[mid];
            } else {
              d = s.buf[mid - 1];
              if (((d < 0.0) != (s.buf[mid] < 0.0)) || std::isinf(d)) {
                y[i] = (d + s.buf[mid]) / 2.0;
              } else {
                y[i] = d + (s.buf[mid] - d) / 2.0;
              }
            }
          }
        }
        i = 129 - kright;
        for (int b_k{i}; b_k < 129; b_k++) {
          i1 = workspace_ixfirst_tmp + b_k;
          k1 = (i1 - kleft) - 2;
          if (!std::isnan(x[k1])) {
            if (s.nbuf == 1) {
              if (x[k1] == s.buf[0]) {
                s.nbuf = 0;
              }
            } else {
              k0 = s.locateElement(x[k1]);
              if ((k0 > 0) && (x[k1] == s.buf[k0 - 1])) {
                k1 = k0 + 1;
                k0 = s.nbuf;
                for (mid = k1; mid <= k0; mid++) {
                  s.buf[mid - 2] = s.buf[mid - 1];
                }
                s.nbuf--;
              }
            }
          }
          i1--;
          if (s.nbuf == 0) {
            y[i1] = rtNaN;
          } else {
            mid = s.nbuf >> 1;
            if ((s.nbuf & 1) == 1) {
              y[i1] = s.buf[mid];
            } else {
              d = s.buf[mid - 1];
              if (((d < 0.0) != (s.buf[mid] < 0.0)) || std::isinf(d)) {
                y[i1] = (d + s.buf[mid]) / 2.0;
              } else {
                y[i1] = d + (s.buf[mid] - d) / 2.0;
              }
            }
          }
        }
      }
    }
  }
}

} // namespace coder

// End of code generation (movmedian.cpp)
