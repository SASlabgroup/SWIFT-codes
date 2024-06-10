//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// SortedBuffer.h
//
// Code generation for function 'SortedBuffer'
//

#pragma once

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include "covrt.h"
#include "emlrt.h"
#include "mex.h"
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>

// Type Definitions
namespace coder {
namespace internal {
class SortedBuffer {
public:
  void insert(const emlrtStack &sp, real_T x);
  void replace(const emlrtStack &sp, real_T xold, real_T xnew);
  void b_remove(const emlrtStack &sp, real_T x);

private:
  int32_T locateElement(real_T x) const;

public:
  array<real_T, 1U> buf;
  int32_T nbuf;
  boolean_T includenans;
  int32_T nnans;
};

} // namespace internal
} // namespace coder

// End of code generation (SortedBuffer.h)
