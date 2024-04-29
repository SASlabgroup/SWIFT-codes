//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eig.h
//
// Code generation for function 'eig'
//

#ifndef EIG_H
#define EIG_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
void eig(const ::coder::array<double, 2U> &A, ::coder::array<creal_T, 2U> &V,
         ::coder::array<creal_T, 1U> &D);

}

#endif
// End of code generation (eig.h)
