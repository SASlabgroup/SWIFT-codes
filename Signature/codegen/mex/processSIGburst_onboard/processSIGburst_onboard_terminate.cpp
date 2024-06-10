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
#include "_coder_processSIGburst_onboard_mex.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"

// Function Definitions
void processSIGburst_onboard_atexit()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  // Free instance data
  covrtFreeInstanceData(&emlrtCoverageInstance);
  // Free instance data
  covrtFreeInstanceData(&emlrtCoverageInstance);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void processSIGburst_onboard_terminate()
{
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

// End of code generation (processSIGburst_onboard_terminate.cpp)
