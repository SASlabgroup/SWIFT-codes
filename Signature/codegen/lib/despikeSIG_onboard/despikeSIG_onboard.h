//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// despikeSIG_onboard.h
//
// Code generation for function 'despikeSIG_onboard'
//

#ifndef DESPIKESIG_ONBOARD_H
#define DESPIKESIG_ONBOARD_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void despikeSIG_onboard(const coder::array<double, 2U> &wraw,
                               double nfilt, double dspikemax,
                               const coder::array<char, 2U> &filltype,
                               coder::array<double, 2U> &wclean,
                               coder::array<bool, 2U> &ispike);

#endif
// End of code generation (despikeSIG_onboard.h)
