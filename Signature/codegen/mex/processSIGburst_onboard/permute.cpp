//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// permute.cpp
//
// Code generation for function 'permute'
//

// Include files
#include "permute.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Variable Definitions
static emlrtRSInfo ih_emlrtRSI{
    44,        // lineNo
    "permute", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\permute.m" // pathName
};

static emlrtRSInfo jh_emlrtRSI{
    47,        // lineNo
    "permute", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\permute.m" // pathName
};

static emlrtRSInfo kh_emlrtRSI{
    53,        // lineNo
    "permute", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\permute.m" // pathName
};

static emlrtRSInfo lh_emlrtRSI{
    51,                  // lineNo
    "reshapeSizeChecks", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\reshapeSizeChecks.m" // pathName
};

static emlrtRSInfo mh_emlrtRSI{
    119,               // lineNo
    "computeDimsData", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\reshapeSizeChecks.m" // pathName
};

static emlrtRSInfo nh_emlrtRSI{
    71,       // lineNo
    "looper", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\permute.m" // pathName
};

static emlrtRSInfo oh_emlrtRSI{
    72,       // lineNo
    "looper", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\permute.m" // pathName
};

static emlrtRTEInfo u_emlrtRTEI{
    74,                  // lineNo
    13,                  // colNo
    "reshapeSizeChecks", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\reshapeSizeChecks.m" // pName
};

static emlrtRTEInfo v_emlrtRTEI{
    81,                  // lineNo
    23,                  // colNo
    "reshapeSizeChecks", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\reshapeSizeChecks.m" // pName
};

static emlrtRTEInfo if_emlrtRTEI{
    47,        // lineNo
    20,        // colNo
    "permute", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\permute.m" // pName
};

static emlrtRTEInfo jf_emlrtRTEI{
    44,        // lineNo
    5,         // colNo
    "permute", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\permute.m" // pName
};

// Function Declarations
namespace coder {
static boolean_T nomovement(const real_T perm[3],
                            const ::coder::array<real_T, 3U> &a);

}

// Function Definitions
namespace coder {
static boolean_T nomovement(const real_T perm[3],
                            const ::coder::array<real_T, 3U> &a)
{
  boolean_T b;
  b = true;
  if ((a.size(0) != 0) && (a.size(1) != 0) && (a.size(2) != 0)) {
    real_T plast;
    int32_T k;
    boolean_T exitg1;
    plast = 0.0;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 3)) {
      if (a.size(static_cast<int32_T>(perm[k]) - 1) != 1) {
        if (plast > perm[k]) {
          b = false;
          exitg1 = true;
        } else {
          plast = perm[k];
          k++;
        }
      } else {
        k++;
      }
    }
  }
  return b;
}

