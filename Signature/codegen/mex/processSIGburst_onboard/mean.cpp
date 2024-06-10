//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mean.cpp
//
// Code generation for function 'mean'
//

// Include files
#include "mean.h"
#include "div.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "sumMatrixIncludeNaN.h"
#include "coder_array.h"
#include "mwmathutil.h"
#include <emmintrin.h>

// Variable Definitions
static emlrtRSInfo lg_emlrtRSI{
    49,     // lineNo
    "mean", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\mean.m" // pathName
};

static emlrtRSInfo mg_emlrtRSI{
    99,                 // lineNo
    "blockedSummation", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRSInfo rg_emlrtRSI{
    46,     // lineNo
    "mean", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\mean.m" // pathName
};

static emlrtRSInfo sg_emlrtRSI{
    47,     // lineNo
    "mean", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\mean.m" // pathName
};

static emlrtRSInfo tg_emlrtRSI{
    71,                      // lineNo
    "combineVectorElements", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\combin"
    "eVectorElements.m" // pathName
};

static emlrtRSInfo ug_emlrtRSI{
    110,                // lineNo
    "blockedSummation", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRSInfo vg_emlrtRSI{
    173,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRSInfo wg_emlrtRSI{
    190,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRSInfo xg_emlrtRSI{
    192,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRSInfo yg_emlrtRSI{
    204,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRSInfo ah_emlrtRSI{
    207,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRSInfo bh_emlrtRSI{
    225,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRSInfo ch_emlrtRSI{
    227,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRSInfo dh_emlrtRSI{
    238,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

static emlrtRTEInfo bf_emlrtRTEI{
    146,                // lineNo
    24,                 // colNo
    "blockedSummation", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pName
};

static emlrtRTEInfo cf_emlrtRTEI{
    151,                // lineNo
    29,                 // colNo
    "blockedSummation", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pName
};

static emlrtRTEInfo df_emlrtRTEI{
    153,                // lineNo
    23,                 // colNo
    "blockedSummation", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pName
};

static emlrtRTEInfo ef_emlrtRTEI{
    76,                 // lineNo
    9,                  // colNo
    "blockedSummation", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pName
};

static emlrtRTEInfo ff_emlrtRTEI{
    81,                 // lineNo
    9,                  // colNo
    "blockedSummation", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pName
};

static emlrtRTEInfo gf_emlrtRTEI{
    47,     // lineNo
    12,     // colNo
    "mean", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\mean.m" // pName
};

// Function Definitions
namespace coder {
void mean(const emlrtStack &sp, const ::coder::array<real_T, 3U> &x,
          ::coder::array<real_T, 2U> &y)
{
  array<real_T, 1U> bsum;
  array<int32_T, 2U> counts;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  int32_T firstBlockLength;
  int32_T xblockoffset;
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
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  st.site = &rg_emlrtRSI;
  b_st.site = &tg_emlrtRSI;
  if ((x.size(0) == 0) || (x.size(1) == 0) || (x.size(2) == 0)) {
    y.set_size(&ef_emlrtRTEI, &b_st, x.size(0), x.size(1));
    firstBlockLength = x.size(0) * x.size(1);
    for (xblockoffset = 0; xblockoffset < firstBlockLength; xblockoffset++) {
      y[xblockoffset] = 0.0;
    }
    counts.set_size(&ff_emlrtRTEI, &b_st, x.size(0), x.size(1));
    for (xblockoffset = 0; xblockoffset < firstBlockLength; xblockoffset++) {
      counts[xblockoffset] = 0;
    }
  } else {
    int32_T bvstride;
    int32_T ix;
    int32_T lastBlockLength;
    int32_T nblocks;
    int32_T vstride;
    int32_T xoffset;
    c_st.site = &ug_emlrtRSI;
    vstride = x.size(0) * x.size(1);
    bvstride = vstride << 10;
    y.set_size(&bf_emlrtRTEI, &c_st, x.size(0), x.size(1));
    counts.set_size(&cf_emlrtRTEI, &c_st, x.size(0), x.size(1));
    bsum.set_size(&df_emlrtRTEI, &c_st, vstride);
    if (x.size(2) <= 1024) {
      firstBlockLength = x.size(2);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = static_cast<int32_T>(static_cast<uint32_T>(x.size(2)) >> 10);
      lastBlockLength = x.size(2) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    d_st.site = &vg_emlrtRSI;
    if (vstride > 2147483646) {
      e_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(e_st);
    }
    for (int32_T xj{0}; xj < vstride; xj++) {
      if (muDoubleScalarIsNaN(x[xj])) {
        y[xj] = 0.0;
        counts[xj] = 0;
      } else {
        y[xj] = x[xj];
        counts[xj] = 1;
      }
      bsum[xj] = 0.0;
    }
    d_st.site = &wg_emlrtRSI;
    for (int32_T k{2}; k <= firstBlockLength; k++) {
      xoffset = (k - 1) * vstride;
      d_st.site = &xg_emlrtRSI;
      for (int32_T xj{0}; xj < vstride; xj++) {
        ix = xoffset + xj;
        if (!muDoubleScalarIsNaN(x[ix])) {
          y[xj] = y[xj] + x[ix];
          counts[xj] = counts[xj] + 1;
        }
      }
    }
    d_st.site = &yg_emlrtRSI;
    for (int32_T ib{2}; ib <= nblocks; ib++) {
      xblockoffset = (ib - 1) * bvstride;
      d_st.site = &ah_emlrtRSI;
      for (int32_T xj{0}; xj < vstride; xj++) {
        ix = xblockoffset + xj;
        if (muDoubleScalarIsNaN(x[ix])) {
          bsum[xj] = 0.0;
        } else {
          bsum[xj] = x[ix];
          counts[xj] = counts[xj] + 1;
        }
      }
      if (ib == nblocks) {
        firstBlockLength = lastBlockLength;
      } else {
        firstBlockLength = 1024;
      }
      d_st.site = &bh_emlrtRSI;
      for (int32_T k{2}; k <= firstBlockLength; k++) {
        xoffset = xblockoffset + (k - 1) * vstride;
        d_st.site = &ch_emlrtRSI;
        for (int32_T xj{0}; xj < vstride; xj++) {
          ix = xoffset + xj;
          if (!muDoubleScalarIsNaN(x[ix])) {
            bsum[xj] = bsum[xj] + x[ix];
            counts[xj] = counts[xj] + 1;
          }
        }
      }
      d_st.site = &dh_emlrtRSI;
      firstBlockLength = (vstride / 2) << 1;
      xblockoffset = firstBlockLength - 2;
      for (int32_T xj{0}; xj <= xblockoffset; xj += 2) {
        __m128d r;
        __m128d r1;
        r = _mm_loadu_pd(&y[xj]);
        r1 = _mm_loadu_pd(&bsum[xj]);
        _mm_storeu_pd(&y[xj], _mm_add_pd(r, r1));
      }
      for (int32_T xj{firstBlockLength}; xj < vstride; xj++) {
        y[xj] = y[xj] + bsum[xj];
      }
    }
  }
  st.site = &sg_emlrtRSI;
  b_st.site = &ee_emlrtRSI;
  c_st.site = &fe_emlrtRSI;
  if (((y.size(0) != 1) && (counts.size(0) != 1) &&
       (y.size(0) != counts.size(0))) ||
      ((y.size(1) != 1) && (counts.size(1) != 1) &&
       (y.size(1) != counts.size(1)))) {
    emlrtErrorWithMessageIdR2018a(&c_st, &k_emlrtRTEI,
                                  "MATLAB:sizeDimensionsMustMatch",
                                  "MATLAB:sizeDimensionsMustMatch", 0);
  }
  if ((y.size(0) == counts.size(0)) && (y.size(1) == counts.size(1))) {
    firstBlockLength = y.size(0) * y.size(1);
    for (xblockoffset = 0; xblockoffset < firstBlockLength; xblockoffset++) {
      y[xblockoffset] =
          y[xblockoffset] / static_cast<real_T>(counts[xblockoffset]);
    }
  } else {
    c_st.site = &vj_emlrtRSI;
    b_binary_expand_op(c_st, y, counts);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

void mean(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
          ::coder::array<real_T, 1U> &y)
{
  __m128d r;
  __m128d r1;
  array<real_T, 1U> bsum;
  array<int32_T, 1U> counts;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  int32_T firstBlockLength;
  int32_T hi;
  int32_T ix;
  int32_T xoffset;
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
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  st.site = &rg_emlrtRSI;
  b_st.site = &tg_emlrtRSI;
  if ((x.size(0) == 0) || (x.size(1) == 0)) {
    y.set_size(&ef_emlrtRTEI, &b_st, x.size(0));
    firstBlockLength = x.size(0);
    for (ix = 0; ix < firstBlockLength; ix++) {
      y[ix] = 0.0;
    }
    counts.set_size(&ff_emlrtRTEI, &b_st, x.size(0));
    for (ix = 0; ix < firstBlockLength; ix++) {
      counts[ix] = 0;
    }
  } else {
    int32_T bvstride;
    int32_T lastBlockLength;
    int32_T nblocks;
    int32_T vstride;
    c_st.site = &ug_emlrtRSI;
    vstride = x.size(0);
    bvstride = x.size(0) << 10;
    y.set_size(&bf_emlrtRTEI, &c_st, x.size(0));
    counts.set_size(&cf_emlrtRTEI, &c_st, x.size(0));
    bsum.set_size(&df_emlrtRTEI, &c_st, x.size(0));
    if (x.size(1) <= 1024) {
      firstBlockLength = x.size(1);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = static_cast<int32_T>(static_cast<uint32_T>(x.size(1)) >> 10);
      lastBlockLength = x.size(1) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    d_st.site = &vg_emlrtRSI;
    if (x.size(0) > 2147483646) {
      e_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(e_st);
    }
    for (int32_T xj{0}; xj < vstride; xj++) {
      if (muDoubleScalarIsNaN(x[xj])) {
        y[xj] = 0.0;
        counts[xj] = 0;
      } else {
        y[xj] = x[xj];
        counts[xj] = 1;
      }
      bsum[xj] = 0.0;
    }
    d_st.site = &wg_emlrtRSI;
    for (int32_T k{2}; k <= firstBlockLength; k++) {
      xoffset = (k - 1) * vstride;
      d_st.site = &xg_emlrtRSI;
      if (vstride > 2147483646) {
        e_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(e_st);
      }
      for (int32_T xj{0}; xj < vstride; xj++) {
        ix = xoffset + xj;
        if (!muDoubleScalarIsNaN(x[ix])) {
          y[xj] = y[xj] + x[ix];
          counts[xj] = counts[xj] + 1;
        }
      }
    }
    d_st.site = &yg_emlrtRSI;
    for (int32_T ib{2}; ib <= nblocks; ib++) {
      firstBlockLength = (ib - 1) * bvstride;
      d_st.site = &ah_emlrtRSI;
      if (vstride > 2147483646) {
        e_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(e_st);
      }
      for (int32_T xj{0}; xj < vstride; xj++) {
        ix = firstBlockLength + xj;
        if (muDoubleScalarIsNaN(x[ix])) {
          bsum[xj] = 0.0;
        } else {
          bsum[xj] = x[ix];
          counts[xj] = counts[xj] + 1;
        }
      }
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      d_st.site = &bh_emlrtRSI;
      for (int32_T k{2}; k <= hi; k++) {
        xoffset = firstBlockLength + (k - 1) * vstride;
        d_st.site = &ch_emlrtRSI;
        for (int32_T xj{0}; xj < vstride; xj++) {
          ix = xoffset + xj;
          if (!muDoubleScalarIsNaN(x[ix])) {
            bsum[xj] = bsum[xj] + x[ix];
            counts[xj] = counts[xj] + 1;
          }
        }
      }
      d_st.site = &dh_emlrtRSI;
      hi = (vstride / 2) << 1;
      xoffset = hi - 2;
      for (int32_T xj{0}; xj <= xoffset; xj += 2) {
        r = _mm_loadu_pd(&y[xj]);
        r1 = _mm_loadu_pd(&bsum[xj]);
        _mm_storeu_pd(&y[xj], _mm_add_pd(r, r1));
      }
      for (int32_T xj{hi}; xj < vstride; xj++) {
        y[xj] = y[xj] + bsum[xj];
      }
    }
  }
  st.site = &sg_emlrtRSI;
  bsum.set_size(&gf_emlrtRTEI, &st, counts.size(0));
  firstBlockLength = counts.size(0);
  for (ix = 0; ix < firstBlockLength; ix++) {
    bsum[ix] = counts[ix];
  }
  b_st.site = &ee_emlrtRSI;
  c_st.site = &fe_emlrtRSI;
  if ((y.size(0) != 1) && (bsum.size(0) != 1) && (y.size(0) != bsum.size(0))) {
    emlrtErrorWithMessageIdR2018a(&c_st, &k_emlrtRTEI,
                                  "MATLAB:sizeDimensionsMustMatch",
                                  "MATLAB:sizeDimensionsMustMatch", 0);
  }
  if (y.size(0) == bsum.size(0)) {
    firstBlockLength = y.size(0);
    hi = (y.size(0) / 2) << 1;
    xoffset = hi - 2;
    for (ix = 0; ix <= xoffset; ix += 2) {
      r = _mm_loadu_pd(&y[ix]);
      r1 = _mm_loadu_pd(&bsum[ix]);
      _mm_storeu_pd(&y[ix], _mm_div_pd(r, r1));
    }
    for (ix = hi; ix < firstBlockLength; ix++) {
      y[ix] = y[ix] / bsum[ix];
    }
  } else {
    c_st.site = &vj_emlrtRSI;
    rdivide(c_st, y, bsum);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

real_T mean(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x)
{
  array<real_T, 1U> c_x;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack st;
  real_T y;
  st.prev = &sp;
  st.tls = sp.tls;
  st.site = &lg_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  b_st.site = &pd_emlrtRSI;
  if (x.size(1) == 0) {
    y = 0.0;
  } else {
    int32_T b_x;
    c_st.site = &mg_emlrtRSI;
    b_x = x.size(1);
    c_x = x.reshape(b_x);
    d_st.site = &rd_emlrtRSI;
    y = sumMatrixColumns(d_st, c_x, x.size(1));
  }
  y /= static_cast<real_T>(x.size(1));
  return y;
}

} // namespace coder

// End of code generation (mean.cpp)
