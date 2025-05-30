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
#include "_coder_processSIGburst_onboard_mex.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"

// Function Declarations
static void processSIGburst_onboard_once();

// Function Definitions
static void processSIGburst_onboard_once()
{
  mex_InitInfAndNan();
  // Allocate instance data
  covrtAllocateInstanceData(&emlrtCoverageInstance);
  // Initialize Coverage Information
  covrtScriptInit(&emlrtCoverageInstance,
                  "C:\\Users\\Kristin "
                  "Zeiden\\GitHub\\MATLAB\\SWIFT-"
                  "codes\\Signature\\processSIGburst_onboard.m",
                  0U, 1U, 15U, 7U, 0U, 0U, 0U, 2U, 0U, 0U, 0U);
  // Initialize Function Information
  covrtFcnInit(&emlrtCoverageInstance, 0U, 0U, "processSIGburst_onboard", 0, -1,
               4299);
  // Initialize Basic Block Information
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 14U, 4283, -1, 4298);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 13U, 4210, -1, 4244);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 12U, 3865, -1, 4115);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 11U, 3662, -1, 3761);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 10U, 3440, -1, 3533);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 9U, 3189, -1, 3267);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 8U, 3159, -1, 3168);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 7U, 2826, -1, 3100);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 6U, 2722, -1, 2770);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 5U, 2553, -1, 2594);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 4U, 2479, -1, 2507);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 3U, 1338, -1, 2360);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 2U, 1168, -1, 1245);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 1U, 1107, -1, 1138);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 0U, 584, -1, 1078);
  // Initialize If Information
  covrtIfInit(&emlrtCoverageInstance, 0U, 0U, 1143, 1163, -1, 1254);
  covrtIfInit(&emlrtCoverageInstance, 0U, 1U, 2449, 2474, 2512, 2675);
  covrtIfInit(&emlrtCoverageInstance, 0U, 2U, 2512, 2544, 2599, 2675);
  covrtIfInit(&emlrtCoverageInstance, 0U, 3U, 3105, 3116, 3331, 4203);
  covrtIfInit(&emlrtCoverageInstance, 0U, 4U, 3331, 3357, 3547, 4203);
  covrtIfInit(&emlrtCoverageInstance, 0U, 5U, 3547, 3578, 3779, 4203);
  covrtIfInit(&emlrtCoverageInstance, 0U, 6U, 3779, 3807, 4124, 4203);
  // Initialize MCDC Information
  // Initialize For Information
  covrtForInit(&emlrtCoverageInstance, 0U, 0U, 1079, 1098, 1258);
  covrtForInit(&emlrtCoverageInstance, 0U, 1U, 2771, 2793, 4254);
  // Initialize While Information
  // Initialize Switch Information
  // Start callback for coverage engine
  covrtScriptStart(&emlrtCoverageInstance, 0U);
  // Allocate instance data
  covrtAllocateInstanceData(&emlrtCoverageInstance);
  // Initialize Coverage Information
  covrtScriptInit(
      &emlrtCoverageInstance,
      "C:\\Users\\Kristin "
      "Zeiden\\Dropbox\\MATLAB\\Functions\\CTDProcessing\\ctd_proc2\\nanmean.m",
      1U, 1U, 3U, 1U, 0U, 0U, 0U, 0U, 0U, 0U, 0U);
  // Initialize Function Information
  covrtFcnInit(&emlrtCoverageInstance, 1U, 0U, "nanmean", 0, -1, 1150);
  // Initialize Basic Block Information
  covrtBasicBlockInit(&emlrtCoverageInstance, 1U, 2U, 988, -1, 1144);
  covrtBasicBlockInit(&emlrtCoverageInstance, 1U, 1U, 805, -1, 953);
  covrtBasicBlockInit(&emlrtCoverageInstance, 1U, 0U, 674, -1, 703);
  // Initialize If Information
  covrtIfInit(&emlrtCoverageInstance, 1U, 0U, 705, 719, 954, 1148);
  // Initialize MCDC Information
  // Initialize For Information
  // Initialize While Information
  // Initialize Switch Information
  // Start callback for coverage engine
  covrtScriptStart(&emlrtCoverageInstance, 1U);
}

void processSIGburst_onboard_initialize()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2022b(&st);
  emlrtClearAllocCountR2012b(&st, false, 0U, nullptr);
  emlrtEnterRtStackR2012b(&st);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    processSIGburst_onboard_once();
  }
}

// End of code generation (processSIGburst_onboard_initialize.cpp)
