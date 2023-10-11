/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_NEDwaves_memlight_api.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 10-Oct-2023 20:23:55
 */

/* Include Files */
#include "_coder_NEDwaves_memlight_api.h"
#include "_coder_NEDwaves_memlight_mex.h"
#include "rtwhalf.h"

/* Variable Definitions */
emlrtCTX emlrtRootTLSGlobal = NULL;

emlrtContext emlrtContextGlobal = {
    true,                                                 /* bFirstTime */
    false,                                                /* bInitialized */
    131626U,                                              /* fVersionInfo */
    NULL,                                                 /* fErrorFunction */
    "NEDwaves_memlight",                                  /* fFunctionName */
    NULL,                                                 /* fRTCallStack */
    false,                                                /* bDebugMode */
    {2045744189U, 2170104910U, 2743257031U, 4284093946U}, /* fSigWrd */
    NULL                                                  /* fSigMem */
};

/* Function Declarations */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId,
                               emxArray_real32_T *y);

static const mxArray *b_emlrt_marshallOut(const real16_T u[42]);

static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *fs,
                                 const char_T *identifier);

static const mxArray *c_emlrt_marshallOut(const int8_T u[42]);

static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId);

static const mxArray *d_emlrt_marshallOut(const uint8_T u[42]);

static void e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               emxArray_real32_T *ret);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *north,
                             const char_T *identifier, emxArray_real32_T *y);

static const mxArray *emlrt_marshallOut(const real16_T u);

static void emxEnsureCapacity_real32_T(emxArray_real32_T *emxArray,
                                       int32_T oldNumel);

static void emxFree_real32_T(const emlrtStack *sp,
                             emxArray_real32_T **pEmxArray);

static void emxInit_real32_T(const emlrtStack *sp,
                             emxArray_real32_T **pEmxArray);

static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

