//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// movmedian.cpp
//
// Code generation for function 'movmedian'
//

// Include files
#include "movmedian.h"
#include "movsortfun.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Variable Definitions
static emlrtRSInfo sb_emlrtRSI{
    10,          // lineNo
    "movmedian", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\movmedian.m" // pathName
};

static emlrtRSInfo tb_emlrtRSI{
    101,              // lineNo
    "movfunDispatch", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movfun"
    "Dispatch.m" // pathName
};

static emlrtRSInfo ub_emlrtRSI{
    102,              // lineNo
    "movfunDispatch", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movfun"
    "Dispatch.m" // pathName
};

static emlrtRSInfo vb_emlrtRSI{
    159,        // lineNo
    "dispatch", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movfun"
    "Dispatch.m" // pathName
};

static emlrtRTEInfo e_emlrtRTEI{
    349,                       // lineNo
    27,                        // colNo
    "movfunAssertValidInputs", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movfun"
    "Dispatch.m" // pName
};

// Function Definitions
namespace coder {
void movmedian(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
               real_T k, ::coder::array<real_T, 2U> &y)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  int32_T kright;
  int32_T xlen;
  int32_T y_tmp;
  st.prev = &sp;
  st.tls = sp.tls;
  st.site = &sb_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_st.site = &tb_emlrtRSI;
  if ((!(k > 0.0)) || muDoubleScalarIsInf(k)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &e_emlrtRTEI,
                                  "MATLAB:movfun:wrongWindowLength",
                                  "MATLAB:movfun:wrongWindowLength", 0);
  }
  b_st.site = &ub_emlrtRSI;
  xlen = x.size(0);
  if (k >= 2.147483647E+9) {
    y_tmp = x.size(0);
    kright = x.size(0);
  } else {
    y_tmp = static_cast<int32_T>(muDoubleScalarFloor(k / 2.0));
    kright = y_tmp;
    if (y_tmp << 1 == k) {
      kright = y_tmp - 1;
    }
    y_tmp = muIntScalarMin_sint32(y_tmp, xlen);
    kright = muIntScalarMin_sint32(kright, xlen);
  }
  c_st.site = &vb_emlrtRSI;
  movsortfun(c_st, x, y_tmp, kright, y);
}

} // namespace coder

// End of code generation (movmedian.cpp)
