//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mldivide.cpp
//
// Code generation for function 'mldivide'
//

// Include files
#include "mldivide.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "warning.h"
#include "coder_array.h"
#include "mwmathutil.h"
#include <algorithm>

// Variable Definitions
static emlrtRSInfo dj_emlrtRSI{
    20,         // lineNo
    "mldivide", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\mldivide.m" // pathName
};

static emlrtRSInfo ej_emlrtRSI{
    42,      // lineNo
    "mldiv", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\mldivide.m" // pathName
};

static emlrtRSInfo fj_emlrtRSI{
    61,        // lineNo
    "lusolve", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m" // pathName
};

static emlrtRSInfo gj_emlrtRSI{
    293,          // lineNo
    "lusolve3x3", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m" // pathName
};

static emlrtRSInfo hj_emlrtRSI{
    315,          // lineNo
    "lusolve3x3", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m" // pathName
};

static emlrtRSInfo ij_emlrtRSI{
    90,              // lineNo
    "warn_singular", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m" // pathName
};

static emlrtRSInfo jj_emlrtRSI{
    55,        // lineNo
    "lusolve", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m" // pathName
};

static emlrtRSInfo kj_emlrtRSI{
    210,          // lineNo
    "lusolve2x2", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m" // pathName
};

static emlrtRSInfo lj_emlrtRSI{
    225,          // lineNo
    "lusolve2x2", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m" // pathName
};

static emlrtRTEInfo of_emlrtRTEI{
    314,       // lineNo
    24,        // colNo
    "lusolve", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m" // pName
};

static emlrtRTEInfo pf_emlrtRTEI{
    224,       // lineNo
    24,        // colNo
    "lusolve", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m" // pName
};

static emlrtRTEInfo qf_emlrtRTEI{
    20,         // lineNo
    5,          // colNo
    "mldivide", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\mldivide.m" // pName
};

// Function Definitions
namespace coder {
void b_mldivide(const emlrtStack &sp, const real_T A[4],
                const ::coder::array<real_T, 2U> &B,
                ::coder::array<real_T, 2U> &Y)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  st.prev = &sp;
  st.tls = sp.tls;
  st.site = &dj_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  if (B.size(1) == 0) {
    Y.set_size(&qf_emlrtRTEI, &st, 2, 0);
  } else {
    real_T a21;
    real_T a22;
    real_T a22_tmp;
    int32_T nb;
    int32_T r1;
    int32_T r2;
    b_st.site = &ej_emlrtRSI;
    c_st.site = &jj_emlrtRSI;
    if (muDoubleScalarAbs(A[1]) > muDoubleScalarAbs(A[0])) {
      r1 = 1;
      r2 = 0;
    } else {
      r1 = 0;
      r2 = 1;
    }
    a21 = A[r2] / A[r1];
    a22_tmp = A[r1 + 2];
    a22 = A[r2 + 2] - a21 * a22_tmp;
    if ((a22 == 0.0) || (A[r1] == 0.0)) {
      d_st.site = &kj_emlrtRSI;
      if (!emlrtSetWarningFlag(&d_st)) {
        e_st.site = &ij_emlrtRSI;
        internal::c_warning(e_st);
      }
    }
    nb = B.size(1);
    Y.set_size(&pf_emlrtRTEI, &c_st, 2, B.size(1));
    d_st.site = &lj_emlrtRSI;
    if (B.size(1) > 2147483646) {
      e_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(e_st);
    }
    for (int32_T k{0}; k < nb; k++) {
      real_T d;
      d = (B[r2 + 2 * k] - B[r1 + 2 * k] * a21) / a22;
      Y[2 * k + 1] = d;
      Y[2 * k] = (B[r1 + 2 * k] - d * a22_tmp) / A[r1];
    }
  }
}

void mldivide(const emlrtStack &sp, const real_T A[9],
              const ::coder::array<real_T, 2U> &B,
              ::coder::array<real_T, 2U> &Y)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  real_T b_A[9];
  real_T a21;
  real_T maxval;
  int32_T r1;
  int32_T r2;
  int32_T r3;
  int32_T rtemp;
  st.prev = &sp;
  st.tls = sp.tls;
  st.site = &dj_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  b_st.site = &ej_emlrtRSI;
  c_st.site = &fj_emlrtRSI;
  std::copy(&A[0], &A[9], &b_A[0]);
  r1 = 0;
  r2 = 1;
  r3 = 2;
  maxval = muDoubleScalarAbs(A[0]);
  a21 = muDoubleScalarAbs(A[1]);
  if (a21 > maxval) {
    maxval = a21;
    r1 = 1;
    r2 = 0;
  }
  if (muDoubleScalarAbs(A[2]) > maxval) {
    r1 = 2;
    r2 = 1;
    r3 = 0;
  }
  b_A[r2] = A[r2] / A[r1];
  b_A[r3] /= b_A[r1];
  b_A[r2 + 3] -= b_A[r2] * b_A[r1 + 3];
  b_A[r3 + 3] -= b_A[r3] * b_A[r1 + 3];
  b_A[r2 + 6] -= b_A[r2] * b_A[r1 + 6];
  b_A[r3 + 6] -= b_A[r3] * b_A[r1 + 6];
  if (muDoubleScalarAbs(b_A[r3 + 3]) > muDoubleScalarAbs(b_A[r2 + 3])) {
    rtemp = r2;
    r2 = r3;
    r3 = rtemp;
  }
  b_A[r3 + 3] /= b_A[r2 + 3];
  b_A[r3 + 6] -= b_A[r3 + 3] * b_A[r2 + 6];
  if ((b_A[r1] == 0.0) || (b_A[r2 + 3] == 0.0) || (b_A[r3 + 6] == 0.0)) {
    d_st.site = &gj_emlrtRSI;
    if (!emlrtSetWarningFlag(&d_st)) {
      e_st.site = &ij_emlrtRSI;
      internal::c_warning(e_st);
    }
  }
  rtemp = B.size(1);
  Y.set_size(&of_emlrtRTEI, &c_st, 3, B.size(1));
  d_st.site = &hj_emlrtRSI;
  if (B.size(1) > 2147483646) {
    e_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(e_st);
  }
  for (int32_T k{0}; k < rtemp; k++) {
    real_T d;
    maxval = B[r1 + 3 * k];
    a21 = B[r2 + 3 * k] - maxval * b_A[r2];
    d = ((B[r3 + 3 * k] - maxval * b_A[r3]) - a21 * b_A[r3 + 3]) / b_A[r3 + 6];
    Y[3 * k + 2] = d;
    maxval -= d * b_A[r1 + 6];
    a21 -= d * b_A[r2 + 6];
    a21 /= b_A[r2 + 3];
    Y[3 * k + 1] = a21;
    maxval -= a21 * b_A[r1 + 3];
    maxval /= b_A[r1];
    Y[3 * k] = maxval;
  }
}

} // namespace coder

// End of code generation (mldivide.cpp)
