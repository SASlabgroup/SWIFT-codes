//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// std.cpp
//
// Code generation for function 'std'
//

// Include files
#include "std.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "sumMatrixIncludeNaN.h"
#include "blas.h"
#include "coder_array.h"
#include "mwmathutil.h"
#include <cstddef>

// Variable Definitions
static emlrtRSInfo ph_emlrtRSI{
    9,     // lineNo
    "std", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\std.m" // pathName
};

static emlrtRSInfo qh_emlrtRSI{
    116,      // lineNo
    "varstd", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\varstd"
    ".m" // pathName
};

static emlrtRSInfo rh_emlrtRSI{
    72,                    // lineNo
    "applyVectorFunction", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunction.m" // pathName
};

static emlrtRSInfo sh_emlrtRSI{
    147,        // lineNo
    "looper1D", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunction.m" // pathName
};

static emlrtRSInfo th_emlrtRSI{
    152,        // lineNo
    "looper1D", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunction.m" // pathName
};

static emlrtRSInfo uh_emlrtRSI{
    157,        // lineNo
    "looper1D", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunction.m" // pathName
};

static emlrtRSInfo vh_emlrtRSI{
    168,          // lineNo
    "copyVector", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunction.m" // pathName
};

static emlrtRSInfo wh_emlrtRSI{
    170,          // lineNo
    "copyVector", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunction.m" // pathName
};

static emlrtRSInfo xh_emlrtRSI{
    115,                             // lineNo
    "@(x)vvarstd(op,x,omitnan,n,w)", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\varstd"
    ".m" // pathName
};

static emlrtRSInfo yh_emlrtRSI{
    48,        // lineNo
    "vvarstd", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\vvarst"
    "d.m" // pathName
};

static emlrtRSInfo ai_emlrtRSI{
    96,        // lineNo
    "vvarstd", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\vvarst"
    "d.m" // pathName
};

static emlrtRSInfo bi_emlrtRSI{
    127,       // lineNo
    "vvarstd", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\vvarst"
    "d.m" // pathName
};

static emlrtRSInfo ci_emlrtRSI{
    143,       // lineNo
    "vvarstd", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\vvarst"
    "d.m" // pathName
};

static emlrtRTEInfo w_emlrtRTEI{
    13,     // lineNo
    9,      // colNo
    "sqrt", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\sqrt.m" // pName
};

static emlrtRTEInfo x_emlrtRTEI{
    60,        // lineNo
    5,         // colNo
    "vvarstd", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\vvarst"
    "d.m" // pName
};

static emlrtRTEInfo y_emlrtRTEI{
    59,        // lineNo
    5,         // colNo
    "vvarstd", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\vvarst"
    "d.m" // pName
};

static emlrtRTEInfo kf_emlrtRTEI{
    9,     // lineNo
    1,     // colNo
    "std", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\std.m" // pName
};

static emlrtRTEInfo lf_emlrtRTEI{
    152,                   // lineNo
    9,                     // colNo
    "applyVectorFunction", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunction.m" // pName
};

static emlrtRTEInfo mf_emlrtRTEI{
    126,       // lineNo
    34,        // colNo
    "vvarstd", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\vvarst"
    "d.m" // pName
};

