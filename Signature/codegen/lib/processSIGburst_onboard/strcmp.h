//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// strcmp.h
//
// Code generation for function 'strcmp'
//

#ifndef STRCMP_H
#define STRCMP_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
bool b_strcmp(const ::coder::array<char, 2U> &a);

bool c_strcmp(const ::coder::array<char, 2U> &a);

} // namespace internal
} // namespace coder

#endif
// End of code generation (strcmp.h)
