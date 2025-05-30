//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// processSIGburst_onboard.h
//
// Code generation for function 'processSIGburst_onboard'
//

#ifndef PROCESSSIGBURST_ONBOARD_H
#define PROCESSSIGBURST_ONBOARD_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void processSIGburst_onboard(const coder::array<double, 2U> &wraw,
                                    double cs, double dz, double bz,
                                    double neoflp, double rmin, double rmax,
                                    double nzfit,
                                    const coder::array<char, 2U> &avgtype,
                                    const coder::array<char, 2U> &fittype,
                                    coder::array<double, 2U> &eps);

#endif
// End of code generation (processSIGburst_onboard.h)
