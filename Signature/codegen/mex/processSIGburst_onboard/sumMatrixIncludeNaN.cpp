//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// sumMatrixIncludeNaN.cpp
//
// Code generation for function 'sumMatrixIncludeNaN'
//

// Include files
#include "sumMatrixIncludeNaN.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Variable Definitions
static emlrtRSInfo xd_emlrtRSI{
    178,          // lineNo
    "sumColumnB", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

static emlrtRSInfo yd_emlrtRSI{
    182,          // lineNo
    "sumColumnB", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

static emlrtRSInfo ae_emlrtRSI{
    183,          // lineNo
    "sumColumnB", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

static emlrtRSInfo be_emlrtRSI{
    184,          // lineNo
    "sumColumnB", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

static emlrtRSInfo ce_emlrtRSI{
    189,          // lineNo
    "sumColumnB", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

static emlrtRSInfo de_emlrtRSI{
    210,         // lineNo
    "sumColumn", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

// Function Declarations
namespace coder {
static real_T sumColumnB(const emlrtStack &sp,
                         const ::coder::array<real_T, 1U> &x, int32_T vlen,
                         int32_T vstart);

static real_T sumColumnB(const emlrtStack &sp,
                         const ::coder::array<real_T, 1U> &x, int32_T vlen);

static real_T sumColumnB4(const ::coder::array<real_T, 1U> &x, int32_T vstart);

} // namespace coder

// Function Definitions
namespace coder {
static real_T sumColumnB(const emlrtStack &sp,
                         const ::coder::array<real_T, 1U> &x, int32_T vlen,
                         int32_T vstart)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T y;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  if (vlen <= 1024) {
    st.site = &xd_emlrtRSI;
    y = x[vstart - 1];
    b_st.site = &de_emlrtRSI;
    if (vlen - 1 > 2147483646) {
      c_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(c_st);
    }
    for (int32_T k{0}; k <= vlen - 2; k++) {
      y += x[vstart + k];
    }
  } else {
    real_T b_y;
    int32_T b_vstart;
    int32_T inb;
    int32_T nfb;
    nfb = vlen / 1024;
    inb = nfb << 10;
    st.site = &yd_emlrtRSI;
    y = x[vstart - 1];
    b_st.site = &de_emlrtRSI;
    for (int32_T k{0}; k < 1023; k++) {
      y += x[vstart + k];
    }
    st.site = &ae_emlrtRSI;
    for (int32_T k{2}; k <= nfb; k++) {
      st.site = &be_emlrtRSI;
      b_vstart = vstart + ((k - 1) << 10);
      b_y = x[b_vstart - 1];
      b_st.site = &de_emlrtRSI;
      for (int32_T b_k{0}; b_k < 1023; b_k++) {
        b_y += x[b_vstart + b_k];
      }
      y += b_y;
    }
    if (vlen > inb) {
      b_vstart = vstart + inb;
      st.site = &ce_emlrtRSI;
      b_y = x[b_vstart - 1];
      nfb = vlen - inb;
      b_st.site = &de_emlrtRSI;
      for (int32_T k{0}; k <= nfb - 2; k++) {
        b_y += x[b_vstart + k];
      }
      y += b_y;
    }
  }
  return y;
}

static real_T sumColumnB(const emlrtStack &sp,
                         const ::coder::array<real_T, 1U> &x, int32_T vlen)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T y;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  if (vlen <= 1024) {
    st.site = &xd_emlrtRSI;
    y = x[0];
    b_st.site = &de_emlrtRSI;
    if (vlen - 1 > 2147483646) {
      c_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(c_st);
    }
    for (int32_T k{0}; k <= vlen - 2; k++) {
      y += x[k + 1];
    }
  } else {
    real_T b_y;
    int32_T inb;
    int32_T nfb;
    nfb = vlen / 1024;
    inb = nfb << 10;
    st.site = &yd_emlrtRSI;
    y = x[0];
    b_st.site = &de_emlrtRSI;
    for (int32_T k{0}; k < 1023; k++) {
      y += x[k + 1];
    }
    st.site = &ae_emlrtRSI;
    for (int32_T k{2}; k <= nfb; k++) {
      int32_T vstart;
      st.site = &be_emlrtRSI;
      vstart = (k - 1) << 10;
      b_y = x[vstart];
      b_st.site = &de_emlrtRSI;
      for (int32_T b_k{0}; b_k < 1023; b_k++) {
        b_y += x[(vstart + b_k) + 1];
      }
      y += b_y;
    }
    if (vlen > inb) {
      st.site = &ce_emlrtRSI;
      b_y = x[inb];
      nfb = vlen - inb;
      b_st.site = &de_emlrtRSI;
      for (int32_T k{0}; k <= nfb - 2; k++) {
        b_y += x[(inb + k) + 1];
      }
      y += b_y;
    }
  }
  return y;
}

static real_T sumColumnB4(const ::coder::array<real_T, 1U> &x, int32_T vstart)
{
  real_T psum1;
  real_T psum2;
  real_T psum3;
  real_T psum4;
  psum1 = x[vstart - 1];
  psum2 = x[vstart + 1023];
  psum3 = x[vstart + 2047];
  psum4 = x[vstart + 3071];
  for (int32_T k{0}; k < 1023; k++) {
    int32_T psum1_tmp;
    psum1_tmp = vstart + k;
    psum1 += x[psum1_tmp];
    psum2 += x[psum1_tmp + 1024];
    psum3 += x[psum1_tmp + 2048];
    psum4 += x[psum1_tmp + 3072];
  }
  return (psum1 + psum2) + (psum3 + psum4);
}

real_T sumColumnB(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
                  int32_T col, int32_T vlen, int32_T vstart)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T y;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  if (vlen <= 1024) {
    int32_T i0;
    st.site = &xd_emlrtRSI;
    i0 = vstart + (col - 1) * x.size(0);
    y = x[i0 - 1];
    b_st.site = &de_emlrtRSI;
    if (vlen - 1 > 2147483646) {
      c_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(c_st);
    }
    for (int32_T k{0}; k <= vlen - 2; k++) {
      y += x[i0 + k];
    }
  } else {
    real_T b_y;
    int32_T i0;
    int32_T i0_tmp;
    int32_T inb;
    int32_T nfb;
    nfb = vlen / 1024;
    inb = nfb << 10;
    st.site = &yd_emlrtRSI;
    i0_tmp = (col - 1) * x.size(0);
    i0 = vstart + i0_tmp;
    y = x[i0 - 1];
    b_st.site = &de_emlrtRSI;
    for (int32_T k{0}; k < 1023; k++) {
      y += x[i0 + k];
    }
    st.site = &ae_emlrtRSI;
    for (int32_T k{2}; k <= nfb; k++) {
      st.site = &be_emlrtRSI;
      i0 = (vstart + ((k - 1) << 10)) + i0_tmp;
      b_y = x[i0 - 1];
      b_st.site = &de_emlrtRSI;
      for (int32_T b_k{0}; b_k < 1023; b_k++) {
        b_y += x[i0 + b_k];
      }
      y += b_y;
    }
    if (vlen > inb) {
      st.site = &ce_emlrtRSI;
      i0 = (vstart + inb) + i0_tmp;
      b_y = x[i0 - 1];
      nfb = vlen - inb;
      b_st.site = &de_emlrtRSI;
      for (int32_T k{0}; k <= nfb - 2; k++) {
        b_y += x[i0 + k];
      }
      y += b_y;
    }
  }
  return y;
}

real_T sumColumnB(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
                  int32_T col, int32_T vlen)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T y;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  if (vlen <= 1024) {
    int32_T i0;
    st.site = &xd_emlrtRSI;
    i0 = (col - 1) * x.size(0);
    y = x[i0];
    b_st.site = &de_emlrtRSI;
    if (vlen - 1 > 2147483646) {
      c_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(c_st);
    }
    for (int32_T k{0}; k <= vlen - 2; k++) {
      y += x[(i0 + k) + 1];
    }
  } else {
    real_T b_y;
    int32_T i0;
    int32_T i0_tmp;
    int32_T inb;
    int32_T nfb;
    nfb = vlen / 1024;
    inb = nfb << 10;
    st.site = &yd_emlrtRSI;
    i0_tmp = (col - 1) * x.size(0);
    y = x[i0_tmp];
    b_st.site = &de_emlrtRSI;
    for (int32_T k{0}; k < 1023; k++) {
      y += x[(i0_tmp + k) + 1];
    }
    st.site = &ae_emlrtRSI;
    for (int32_T k{2}; k <= nfb; k++) {
      st.site = &be_emlrtRSI;
      i0 = ((k - 1) << 10) + i0_tmp;
      b_y = x[i0];
      b_st.site = &de_emlrtRSI;
      for (int32_T b_k{0}; b_k < 1023; b_k++) {
        b_y += x[(i0 + b_k) + 1];
      }
      y += b_y;
    }
    if (vlen > inb) {
      st.site = &ce_emlrtRSI;
      i0 = (inb + i0_tmp) + 1;
      b_y = x[i0 - 1];
      nfb = vlen - inb;
      b_st.site = &de_emlrtRSI;
      for (int32_T k{0}; k <= nfb - 2; k++) {
        b_y += x[i0 + k];
      }
      y += b_y;
    }
  }
  return y;
}

real_T sumColumnB4(const ::coder::array<real_T, 2U> &x, int32_T col,
                   int32_T vstart)
{
  real_T psum1;
  real_T psum2;
  real_T psum3;
  real_T psum4;
  int32_T i1;
  i1 = vstart + (col - 1) * x.size(0);
  psum1 = x[i1 - 1];
  psum2 = x[i1 + 1023];
  psum3 = x[i1 + 2047];
  psum4 = x[i1 + 3071];
  for (int32_T k{0}; k < 1023; k++) {
    int32_T psum1_tmp;
    psum1_tmp = i1 + k;
    psum1 += x[psum1_tmp];
    psum2 += x[psum1_tmp + 1024];
    psum3 += x[psum1_tmp + 2048];
    psum4 += x[psum1_tmp + 3072];
  }
  return (psum1 + psum2) + (psum3 + psum4);
}

real_T sumMatrixColumns(const emlrtStack &sp,
                        const ::coder::array<real_T, 1U> &x, int32_T vlen)
{
  emlrtStack st;
  real_T y;
  st.prev = &sp;
  st.tls = sp.tls;
  if (vlen < 4096) {
    st.site = &td_emlrtRSI;
    y = sumColumnB(st, x, vlen);
  } else {
    int32_T inb;
    int32_T nfb;
    int32_T nleft;
    nfb = vlen / 4096;
    inb = nfb << 12;
    nleft = vlen - inb;
    y = sumColumnB4(x, 1);
    for (int32_T ib{2}; ib <= nfb; ib++) {
      y += sumColumnB4(x, ((ib - 1) << 12) + 1);
    }
    if (nleft > 0) {
      st.site = &wd_emlrtRSI;
      y += sumColumnB(st, x, nleft, inb + 1);
    }
  }
  return y;
}

} // namespace coder

// End of code generation (sumMatrixIncludeNaN.cpp)