// Function Definitions
namespace coder {
void b_std(const emlrtStack &sp, const ::coder::array<real_T, 3U> &x,
           ::coder::array<real_T, 2U> &y)
{
  ptrdiff_t incx_t;
  ptrdiff_t n_t;
  array<real_T, 1U> absdiff;
  array<real_T, 1U> xv;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  emlrtStack i_st;
  emlrtStack j_st;
  emlrtStack st;
  int32_T loop_ub;
  int32_T n;
  int32_T nnans;
  int32_T nx;
  int32_T outsize_idx_0;
  int32_T stride;
  boolean_T b_overflow;
  boolean_T overflow;
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
  j_st.prev = &i_st;
  j_st.tls = i_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  st.site = &ph_emlrtRSI;
  b_st.site = &qh_emlrtRSI;
  y.set_size(&kf_emlrtRTEI, &b_st, x.size(0), x.size(1));
  nnans = x.size(0) * x.size(1);
  for (int32_T k{0}; k < nnans; k++) {
    y[k] = 0.0;
  }
  c_st.site = &rh_emlrtRSI;
  nx = x.size(2);
  stride = x.size(0) * x.size(1);
  d_st.site = &sh_emlrtRSI;
  if (stride > 2147483646) {
    e_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(e_st);
  }
  if (stride - 1 >= 0) {
    outsize_idx_0 = x.size(2);
    loop_ub = x.size(2);
    overflow = (x.size(2) > 2147483646);
    n = x.size(2);
    b_overflow = (x.size(2) > 2147483646);
  }
  for (int32_T j{0}; j < stride; j++) {
    d_st.site = &th_emlrtRSI;
    e_st.site = &vh_emlrtRSI;
    f_st.site = &eh_emlrtRSI;
    xv.set_size(&lf_emlrtRTEI, &e_st, outsize_idx_0);
    for (int32_T k{0}; k < loop_ub; k++) {
      xv[k] = 0.0;
    }
    e_st.site = &wh_emlrtRSI;
    if (overflow) {
      f_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(f_st);
    }
    for (int32_T k{0}; k < nx; k++) {
      xv[k] = x[j + k * stride];
    }
    d_st.site = &uh_emlrtRSI;
    e_st.site = &cc_emlrtRSI;
    f_st.site = &xh_emlrtRSI;
    nnans = 0;
    g_st.site = &yh_emlrtRSI;
    if (b_overflow) {
      h_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(h_st);
    }
    for (int32_T k{0}; k < n; k++) {
      if (muDoubleScalarIsNaN(xv[k])) {
        nnans++;
      } else {
        xv[k - nnans] = xv[k];
      }
    }
    if (nnans < 0) {
      emlrtErrorWithMessageIdR2018a(&f_st, &y_emlrtRTEI,
                                    "Coder:builtins:AssertionFailed",
                                    "Coder:builtins:AssertionFailed", 0);
    }
    if (nnans > x.size(2)) {
      emlrtErrorWithMessageIdR2018a(&f_st, &x_emlrtRTEI,
                                    "Coder:builtins:AssertionFailed",
                                    "Coder:builtins:AssertionFailed", 0);
    }
    nnans = x.size(2) - nnans;
    if (nnans == 0) {
      y[j] = rtNaN;
    } else if (nnans == 1) {
      if ((!muDoubleScalarIsInf(xv[0])) && (!muDoubleScalarIsNaN(xv[0]))) {
        y[j] = 0.0;
      } else {
        y[j] = rtNaN;
      }
    } else {
      real_T xbar;
      g_st.site = &ai_emlrtRSI;
      h_st.site = &pd_emlrtRSI;
      if ((xv.size(0) == 0) || (nnans == 0)) {
        xbar = 0.0;
      } else {
        i_st.site = &qd_emlrtRSI;
        j_st.site = &rd_emlrtRSI;
        xbar = sumMatrixColumns(j_st, xv, nnans);
      }
      xbar /= static_cast<real_T>(nnans);
      absdiff.set_size(&mf_emlrtRTEI, &f_st, xv.size(0));
      g_st.site = &bi_emlrtRSI;
      if (nnans > 2147483646) {
        h_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(h_st);
      }
      for (int32_T k{0}; k < nnans; k++) {
        absdiff[k] = muDoubleScalarAbs(xv[k] - xbar);
      }
      if (nnans < 1) {
        xbar = 0.0;
      } else {
        n_t = (ptrdiff_t)nnans;
        incx_t = (ptrdiff_t)1;
        xbar = dnrm2(&n_t, &(absdiff.data())[0], &incx_t);
      }
      g_st.site = &ci_emlrtRSI;
      if (nnans - 1 < 0) {
        emlrtErrorWithMessageIdR2018a(
            &g_st, &w_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
            "Coder:toolbox:ElFunDomainError", 3, 4, 4, "sqrt");
      }
      y[j] = xbar / muDoubleScalarSqrt(static_cast<real_T>(nnans) - 1.0);
    }
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

} // namespace coder

// End of code generation (std.cpp)
