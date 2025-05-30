//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// warning.cpp
//
// Code generation for function 'warning'
//

// Include files
#include "warning.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"

// Variable Definitions
static emlrtMCInfo emlrtMCI{
    14,        // lineNo
    25,        // colNo
    "warning", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\shared\\coder\\coder\\lib\\+coder\\+"
    "internal\\warning.m" // pName
};

static emlrtMCInfo b_emlrtMCI{
    14,        // lineNo
    9,         // colNo
    "warning", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\shared\\coder\\coder\\lib\\+coder\\+"
    "internal\\warning.m" // pName
};

static emlrtRSInfo mj_emlrtRSI{
    14,        // lineNo
    "warning", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\shared\\coder\\coder\\lib\\+coder\\+"
    "internal\\warning.m" // pathName
};

// Function Declarations
static void b_feval(const emlrtStack &sp, const mxArray *m, const mxArray *m1,
                    emlrtMCInfo &location);

static const mxArray *feval(const emlrtStack &sp, const mxArray *m1,
                            const mxArray *m2, emlrtMCInfo &location);

// Function Definitions
static void b_feval(const emlrtStack &sp, const mxArray *m, const mxArray *m1,
                    emlrtMCInfo &location)
{
  const mxArray *pArrays[2];
  pArrays[0] = m;
  pArrays[1] = m1;
  emlrtCallMATLABR2012b((emlrtConstCTX)&sp, 0, nullptr, 2, &pArrays[0], "feval",
                        true, &location);
}

static const mxArray *feval(const emlrtStack &sp, const mxArray *m1,
                            const mxArray *m2, emlrtMCInfo &location)
{
  const mxArray *pArrays[2];
  const mxArray *m;
  pArrays[0] = m1;
  pArrays[1] = m2;
  return emlrtCallMATLABR2012b((emlrtConstCTX)&sp, 1, &m, 2, &pArrays[0],
                               "feval", true, &location);
}

namespace coder {
namespace internal {
void b_warning(const emlrtStack &sp)
{
  static const int32_T iv[2]{1, 7};
  static const int32_T iv1[2]{1, 7};
  static const int32_T iv2[2]{1, 26};
  static const char_T msgID[26]{'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o',
                                'l', 'b', 'o', 'x', ':', 's', 'c', 'h', 'u',
                                'r', '_', 'f', 'a', 'i', 'l', 'e', 'd'};
  static const char_T b_u[7]{'m', 'e', 's', 's', 'a', 'g', 'e'};
  static const char_T u[7]{'w', 'a', 'r', 'n', 'i', 'n', 'g'};
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *m;
  const mxArray *y;
  st.prev = &sp;
  st.tls = sp.tls;
  y = nullptr;
  m = emlrtCreateCharArray(2, &iv[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 7, m, &u[0]);
  emlrtAssign(&y, m);
  b_y = nullptr;
  m = emlrtCreateCharArray(2, &iv1[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 7, m, &b_u[0]);
  emlrtAssign(&b_y, m);
  c_y = nullptr;
  m = emlrtCreateCharArray(2, &iv2[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 26, m, &msgID[0]);
  emlrtAssign(&c_y, m);
  st.site = &mj_emlrtRSI;
  b_feval(st, y, feval(st, b_y, c_y, emlrtMCI), b_emlrtMCI);
}

void c_warning(const emlrtStack &sp)
{
  static const int32_T iv[2]{1, 7};
  static const int32_T iv1[2]{1, 7};
  static const int32_T iv2[2]{1, 21};
  static const char_T msgID[21]{'M', 'A', 'T', 'L', 'A', 'B', ':',
                                's', 'i', 'n', 'g', 'u', 'l', 'a',
                                'r', 'M', 'a', 't', 'r', 'i', 'x'};
  static const char_T b_u[7]{'m', 'e', 's', 's', 'a', 'g', 'e'};
  static const char_T u[7]{'w', 'a', 'r', 'n', 'i', 'n', 'g'};
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *m;
  const mxArray *y;
  st.prev = &sp;
  st.tls = sp.tls;
  y = nullptr;
  m = emlrtCreateCharArray(2, &iv[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 7, m, &u[0]);
  emlrtAssign(&y, m);
  b_y = nullptr;
  m = emlrtCreateCharArray(2, &iv1[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 7, m, &b_u[0]);
  emlrtAssign(&b_y, m);
  c_y = nullptr;
  m = emlrtCreateCharArray(2, &iv2[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 21, m, &msgID[0]);
  emlrtAssign(&c_y, m);
  st.site = &mj_emlrtRSI;
  b_feval(st, y, feval(st, b_y, c_y, emlrtMCI), b_emlrtMCI);
}

void warning(const emlrtStack &sp)
{
  static const int32_T iv[2]{1, 7};
  static const int32_T iv1[2]{1, 7};
  static const int32_T iv2[2]{1, 24};
  static const char_T msgID[24]{'M', 'A', 'T', 'L', 'A', 'B', ':', 'e',
                                'i', 'g', ':', 'N', 'o', 'C', 'o', 'n',
                                'v', 'e', 'r', 'g', 'e', 'n', 'c', 'e'};
  static const char_T b_u[7]{'m', 'e', 's', 's', 'a', 'g', 'e'};
  static const char_T u[7]{'w', 'a', 'r', 'n', 'i', 'n', 'g'};
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *m;
  const mxArray *y;
  st.prev = &sp;
  st.tls = sp.tls;
  y = nullptr;
  m = emlrtCreateCharArray(2, &iv[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 7, m, &u[0]);
  emlrtAssign(&y, m);
  b_y = nullptr;
  m = emlrtCreateCharArray(2, &iv1[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 7, m, &b_u[0]);
  emlrtAssign(&b_y, m);
  c_y = nullptr;
  m = emlrtCreateCharArray(2, &iv2[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)&sp, 24, m, &msgID[0]);
  emlrtAssign(&c_y, m);
  st.site = &mj_emlrtRSI;
  b_feval(st, y, feval(st, b_y, c_y, emlrtMCI), b_emlrtMCI);
}

} // namespace internal
} // namespace coder

// End of code generation (warning.cpp)
