//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// meshgrid.cpp
//
// Code generation for function 'meshgrid'
//

// Include files
#include "meshgrid.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Variable Definitions
static emlrtRSInfo pg_emlrtRSI{
    31,         // lineNo
    "meshgrid", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\meshgrid.m" // pathName
};

static emlrtRSInfo qg_emlrtRSI{
    32,         // lineNo
    "meshgrid", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\meshgrid.m" // pathName
};

static emlrtRTEInfo ye_emlrtRTEI{
    20,         // lineNo
    25,         // colNo
    "meshgrid", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\meshgrid.m" // pName
};

static emlrtRTEInfo af_emlrtRTEI{
    21,         // lineNo
    25,         // colNo
    "meshgrid", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\meshgrid.m" // pName
};

// Function Definitions
namespace coder {
void meshgrid(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
              ::coder::array<real_T, 2U> &xx, ::coder::array<real_T, 2U> &yy)
{
  emlrtStack b_st;
  emlrtStack st;
  int32_T nx;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  nx = x.size(1);
  xx.set_size(&ye_emlrtRTEI, &sp, x.size(1), x.size(1));
  yy.set_size(&af_emlrtRTEI, &sp, x.size(1), x.size(1));
  if (x.size(1) != 0) {
    st.site = &pg_emlrtRSI;
    if (x.size(1) > 2147483646) {
      b_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(b_st);
    }
    for (int32_T j{0}; j < nx; j++) {
      st.site = &qg_emlrtRSI;
      if (nx > 2147483646) {
        b_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(b_st);
      }
      for (int32_T i{0}; i < nx; i++) {
        xx[i + xx.size(0) * j] = x[j];
        yy[i + yy.size(0) * j] = x[i];
      }
    }
  }
}

} // namespace coder

// End of code generation (meshgrid.cpp)
