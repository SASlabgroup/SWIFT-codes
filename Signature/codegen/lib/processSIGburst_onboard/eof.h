//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eof.h
//
// Code generation for function 'eof'
//

#ifndef EOF_H
#define EOF_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
void eof(coder::array<double, 2U> &X, creal_T EOFs[16384],
         coder::array<creal_T, 2U> &alpha, double Xm[128], creal_T E[128]);

#endif
// End of code generation (eof.h)
