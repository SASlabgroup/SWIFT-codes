//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzlarf.h
//
// Code generation for function 'xzlarf'
//

#ifndef XZLARF_H
#define XZLARF_H

// Include files
#include "rtwtypes.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
void xzlarf(int m, int n, int iv0, double tau, double C[16384], int ic0,
            double work[128]);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xzlarf.h)
