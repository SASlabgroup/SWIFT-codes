//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// repmat.cpp
//
// Code generation for function 'repmat'
//

// Include files
#include "repmat.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Variable Definitions
static emlrtRSInfo fh_emlrtRSI{
    64,       // lineNo
    "repmat", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m" // pathName
};

static emlrtRSInfo gh_emlrtRSI{
    66,       // lineNo
    "repmat", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m" // pathName
};

static emlrtRSInfo hh_emlrtRSI{
    71,       // lineNo
    "repmat", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m" // pathName
};

static emlrtRTEInfo t_emlrtRTEI{
    58,                   // lineNo
    23,                   // colNo
    "assertValidSizeArg", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\assertValidSizeArg.m" // pName
};

static emlrtRTEInfo hf_emlrtRTEI{
    59,       // lineNo
    28,       // colNo
    "repmat", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m" // pName
};

// Function Definitions
namespace coder {
void repmat(const emlrtStack &sp, const ::coder::array<real_T, 2U> &a,
            real_T varargin_3, ::coder::array<real_T, 3U> &b)
{
  emlrtStack b_st;
  emlrtStack st;
  int32_T i;
  int32_T ncols;
  int32_T nrows;
  st.prev = &sp;
  st.tls = sp.tls;
  st.site = &eh_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if ((varargin_3 != varargin_3) || muDoubleScalarIsInf(varargin_3)) {
    emlrtErrorWithMessageIdR2018a(
        &st, &t_emlrtRTEI, "Coder:MATLAB:NonIntegerInput",
        "Coder:MATLAB:NonIntegerInput", 4, 12, MIN_int32_T, 12, MAX_int32_T);
  }
  i = static_cast<int32_T>(varargin_3);
  b.set_size(&hf_emlrtRTEI, &sp, a.size(0), a.size(1), i);
  nrows = a.size(0);
  ncols = a.size(1);
  st.site = &fh_emlrtRSI;
  if (static_cast<int32_T>(varargin_3) > 2147483646) {
    b_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(b_st);
  }
  for (int32_T jtilecol{0}; jtilecol < i; jtilecol++) {
    int32_T ibtile;
    ibtile = jtilecol * (nrows * ncols) - 1;
    st.site = &gh_emlrtRSI;
    if (ncols > 2147483646) {
      b_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(b_st);
    }
    for (int32_T jcol{0}; jcol < ncols; jcol++) {
      int32_T iacol_tmp;
      int32_T ibmat;
      iacol_tmp = jcol * nrows;
      ibmat = ibtile + iacol_tmp;
      st.site = &hh_emlrtRSI;
      if (nrows > 2147483646) {
        b_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(b_st);
      }
      for (int32_T k{0}; k < nrows; k++) {
        b[(ibmat + k) + 1] = a[iacol_tmp + k];
      }
    }
  }
}

} // namespace coder

// End of code generation (repmat.cpp)
