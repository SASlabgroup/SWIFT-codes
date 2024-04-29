//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// permute.h
//
// Code generation for function 'permute'
//

#ifndef PERMUTE_H
#define PERMUTE_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
void b_permute(const ::coder::array<double, 3U> &a,
               ::coder::array<double, 3U> &b);

void permute(const ::coder::array<double, 3U> &a,
             ::coder::array<double, 3U> &b);

} // namespace coder

#endif
// End of code generation (permute.h)
