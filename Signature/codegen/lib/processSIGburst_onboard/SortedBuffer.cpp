//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// SortedBuffer.cpp
//
// Code generation for function 'SortedBuffer'
//

// Include files
#include "SortedBuffer.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "rt_nonfinite.h"

// Function Definitions
namespace coder {
namespace internal {
void SortedBuffer::insert(double x)
{
  int i;
  int i1;
  if (nbuf >= buf.size(0)) {
    i = buf.size(0);
    buf.set_size(i + 256);
    for (i1 = 0; i1 < 256; i1++) {
      buf[i + i1] = 0.0;
    }
  }
  if (!rtIsNaN(x)) {
    if (nbuf == 0) {
      buf[0] = x;
      nbuf = 1;
    } else {
      int b_i;
      b_i = locateElement(x);
      if (b_i == 0) {
        i = nbuf;
        for (int k = i; k >= 1; k--) {
          buf[k] = buf[k - 1];
        }
        buf[0] = x;
        nbuf++;
      } else if (b_i >= nbuf) {
        nbuf++;
        buf[nbuf - 1] = x;
      } else {
        i = nbuf;
        i1 = b_i + 1;
        for (int k = i; k >= i1; k--) {
          buf[k] = buf[k - 1];
        }
        buf[b_i] = x;
        nbuf++;
      }
    }
  }
}

int SortedBuffer::locateElement(double x) const
{
  int i;
  if ((nbuf == 0) || (x < buf[0])) {
    i = 0;
  } else if (x < buf[nbuf - 1]) {
    int ip1;
    int upper;
    i = 1;
    ip1 = 2;
    upper = nbuf;
    while (upper > ip1) {
      int m;
      m = (i + upper) >> 1;
      if (x < buf[m - 1]) {
        upper = m;
      } else {
        i = m;
        ip1 = m + 1;
      }
    }
  } else {
    i = nbuf;
  }
  return i;
}

void SortedBuffer::replace(double xold, double xnew)
{
  if (rtIsNaN(xold)) {
    insert(xnew);
  } else if (rtIsNaN(xnew)) {
    if (nbuf == 1) {
      if (xold == buf[0]) {
        nbuf = 0;
      }
    } else {
      int iold;
      iold = locateElement(xold);
      if ((iold > 0) && (xold == buf[iold - 1])) {
        int i;
        i = iold + 1;
        iold = nbuf;
        for (int k = i; k <= iold; k++) {
          buf[k - 2] = buf[k - 1];
        }
        nbuf--;
      }
    }
  } else {
    int iold;
    iold = locateElement(xold);
    if ((iold > 0) && (buf[iold - 1] == xold)) {
      int inew;
      inew = locateElement(xnew);
      if (iold <= inew) {
        int i;
        i = inew - 1;
        for (int k = iold; k <= i; k++) {
          buf[k - 1] = buf[k];
        }
        buf[inew - 1] = xnew;
      } else if (iold == inew + 1) {
        buf[iold - 1] = xnew;
      } else {
        int i;
        i = inew + 2;
        for (int k = iold; k >= i; k--) {
          buf[k - 1] = buf[k - 2];
        }
        buf[inew] = xnew;
      }
    } else {
      insert(xnew);
    }
  }
}

} // namespace internal
} // namespace coder

// End of code generation (SortedBuffer.cpp)
