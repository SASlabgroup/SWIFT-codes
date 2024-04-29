//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_SFdissipation_onboard_api.cpp
//
// Code generation for function 'SFdissipation_onboard'
//

// Include files
#include "_coder_SFdissipation_onboard_api.h"
#include "_coder_SFdissipation_onboard_mex.h"
#include "coder_array_mex.h"

// Variable Definitions
emlrtCTX emlrtRootTLSGlobal{nullptr};

emlrtContext emlrtContextGlobal{
    true,                                                 // bFirstTime
    false,                                                // bInitialized
    131642U,                                              // fVersionInfo
    nullptr,                                              // fErrorFunction
    "SFdissipation_onboard",                              // fFunctionName
    nullptr,                                              // fRTCallStack
    false,                                                // bDebugMode
    {2045744189U, 2170104910U, 2743257031U, 4284093946U}, // fSigWrd
    nullptr                                               // fSigMem
};

// Function Declarations
static void b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret);

static real_T b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *rmin,
                                 const char_T *identifier);

static real_T b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId);

static void b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<char_T, 2U> &ret);

static const mxArray *b_emlrt_marshallOut(const real_T u[128]);

static real_T (*c_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId))[128];

static real_T d_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *w,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y);

static real_T (*emlrt_marshallIn(const emlrtStack &sp, const mxArray *z,
                                 const char_T *identifier))[128];

static real_T (*emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId))[128];

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *fittype,
                             const char_T *identifier,
                             coder::array<char_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<char_T, 2U> &y);

static const mxArray *emlrt_marshallOut(const real_T u[128]);

static const mxArray *emlrt_marshallOut(const struct0_T &u);

// Function Definitions
static void b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret)
{
  static const int32_T dims[2]{128, -1};
  int32_T iv[2];
  boolean_T bv[2]{false, true};
  emlrtCheckVsBuiltInR2012b((emlrtConstCTX)&sp, msgId, src, "double", false, 2U,
                            (const void *)&dims[0], &bv[0], &iv[0]);
  ret.prealloc(iv[0] * iv[1]);
  ret.set_size(iv[0], iv[1]);
  ret.set(static_cast<real_T *>(emlrtMxGetData(src)), ret.size(0), ret.size(1));
  emlrtDestroyArray(&src);
}

static real_T b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *rmin,
                                 const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  real_T y;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(sp, emlrtAlias(rmin), &thisId);
  emlrtDestroyArray(&rmin);
  return y;
}

static real_T b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = d_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<char_T, 2U> &ret)
{
  static const int32_T dims[2]{1, -1};
  int32_T iv[2];
  boolean_T bv[2]{false, true};
  emlrtCheckVsBuiltInR2012b((emlrtConstCTX)&sp, msgId, src, "char", false, 2U,
                            (const void *)&dims[0], &bv[0], &iv[0]);
  ret.set_size(iv[0], iv[1]);
  emlrtImportArrayR2015b((emlrtConstCTX)&sp, src, &ret[0], 1, false);
  emlrtDestroyArray(&src);
}

static const mxArray *b_emlrt_marshallOut(const real_T u[128])
{
  static const int32_T iv[2]{1, 128};
  const mxArray *m;
  const mxArray *y;
  real_T *pData;
  y = nullptr;
  m = emlrtCreateNumericArray(2, (const void *)&iv[0], mxDOUBLE_CLASS, mxREAL);
  pData = emlrtMxGetPr(m);
  for (int32_T i{0}; i < 128; i++) {
    pData[i] = u[i];
  }
  emlrtAssign(&y, m);
  return y;
}

static real_T (*c_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId))[128]
{
  static const int32_T dims{128};
  real_T(*ret)[128];
  int32_T i;
  boolean_T b{false};
  emlrtCheckVsBuiltInR2012b((emlrtConstCTX)&sp, msgId, src, "double", false, 1U,
                            (const void *)&dims, &b, &i);
  ret = (real_T(*)[128])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real_T d_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims{0};
  real_T ret;
  emlrtCheckBuiltInR2012b((emlrtConstCTX)&sp, msgId, src, "double", false, 0U,
                          (const void *)&dims);
  ret = *static_cast<real_T *>(emlrtMxGetData(src));
  emlrtDestroyArray(&src);
  return ret;
}

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *w,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(w), &thisId, y);
  emlrtDestroyArray(&w);
}

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static real_T (*emlrt_marshallIn(const emlrtStack &sp, const mxArray *z,
                                 const char_T *identifier))[128]
{
  emlrtMsgIdentifier thisId;
  real_T(*y)[128];
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = emlrt_marshallIn(sp, emlrtAlias(z), &thisId);
  emlrtDestroyArray(&z);
  return y;
}

