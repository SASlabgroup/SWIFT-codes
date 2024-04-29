//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzhgeqz.h
//
// Code generation for function 'xzhgeqz'
//

#ifndef XZHGEQZ_H
#define XZHGEQZ_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
void xzhgeqz(::coder::array<creal_T, 2U> &A, int ilo, int ihi,
             ::coder::array<creal_T, 2U> &Z, int *info,
             ::coder::array<creal_T, 1U> &alpha1,
             ::coder::array<creal_T, 1U> &beta1);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xzhgeqz.h)
