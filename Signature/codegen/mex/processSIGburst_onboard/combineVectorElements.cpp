//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// combineVectorElements.cpp
//
// Code generation for function 'combineVectorElements'
//

// Include files
#include "combineVectorElements.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Variable Definitions
static emlrtRSInfo jd_emlrtRSI{
    138,                     // lineNo
    "combineVectorElements", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\combin"
    "eVectorElements.m" // pathName
};

static emlrtRSInfo kd_emlrtRSI{
    177,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\combin"
    "eVectorElements.m" // pathName
};

static emlrtRSInfo ld_emlrtRSI{
    198,                // lineNo
    "colMajorFlatIter", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\combin"
    "eVectorElements.m" // pathName
};

static emlrtRTEInfo jd_emlrtRTEI{
    170,                     // lineNo
    24,                      // colNo
    "combineVectorElements", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\combin"
    "eVectorElements.m" // pName
};

static emlrtRTEInfo kd_emlrtRTEI{
    97,                      // lineNo
    13,                      // colNo
    "combineVectorElements", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\combin"
    "eVectorElements.m" // pName
};

// Function Definitions
namespace coder {
int32_T b_combineVectorElements(const emlrtStack &sp,
                                const ::coder::array<boolean_T, 1U> &x)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  int32_T vlen;
  int32_T y;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  vlen = x.size(0);
  if (x.size(0) == 0) {
    y = 0;
  } else {
    st.site = &jd_emlrtRSI;
    y = x[0];
    b_st.site = &ld_emlrtRSI;
    if (x.size(0) > 2147483646) {
      c_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(c_st);
    }
    for (int32_T k{2}; k <= vlen; k++) {
      y += x[k - 1];
    }
  }
  return y;
}

void combineVectorElements(const emlrtStack &sp,
                           const ::coder::array<boolean_T, 2U> &x,
                           ::coder::array<int32_T, 2U> &y)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  int32_T vlen;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  vlen = x.size(0);
  if ((x.size(0) == 0) || (x.size(1) == 0)) {
    y.set_size(&kd_emlrtRTEI, &sp, 1, x.size(1));
    vlen = x.size(1);
    for (int32_T npages{0}; npages < vlen; npages++) {
      y[npages] = 0;
    }
  } else {
    int32_T npages;
    boolean_T overflow;
    st.site = &jd_emlrtRSI;
    npages = x.size(1);
    y.set_size(&jd_emlrtRTEI, &st, 1, x.size(1));
    b_st.site = &kd_emlrtRSI;
    if (x.size(1) > 2147483646) {
      c_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(c_st);
    }
    overflow = (x.size(0) > 2147483646);
    for (int32_T i{0}; i < npages; i++) {
      int32_T xpageoffset;
      xpageoffset = i * x.size(0);
      y[i] = x[xpageoffset];
      b_st.site = &ld_emlrtRSI;
      if (overflow) {
        c_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(c_st);
      }
      for (int32_T k{2}; k <= vlen; k++) {
        y[i] = y[i] + x[(xpageoffset + k) - 1];
      }
    }
  }
}

} // namespace coder

// End of code generation (combineVectorElements.cpp)
