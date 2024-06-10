//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// power.cpp
//
// Code generation for function 'power'
//

// Include files
#include "power.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Variable Definitions
static emlrtRSInfo
    yi_emlrtRSI{
        81,         // lineNo
        "fltpower", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\power.m" // pathName
    };

static emlrtRSInfo
    aj_emlrtRSI{
        102,                     // lineNo
        "fltpower_domain_error", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\power.m" // pathName
    };

static emlrtRTEInfo
    nf_emlrtRTEI{
        71,      // lineNo
        5,       // colNo
        "power", // fName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\power.m" // pName
    };

// Function Definitions
namespace coder {
void power(const emlrtStack &sp, const ::coder::array<real_T, 1U> &a,
           ::coder::array<real_T, 1U> &y)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack st;
  int32_T nx;
  boolean_T p;
  st.prev = &sp;
  st.tls = sp.tls;
  st.site = &rb_emlrtRSI;
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
  b_st.site = &yi_emlrtRSI;
  if (a.size(0) == 1) {
    p = (a[0] < 0.0);
  } else {
    c_st.site = &aj_emlrtRSI;
    d_st.site = &pe_emlrtRSI;
    nx = a.size(0);
    p = false;
    e_st.site = &qe_emlrtRSI;
    if (a.size(0) > 2147483646) {
      f_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(f_st);
    }
    for (int32_T k{0}; k < nx; k++) {
      if (p || (a[k] < 0.0)) {
        p = true;
      }
    }
  }
  if (p) {
    emlrtErrorWithMessageIdR2018a(&st, &b_emlrtRTEI,
                                  "Coder:toolbox:power_domainError",
                                  "Coder:toolbox:power_domainError", 0);
  }
  y.set_size(&nf_emlrtRTEI, &st, a.size(0));
  nx = a.size(0);
  for (int32_T k{0}; k < nx; k++) {
    real_T varargin_1;
    varargin_1 = a[k];
    y[k] = muDoubleScalarPower(varargin_1, 0.66666666666666663);
  }
}

} // namespace coder

// End of code generation (power.cpp)
