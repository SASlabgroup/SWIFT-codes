//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_NEDwaves_api.cpp
//
// Code generation for function 'NEDwaves'
//

// Include files
#include "_coder_NEDwaves_api.h"
#include "_coder_NEDwaves_mex.h"
#include "coder_array_mex.h"

// Variable Definitions
emlrtCTX emlrtRootTLSGlobal{nullptr};

emlrtContext emlrtContextGlobal{
    true,                                                 // bFirstTime
    false,                                                // bInitialized
    131626U,                                              // fVersionInfo
    nullptr,                                              // fErrorFunction
    "NEDwaves",                                           // fFunctionName
    nullptr,                                              // fRTCallStack
    false,                                                // bDebugMode
    {2045744189U, 2170104910U, 2743257031U, 4284093946U}, // fSigWrd
    nullptr                                               // fSigMem
};

// Function Declarations
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real32_T, 1U> &ret);

static real_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *north,
                             const char_T *identifier,
                             coder::array<real32_T, 1U> &y);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real32_T, 1U> &y);

static real_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *fs,
                               const char_T *identifier);

static real_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId);

static const mxArray *emlrt_marshallOut(const real_T u);

static const mxArray *emlrt_marshallOut(const coder::array<real_T, 2U> &u);

// Function Definitions
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real32_T, 1U> &ret)
{
  static const int32_T dims{-1};
  int32_T i;
  const boolean_T b{true};
  emlrtCheckVsBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"single",
                            false, 1U, (void *)&dims, &b, &i);
  ret.prealloc(i);
  ret.set_size(i);
  ret.set(static_cast<real32_T *>(emlrtMxGetData(src)), ret.size(0));
  emlrtDestroyArray(&src);
}

static real_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims{0};
  real_T ret;
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                          false, 0U, (void *)&dims);
  ret = *static_cast<real_T *>(emlrtMxGetData(src));
  emlrtDestroyArray(&src);
  return ret;
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *north,
                             const char_T *identifier,
                             coder::array<real32_T, 1U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(north), &thisId, y);
  emlrtDestroyArray(&north);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real32_T, 1U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static real_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *fs,
                               const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  real_T y;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = emlrt_marshallIn(sp, emlrtAlias(fs), &thisId);
  emlrtDestroyArray(&fs);
  return y;
}

static real_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = b_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static const mxArray *emlrt_marshallOut(const real_T u)
{
  const mxArray *m;
  const mxArray *y;
  y = nullptr;
  m = emlrtCreateDoubleScalar(u);
  emlrtAssign(&y, m);
  return y;
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

void NEDwaves_api(const mxArray *const prhs[4], int32_T nlhs,
                  const mxArray *plhs[10])
{
  coder::array<real_T, 2U> E;
  coder::array<real_T, 2U> a1;
  coder::array<real_T, 2U> a2;
  coder::array<real_T, 2U> b1;
  coder::array<real_T, 2U> b2;
  coder::array<real_T, 2U> check;
  coder::array<real_T, 2U> f;
  coder::array<real32_T, 1U> down;
  coder::array<real32_T, 1U> east;
  coder::array<real32_T, 1U> north;
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  const mxArray *prhs_copy_idx_0;
  const mxArray *prhs_copy_idx_1;
  const mxArray *prhs_copy_idx_2;
  real_T Dp;
  real_T Hs;
  real_T Tp;
  real_T fs;
  st.tls = emlrtRootTLSGlobal;
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  prhs_copy_idx_0 = emlrtProtectR2012b(prhs[0], 0, false, -1);
  prhs_copy_idx_1 = emlrtProtectR2012b(prhs[1], 1, false, -1);
  prhs_copy_idx_2 = emlrtProtectR2012b(prhs[2], 2, false, -1);
  // Marshall function inputs
  north.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs_copy_idx_0), "north", north);
  east.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs_copy_idx_1), "east", east);
  down.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs_copy_idx_2), "down", down);
  fs = emlrt_marshallIn(&st, emlrtAliasP(prhs[3]), "fs");
  // Invoke the target function
  NEDwaves(north, east, down, fs, &Hs, &Tp, &Dp, E, f, a1, b1, a2, b2, check);
  // Marshall function outputs
  plhs[0] = emlrt_marshallOut(Hs);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOut(Tp);
  }
  if (nlhs > 2) {
    plhs[2] = emlrt_marshallOut(Dp);
  }
  if (nlhs > 3) {
    E.no_free();
    plhs[3] = emlrt_marshallOut(E);
  }
  if (nlhs > 4) {
    f.no_free();
    plhs[4] = emlrt_marshallOut(f);
  }
  if (nlhs > 5) {
    a1.no_free();
    plhs[5] = emlrt_marshallOut(a1);
  }
  if (nlhs > 6) {
    b1.no_free();
    plhs[6] = emlrt_marshallOut(b1);
  }
  if (nlhs > 7) {
    a2.no_free();
    plhs[7] = emlrt_marshallOut(a2);
  }
  if (nlhs > 8) {
    b2.no_free();
    plhs[8] = emlrt_marshallOut(b2);
  }
  if (nlhs > 9) {
    check.no_free();
    plhs[9] = emlrt_marshallOut(check);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

void NEDwaves_atexit()
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
  NEDwaves_xil_terminate();
  NEDwaves_xil_shutdown();
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void NEDwaves_initialize()
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

void NEDwaves_terminate()
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

// End of code generation (_coder_NEDwaves_api.cpp)
