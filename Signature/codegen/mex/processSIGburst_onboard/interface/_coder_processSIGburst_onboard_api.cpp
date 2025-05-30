//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_processSIGburst_onboard_api.cpp
//
// Code generation for function '_coder_processSIGburst_onboard_api'
//

// Include files
#include "_coder_processSIGburst_onboard_api.h"
#include "processSIGburst_onboard.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Declarations
static void b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret);

static real_T b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

static void b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<char_T, 2U> &ret);

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *wraw,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y);

static real_T emlrt_marshallIn(const emlrtStack &sp, const mxArray *cs,
                               const char_T *identifier);

static real_T emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId);

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *avgtype,
                             const char_T *identifier,
                             coder::array<char_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<char_T, 2U> &y);

static const mxArray *emlrt_marshallOut(const coder::array<real_T, 2U> &u);

// Function Definitions
static void b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret)
{
  static const int32_T dims[2]{-1, -1};
  int32_T iv[2];
  boolean_T bv[2]{true, true};
  emlrtCheckVsBuiltInR2012b((emlrtConstCTX)&sp, msgId, src, "double", false, 2U,
                            (const void *)&dims[0], &bv[0], &iv[0]);
  ret.prealloc(iv[0] * iv[1]);
  ret.set_size(static_cast<emlrtRTEInfo *>(nullptr), &sp, iv[0], iv[1]);
  ret.set(static_cast<real_T *>(emlrtMxGetData(src)), ret.size(0), ret.size(1));
  emlrtDestroyArray(&src);
}

static real_T b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
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

static void b_emlrt_marshallIn(const emlrtStack &sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<char_T, 2U> &ret)
{
  static const int32_T dims[2]{1, -1};
  int32_T iv[2];
  boolean_T bv[2]{false, true};
  emlrtCheckVsBuiltInR2012b((emlrtConstCTX)&sp, msgId, src, "char", false, 2U,
                            (const void *)&dims[0], &bv[0], &iv[0]);
  ret.set_size(static_cast<emlrtRTEInfo *>(nullptr), &sp, iv[0], iv[1]);
  emlrtImportArrayR2015b((emlrtConstCTX)&sp, src, &ret[0], 1, false);
  emlrtDestroyArray(&src);
}

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *wraw,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(wraw), &thisId, y);
  emlrtDestroyArray(&wraw);
}

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static real_T emlrt_marshallIn(const emlrtStack &sp, const mxArray *cs,
                               const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  real_T y;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = emlrt_marshallIn(sp, emlrtAlias(cs), &thisId);
  emlrtDestroyArray(&cs);
  return y;
}

static real_T emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = b_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *avgtype,
                             const char_T *identifier,
                             coder::array<char_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(avgtype), &thisId, y);
  emlrtDestroyArray(&avgtype);
}

static void emlrt_marshallIn(const emlrtStack &sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<char_T, 2U> &y)
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

void processSIGburst_onboard_api(const mxArray *const prhs[10],
                                 const mxArray **plhs)
{
  coder::array<real_T, 2U> eps;
  coder::array<real_T, 2U> wraw;
  coder::array<char_T, 2U> avgtype;
  coder::array<char_T, 2U> fittype;
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  real_T bz;
  real_T cs;
  real_T dz;
  real_T neoflp;
  real_T nzfit;
  real_T rmax;
  real_T rmin;
  st.tls = emlrtRootTLSGlobal;
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  // Marshall function inputs
  wraw.no_free();
  emlrt_marshallIn(st, emlrtAlias(prhs[0]), "wraw", wraw);
  cs = emlrt_marshallIn(st, emlrtAliasP(prhs[1]), "cs");
  dz = emlrt_marshallIn(st, emlrtAliasP(prhs[2]), "dz");
  bz = emlrt_marshallIn(st, emlrtAliasP(prhs[3]), "bz");
  neoflp = emlrt_marshallIn(st, emlrtAliasP(prhs[4]), "neoflp");
  rmin = emlrt_marshallIn(st, emlrtAliasP(prhs[5]), "rmin");
  rmax = emlrt_marshallIn(st, emlrtAliasP(prhs[6]), "rmax");
  nzfit = emlrt_marshallIn(st, emlrtAliasP(prhs[7]), "nzfit");
  emlrt_marshallIn(st, emlrtAliasP(prhs[8]), "avgtype", avgtype);
  emlrt_marshallIn(st, emlrtAliasP(prhs[9]), "fittype", fittype);
  // Invoke the target function
  processSIGburst_onboard(&st, wraw, cs, dz, bz, neoflp, rmin, rmax, nzfit,
                          avgtype, fittype, eps);
  // Marshall function outputs
  eps.no_free();
  *plhs = emlrt_marshallOut(eps);
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

// End of code generation (_coder_processSIGburst_onboard_api.cpp)
