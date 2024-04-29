//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xdlaln2.h
//
// Code generation for function 'xdlaln2'
//

#ifndef XDLALN2_H
#define XDLALN2_H

// Include files
#include "rtwtypes.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
double xdlaln2(int na, int nw, double smin, const double A[16384], int ia0,
               const double B[384], int ib0, double wr, double wi, double X[4],
               double &xnorm);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xdlaln2.h)
