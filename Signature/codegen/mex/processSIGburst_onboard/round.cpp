//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// round.cpp
//
// Code generation for function 'round'
//

// Include files
#include "round.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Variable Definitions
static emlrtRSInfo ng_emlrtRSI{
    16,      // lineNo
    "round", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\round.m" // pathName
};

// Function Definitions
namespace coder {
void b_round(const emlrtStack &sp, ::coder::array<real_T, 2U> &x)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  int32_T nx_tmp;
  st.prev = &sp;
  st.tls = sp.tls;
  st.site = &ng_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  nx_tmp = x.size(0) * x.size(1);
  b_st.site = &og_emlrtRSI;
  if (nx_tmp > 2147483646) {
    c_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(c_st);
  }
  for (int32_T k{0}; k < nx_tmp; k++) {
    x[k] = muDoubleScalarRound(x[k]);
  }
}

} // namespace coder

// End of code generation (round.cpp)
