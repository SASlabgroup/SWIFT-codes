//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// sort.cpp
//
// Code generation for function 'sort'
//

// Include files
#include "sort.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "sortIdx.h"
#include "sortLE.h"
#include "coder_array.h"

// Variable Definitions
static emlrtRSInfo wf_emlrtRSI{
    76,     // lineNo
    "sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m" // pathName
};

static emlrtRSInfo xf_emlrtRSI{
    79,     // lineNo
    "sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m" // pathName
};

static emlrtRSInfo yf_emlrtRSI{
    81,     // lineNo
    "sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m" // pathName
};

static emlrtRSInfo ag_emlrtRSI{
    84,     // lineNo
    "sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m" // pathName
};

static emlrtRSInfo bg_emlrtRSI{
    87,     // lineNo
    "sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m" // pathName
};

static emlrtRSInfo cg_emlrtRSI{
    90,     // lineNo
    "sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m" // pathName
};

static emlrtRSInfo dg_emlrtRSI{
    55,         // lineNo
    "prodsize", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\shared\\coder\\coder\\lib\\+coder\\+"
    "internal\\prodsize.m" // pathName
};

static emlrtRSInfo eg_emlrtRSI{
    125,       // lineNo
    "sortIdx", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo
    fg_emlrtRSI{
        57,          // lineNo
        "mergesort", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\mergesort.m" // pathName
    };

static emlrtRSInfo
    gg_emlrtRSI{
        113,         // lineNo
        "mergesort", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\mergesort.m" // pathName
    };

static emlrtRSInfo
    hg_emlrtRSI{
        123,         // lineNo
        "mergesort", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\mergesort.m" // pathName
    };

static emlrtRSInfo
    ig_emlrtRSI{
        126,         // lineNo
        "mergesort", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\mergesort.m" // pathName
    };

static emlrtRTEInfo sf_emlrtRTEI{
    56,     // lineNo
    24,     // colNo
    "sort", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m" // pName
};

static emlrtRTEInfo tf_emlrtRTEI{
    75,     // lineNo
    26,     // colNo
    "sort", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m" // pName
};

static emlrtRTEInfo
    vf_emlrtRTEI{
        52,          // lineNo
        9,           // colNo
        "mergesort", // fName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\mergesort.m" // pName
    };

static emlrtRTEInfo
    wf_emlrtRTEI{
        122,         // lineNo
        13,          // colNo
        "mergesort", // fName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\mergesort.m" // pName
    };

// Function Definitions
namespace coder {
namespace internal {
void sort(const emlrtStack &sp, ::coder::array<real_T, 1U> &x,
          ::coder::array<int32_T, 1U> &idx)
{
  array<real_T, 1U> vwork;
  array<int32_T, 1U> iidx;
  emlrtStack b_st;
  emlrtStack st;
  int32_T dim;
  int32_T i;
  int32_T vlen;
  int32_T vstride;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  dim = 0;
  if (x.size(0) != 1) {
    dim = -1;
  }
  if (dim + 2 <= 1) {
    i = x.size(0);
  } else {
    i = 1;
  }
  vlen = i - 1;
  vwork.set_size(&sf_emlrtRTEI, &sp, i);
  idx.set_size(&tf_emlrtRTEI, &sp, x.size(0));
  st.site = &wf_emlrtRSI;
  vstride = 1;
  for (int32_T k{0}; k <= dim; k++) {
    vstride *= x.size(0);
  }
  st.site = &xf_emlrtRSI;
  st.site = &yf_emlrtRSI;
  if (vstride > 2147483646) {
    b_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(b_st);
  }
  for (int32_T j{0}; j < vstride; j++) {
    st.site = &ag_emlrtRSI;
    if (i > 2147483646) {
      b_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(b_st);
    }
    for (int32_T k{0}; k <= vlen; k++) {
      vwork[k] = x[j + k * vstride];
    }
    st.site = &bg_emlrtRSI;
    sortIdx(st, vwork, iidx);
    st.site = &cg_emlrtRSI;
    for (int32_T k{0}; k <= vlen; k++) {
      dim = j + k * vstride;
      x[dim] = vwork[k];
      idx[dim] = iidx[k];
    }
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

void sort(const emlrtStack &sp, ::coder::array<creal_T, 1U> &x,
          ::coder::array<int32_T, 1U> &idx)
{
  array<creal_T, 1U> vwork;
  array<creal_T, 1U> xwork;
  array<int32_T, 1U> iidx;
  array<int32_T, 1U> iwork;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack st;
  int32_T dim;
  int32_T i;
  int32_T k;
  int32_T qEnd;
  int32_T vlen_tmp;
  int32_T vstride;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  dim = 0;
  if (x.size(0) != 1) {
    dim = -1;
  }
  if (dim + 2 <= 1) {
    i = x.size(0);
  } else {
    i = 1;
  }
  vlen_tmp = i - 1;
  vwork.set_size(&sf_emlrtRTEI, &sp, i);
  idx.set_size(&tf_emlrtRTEI, &sp, x.size(0));
  st.site = &wf_emlrtRSI;
  vstride = 1;
  b_st.site = &dg_emlrtRSI;
  for (k = 0; k <= dim; k++) {
    vstride *= x.size(0);
  }
  st.site = &xf_emlrtRSI;
  st.site = &yf_emlrtRSI;
  if (vstride > 2147483646) {
    b_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(b_st);
  }
  for (int32_T j{0}; j < vstride; j++) {
    int32_T i1;
    int32_T i2;
    int32_T n_tmp;
    st.site = &ag_emlrtRSI;
    if (i > 2147483646) {
      b_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(b_st);
    }
    for (k = 0; k <= vlen_tmp; k++) {
      vwork[k] = x[j + k * vstride];
    }
    st.site = &bg_emlrtRSI;
    i1 = vwork.size(0);
    n_tmp = vwork.size(0) + 1;
    iidx.set_size(&uf_emlrtRTEI, &st, vwork.size(0));
    dim = vwork.size(0);
    for (i2 = 0; i2 < dim; i2++) {
      iidx[i2] = 0;
    }
    if (vwork.size(0) != 0) {
      b_st.site = &eg_emlrtRSI;
      iwork.set_size(&vf_emlrtRTEI, &b_st, vwork.size(0));
      c_st.site = &fg_emlrtRSI;
      if (vwork.size(0) - 1 > 2147483645) {
        d_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(d_st);
      }
      for (k = 1; k <= vlen_tmp; k += 2) {
        if (sortLE(vwork, k, k + 1)) {
          iidx[k - 1] = k;
          iidx[k] = k + 1;
        } else {
          iidx[k - 1] = k + 1;
          iidx[k] = k;
        }
      }
      if ((vwork.size(0) & 1) != 0) {
        iidx[vwork.size(0) - 1] = vwork.size(0);
      }
      dim = 2;
      while (dim < i1) {
        int32_T b_i2;
        int32_T b_j;
        b_i2 = dim << 1;
        b_j = 1;
        for (int32_T pEnd{dim + 1}; pEnd < i1 + 1; pEnd = qEnd + dim) {
          int32_T kEnd;
          int32_T p;
          int32_T q;
          p = b_j;
          q = pEnd;
          qEnd = b_j + b_i2;
          if (qEnd > i1 + 1) {
            qEnd = n_tmp;
          }
          k = 0;
          kEnd = qEnd - b_j;
          while (k + 1 <= kEnd) {
            int32_T i3;
            i2 = iidx[p - 1];
            i3 = iidx[q - 1];
            if (sortLE(vwork, i2, i3)) {
              iwork[k] = i2;
              p++;
              if (p == pEnd) {
                while (q < qEnd) {
                  k++;
                  iwork[k] = iidx[q - 1];
                  q++;
                }
              }
            } else {
              iwork[k] = i3;
              q++;
              if (q == qEnd) {
                while (p < pEnd) {
                  k++;
                  iwork[k] = iidx[p - 1];
                  p++;
                }
              }
            }
            k++;
          }
          c_st.site = &gg_emlrtRSI;
          for (k = 0; k < kEnd; k++) {
            iidx[(b_j + k) - 1] = iwork[k];
          }
          b_j = qEnd;
        }
        dim = b_i2;
      }
      xwork.set_size(&wf_emlrtRTEI, &b_st, vwork.size(0));
      c_st.site = &hg_emlrtRSI;
      if (vwork.size(0) > 2147483646) {
        d_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(d_st);
      }
      for (k = 0; k <= n_tmp - 2; k++) {
        xwork[k] = vwork[k];
      }
      c_st.site = &ig_emlrtRSI;
      for (k = 0; k <= n_tmp - 2; k++) {
        vwork[k] = xwork[iidx[k] - 1];
      }
    }
    st.site = &cg_emlrtRSI;
    for (k = 0; k <= vlen_tmp; k++) {
      i1 = j + k * vstride;
      x[i1] = vwork[k];
      idx[i1] = iidx[k];
    }
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

} // namespace internal
} // namespace coder

// End of code generation (sort.cpp)
