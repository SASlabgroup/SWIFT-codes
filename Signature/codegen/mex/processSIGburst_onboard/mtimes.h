//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mtimes.h
//
// Code generation for function 'mtimes'
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

// Function Declarations
namespace coder {
namespace internal {
namespace blas {
void b_mtimes(const ::coder::array<real_T, 2U> &A,
              const ::coder::array<real_T, 2U> &B, real_T C[4]);

void b_mtimes(const ::coder::array<real_T, 2U> &A,
              const ::coder::array<real_T, 1U> &B, real_T C[2]);

void mtimes(const emlrtStack &sp, const ::coder::array<creal_T, 2U> &A,
            const ::coder::array<creal_T, 2U> &B,
            ::coder::array<creal_T, 2U> &C);

void mtimes(const emlrtStack &sp, const ::coder::array<real_T, 2U> &A,
            const ::coder::array<real_T, 2U> &B, ::coder::array<real_T, 2U> &C);

void mtimes(const ::coder::array<real_T, 2U> &A,
            const ::coder::array<real_T, 2U> &B, real_T C[9]);

void mtimes(const ::coder::array<real_T, 2U> &A,
            const ::coder::array<real_T, 1U> &B, real_T C[3]);

} // namespace blas
} // namespace internal
} // namespace coder

// End of code generation (mtimes.h)
