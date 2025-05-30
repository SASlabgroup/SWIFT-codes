//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// SortedBuffer.h
//
// Code generation for function 'SortedBuffer'
//

#ifndef SORTEDBUFFER_H
#define SORTEDBUFFER_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Type Definitions
namespace coder {
namespace internal {
class SortedBuffer {
public:
  int locateElement(double x) const;
  void insert(double x);
  void replace(double xold, double xnew);
  array<double, 1U> buf;
  int nbuf;
  bool includenans;
  int nnans;
};

} // namespace internal
} // namespace coder

#endif
// End of code generation (SortedBuffer.h)
