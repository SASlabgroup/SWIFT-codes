//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// sortIdx.cpp
//
// Code generation for function 'sortIdx'
//

// Include files
#include "sortIdx.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Variable Definitions
static emlrtRSInfo gi_emlrtRSI{
    105,       // lineNo
    "sortIdx", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo hi_emlrtRSI{
    308,                // lineNo
    "block_merge_sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo ii_emlrtRSI{
    316,                // lineNo
    "block_merge_sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo ji_emlrtRSI{
    317,                // lineNo
    "block_merge_sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo ki_emlrtRSI{
    325,                // lineNo
    "block_merge_sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo li_emlrtRSI{
    333,                // lineNo
    "block_merge_sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo mi_emlrtRSI{
    392,                      // lineNo
    "initialize_vector_sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo ni_emlrtRSI{
    420,                      // lineNo
    "initialize_vector_sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo oi_emlrtRSI{
    427,                      // lineNo
    "initialize_vector_sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo pi_emlrtRSI{
    587,                // lineNo
    "merge_pow2_block", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo qi_emlrtRSI{
    589,                // lineNo
    "merge_pow2_block", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo ri_emlrtRSI{
    617,                // lineNo
    "merge_pow2_block", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo si_emlrtRSI{
    499,           // lineNo
    "merge_block", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo ui_emlrtRSI{
    507,           // lineNo
    "merge_block", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo vi_emlrtRSI{
    514,           // lineNo
    "merge_block", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo wi_emlrtRSI{
    561,     // lineNo
    "merge", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRSInfo xi_emlrtRSI{
    530,     // lineNo
    "merge", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pathName
};

static emlrtRTEInfo xf_emlrtRTEI{
    386,       // lineNo
    1,         // colNo
    "sortIdx", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pName
};

static emlrtRTEInfo yf_emlrtRTEI{
    388,       // lineNo
    1,         // colNo
    "sortIdx", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pName
};

// Function Declarations
namespace coder {
namespace internal {
static void merge(const emlrtStack &sp, ::coder::array<int32_T, 1U> &idx,
                  ::coder::array<real_T, 1U> &x, int32_T offset, int32_T np,
                  int32_T nq, ::coder::array<int32_T, 1U> &iwork,
                  ::coder::array<real_T, 1U> &xwork);

static void merge_block(const emlrtStack &sp, ::coder::array<int32_T, 1U> &idx,
                        ::coder::array<real_T, 1U> &x, int32_T offset,
                        int32_T n, int32_T preSortLevel,
                        ::coder::array<int32_T, 1U> &iwork,
                        ::coder::array<real_T, 1U> &xwork);

} // namespace internal
} // namespace coder

// Function Definitions
namespace coder {
namespace internal {
static void merge(const emlrtStack &sp, ::coder::array<int32_T, 1U> &idx,
                  ::coder::array<real_T, 1U> &x, int32_T offset, int32_T np,
                  int32_T nq, ::coder::array<int32_T, 1U> &iwork,
                  ::coder::array<real_T, 1U> &xwork)
{
  emlrtStack b_st;
  emlrtStack st;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (nq != 0) {
    int32_T iout;
    int32_T n_tmp;
    int32_T p;
    int32_T q;
    n_tmp = np + nq;
    st.site = &xi_emlrtRSI;
    if (n_tmp > 2147483646) {
      b_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(b_st);
    }
    for (int32_T j{0}; j < n_tmp; j++) {
      iout = offset + j;
      iwork[j] = idx[iout];
      xwork[j] = x[iout];
    }
    p = 0;
    q = np;
    iout = offset - 1;
    int32_T exitg1;
    do {
      exitg1 = 0;
      iout++;
      if (xwork[p] <= xwork[q]) {
        idx[iout] = iwork[p];
        x[iout] = xwork[p];
        if (p + 1 < np) {
          p++;
        } else {
          exitg1 = 1;
        }
      } else {
        idx[iout] = iwork[q];
        x[iout] = xwork[q];
        if (q + 1 < n_tmp) {
          q++;
        } else {
          q = iout - p;
          st.site = &wi_emlrtRSI;
          if ((p + 1 <= np) && (np > 2147483646)) {
            b_st.site = &bc_emlrtRSI;
            check_forloop_overflow_error(b_st);
          }
          for (int32_T j{p + 1}; j <= np; j++) {
            iout = q + j;
            idx[iout] = iwork[j - 1];
            x[iout] = xwork[j - 1];
          }
          exitg1 = 1;
        }
      }
    } while (exitg1 == 0);
  }
}

static void merge_block(const emlrtStack &sp, ::coder::array<int32_T, 1U> &idx,
                        ::coder::array<real_T, 1U> &x, int32_T offset,
                        int32_T n, int32_T preSortLevel,
                        ::coder::array<int32_T, 1U> &iwork,
                        ::coder::array<real_T, 1U> &xwork)
{
  emlrtStack st;
  int32_T bLen;
  int32_T nPairs;
  st.prev = &sp;
  st.tls = sp.tls;
  nPairs = n >> preSortLevel;
  bLen = 1 << preSortLevel;
  while (nPairs > 1) {
    int32_T nTail;
    int32_T tailOffset;
    if ((nPairs & 1) != 0) {
      nPairs--;
      tailOffset = bLen * nPairs;
      nTail = n - tailOffset;
      if (nTail > bLen) {
        st.site = &si_emlrtRSI;
        merge(st, idx, x, offset + tailOffset, bLen, nTail - bLen, iwork,
              xwork);
      }
    }
    tailOffset = bLen << 1;
    nPairs >>= 1;
    for (nTail = 0; nTail < nPairs; nTail++) {
      st.site = &ui_emlrtRSI;
      merge(st, idx, x, offset + nTail * tailOffset, bLen, bLen, iwork, xwork);
    }
    bLen = tailOffset;
  }
  if (n > bLen) {
    st.site = &vi_emlrtRSI;
    merge(st, idx, x, offset, bLen, n - bLen, iwork, xwork);
  }
}

void sortIdx(const emlrtStack &sp, ::coder::array<real_T, 1U> &x,
             ::coder::array<int32_T, 1U> &idx)
{
  array<real_T, 1U> xwork;
  array<int32_T, 1U> iwork;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack st;
  int32_T i;
  int32_T ib;
  uint32_T unnamed_idx_0;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  unnamed_idx_0 = static_cast<uint32_T>(x.size(0));
  idx.set_size(&uf_emlrtRTEI, &sp, static_cast<int32_T>(unnamed_idx_0));
  ib = static_cast<int32_T>(unnamed_idx_0);
  for (i = 0; i < ib; i++) {
    idx[i] = 0;
  }
  if (x.size(0) != 0) {
    real_T x4[4];
    int32_T idx4[4];
    int32_T bLen;
    int32_T i2;
    int32_T i3;
    int32_T i4;
    int32_T idx_tmp;
    int32_T n;
    int32_T quartetOffset;
    int32_T wOffset_tmp;
    st.site = &gi_emlrtRSI;
    b_st.site = &hi_emlrtRSI;
    n = x.size(0);
    x4[0] = 0.0;
    idx4[0] = 0;
    x4[1] = 0.0;
    idx4[1] = 0;
    x4[2] = 0.0;
    idx4[2] = 0;
    x4[3] = 0.0;
    idx4[3] = 0;
    iwork.set_size(&xf_emlrtRTEI, &b_st, static_cast<int32_T>(unnamed_idx_0));
    for (i = 0; i < ib; i++) {
      iwork[i] = 0;
    }
    ib = x.size(0);
    xwork.set_size(&yf_emlrtRTEI, &b_st, ib);
    for (i = 0; i < ib; i++) {
      xwork[i] = 0.0;
    }
    bLen = 0;
    ib = 0;
    c_st.site = &mi_emlrtRSI;
    if (x.size(0) > 2147483646) {
      d_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(d_st);
    }
    for (int32_T k{0}; k < n; k++) {
      if (muDoubleScalarIsNaN(x[k])) {
        idx_tmp = (n - bLen) - 1;
        idx[idx_tmp] = k + 1;
        xwork[idx_tmp] = x[k];
        bLen++;
      } else {
        ib++;
        idx4[ib - 1] = k + 1;
        x4[ib - 1] = x[k];
        if (ib == 4) {
          real_T d;
          real_T d1;
          int8_T b_i2;
          int8_T b_i3;
          int8_T b_i4;
          int8_T i1;
          quartetOffset = k - bLen;
          if (x4[0] <= x4[1]) {
            ib = 1;
            i2 = 2;
          } else {
            ib = 2;
            i2 = 1;
          }
          if (x4[2] <= x4[3]) {
            i3 = 3;
            i4 = 4;
          } else {
            i3 = 4;
            i4 = 3;
          }
          d = x4[i3 - 1];
          d1 = x4[ib - 1];
          if (d1 <= d) {
            d1 = x4[i2 - 1];
            if (d1 <= d) {
              i1 = static_cast<int8_T>(ib);
              b_i2 = static_cast<int8_T>(i2);
              b_i3 = static_cast<int8_T>(i3);
              b_i4 = static_cast<int8_T>(i4);
            } else if (d1 <= x4[i4 - 1]) {
              i1 = static_cast<int8_T>(ib);
              b_i2 = static_cast<int8_T>(i3);
              b_i3 = static_cast<int8_T>(i2);
              b_i4 = static_cast<int8_T>(i4);
            } else {
              i1 = static_cast<int8_T>(ib);
              b_i2 = static_cast<int8_T>(i3);
              b_i3 = static_cast<int8_T>(i4);
              b_i4 = static_cast<int8_T>(i2);
            }
          } else {
            d = x4[i4 - 1];
            if (d1 <= d) {
              if (x4[i2 - 1] <= d) {
                i1 = static_cast<int8_T>(i3);
                b_i2 = static_cast<int8_T>(ib);
                b_i3 = static_cast<int8_T>(i2);
                b_i4 = static_cast<int8_T>(i4);
              } else {
                i1 = static_cast<int8_T>(i3);
                b_i2 = static_cast<int8_T>(ib);
                b_i3 = static_cast<int8_T>(i4);
                b_i4 = static_cast<int8_T>(i2);
              }
            } else {
              i1 = static_cast<int8_T>(i3);
              b_i2 = static_cast<int8_T>(i4);
              b_i3 = static_cast<int8_T>(ib);
              b_i4 = static_cast<int8_T>(i2);
            }
          }
          idx[quartetOffset - 3] = idx4[i1 - 1];
          idx[quartetOffset - 2] = idx4[b_i2 - 1];
          idx[quartetOffset - 1] = idx4[b_i3 - 1];
          idx[quartetOffset] = idx4[b_i4 - 1];
          x[quartetOffset - 3] = x4[i1 - 1];
          x[quartetOffset - 2] = x4[b_i2 - 1];
          x[quartetOffset - 1] = x4[b_i3 - 1];
          x[quartetOffset] = x4[b_i4 - 1];
          ib = 0;
        }
      }
    }
    wOffset_tmp = x.size(0) - bLen;
    if (ib > 0) {
      int8_T perm[4];
      perm[1] = 0;
      perm[2] = 0;
      perm[3] = 0;
      if (ib == 1) {
        perm[0] = 1;
      } else if (ib == 2) {
        if (x4[0] <= x4[1]) {
          perm[0] = 1;
          perm[1] = 2;
        } else {
          perm[0] = 2;
          perm[1] = 1;
        }
      } else if (x4[0] <= x4[1]) {
        if (x4[1] <= x4[2]) {
          perm[0] = 1;
          perm[1] = 2;
          perm[2] = 3;
        } else if (x4[0] <= x4[2]) {
          perm[0] = 1;
          perm[1] = 3;
          perm[2] = 2;
        } else {
          perm[0] = 3;
          perm[1] = 1;
          perm[2] = 2;
        }
      } else if (x4[0] <= x4[2]) {
        perm[0] = 2;
        perm[1] = 1;
        perm[2] = 3;
      } else if (x4[1] <= x4[2]) {
        perm[0] = 2;
        perm[1] = 3;
        perm[2] = 1;
      } else {
        perm[0] = 3;
        perm[1] = 2;
        perm[2] = 1;
      }
      c_st.site = &ni_emlrtRSI;
      if (ib > 2147483646) {
        d_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(d_st);
      }
      i = static_cast<uint8_T>(ib);
      for (int32_T k{0}; k < i; k++) {
        idx_tmp = perm[k] - 1;
        quartetOffset = (wOffset_tmp - ib) + k;
        idx[quartetOffset] = idx4[idx_tmp];
        x[quartetOffset] = x4[idx_tmp];
      }
    }
    ib = bLen >> 1;
    c_st.site = &oi_emlrtRSI;
    for (int32_T k{0}; k < ib; k++) {
      quartetOffset = wOffset_tmp + k;
      i2 = idx[quartetOffset];
      idx_tmp = (n - k) - 1;
      idx[quartetOffset] = idx[idx_tmp];
      idx[idx_tmp] = i2;
      x[quartetOffset] = xwork[idx_tmp];
      x[idx_tmp] = xwork[quartetOffset];
    }
    if ((bLen & 1) != 0) {
      i = wOffset_tmp + ib;
      x[i] = xwork[i];
    }
    ib = 2;
    if (wOffset_tmp > 1) {
      if (x.size(0) >= 256) {
        int32_T nBlocks;
        nBlocks = wOffset_tmp >> 8;
        if (nBlocks > 0) {
          b_st.site = &ii_emlrtRSI;
          for (int32_T b{0}; b < nBlocks; b++) {
            real_T b_xwork[256];
            int32_T b_iwork[256];
            b_st.site = &ji_emlrtRSI;
            i4 = (b << 8) - 1;
            for (int32_T b_b{0}; b_b < 6; b_b++) {
              bLen = 1 << (b_b + 2);
              n = bLen << 1;
              i = 256 >> (b_b + 3);
              c_st.site = &pi_emlrtRSI;
              for (int32_T k{0}; k < i; k++) {
                i2 = (i4 + k * n) + 1;
                c_st.site = &qi_emlrtRSI;
                for (quartetOffset = 0; quartetOffset < n; quartetOffset++) {
                  ib = i2 + quartetOffset;
                  b_iwork[quartetOffset] = idx[ib];
                  b_xwork[quartetOffset] = x[ib];
                }
                i3 = 0;
                quartetOffset = bLen;
                ib = i2 - 1;
                int32_T exitg1;
                do {
                  exitg1 = 0;
                  ib++;
                  if (b_xwork[i3] <= b_xwork[quartetOffset]) {
                    idx[ib] = b_iwork[i3];
                    x[ib] = b_xwork[i3];
                    if (i3 + 1 < bLen) {
                      i3++;
                    } else {
                      exitg1 = 1;
                    }
                  } else {
                    idx[ib] = b_iwork[quartetOffset];
                    x[ib] = b_xwork[quartetOffset];
                    if (quartetOffset + 1 < n) {
                      quartetOffset++;
                    } else {
                      ib -= i3;
                      c_st.site = &ri_emlrtRSI;
                      for (quartetOffset = i3 + 1; quartetOffset <= bLen;
                           quartetOffset++) {
                        idx_tmp = ib + quartetOffset;
                        idx[idx_tmp] = b_iwork[quartetOffset - 1];
                        x[idx_tmp] = b_xwork[quartetOffset - 1];
                      }
                      exitg1 = 1;
                    }
                  }
                } while (exitg1 == 0);
              }
            }
          }
          ib = nBlocks << 8;
          quartetOffset = wOffset_tmp - ib;
          if (quartetOffset > 0) {
            b_st.site = &ki_emlrtRSI;
            merge_block(b_st, idx, x, ib, quartetOffset, 2, iwork, xwork);
          }
          ib = 8;
        }
      }
      b_st.site = &li_emlrtRSI;
      merge_block(b_st, idx, x, 0, wOffset_tmp, ib, iwork, xwork);
    }
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

} // namespace internal
} // namespace coder

// End of code generation (sortIdx.cpp)
