//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// SFdissipation_onboard.h
//
// Code generation for function 'SFdissipation_onboard'
//

#ifndef SFDISSIPATION_ONBOARD_H
#define SFDISSIPATION_ONBOARD_H

// Include files
#include "SFdissipation_onboard_types.h"
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void SFdissipation_onboard(const coder::array<double, 2U> &w,
                                  const double z[128], double rmin, double rmax,
                                  double nzfit,
                                  const coder::array<char, 2U> &fittype,
                                  const coder::array<char, 2U> &avgtype,
                                  double eps[128], struct0_T *qual);

#endif
// End of code generation (SFdissipation_onboard.h)
