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
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
void SortedBuffer::insert(double x)
{
  int i;
  int i1;
  if (this->nbuf >= this->buf.size(0)) {
    i = this->buf.size(0);
    this->buf.set_size(i + 256);
    for (i1 = 0; i1 < 256; i1++) {
      this->buf[i + i1] = 0.0;
    }
  }
  if (!std::isnan(x)) {
    if (this->nbuf == 0) {
      this->buf[0] = x;
      this->nbuf = 1;
    } else {
      int b_i;
      b_i = this->locateElement(x);
      if (b_i == 0) {
        i = this->nbuf;
        for (int k{i}; k >= 1; k--) {
          this->buf[k] = this->buf[k - 1];
        }
        this->buf[0] = x;
        this->nbuf++;
      } else if (b_i >= this->nbuf) {
        this->nbuf++;
        this->buf[this->nbuf - 1] = x;
      } else {
        i = this->nbuf;
        i1 = b_i + 1;
        for (int k{i}; k >= i1; k--) {
          this->buf[k] = this->buf[k - 1];
        }
        this->buf[b_i] = x;
        this->nbuf++;
      }
    }
  }
}

int SortedBuffer::locateElement(double x) const
{
  int i;
  if ((this->nbuf == 0) || (x < this->buf[0])) {
    i = 0;
  } else if (x < this->buf[this->nbuf - 1]) {
    int ip1;
    int upper;
    i = 1;
    ip1 = 2;
    upper = this->nbuf;
    while (upper > ip1) {
      int m;
      m = (i + upper) >> 1;
      if (x < this->buf[m - 1]) {
        upper = m;
      } else {
        i = m;
        ip1 = m + 1;
      }
    }
  } else {
    i = this->nbuf;
  }
  return i;
}

void SortedBuffer::replace(double xold, double xnew)
{
  if (std::isnan(xold)) {
    this->insert(xnew);
  } else if (std::isnan(xnew)) {
    if (!std::isnan(xold)) {
      if (this->nbuf == 1) {
        if (xold == this->buf[0]) {
          this->nbuf = 0;
        }
      } else {
        int iold;
        iold = this->locateElement(xold);
        if ((iold > 0) && (xold == this->buf[iold - 1])) {
          int i;
          i = iold + 1;
          iold = this->nbuf;
          for (int k{i}; k <= iold; k++) {
            this->buf[k - 2] = this->buf[k - 1];
          }
          this->nbuf--;
        }
      }
    }
  } else {
    int iold;
    iold = this->locateElement(xold);
    if ((iold > 0) && (this->buf[iold - 1] == xold)) {
      int inew;
      inew = this->locateElement(xnew);
      if (iold <= inew) {
        int i;
        i = inew - 1;
        for (int k{iold}; k <= i; k++) {
          this->buf[k - 1] = this->buf[k];
        }
        this->buf[inew - 1] = xnew;
      } else if (iold == inew + 1) {
        this->buf[iold - 1] = xnew;
      } else {
        int i;
        i = inew + 2;
        for (int k{iold}; k >= i; k--) {
          this->buf[k - 1] = this->buf[k - 2];
        }
        this->buf[inew] = xnew;
      }
    } else {
      this->insert(xnew);
    }
  }
}

} // namespace internal
} // namespace coder

// End of code generation (SortedBuffer.cpp)
