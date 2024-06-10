//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// log10.cpp
//
// Code generation for function 'log10'
//

// Include files
#include "log10.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Variable Definitions
static emlrtRSInfo di_emlrtRSI{
    17,      // lineNo
    "log10", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\log10.m" // pathName
};

static emlrtRTEInfo bb_emlrtRTEI{
    14,      // lineNo
    9,       // colNo
    "log10", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\log10.m" // pName
};

// Function Definitions
namespace coder {
void b_log10(const emlrtStack &sp, ::coder::array<real_T, 1U> &x)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  int32_T nx;
  boolean_T p;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  p = false;
  nx = x.size(0);
  for (int32_T k{0}; k < nx; k++) {
    if (p || (x[k] < 0.0)) {
      p = true;
    }
  }
  if (p) {
    emlrtErrorWithMessageIdR2018a(
        &sp, &bb_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
        "Coder:toolbox:ElFunDomainError", 3, 4, 5, "log10");
  }
  st.site = &di_emlrtRSI;
  nx = x.size(0);
  b_st.site = &og_emlrtRSI;
  if (x.size(0) > 2147483646) {
    c_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(c_st);
  }
  for (int32_T k{0}; k < nx; k++) {
    x[k] = muDoubleScalarLog10(x[k]);
  }
}

void b_log10(const emlrtStack &sp, ::coder::array<real_T, 3U> &x)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  int32_T i;
  boolean_T p;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  p = false;
  i = x.size(0) * x.size(1) * x.size(2);
  for (int32_T k{0}; k < i; k++) {
    if (p || (x[k] < 0.0)) {
      p = true;
    }
  }
  if (p) {
    emlrtErrorWithMessageIdR2018a(
        &sp, &bb_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
        "Coder:toolbox:ElFunDomainError", 3, 4, 5, "log10");
  }
  st.site = &di_emlrtRSI;
  b_st.site = &og_emlrtRSI;
  if (i > 2147483646) {
    c_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(c_st);
  }
  for (int32_T k{0}; k < i; k++) {
    x[k] = muDoubleScalarLog10(x[k]);
  }
}

} // namespace coder

// End of code generation (log10.cpp)
