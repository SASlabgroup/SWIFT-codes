/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_NEDwaves_memlight_mex.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 10-Oct-2023 20:23:55
 */

/* Include Files */
#include "_coder_NEDwaves_memlight_mex.h"
#include "_coder_NEDwaves_memlight_api.h"

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
  mexAtExit(&NEDwaves_memlight_atexit);
  /* Module initialization. */
  NEDwaves_memlight_initialize();
  /* Dispatch the entry-point. */
  unsafe_NEDwaves_memlight_mexFunction(nlhs, plhs, nrhs, prhs);
  /* Module termination. */
  NEDwaves_memlight_terminate();
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
 *                mxArray *plhs[11]
 *                int32_T nrhs
 *                const mxArray *prhs[4]
 * Return Type  : void
 */
void unsafe_NEDwaves_memlight_mexFunction(int32_T nlhs, mxArray *plhs[11],
                                          int32_T nrhs, const mxArray *prhs[4])
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  const mxArray *outputs[11];
  int32_T b_nlhs;
  st.tls = emlrtRootTLSGlobal;
  /* Check for proper number of arguments. */
  if (nrhs != 4) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 4, 4,
                        17, "NEDwaves_memlight");
  }
  if (nlhs > 11) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 17,
                        "NEDwaves_memlight");
  }
  /* Call the function. */
  NEDwaves_memlight_api(prhs, nlhs, outputs);
  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }
  emlrtReturnArrays(b_nlhs, &plhs[0], &outputs[0]);
}

/*
 * File trailer for _coder_NEDwaves_memlight_mex.c
 *
 * [EOF]
 */