static real_T (*emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId))[128]
{
  real_T(*y)[128];
  y = c_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *fittype,
                             const char_T *identifier,
                             coder::array<char_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(fittype), &thisId, y);
  emlrtDestroyArray(&fittype);
}

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<char_T, 2U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static const mxArray *emlrt_marshallOut(const real_T u[128])
{
  static const int32_T iv[2]{0, 0};
  static const int32_T iv1[2]{1, 128};
  const mxArray *m;
  const mxArray *y;
  y = nullptr;
  m = emlrtCreateNumericArray(2, (const void *)&iv[0], mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m, &iv1[0], 2);
  emlrtAssign(&y, m);
  return y;
}

static const mxArray *emlrt_marshallOut(const struct0_T &u)
{
  static const char_T *sv[6]{"mspe", "slope", "epserr", "A", "B", "N"};
  const mxArray *y;
  y = nullptr;
  emlrtAssign(&y, emlrtCreateStructMatrix(1, 1, 6, (const char_T **)&sv[0]));
  emlrtSetFieldR2017b(y, 0, "mspe", b_emlrt_marshallOut(u.mspe), 0);
  emlrtSetFieldR2017b(y, 0, "slope", b_emlrt_marshallOut(u.slope), 1);
  emlrtSetFieldR2017b(y, 0, "epserr", b_emlrt_marshallOut(u.epserr), 2);
  emlrtSetFieldR2017b(y, 0, "A", b_emlrt_marshallOut(u.A), 3);
  emlrtSetFieldR2017b(y, 0, "B", b_emlrt_marshallOut(u.B), 4);
  emlrtSetFieldR2017b(y, 0, "N", b_emlrt_marshallOut(u.N), 5);
  return y;
}

void SFdissipation_onboard_api(const mxArray *const prhs[7], int32_T nlhs,
                               const mxArray *plhs[2])
{
  coder::array<real_T, 2U> w;
  coder::array<char_T, 2U> avgtype;
  coder::array<char_T, 2U> fittype;
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  struct0_T qual;
  real_T(*eps)[128];
  real_T(*z)[128];
  real_T nzfit;
  real_T rmax;
  real_T rmin;
  st.tls = emlrtRootTLSGlobal;
  eps = (real_T(*)[128])mxMalloc(sizeof(real_T[128]));
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  // Marshall function inputs
  w.no_free();
  emlrt_marshallIn(st, emlrtAlias(prhs[0]), "w", w);
  z = emlrt_marshallIn(st, emlrtAlias(prhs[1]), "z");
  rmin = b_emlrt_marshallIn(st, emlrtAliasP(prhs[2]), "rmin");
  rmax = b_emlrt_marshallIn(st, emlrtAliasP(prhs[3]), "rmax");
  nzfit = b_emlrt_marshallIn(st, emlrtAliasP(prhs[4]), "nzfit");
  emlrt_marshallIn(st, emlrtAliasP(prhs[5]), "fittype", fittype);
  emlrt_marshallIn(st, emlrtAliasP(prhs[6]), "avgtype", avgtype);
  // Invoke the target function
  SFdissipation_onboard(w, *z, rmin, rmax, nzfit, fittype, avgtype, *eps,
                        &qual);
  // Marshall function outputs
  plhs[0] = emlrt_marshallOut(*eps);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOut(qual);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

void SFdissipation_onboard_atexit()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  SFdissipation_onboard_xil_terminate();
  SFdissipation_onboard_xil_shutdown();
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void SFdissipation_onboard_initialize()
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

void SFdissipation_onboard_terminate()
{
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

// End of code generation (_coder_SFdissipation_onboard_api.cpp)
