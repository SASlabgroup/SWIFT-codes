//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mtimes.h
//
// Code generation for function 'mtimes'
//

#ifndef MTIMES_H
#define MTIMES_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace blas {
void b_mtimes(const ::coder::array<double, 2U> &A,
              const ::coder::array<double, 2U> &B, double C[9]);

void mtimes(const ::coder::array<double, 2U> &A, const double B[2],
            ::coder::array<double, 1U> &C);

void mtimes(const ::coder::array<double, 2U> &A,
            const ::coder::array<double, 2U> &B, double C[4]);

} // namespace blas
} // namespace internal
} // namespace coder

#endif
// End of code generation (mtimes.h)
