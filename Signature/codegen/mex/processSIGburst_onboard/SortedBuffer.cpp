//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// SortedBuffer.cpp
//
// Code generation for function 'SortedBuffer'
//

// Include files
#include "SortedBuffer.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Variable Definitions
static emlrtRSInfo pc_emlrtRSI{
    138,                    // lineNo
    "SortedBuffer/replace", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\SortedBuffer."
    "m" // pathName
};

static emlrtRSInfo qc_emlrtRSI{
    121,                   // lineNo
    "SortedBuffer/remove", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\SortedBuffer."
    "m" // pathName
};

static emlrtRTEInfo rf_emlrtRTEI{
    63,             // lineNo
    24,             // colNo
    "SortedBuffer", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\SortedBuffer."
    "m" // pName
};

static emlrtRSInfo oj_emlrtRSI{
    136,                    // lineNo
    "SortedBuffer/replace", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\SortedBuffer."
    "m" // pathName
};

static emlrtRSInfo pj_emlrtRSI{
    161,                    // lineNo
    "SortedBuffer/replace", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\SortedBuffer."
    "m" // pathName
};

// Function Definitions
namespace coder {
namespace internal {
int32_T SortedBuffer::locateElement(real_T x) const
{
  int32_T i;
  if ((nbuf == 0) || (x < buf[0])) {
    i = 0;
  } else if (x < buf[nbuf - 1]) {
    int32_T ip1;
    int32_T upper;
    i = 1;
    ip1 = 2;
    upper = nbuf;
    while (upper > ip1) {
      int32_T m;
      m = (i + upper) >> 1;
      if (x < buf[m - 1]) {
        upper = m;
      } else {
        i = m;
        ip1 = m + 1;
      }
    }
  } else {
    i = nbuf;
  }
  return i;
}

void SortedBuffer::b_remove(const emlrtStack &sp, real_T x)
{
  emlrtStack b_st;
  emlrtStack st;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (!muDoubleScalarIsNaN(x)) {
    if (nbuf == 1) {
      if (x == buf[0]) {
        nbuf = 0;
      }
    } else {
      int32_T i;
      i = locateElement(x);
      if ((i > 0) && (x == buf[i - 1])) {
        int32_T a;
        int32_T b;
        a = i + 1;
        b = nbuf;
        st.site = &qc_emlrtRSI;
        if ((i + 1 <= nbuf) && (nbuf > 2147483646)) {
          b_st.site = &bc_emlrtRSI;
          check_forloop_overflow_error(b_st);
        }
        for (i = a; i <= b; i++) {
          buf[i - 2] = buf[i - 1];
        }
        nbuf--;
      }
    }
  }
}

void SortedBuffer::insert(const emlrtStack &sp, real_T x)
{
  int32_T i;
  int32_T i1;
  if (nbuf >= buf.size(0)) {
    i = buf.size(0);
    buf.set_size(&rf_emlrtRTEI, &sp, i + 256);
    for (i1 = 0; i1 < 256; i1++) {
      buf[i + i1] = 0.0;
    }
  }
  if (!muDoubleScalarIsNaN(x)) {
    if (nbuf == 0) {
      buf[0] = x;
      nbuf = 1;
    } else {
      int32_T b_i;
      b_i = locateElement(x);
      if (b_i == 0) {
        i = nbuf;
        for (int32_T k{i}; k >= 1; k--) {
          buf[k] = buf[k - 1];
        }
        buf[0] = x;
        nbuf++;
      } else if (b_i >= nbuf) {
        nbuf++;
        buf[nbuf - 1] = x;
      } else {
        i = nbuf;
        i1 = b_i + 1;
        for (int32_T k{i}; k >= i1; k--) {
          buf[k] = buf[k - 1];
        }
        buf[b_i] = x;
        nbuf++;
      }
    }
  }
}

void SortedBuffer::replace(const emlrtStack &sp, real_T xold, real_T xnew)
{
  emlrtStack st;
  st.prev = &sp;
  st.tls = sp.tls;
  if (muDoubleScalarIsNaN(xold)) {
    st.site = &oj_emlrtRSI;
    insert(st, xnew);
  } else if (muDoubleScalarIsNaN(xnew)) {
    st.site = &pc_emlrtRSI;
    b_remove(st, xold);
  } else {
    int32_T iold;
    iold = locateElement(xold);
    if ((iold > 0) && (buf[iold - 1] == xold)) {
      int32_T inew;
      inew = locateElement(xnew);
      if (iold <= inew) {
        int32_T i;
        i = inew - 1;
        for (int32_T k{iold}; k <= i; k++) {
          buf[k - 1] = buf[k];
        }
        buf[inew - 1] = xnew;
      } else if (iold == inew + 1) {
        buf[iold - 1] = xnew;
      } else {
        int32_T i;
        i = inew + 2;
        for (int32_T k{iold}; k >= i; k--) {
          buf[k - 1] = buf[k - 2];
        }
        buf[inew] = xnew;
      }
    } else {
      st.site = &pj_emlrtRSI;
      insert(st, xnew);
    }
  }
}

} // namespace internal
} // namespace coder

// End of code generation (SortedBuffer.cpp)