void b_permute(const emlrtStack &sp, const ::coder::array<real_T, 3U> &a,
               ::coder::array<real_T, 3U> &b)
{
  static const real_T dv[3]{3.0, 1.0, 2.0};
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  int32_T subsa_idx_1;
  int32_T subsa_idx_2;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  if (nomovement(dv, a)) {
    int32_T maxdimlen;
    int32_T nx;
    st.site = &ih_emlrtRSI;
    nx = a.size(0) * a.size(1) * a.size(2);
    b_st.site = &lh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    maxdimlen = a.size(0);
    if (a.size(1) > a.size(0)) {
      maxdimlen = a.size(1);
    }
    if (a.size(2) > maxdimlen) {
      maxdimlen = a.size(2);
    }
    maxdimlen = muIntScalarMax_sint32(nx, maxdimlen);
    if (a.size(2) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(0) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(1) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    maxdimlen = a.size(0) * a.size(2) * a.size(1);
    if (maxdimlen != nx) {
      emlrtErrorWithMessageIdR2018a(
          &st, &v_emlrtRTEI, "Coder:MATLAB:getReshapeDims_notSameNumel",
          "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }
    b.set_size(&jf_emlrtRTEI, &sp, a.size(2), a.size(0), a.size(1));
    for (nx = 0; nx < maxdimlen; nx++) {
      b[nx] = a[nx];
    }
  } else {
    int32_T maxdimlen;
    int32_T nx;
    st.site = &jh_emlrtRSI;
    nx = a.size(0) * a.size(1) * a.size(2);
    b_st.site = &lh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    maxdimlen = a.size(0);
    if (a.size(1) > a.size(0)) {
      maxdimlen = a.size(1);
    }
    if (a.size(2) > maxdimlen) {
      maxdimlen = a.size(2);
    }
    maxdimlen = muIntScalarMax_sint32(nx, maxdimlen);
    if (a.size(2) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(0) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(1) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(0) * a.size(2) * a.size(1) != nx) {
      emlrtErrorWithMessageIdR2018a(
          &st, &v_emlrtRTEI, "Coder:MATLAB:getReshapeDims_notSameNumel",
          "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }
    b.set_size(&if_emlrtRTEI, &sp, a.size(2), a.size(0), a.size(1));
    st.site = &kh_emlrtRSI;
    maxdimlen = a.size(2);
    b_st.site = &nh_emlrtRSI;
    if (a.size(2) > 2147483646) {
      c_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(c_st);
    }
    for (int32_T k{0}; k < maxdimlen; k++) {
      b_st.site = &oh_emlrtRSI;
      nx = a.size(1);
      c_st.site = &nh_emlrtRSI;
      if (a.size(1) > 2147483646) {
        d_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(d_st);
      }
      for (int32_T b_k{0}; b_k < nx; b_k++) {
        int32_T b_b;
        c_st.site = &oh_emlrtRSI;
        b_b = a.size(0);
        d_st.site = &nh_emlrtRSI;
        if (a.size(0) > 2147483646) {
          e_st.site = &bc_emlrtRSI;
          check_forloop_overflow_error(e_st);
        }
        if (a.size(0) - 1 >= 0) {
          subsa_idx_1 = b_k + 1;
          subsa_idx_2 = k + 1;
        }
        for (int32_T c_k{0}; c_k < b_b; c_k++) {
          b[((subsa_idx_2 + b.size(0) * c_k) +
             b.size(0) * b.size(1) * (subsa_idx_1 - 1)) -
            1] = a[(c_k + a.size(0) * (subsa_idx_1 - 1)) +
                   a.size(0) * a.size(1) * (subsa_idx_2 - 1)];
        }
      }
    }
  }
}

void permute(const emlrtStack &sp, const ::coder::array<real_T, 3U> &a,
             ::coder::array<real_T, 3U> &b)
{
  static const real_T dv[3]{1.0, 3.0, 2.0};
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  int32_T subsa_idx_1;
  int32_T subsa_idx_2;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  if (nomovement(dv, a)) {
    int32_T maxdimlen;
    int32_T nx;
    st.site = &ih_emlrtRSI;
    nx = a.size(0) * a.size(1) * a.size(2);
    b_st.site = &lh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    maxdimlen = a.size(0);
    if (a.size(1) > a.size(0)) {
      maxdimlen = a.size(1);
    }
    if (a.size(2) > maxdimlen) {
      maxdimlen = a.size(2);
    }
    maxdimlen = muIntScalarMax_sint32(nx, maxdimlen);
    if (a.size(0) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(2) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(1) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    maxdimlen = a.size(0) * a.size(2) * a.size(1);
    if (maxdimlen != nx) {
      emlrtErrorWithMessageIdR2018a(
          &st, &v_emlrtRTEI, "Coder:MATLAB:getReshapeDims_notSameNumel",
          "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }
    b.set_size(&jf_emlrtRTEI, &sp, a.size(0), a.size(2), a.size(1));
    for (nx = 0; nx < maxdimlen; nx++) {
      b[nx] = a[nx];
    }
  } else {
    int32_T maxdimlen;
    int32_T nx;
    st.site = &jh_emlrtRSI;
    nx = a.size(0) * a.size(1) * a.size(2);
    b_st.site = &lh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    c_st.site = &mh_emlrtRSI;
    maxdimlen = a.size(0);
    if (a.size(1) > a.size(0)) {
      maxdimlen = a.size(1);
    }
    if (a.size(2) > maxdimlen) {
      maxdimlen = a.size(2);
    }
    maxdimlen = muIntScalarMax_sint32(nx, maxdimlen);
    if (a.size(0) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(2) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(1) > maxdimlen) {
      emlrtErrorWithMessageIdR2018a(
          &st, &u_emlrtRTEI, "Coder:toolbox:reshape_emptyReshapeLimit",
          "Coder:toolbox:reshape_emptyReshapeLimit", 0);
    }
    if (a.size(0) * a.size(2) * a.size(1) != nx) {
      emlrtErrorWithMessageIdR2018a(
          &st, &v_emlrtRTEI, "Coder:MATLAB:getReshapeDims_notSameNumel",
          "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }
    b.set_size(&if_emlrtRTEI, &sp, a.size(0), a.size(2), a.size(1));
    st.site = &kh_emlrtRSI;
    maxdimlen = a.size(2);
    b_st.site = &nh_emlrtRSI;
    if (a.size(2) > 2147483646) {
      c_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(c_st);
    }
    for (int32_T k{0}; k < maxdimlen; k++) {
      b_st.site = &oh_emlrtRSI;
      nx = a.size(1);
      c_st.site = &nh_emlrtRSI;
      if (a.size(1) > 2147483646) {
        d_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(d_st);
      }
      for (int32_T b_k{0}; b_k < nx; b_k++) {
        int32_T b_b;
        c_st.site = &oh_emlrtRSI;
        b_b = a.size(0);
        d_st.site = &nh_emlrtRSI;
        if (a.size(0) > 2147483646) {
          e_st.site = &bc_emlrtRSI;
          check_forloop_overflow_error(e_st);
        }
        if (a.size(0) - 1 >= 0) {
          subsa_idx_1 = b_k + 1;
          subsa_idx_2 = k + 1;
        }
        for (int32_T c_k{0}; c_k < b_b; c_k++) {
          b[(c_k + b.size(0) * (subsa_idx_2 - 1)) +
            b.size(0) * b.size(1) * (subsa_idx_1 - 1)] =
              a[(c_k + a.size(0) * (subsa_idx_1 - 1)) +
                a.size(0) * a.size(1) * (subsa_idx_2 - 1)];
        }
      }
    }
  }
}

} // namespace coder

// End of code generation (permute.cpp)
