//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// nanmean.cpp
//
// Code generation for function 'nanmean'
//

// Include files
#include "nanmean.h"
#include "combineVectorElements.h"
#include "div.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "sumMatrixIncludeNaN.h"
#include "coder_array.h"
#include "mwmathutil.h"
#include <emmintrin.h>

// Variable Definitions
static emlrtRSInfo
    md_emlrtRSI{
        22,        // lineNo
        "nanmean", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\Dropbox\\MATLAB\\Functions\\CTDProcessing\\ctd_proc2\\nanmean."
        "m" // pathName
    };

static emlrtRSInfo
    nd_emlrtRSI{
        25,        // lineNo
        "nanmean", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\Dropbox\\MATLAB\\Functions\\CTDProcessing\\ctd_proc2\\nanmean."
        "m" // pathName
    };

static emlrtRSInfo od_emlrtRSI{
    20,    // lineNo
    "sum", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\sum.m" // pathName
};

static emlrtRSInfo sd_emlrtRSI{
    41,                 // lineNo
    "sumMatrixColumns", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

static emlrtRSInfo ud_emlrtRSI{
    50,                 // lineNo
    "sumMatrixColumns", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

static emlrtRSInfo vd_emlrtRSI{
    53,                 // lineNo
    "sumMatrixColumns", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

static emlrtBCInfo
    fb_emlrtBCI{
        -1,        // iFirst
        -1,        // iLast
        18,        // lineNo
        3,         // colNo
        "x",       // aName
        "nanmean", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\Dropbox\\MATLAB\\Functions\\CTDProcessing\\ctd_proc2\\nanmean."
        "m", // pName
        0    // checkKind
    };

static emlrtBCInfo
    gb_emlrtBCI{
        -1,        // iFirst
        -1,        // iLast
        23,        // lineNo
        7,         // colNo
        "n",       // aName
        "nanmean", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\Dropbox\\MATLAB\\Functions\\CTDProcessing\\ctd_proc2\\nanmean."
        "m", // pName
        0    // checkKind
    };

static emlrtRTEInfo
    ld_emlrtRTEI{
        17,        // lineNo
        1,         // colNo
        "nanmean", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\Dropbox\\MATLAB\\Functions\\CTDProcessing\\ctd_proc2\\nanmean."
        "m" // pName
    };

static emlrtRTEInfo
    md_emlrtRTEI{
        22,        // lineNo
        5,         // colNo
        "nanmean", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\Dropbox\\MATLAB\\Functions\\CTDProcessing\\ctd_proc2\\nanmean."
        "m" // pName
    };

static emlrtRTEInfo nd_emlrtRTEI{
    35,                    // lineNo
    20,                    // colNo
    "sumMatrixIncludeNaN", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pName
};

static emlrtRTEInfo
    od_emlrtRTEI{
        25,        // lineNo
        9,         // colNo
        "nanmean", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\Dropbox\\MATLAB\\Functions\\CTDProcessing\\ctd_proc2\\nanmean."
        "m" // pName
    };

static emlrtRTEInfo
    pd_emlrtRTEI{
        25,        // lineNo
        5,         // colNo
        "nanmean", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\Dropbox\\MATLAB\\Functions\\CTDProcessing\\ctd_proc2\\nanmean."
        "m" // pName
    };

// Function Definitions
void nanmean(const emlrtStack &sp, coder::array<real_T, 2U> &x,
             coder::array<real_T, 2U> &m)
{
  coder::array<real_T, 2U> n;
  coder::array<int32_T, 2U> nz;
  coder::array<boolean_T, 2U> nans;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  emlrtStack i_st;
  emlrtStack st;
  int32_T inb;
  int32_T ncols;
  int32_T nfb;
  int32_T nleft;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  h_st.prev = &g_st;
  h_st.tls = g_st.tls;
  i_st.prev = &h_st;
  i_st.tls = h_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  covrtLogFcn(&emlrtCoverageInstance, 1, 0);
  covrtLogBasicBlock(&emlrtCoverageInstance, 1, 0);
  // NANMEAN Mean value, ignoring NaNs.
  //    M = NANMEAN(X) returns the sample mean of X, treating NaNs as missing
  //    values.  For vector input, M is the mean value of the non-NaN elements
  //    in X.  For matrix input, M is a row vector containing the mean value of
  //    non-NaN elements in each column.  For N-D arrays, NANMEAN operates
  //    along the first non-singleton dimension.
  //
  //    NANMEAN(X,DIM) takes the mean along dimension DIM of X.
  //
  //    See also MEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.
  //    Copyright 1993-2004 The MathWorks, Inc.
  //    $Revision: 2.13.4.3 $  $Date: 2004/07/28 04:38:41 $
  //  Find NaNs and set them to zero
  nans.set_size(&ld_emlrtRTEI, &sp, x.size(0), x.size(1));
  ncols = x.size(0) * x.size(1);
  for (nleft = 0; nleft < ncols; nleft++) {
    nans[nleft] = muDoubleScalarIsNaN(x[nleft]);
  }
  nfb = ncols - 1;
  for (inb = 0; inb <= nfb; inb++) {
    if (nans[inb]) {
      nleft = x.size(0) * x.size(1) - 1;
      if (inb > nleft) {
        emlrtDynamicBoundsCheckR2012b(inb, 0, nleft, &fb_emlrtBCI,
                                      (emlrtConstCTX)&sp);
      }
      x[inb] = 0.0;
    }
  }
  covrtLogIf(&emlrtCoverageInstance, 1, 0, 0, true);
  covrtLogBasicBlock(&emlrtCoverageInstance, 1, 1);
  //  let sum deal with figuring out which dimension to use
  //  Count up non-NaNs.
  st.site = &md_emlrtRSI;
  for (nleft = 0; nleft < ncols; nleft++) {
    nans[nleft] = !nans[nleft];
  }
  b_st.site = &hd_emlrtRSI;
  if ((nans.size(0) == 1) && (nans.size(1) != 1)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &c_emlrtRTEI,
                                  "Coder:toolbox:autoDimIncompatibility",
                                  "Coder:toolbox:autoDimIncompatibility", 0);
  }
  if ((nans.size(0) == 0) && (nans.size(1) == 0)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &d_emlrtRTEI,
                                  "Coder:toolbox:UnsupportedSpecialEmpty",
                                  "Coder:toolbox:UnsupportedSpecialEmpty", 0);
  }
  c_st.site = &id_emlrtRSI;
  coder::combineVectorElements(c_st, nans, nz);
  n.set_size(&md_emlrtRTEI, &st, 1, nz.size(1));
  ncols = nz.size(1);
  for (nleft = 0; nleft < ncols; nleft++) {
    n[nleft] = nz[nleft];
  }
  nfb = n.size(1) - 1;
  for (inb = 0; inb <= nfb; inb++) {
    if (n[inb] == 0.0) {
      if (inb > n.size(1) - 1) {
        emlrtDynamicBoundsCheckR2012b(inb, 0, n.size(1) - 1, &gb_emlrtBCI,
                                      (emlrtConstCTX)&sp);
      }
      n[inb] = rtNaN;
    }
  }
  //  prevent divideByZero warnings
  //  Sum up non-NaNs, and divide by the number of non-NaNs.
  st.site = &nd_emlrtRSI;
  b_st.site = &nd_emlrtRSI;
  c_st.site = &od_emlrtRSI;
  if ((x.size(0) == 1) && (x.size(1) != 1)) {
    emlrtErrorWithMessageIdR2018a(&c_st, &c_emlrtRTEI,
                                  "Coder:toolbox:autoDimIncompatibility",
                                  "Coder:toolbox:autoDimIncompatibility", 0);
  }
  if ((x.size(0) == 0) && (x.size(1) == 0)) {
    emlrtErrorWithMessageIdR2018a(&c_st, &d_emlrtRTEI,
                                  "Coder:toolbox:UnsupportedSpecialEmpty",
                                  "Coder:toolbox:UnsupportedSpecialEmpty", 0);
  }
  d_st.site = &id_emlrtRSI;
  e_st.site = &pd_emlrtRSI;
  if ((x.size(0) == 0) || (x.size(1) == 0)) {
    m.set_size(&od_emlrtRTEI, &e_st, 1, x.size(1));
    ncols = x.size(1);
    for (nleft = 0; nleft < ncols; nleft++) {
      m[nleft] = 0.0;
    }
  } else {
    f_st.site = &qd_emlrtRSI;
    g_st.site = &rd_emlrtRSI;
    m.set_size(&nd_emlrtRTEI, &g_st, 1, x.size(1));
    ncols = x.size(1) - 1;
    if (x.size(0) < 4096) {
      h_st.site = &sd_emlrtRSI;
      if (x.size(1) > 2147483646) {
        i_st.site = &bc_emlrtRSI;
        coder::check_forloop_overflow_error(i_st);
      }
      for (int32_T col{0}; col <= ncols; col++) {
        h_st.site = &td_emlrtRSI;
        m[col] = coder::sumColumnB(h_st, x, col + 1, x.size(0));
      }
    } else {
      nfb = static_cast<int32_T>(static_cast<uint32_T>(x.size(0)) >> 12);
      inb = nfb << 12;
      nleft = x.size(0) - inb;
      h_st.site = &ud_emlrtRSI;
      if (x.size(1) > 2147483646) {
        i_st.site = &bc_emlrtRSI;
        coder::check_forloop_overflow_error(i_st);
      }
      for (int32_T col{0}; col <= ncols; col++) {
        real_T s;
        s = coder::sumColumnB4(x, col + 1, 1);
        h_st.site = &vd_emlrtRSI;
        for (int32_T ib{2}; ib <= nfb; ib++) {
          s += coder::sumColumnB4(x, col + 1, ((ib - 1) << 12) + 1);
        }
        if (nleft > 0) {
          h_st.site = &wd_emlrtRSI;
          s += coder::sumColumnB(h_st, x, col + 1, nleft, inb + 1);
        }
        m[col] = s;
      }
    }
  }
  b_st.site = &ee_emlrtRSI;
  c_st.site = &fe_emlrtRSI;
  if ((m.size(1) != 1) && (n.size(1) != 1) && (m.size(1) != n.size(1))) {
    emlrtErrorWithMessageIdR2018a(&c_st, &k_emlrtRTEI,
                                  "MATLAB:sizeDimensionsMustMatch",
                                  "MATLAB:sizeDimensionsMustMatch", 0);
  }
  if (m.size(1) == n.size(1)) {
    ncols = m.size(1) - 1;
    m.set_size(&pd_emlrtRTEI, &b_st, 1, m.size(1));
    nfb = (m.size(1) / 2) << 1;
    inb = nfb - 2;
    for (nleft = 0; nleft <= inb; nleft += 2) {
      __m128d r;
      __m128d r1;
      r = _mm_loadu_pd(&m[nleft]);
      r1 = _mm_loadu_pd(&n[nleft]);
      _mm_storeu_pd(&m[nleft], _mm_div_pd(r, r1));
    }
    for (nleft = nfb; nleft <= ncols; nleft++) {
      m[nleft] = m[nleft] / n[nleft];
    }
  } else {
    c_st.site = &vj_emlrtRSI;
    rdivide(c_st, m, n);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

real_T nanmean(real_T x)
{
  real_T b_unnamed_idx_0;
  real_T unnamed_idx_0;
  boolean_T nans;
  covrtLogFcn(&emlrtCoverageInstance, 1, 0);
  covrtLogBasicBlock(&emlrtCoverageInstance, 1, 0);
  // NANMEAN Mean value, ignoring NaNs.
  //    M = NANMEAN(X) returns the sample mean of X, treating NaNs as missing
  //    values.  For vector input, M is the mean value of the non-NaN elements
  //    in X.  For matrix input, M is a row vector containing the mean value of
  //    non-NaN elements in each column.  For N-D arrays, NANMEAN operates
  //    along the first non-singleton dimension.
  //
  //    NANMEAN(X,DIM) takes the mean along dimension DIM of X.
  //
  //    See also MEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.
  //    Copyright 1993-2004 The MathWorks, Inc.
  //    $Revision: 2.13.4.3 $  $Date: 2004/07/28 04:38:41 $
  //  Find NaNs and set them to zero
  nans = muDoubleScalarIsNaN(x);
  unnamed_idx_0 = x;
  if (nans) {
    unnamed_idx_0 = 0.0;
  }
  covrtLogIf(&emlrtCoverageInstance, 1, 0, 0, false);
  covrtLogBasicBlock(&emlrtCoverageInstance, 1, 2);
  //  Count up non-NaNs.
  b_unnamed_idx_0 = !nans;
  if (nans) {
    b_unnamed_idx_0 = rtNaN;
  }
  //  prevent divideByZero warnings
  //  Sum up non-NaNs, and divide by the number of non-NaNs.
  if (muDoubleScalarIsNaN(unnamed_idx_0)) {
    unnamed_idx_0 = 0.0;
  }
  return unnamed_idx_0 / b_unnamed_idx_0;
}

// End of code generation (nanmean.cpp)
