//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_SFdissipation_onboard_mex.cpp
//
// Code generation for function 'SFdissipation_onboard'
//

// Include files
#include "_coder_SFdissipation_onboard_mex.h"
#include "_coder_SFdissipation_onboard_api.h"

// Function Definitions
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs,
                 const mxArray *prhs[])
{
  mexAtExit(&SFdissipation_onboard_atexit);
  // Module initialization.
  SFdissipation_onboard_initialize();
  // Dispatch the entry-point.
  unsafe_SFdissipation_onboard_mexFunction(nlhs, plhs, nrhs, prhs);
  // Module termination.
  SFdissipation_onboard_terminate();
}

emlrtCTX mexFunctionCreateRootTLS()
{
  emlrtCreateRootTLSR2022a(&emlrtRootTLSGlobal, &emlrtContextGlobal, nullptr, 1,
                           nullptr, "windows-1252", true);
  return emlrtRootTLSGlobal;
}

void unsafe_SFdissipation_onboard_mexFunction(int32_T nlhs, mxArray *plhs[2],
                                              int32_T nrhs,
                                              const mxArray *prhs[7])
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  const mxArray *b_prhs[7];
  const mxArray *outputs[2];
  int32_T i1;
  st.tls = emlrtRootTLSGlobal;
  // Check for proper number of arguments.
  if (nrhs != 7) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 7, 4,
                        21, "SFdissipation_onboard");
  }
  if (nlhs > 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 21,
                        "SFdissipation_onboard");
  }
  // Call the function.
  for (int32_T i{0}; i < 7; i++) {
    b_prhs[i] = prhs[i];
  }
  SFdissipation_onboard_api(b_prhs, nlhs, outputs);
  // Copy over outputs to the caller.
  if (nlhs < 1) {
    i1 = 1;
  } else {
    i1 = nlhs;
  }
  emlrtReturnArrays(i1, &plhs[0], &outputs[0]);
}

// End of code generation (_coder_SFdissipation_onboard_mex.cpp)
