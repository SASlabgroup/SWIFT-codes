//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_eof_api.cpp
//
// Code generation for function 'eof'
//

// Include files
#include "_coder_eof_api.h"
#include "_coder_eof_mex.h"
#include "coder_array_mex.h"

// Variable Definitions
emlrtCTX emlrtRootTLSGlobal{nullptr};

emlrtContext emlrtContextGlobal{
    true,                                                 // bFirstTime
    false,                                                // bInitialized
    131610U,                                              // fVersionInfo
    nullptr,                                              // fErrorFunction
    "eof",                                                // fFunctionName
    nullptr,                                              // fRTCallStack
    false,                                                // bDebugMode
    {2045744189U, 2170104910U, 2743257031U, 4284093946U}, // fSigWrd
    nullptr                                               // fSigMem
};

// Function Declarations
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret);

static const mxArray *b_emlrt_marshallOut(const emlrtStack *sp,
                                          const coder::array<creal_T, 2U> &u);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *X,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y);

static const mxArray *emlrt_marshallOut(const coder::array<real_T, 2U> &u);

static const mxArray *emlrt_marshallOut(const emlrtStack *sp,
                                        const coder::array<creal_T, 2U> &u);

// Function Definitions
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret)
{
  static const int32_T dims[2]{-1, -1};
  int32_T iv[2];
  const boolean_T bv[2]{true, true};
  emlrtCheckVsBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                            false, 2U, (void *)&dims[0], &bv[0], &iv[0]);
  ret.prealloc(iv[0] * iv[1]);
  ret.set_size(iv[0], iv[1]);
  ret.set((real_T *)emlrtMxGetData(src), ret.size(0), ret.size(1));
  emlrtDestroyArray(&src);
}

static const mxArray *b_emlrt_marshallOut(const emlrtStack *sp,
                                          const coder::array<creal_T, 2U> &u)
{
  const mxArray *m;
  const mxArray *y;
  int32_T iv[2];
  y = nullptr;
  iv[0] = 1;
  iv[1] = u.size(1);
  m = emlrtCreateNumericArray(2, &iv[0], mxDOUBLE_CLASS, mxCOMPLEX);
  emlrtExportNumericArrayR2013b((emlrtCTX)sp, m, &u[0], 8);
  emlrtAssign(&y, m);
  return y;
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *X,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(X), &thisId, y);
  emlrtDestroyArray(&X);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static const mxArray *emlrt_marshallOut(const coder::array<real_T, 2U> &u)
{
  static const int32_T iv[2]{0, 0};
  const mxArray *m;
  const mxArray *y;
  y = nullptr;
  m = emlrtCreateNumericArray(2, (const void *)&iv[0], mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m, &(((coder::array<real_T, 2U> *)&u)->data())[0]);
  emlrtSetDimensions((mxArray *)m, ((coder::array<real_T, 2U> *)&u)->size(), 2);
  emlrtAssign(&y, m);
  return y;
}

static const mxArray *emlrt_marshallOut(const emlrtStack *sp,
                                        const coder::array<creal_T, 2U> &u)
{
  const mxArray *m;
  const mxArray *y;
  int32_T iv[2];
  y = nullptr;
  iv[0] = u.size(0);
  iv[1] = u.size(1);
  m = emlrtCreateNumericArray(2, &iv[0], mxDOUBLE_CLASS, mxCOMPLEX);
  emlrtExportNumericArrayR2013b((emlrtCTX)sp, m, &u[0], 8);
  emlrtAssign(&y, m);
  return y;
}

void eof_api(const mxArray *prhs, int32_T nlhs, const mxArray *plhs[4])
{
  coder::array<creal_T, 2U> E;
  coder::array<creal_T, 2U> EOFs;
  coder::array<creal_T, 2U> alpha;
  coder::array<real_T, 2U> X;
  coder::array<real_T, 2U> Xm;
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  const mxArray *prhs_copy_idx_0;
  st.tls = emlrtRootTLSGlobal;
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  prhs_copy_idx_0 = emlrtProtectR2012b(prhs, 0, false, -1);
  // Marshall function inputs
  X.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs_copy_idx_0), "X", X);
  // Invoke the target function
  eof(X, EOFs, alpha, E, Xm);
  // Marshall function outputs
  plhs[0] = emlrt_marshallOut(&st, EOFs);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOut(&st, alpha);
  }
  if (nlhs > 2) {
    plhs[2] = b_emlrt_marshallOut(&st, E);
  }
  if (nlhs > 3) {
    Xm.no_free();
    plhs[3] = emlrt_marshallOut(Xm);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

void eof_atexit()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  eof_xil_terminate();
  eof_xil_shutdown();
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void eof_initialize()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, nullptr);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

void eof_terminate()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

// End of code generation (_coder_eof_api.cpp)