/* Function Definitions */
/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *u
 *                const emlrtMsgIdentifier *parentId
 *                emxArray_real32_T *y
 * Return Type  : void
 */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId,
                               emxArray_real32_T *y)
{
  e_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

/*
 * Arguments    : const real16_T u[42]
 * Return Type  : const mxArray *
 */
static const mxArray *b_emlrt_marshallOut(const real16_T u[42])
{
  static const int32_T iv[2] = {0, 0};
  static const int32_T iv1[2] = {1, 42};
  const mxArray *m;
  const mxArray *y;
  y = NULL;
  m = emlrtCreateNumericArray(2, (const void *)&iv[0], mxHALF_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m, &iv1[0], 2);
  emlrtAssign(&y, m);
  return y;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *fs
 *                const char_T *identifier
 * Return Type  : real_T
 */
static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *fs,
                                 const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  real_T y;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = d_emlrt_marshallIn(sp, emlrtAlias(fs), &thisId);
  emlrtDestroyArray(&fs);
  return y;
}

/*
 * Arguments    : const int8_T u[42]
 * Return Type  : const mxArray *
 */
static const mxArray *c_emlrt_marshallOut(const int8_T u[42])
{
  static const int32_T iv[2] = {0, 0};
  static const int32_T iv1[2] = {1, 42};
  const mxArray *m;
  const mxArray *y;
  y = NULL;
  m = emlrtCreateNumericArray(2, (const void *)&iv[0], mxINT8_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m, &iv1[0], 2);
  emlrtAssign(&y, m);
  return y;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *u
 *                const emlrtMsgIdentifier *parentId
 * Return Type  : real_T
 */
static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = f_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

/*
 * Arguments    : const uint8_T u[42]
 * Return Type  : const mxArray *
 */
static const mxArray *d_emlrt_marshallOut(const uint8_T u[42])
{
  static const int32_T iv[2] = {0, 0};
  static const int32_T iv1[2] = {1, 42};
  const mxArray *m;
  const mxArray *y;
  y = NULL;
  m = emlrtCreateNumericArray(2, (const void *)&iv[0], mxUINT8_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m, &iv1[0], 2);
  emlrtAssign(&y, m);
  return y;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *src
 *                const emlrtMsgIdentifier *msgId
 *                emxArray_real32_T *ret
 * Return Type  : void
 */
static void e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               emxArray_real32_T *ret)
{
  static const int32_T dims[2] = {1, -1};
  int32_T iv[2];
  int32_T i;
  const boolean_T bv[2] = {false, true};
  emlrtCheckVsBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"single",
                            false, 2U, (void *)&dims[0], &bv[0], &iv[0]);
  ret->allocatedSize = iv[0] * iv[1];
  i = ret->size[0] * ret->size[1];
  ret->size[0] = iv[0];
  ret->size[1] = iv[1];
  emxEnsureCapacity_real32_T(ret, i);
  ret->data = (real32_T *)emlrtMxGetData(src);
  ret->canFreeData = false;
  emlrtDestroyArray(&src);
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *north
 *                const char_T *identifier
 *                emxArray_real32_T *y
 * Return Type  : void
 */
static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *north,
                             const char_T *identifier, emxArray_real32_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  b_emlrt_marshallIn(sp, emlrtAlias(north), &thisId, y);
  emlrtDestroyArray(&north);
}

/*
 * Arguments    : const real16_T u
 * Return Type  : const mxArray *
 */
static const mxArray *emlrt_marshallOut(const real16_T u)
{
  const mxArray *m;
  const mxArray *y;
  y = NULL;
  m = emlrtCreateNumericMatrix(1, 1, mxHALF_CLASS, mxREAL);
  *(real16_T *)emlrtMxGetData(m) = u;
  emlrtAssign(&y, m);
  return y;
}

/*
 * Arguments    : emxArray_real32_T *emxArray
 *                int32_T oldNumel
 * Return Type  : void
 */
static void emxEnsureCapacity_real32_T(emxArray_real32_T *emxArray,
                                       int32_T oldNumel)
{
  int32_T i;
  int32_T newNumel;
  void *newData;
  if (oldNumel < 0) {
    oldNumel = 0;
  }
  newNumel = 1;
  for (i = 0; i < emxArray->numDimensions; i++) {
    newNumel *= emxArray->size[i];
  }
  if (newNumel > emxArray->allocatedSize) {
    i = emxArray->allocatedSize;
    if (i < 16) {
      i = 16;
    }
    while (i < newNumel) {
      if (i > 1073741823) {
        i = MAX_int32_T;
      } else {
        i *= 2;
      }
    }
    newData = emlrtCallocMex((uint32_T)i, sizeof(real32_T));
    if (emxArray->data != NULL) {
      memcpy(newData, emxArray->data, sizeof(real32_T) * oldNumel);
      if (emxArray->canFreeData) {
        emlrtFreeMex(emxArray->data);
      }
    }
    emxArray->data = (real32_T *)newData;
    emxArray->allocatedSize = i;
    emxArray->canFreeData = true;
  }
}

/*
 * Arguments    : const emlrtStack *sp
 *                emxArray_real32_T **pEmxArray
 * Return Type  : void
 */
static void emxFree_real32_T(const emlrtStack *sp,
                             emxArray_real32_T **pEmxArray)
{
  if (*pEmxArray != (emxArray_real32_T *)NULL) {
    if (((*pEmxArray)->data != (real32_T *)NULL) && (*pEmxArray)->canFreeData) {
      emlrtFreeMex((*pEmxArray)->data);
    }
    emlrtFreeMex((*pEmxArray)->size);
    emlrtRemoveHeapReference((emlrtCTX)sp, (void *)pEmxArray);
    emlrtFreeEmxArray(*pEmxArray);
    *pEmxArray = (emxArray_real32_T *)NULL;
  }
}

/*
 * Arguments    : const emlrtStack *sp
 *                emxArray_real32_T **pEmxArray
 * Return Type  : void
 */
static void emxInit_real32_T(const emlrtStack *sp,
                             emxArray_real32_T **pEmxArray)
{
  emxArray_real32_T *emxArray;
  int32_T i;
  *pEmxArray =
      (emxArray_real32_T *)emlrtMallocEmxArray(sizeof(emxArray_real32_T));
  emlrtPushHeapReferenceStackEmxArray((emlrtCTX)sp, true, (void *)pEmxArray,
                                      (void *)&emxFree_real32_T, NULL, NULL,
                                      NULL);
  emxArray = *pEmxArray;
  emxArray->data = (real32_T *)NULL;
  emxArray->numDimensions = 2;
  emxArray->size = (int32_T *)emlrtMallocMex(sizeof(int32_T) * 2U);
  emxArray->allocatedSize = 0;
  emxArray->canFreeData = true;
  for (i = 0; i < 2; i++) {
    emxArray->size[i] = 0;
  }
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *src
 *                const emlrtMsgIdentifier *msgId
 * Return Type  : real_T
 */
static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  real_T ret;
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                          false, 0U, (void *)&dims);
  ret = *(real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

/*
 * Arguments    : const mxArray * const prhs[4]
 *                int32_T nlhs
 *                const mxArray *plhs[11]
 * Return Type  : void
 */
void NEDwaves_memlight_api(const mxArray *const prhs[4], int32_T nlhs,
                           const mxArray *plhs[11])
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  emxArray_real32_T *down;
  emxArray_real32_T *east;
  emxArray_real32_T *north;
  const mxArray *prhs_copy_idx_0;
  const mxArray *prhs_copy_idx_1;
  const mxArray *prhs_copy_idx_2;
  real_T fs;
  real16_T(*E)[42];
  real16_T Dp;
  real16_T Hs;
  real16_T Tp;
  real16_T b_fmax;
  real16_T b_fmin;
  int8_T(*a1)[42];
  int8_T(*a2)[42];
  int8_T(*b1)[42];
  int8_T(*b2)[42];
  uint8_T(*check)[42];
  st.tls = emlrtRootTLSGlobal;
  E = (real16_T(*)[42])mxMalloc(sizeof(real16_T[42]));
  a1 = (int8_T(*)[42])mxMalloc(sizeof(int8_T[42]));
  b1 = (int8_T(*)[42])mxMalloc(sizeof(int8_T[42]));
  a2 = (int8_T(*)[42])mxMalloc(sizeof(int8_T[42]));
  b2 = (int8_T(*)[42])mxMalloc(sizeof(int8_T[42]));
  check = (uint8_T(*)[42])mxMalloc(sizeof(uint8_T[42]));
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  emxInit_real32_T(&st, &north);
  emxInit_real32_T(&st, &east);
  emxInit_real32_T(&st, &down);
  prhs_copy_idx_0 = emlrtProtectR2012b(prhs[0], 0, false, -1);
  prhs_copy_idx_1 = emlrtProtectR2012b(prhs[1], 1, false, -1);
  prhs_copy_idx_2 = emlrtProtectR2012b(prhs[2], 2, false, -1);
  /* Marshall function inputs */
  north->canFreeData = false;
  emlrt_marshallIn(&st, emlrtAlias(prhs_copy_idx_0), "north", north);
  east->canFreeData = false;
  emlrt_marshallIn(&st, emlrtAlias(prhs_copy_idx_1), "east", east);
  down->canFreeData = false;
  emlrt_marshallIn(&st, emlrtAlias(prhs_copy_idx_2), "down", down);
  fs = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[3]), "fs");
  /* Invoke the target function */
  NEDwaves_memlight(north, east, down, fs, &Hs, &Tp, &Dp, *E, &b_fmin, &b_fmax,
                    *a1, *b1, *a2, *b2, *check);
  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(Hs);
  emxFree_real32_T(&st, &down);
  emxFree_real32_T(&st, &east);
  emxFree_real32_T(&st, &north);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOut(Tp);
  }
  if (nlhs > 2) {
    plhs[2] = emlrt_marshallOut(Dp);
  }
  if (nlhs > 3) {
    plhs[3] = b_emlrt_marshallOut(*E);
  }
  if (nlhs > 4) {
    plhs[4] = emlrt_marshallOut(b_fmin);
  }
  if (nlhs > 5) {
    plhs[5] = emlrt_marshallOut(b_fmax);
  }
  if (nlhs > 6) {
    plhs[6] = c_emlrt_marshallOut(*a1);
  }
  if (nlhs > 7) {
    plhs[7] = c_emlrt_marshallOut(*b1);
  }
  if (nlhs > 8) {
    plhs[8] = c_emlrt_marshallOut(*a2);
  }
  if (nlhs > 9) {
    plhs[9] = c_emlrt_marshallOut(*b2);
  }
  if (nlhs > 10) {
    plhs[10] = d_emlrt_marshallOut(*check);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void NEDwaves_memlight_atexit(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  NEDwaves_memlight_xil_terminate();
  NEDwaves_memlight_xil_shutdown();
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void NEDwaves_memlight_initialize(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, NULL);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void NEDwaves_memlight_terminate(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/*
 * File trailer for _coder_NEDwaves_memlight_api.c
 *
 * [EOF]
 */
