//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_NEDwaves_mex.cpp
//
// Code generation for function 'NEDwaves'
//

// Include files
#include "_coder_NEDwaves_mex.h"
#include "_coder_NEDwaves_api.h"

// Function Definitions
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs,
                 const mxArray *prhs[])
{
  mexAtExit(&NEDwaves_atexit);
  // Module initialization.
  NEDwaves_initialize();
  // Dispatch the entry-point.
  unsafe_NEDwaves_mexFunction(nlhs, plhs, nrhs, prhs);
  // Module termination.
  NEDwaves_terminate();
}

emlrtCTX mexFunctionCreateRootTLS()
{
  emlrtCreateRootTLSR2022a(&emlrtRootTLSGlobal, &emlrtContextGlobal, nullptr, 1,
                           nullptr, (const char_T *)"UTF-8", true);
  return emlrtRootTLSGlobal;
}

void unsafe_NEDwaves_mexFunction(int32_T nlhs, mxArray *plhs[10], int32_T nrhs,
                                 const mxArray *prhs[4])
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  const mxArray *outputs[10];
  int32_T b_nlhs;
  st.tls = emlrtRootTLSGlobal;
  // Check for proper number of arguments.
  if (nrhs != 4) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 4, 4,
                        8, "NEDwaves");
  }
  if (nlhs > 10) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 8,
                        "NEDwaves");
  }
  // Call the function.
  NEDwaves_api(prhs, nlhs, outputs);
  // Copy over outputs to the caller.
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }
  emlrtReturnArrays(b_nlhs, &plhs[0], &outputs[0]);
}

// End of code generation (_coder_NEDwaves_mex.cpp)
