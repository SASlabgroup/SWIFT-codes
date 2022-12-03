//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// NEDwaves.h
//
// Code generation for function 'NEDwaves'
//

#ifndef NEDWAVES_H
#define NEDWAVES_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void NEDwaves(coder::array<float, 1U> &north,
                     coder::array<float, 1U> &east,
                     coder::array<float, 1U> &down, double fs, double *Hs,
                     double *Tp, double *Dp, coder::array<double, 2U> &E,
                     coder::array<double, 2U> &f, coder::array<double, 2U> &a1,
                     coder::array<double, 2U> &b1, coder::array<double, 2U> &a2,
                     coder::array<double, 2U> &b2,
                     coder::array<double, 2U> &check);

#endif
// End of code generation (NEDwaves.h)
