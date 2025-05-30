//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_processSIGburst_onboard_lowmem_mex.cpp
//
// Code generation for function 'processSIGburst_onboard_lowmem'
//

// Include files
#include "_coder_processSIGburst_onboard_lowmem_mex.h"
#include "_coder_processSIGburst_onboard_lowmem_api.h"

// Function Definitions
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs,
                 const mxArray *prhs[])
{
  mexAtExit(&processSIGburst_onboard_lowmem_atexit);
  // Module initialization.
  processSIGburst_onboard_lowmem_initialize();
  // Dispatch the entry-point.
  unsafe_processSIGburst_onboard_lowmem_mexFunction(nlhs, plhs, nrhs, prhs);
  // Module termination.
  processSIGburst_onboard_lowmem_terminate();
}

emlrtCTX mexFunctionCreateRootTLS()
{
  emlrtCreateRootTLSR2022a(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1,
                           NULL, "windows-1252", true);
  return emlrtRootTLSGlobal;
}

void unsafe_processSIGburst_onboard_lowmem_mexFunction(int32_T nlhs,
                                                       mxArray *plhs[1],
                                                       int32_T nrhs,
                                                       const mxArray *prhs[10])
{
  emlrtStack st = {
      NULL, // site
      NULL, // tls
      NULL  // prev
  };
  const mxArray *b_prhs[10];
  const mxArray *outputs;
  st.tls = emlrtRootTLSGlobal;
  // Check for proper number of arguments.
  if (nrhs != 10) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 10, 4,
                        30, "processSIGburst_onboard_lowmem");
  }
  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 30,
                        "processSIGburst_onboard_lowmem");
  }
  // Call the function.
  for (int32_T i = 0; i < 10; i++) {
    b_prhs[i] = prhs[i];
  }
  processSIGburst_onboard_lowmem_api(b_prhs, &outputs);
  // Copy over outputs to the caller.
  emlrtReturnArrays(1, &plhs[0], &outputs);
}

// End of code generation (_coder_processSIGburst_onboard_lowmem_mex.cpp)
