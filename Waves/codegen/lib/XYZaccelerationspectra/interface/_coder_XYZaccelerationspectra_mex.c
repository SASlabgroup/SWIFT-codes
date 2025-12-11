/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_XYZaccelerationspectra_mex.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 11-Dec-2025 06:39:36
 */

/* Include Files */
#include "_coder_XYZaccelerationspectra_mex.h"
#include "_coder_XYZaccelerationspectra_api.h"

/* Function Definitions */
/*
 * Arguments    : int32_T nlhs
 *                mxArray *plhs[]
 *                int32_T nrhs
 *                const mxArray *prhs[]
 * Return Type  : void
 */
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs,
                 const mxArray *prhs[])
{
  mexAtExit(&XYZaccelerationspectra_atexit);
  /* Module initialization. */
  XYZaccelerationspectra_initialize();
  /* Dispatch the entry-point. */
  unsafe_XYZaccelerationspectra_mexFunction(nlhs, plhs, nrhs, prhs);
  /* Module termination. */
  XYZaccelerationspectra_terminate();
}

/*
 * Arguments    : void
 * Return Type  : emlrtCTX
 */
emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLSR2022a(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1,
                           NULL, (const char_T *)"UTF-8", true);
  return emlrtRootTLSGlobal;
}

/*
 * Arguments    : int32_T nlhs
 *                mxArray *plhs[5]
 *                int32_T nrhs
 *                const mxArray *prhs[4]
 * Return Type  : void
 */
void unsafe_XYZaccelerationspectra_mexFunction(int32_T nlhs, mxArray *plhs[5],
                                               int32_T nrhs,
                                               const mxArray *prhs[4])
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  const mxArray *outputs[5];
  int32_T b_nlhs;
  st.tls = emlrtRootTLSGlobal;
  /* Check for proper number of arguments. */
  if (nrhs != 4) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 4, 4,
                        22, "XYZaccelerationspectra");
  }
  if (nlhs > 5) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 22,
                        "XYZaccelerationspectra");
  }
  /* Call the function. */
  XYZaccelerationspectra_api(prhs, nlhs, outputs);
  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }
  emlrtReturnArrays(b_nlhs, &plhs[0], &outputs[0]);
}

/*
 * File trailer for _coder_XYZaccelerationspectra_mex.c
 *
 * [EOF]
 */
