//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// processSIGburst_onboard_terminate.cpp
//
// Code generation for function 'processSIGburst_onboard_terminate'
//

// Include files
#include "processSIGburst_onboard_terminate.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "omp.h"

// Function Definitions
void processSIGburst_onboard_terminate()
{
  omp_destroy_nest_lock(&processSIGburst_onboard_nestLockGlobal);
  isInitialized_processSIGburst_onboard = false;
}

// End of code generation (processSIGburst_onboard_terminate.cpp)
