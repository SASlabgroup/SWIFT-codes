//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// div.h
//
// Code generation for function 'div'
//

#ifndef DIV_H
#define DIV_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
void b_binary_expand_op(coder::array<double, 2U> &in1,
                        const coder::array<double, 2U> &in2,
                        const coder::array<double, 2U> &in3);

void b_binary_expand_op(coder::array<double, 2U> &in1,
                        const coder::array<creal_T, 2U> &in2,
                        const coder::array<double, 2U> &in3);

void b_rdivide(coder::array<double, 2U> &in1,
               const coder::array<double, 2U> &in2);

void binary_expand_op(coder::array<double, 2U> &in1,
                      const coder::array<creal_T, 2U> &in2);

void binary_expand_op(coder::array<double, 2U> &in1,
                      const coder::array<double, 2U> &in2,
                      const coder::array<double, 2U> &in3);

void binary_expand_op(coder::array<double, 2U> &in1,
                      const coder::array<creal_T, 2U> &in2,
                      const coder::array<double, 2U> &in3);

void rdivide(coder::array<double, 2U> &in1,
             const coder::array<double, 2U> &in2);

#endif
// End of code generation (div.h)
