//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// processSIGburst_onboard_initialize.cpp
//
// Code generation for function 'processSIGburst_onboard_initialize'
//

// Include files
#include "processSIGburst_onboard_initialize.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "omp.h"

// Function Definitions
void processSIGburst_onboard_initialize()
{
  omp_init_nest_lock(&processSIGburst_onboard_nestLockGlobal);
  isInitialized_processSIGburst_onboard = true;
}

// End of code generation (processSIGburst_onboard_initialize.cpp)
