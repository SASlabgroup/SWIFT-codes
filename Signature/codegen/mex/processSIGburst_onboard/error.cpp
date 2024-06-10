//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// error.cpp
//
// Code generation for function 'error'
//

// Include files
#include "error.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"

// Variable Definitions
static emlrtMCInfo c_emlrtMCI{
    27,      // lineNo
    5,       // colNo
    "error", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\lang\\error.m" // pName
};

static emlrtRSInfo nj_emlrtRSI{
    27,      // lineNo
    "error", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\lang\\error.m" // pathName
};

// Function Declarations
static void b_error(const emlrtStack &sp, const mxArray *m,
                    emlrtMCInfo &location);

// Function Definitions
static void b_error(const emlrtStack &sp, const mxArray *m,
                    emlrtMCInfo &location)
{
  const mxArray *pArray;
  pArray = m;
  emlrtCallMATLABR2012b((emlrtConstCTX)&sp, 0, nullptr, 1, &pArray, "error",
                        true, &location);
}

namespace coder {
void c_error(const emlrtStack &sp)
{
  static const int32_T iv[2]{1, 46};
  static const char_T varargin_1[46]{
      'A',  'v', 'e',  'r', 'a', 'g', 'e', ' ',  'e',  's', 't', 'i',
      'm',  'a', 't',  'o', 'r', ' ', 'm', 'u',  's',  't', ' ', 'b',
      'e',  ' ', '\'', 'm', 'e', 'a', 'n', '\'', ' ',  'o', 'r', ' ',
      '\'', 'l', 'o',  'g', 'm', 'e', 'a', 'n',  '\'', '.'};
  emlrtStack st;
  const mxArray *m;
  const mxArray *y;
  st.prev = &sp;
  st.tls = sp.tls;
  y = nullptr;
  m = emlrtCreateCharArray(2, &iv[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 46, m, &varargin_1[0]);
  emlrtAssign(&y, m);
  st.site = &nj_emlrtRSI;
  b_error(st, y, c_emlrtMCI);
}

void d_error(const emlrtStack &sp)
{
  static const int32_T iv[2]{1, 43};
  static const char_T varargin_1[43]{
      'F',  'i', 't',  ' ', 't', 'y',  'p',  'e', ' ', 'm', 'u',
      's',  't', ' ',  'b', 'e', ' ',  '\'', 'l', 'i', 'n', 'e',
      'a',  'r', '\'', ',', ' ', '\'', 'c',  'u', 'b', 'i', 'c',
      '\'', ' ', 'o',  'r', ' ', '\'', 'l',  'o', 'g', '\''};
  emlrtStack st;
  const mxArray *m;
  const mxArray *y;
  st.prev = &sp;
  st.tls = sp.tls;
  y = nullptr;
  m = emlrtCreateCharArray(2, &iv[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 43, m, &varargin_1[0]);
  emlrtAssign(&y, m);
  st.site = &nj_emlrtRSI;
  b_error(st, y, c_emlrtMCI);
}

} // namespace coder

// End of code generation (error.cpp)
