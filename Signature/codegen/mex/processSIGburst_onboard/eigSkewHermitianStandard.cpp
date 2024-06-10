//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eigSkewHermitianStandard.cpp
//
// Code generation for function 'eigSkewHermitianStandard'
//

// Include files
#include "eigSkewHermitianStandard.h"
#include "anyNonFinite.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "warning.h"
#include "coder_array.h"
#include "lapacke.h"
#include "mwmathutil.h"
#include <cstddef>

// Variable Definitions
static emlrtRSInfo ve_emlrtRSI{
    12,                         // lineNo
    "eigSkewHermitianStandard", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigSkew"
    "HermitianStandard.m" // pathName
};

static emlrtRSInfo we_emlrtRSI{
    24,                             // lineNo
    "eigRealSkewSymmetricStandard", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigReal"
    "SkewSymmetricStandard.m" // pathName
};

static emlrtRSInfo xe_emlrtRSI{
    22,                             // lineNo
    "eigRealSkewSymmetricStandard", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigReal"
    "SkewSymmetricStandard.m" // pathName
};

static emlrtRSInfo ye_emlrtRSI{
    35,      // lineNo
    "schur", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pathName
};

static emlrtRSInfo af_emlrtRSI{
    43,      // lineNo
    "schur", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pathName
};

static emlrtRSInfo bf_emlrtRSI{
    66,      // lineNo
    "schur", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pathName
};

static emlrtRSInfo cf_emlrtRSI{
    69,      // lineNo
    "schur", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pathName
};

static emlrtRSInfo df_emlrtRSI{
    70,      // lineNo
    "schur", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pathName
};

static emlrtRSInfo ef_emlrtRSI{
    83,      // lineNo
    "schur", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pathName
};

static emlrtRSInfo ff_emlrtRSI{
    48,     // lineNo
    "triu", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\triu.m" // pathName
};

static emlrtRSInfo gf_emlrtRSI{
    47,     // lineNo
    "triu", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\triu.m" // pathName
};

static emlrtRSInfo hf_emlrtRSI{
    15,       // lineNo
    "xgehrd", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgehrd.m" // pathName
};

static emlrtRSInfo if_emlrtRSI{
    85,             // lineNo
    "ceval_xgehrd", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgehrd.m" // pathName
};

static emlrtRSInfo jf_emlrtRSI{
    69,                // lineNo
    "ceval_xungorghr", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xungorghr.m" // pathName
};

static emlrtRSInfo kf_emlrtRSI{
    11,          // lineNo
    "xungorghr", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xungorghr.m" // pathName
};

static emlrtRSInfo lf_emlrtRSI{
    17,       // lineNo
    "xhseqr", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xhseqr.m" // pathName
};

static emlrtRSInfo mf_emlrtRSI{
    128,            // lineNo
    "ceval_xhseqr", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xhseqr.m" // pathName
};

static emlrtRSInfo nf_emlrtRSI{
    151,                   // lineNo
    "extractEigenVectors", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigReal"
    "SkewSymmetricStandard.m" // pathName
};

static emlrtRTEInfo q_emlrtRTEI{
    18,      // lineNo
    15,      // colNo
    "schur", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pName
};

static emlrtRTEInfo ie_emlrtRTEI{
    1,        // lineNo
    27,       // colNo
    "xgehrd", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgehrd.m" // pName
};

static emlrtRTEInfo je_emlrtRTEI{
    76,       // lineNo
    22,       // colNo
    "xgehrd", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgehrd.m" // pName
};

static emlrtRTEInfo ke_emlrtRTEI{
    86,       // lineNo
    9,        // colNo
    "xgehrd", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgehrd.m" // pName
};

static emlrtRTEInfo le_emlrtRTEI{
    87,       // lineNo
    9,        // colNo
    "xgehrd", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgehrd.m" // pName
};

static emlrtRTEInfo me_emlrtRTEI{
    69,      // lineNo
    13,      // colNo
    "schur", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pName
};

static emlrtRTEInfo ne_emlrtRTEI{
    111,      // lineNo
    29,       // colNo
    "xhseqr", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xhseqr.m" // pName
};

static emlrtRTEInfo oe_emlrtRTEI{
    112,      // lineNo
    29,       // colNo
    "xhseqr", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xhseqr.m" // pName
};

static emlrtRTEInfo pe_emlrtRTEI{
    129,      // lineNo
    9,        // colNo
    "xhseqr", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xhseqr.m" // pName
};

static emlrtRTEInfo qe_emlrtRTEI{
    130,      // lineNo
    9,        // colNo
    "xhseqr", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xhseqr.m" // pName
};

static emlrtRTEInfo re_emlrtRTEI{
    42,      // lineNo
    9,       // colNo
    "schur", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pName
};

static emlrtRTEInfo se_emlrtRTEI{
    46,      // lineNo
    9,       // colNo
    "schur", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\schur.m" // pName
};

static emlrtRTEInfo te_emlrtRTEI{
    108,                            // lineNo
    24,                             // colNo
    "eigRealSkewSymmetricStandard", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigReal"
    "SkewSymmetricStandard.m" // pName
};

static emlrtRTEInfo ue_emlrtRTEI{
    24,                             // lineNo
    9,                              // colNo
    "eigRealSkewSymmetricStandard", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigReal"
    "SkewSymmetricStandard.m" // pName
};

// Function Definitions
namespace coder {
void eigSkewHermitianStandard(const emlrtStack &sp,
                              const ::coder::array<real_T, 2U> &A,
                              ::coder::array<creal_T, 2U> &V,
                              ::coder::array<creal_T, 1U> &D)
{
  static const char_T b_fname[14]{'L', 'A', 'P', 'A', 'C', 'K', 'E',
                                  '_', 'd', 'o', 'r', 'g', 'h', 'r'};
  static const char_T c_fname[14]{'L', 'A', 'P', 'A', 'C', 'K', 'E',
                                  '_', 'd', 'h', 's', 'e', 'q', 'r'};
  static const char_T fname[14]{'L', 'A', 'P', 'A', 'C', 'K', 'E',
                                '_', 'd', 'g', 'e', 'h', 'r', 'd'};
  array<real_T, 2U> U;
  array<real_T, 2U> b_A;
  array<real_T, 2U> wi;
  array<real_T, 2U> wr;
  array<real_T, 1U> tau;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  real_T lambda;
  int32_T exitg1;
  int32_T i;
  int32_T istart;
  int32_T j;
  int32_T n;
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
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  st.site = &ve_emlrtRSI;
  b_st.site = &xe_emlrtRSI;
  if (A.size(0) != A.size(1)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &q_emlrtRTEI, "Coder:MATLAB:square",
                                  "Coder:MATLAB:square", 0);
  }
  c_st.site = &ye_emlrtRSI;
  if (internal::anyNonFinite(c_st, A)) {
    int32_T loop_ub_tmp;
    uint32_T unnamed_idx_0_tmp;
    unnamed_idx_0_tmp = static_cast<uint32_T>(A.size(0));
    U.set_size(&re_emlrtRTEI, &b_st, A.size(0), A.size(1));
    loop_ub_tmp = A.size(0) * A.size(1);
    for (istart = 0; istart < loop_ub_tmp; istart++) {
      U[istart] = rtNaN;
    }
    c_st.site = &af_emlrtRSI;
    n = A.size(0);
    if ((A.size(0) != 0) && (A.size(1) != 0) && (A.size(0) > 1)) {
      int32_T jend;
      istart = 2;
      if (A.size(0) - 2 < A.size(1) - 1) {
        jend = A.size(0) - 1;
      } else {
        jend = A.size(1);
      }
      d_st.site = &gf_emlrtRSI;
      for (j = 0; j < jend; j++) {
        d_st.site = &ff_emlrtRSI;
        if ((istart <= static_cast<int32_T>(unnamed_idx_0_tmp)) &&
            (static_cast<int32_T>(unnamed_idx_0_tmp) > 2147483646)) {
          e_st.site = &bc_emlrtRSI;
          check_forloop_overflow_error(e_st);
        }
        for (i = istart; i <= n; i++) {
          U[(i + U.size(0) * j) - 1] = 0.0;
        }
        istart++;
      }
    }
    b_A.set_size(&se_emlrtRTEI, &b_st, A.size(0), A.size(1));
    for (istart = 0; istart < loop_ub_tmp; istart++) {
      b_A[istart] = rtNaN;
    }
  } else {
    ptrdiff_t info_t;
    int32_T jend;
    boolean_T b;
    boolean_T b_p;
    boolean_T p;
    c_st.site = &bf_emlrtRSI;
    b_A.set_size(&ie_emlrtRTEI, &c_st, A.size(0), A.size(1));
    n = A.size(0) * A.size(1);
    for (istart = 0; istart < n; istart++) {
      b_A[istart] = A[istart];
    }
    d_st.site = &hf_emlrtRSI;
    n = b_A.size(0);
    if (b_A.size(0) < 1) {
      jend = 0;
    } else {
      jend = b_A.size(0) - 1;
    }
    tau.set_size(&je_emlrtRTEI, &d_st, jend);
    if (b_A.size(0) > 1) {
      info_t = LAPACKE_dgehrd(102, (ptrdiff_t)b_A.size(0), (ptrdiff_t)1,
                              (ptrdiff_t)b_A.size(0), &(b_A.data())[0],
                              (ptrdiff_t)muIntScalarMax_sint32(1, n),
                              &(tau.data())[0]);
      e_st.site = &if_emlrtRSI;
      if ((int32_T)info_t != 0) {
        p = true;
        if ((int32_T)info_t != -5) {
          if ((int32_T)info_t == -1010) {
            emlrtErrorWithMessageIdR2018a(&e_st, &o_emlrtRTEI, "MATLAB:nomem",
                                          "MATLAB:nomem", 0);
          } else {
            emlrtErrorWithMessageIdR2018a(
                &e_st, &n_emlrtRTEI, "Coder:toolbox:LAPACKCallErrorInfo",
                "Coder:toolbox:LAPACKCallErrorInfo", 5, 4, 14, &fname[0], 12,
                (int32_T)info_t);
          }
        }
      } else {
        p = false;
      }
      if (p) {
        n = b_A.size(0);
        istart = b_A.size(1);
        b_A.set_size(&ke_emlrtRTEI, &d_st, n, istart);
        n *= istart;
        for (istart = 0; istart < n; istart++) {
          b_A[istart] = rtNaN;
        }
        n = tau.size(0);
        tau.set_size(&le_emlrtRTEI, &d_st, n);
        for (istart = 0; istart < n; istart++) {
          tau[istart] = rtNaN;
        }
      }
    }
    c_st.site = &cf_emlrtRSI;
    U.set_size(&me_emlrtRTEI, &c_st, b_A.size(0), b_A.size(1));
    n = b_A.size(0) * b_A.size(1);
    for (istart = 0; istart < n; istart++) {
      U[istart] = b_A[istart];
    }
    d_st.site = &kf_emlrtRSI;
    b = ((U.size(0) != 0) && (U.size(1) != 0));
    if (b) {
      info_t = LAPACKE_dorghr(102, (ptrdiff_t)A.size(0), (ptrdiff_t)1,
                              (ptrdiff_t)A.size(0), &(U.data())[0],
                              (ptrdiff_t)A.size(0), &(tau.data())[0]);
      e_st.site = &jf_emlrtRSI;
      if ((int32_T)info_t != 0) {
        p = true;
        b_p = false;
        if ((int32_T)info_t == -5) {
          b_p = true;
        } else if ((int32_T)info_t == -7) {
          b_p = true;
        }
        if (!b_p) {
          if ((int32_T)info_t == -1010) {
            emlrtErrorWithMessageIdR2018a(&e_st, &o_emlrtRTEI, "MATLAB:nomem",
                                          "MATLAB:nomem", 0);
          } else {
            emlrtErrorWithMessageIdR2018a(
                &e_st, &n_emlrtRTEI, "Coder:toolbox:LAPACKCallErrorInfo",
                "Coder:toolbox:LAPACKCallErrorInfo", 5, 4, 14, &b_fname[0], 12,
                (int32_T)info_t);
          }
        }
      } else {
        p = false;
      }
      if (p) {
        n = U.size(0);
        istart = U.size(1);
        U.set_size(&me_emlrtRTEI, &d_st, n, istart);
        n *= istart;
        for (istart = 0; istart < n; istart++) {
          U[istart] = rtNaN;
        }
      }
    }
    c_st.site = &df_emlrtRSI;
    d_st.site = &lf_emlrtRSI;
    n = b_A.size(0);
    info_t = (ptrdiff_t)b_A.size(0);
    if (b) {
      wr.set_size(&ne_emlrtRTEI, &d_st, 1, b_A.size(0));
      wi.set_size(&oe_emlrtRTEI, &d_st, 1, b_A.size(0));
      info_t = LAPACKE_dhseqr(102, 'S', 'V', info_t, (ptrdiff_t)1,
                              (ptrdiff_t)b_A.size(0), &(b_A.data())[0], info_t,
                              &wr[0], &wi[0], &(U.data())[0],
                              (ptrdiff_t)muIntScalarMax_sint32(1, n));
      jend = (int32_T)info_t;
      e_st.site = &mf_emlrtRSI;
      if ((int32_T)info_t < 0) {
        p = true;
        b_p = false;
        if ((int32_T)info_t == -7) {
          b_p = true;
        } else if ((int32_T)info_t == -11) {
          b_p = true;
        }
        if (!b_p) {
          if ((int32_T)info_t == -1010) {
            emlrtErrorWithMessageIdR2018a(&e_st, &o_emlrtRTEI, "MATLAB:nomem",
                                          "MATLAB:nomem", 0);
          } else {
            emlrtErrorWithMessageIdR2018a(
                &e_st, &n_emlrtRTEI, "Coder:toolbox:LAPACKCallErrorInfo",
                "Coder:toolbox:LAPACKCallErrorInfo", 5, 4, 14, &c_fname[0], 12,
                (int32_T)info_t);
          }
        }
      } else {
        p = false;
      }
      if (p) {
        n = b_A.size(0);
        istart = b_A.size(1);
        b_A.set_size(&pe_emlrtRTEI, &d_st, n, istart);
        n *= istart;
        for (istart = 0; istart < n; istart++) {
          b_A[istart] = rtNaN;
        }
        n = U.size(0);
        istart = U.size(1);
        U.set_size(&qe_emlrtRTEI, &d_st, n, istart);
        n *= istart;
        for (istart = 0; istart < n; istart++) {
          U[istart] = rtNaN;
        }
      }
    } else {
      jend = 0;
    }
    if ((jend != 0) && (!emlrtSetWarningFlag(&b_st))) {
      c_st.site = &ef_emlrtRSI;
      internal::b_warning(c_st);
    }
  }
  n = b_A.size(0);
  D.set_size(&te_emlrtRTEI, &st, b_A.size(0));
  i = 1;
  do {
    exitg1 = 0;
    if (i <= n) {
      boolean_T guard1;
      guard1 = false;
      if (i != n) {
        lambda = b_A[i + b_A.size(0) * (i - 1)];
        if (lambda != 0.0) {
          lambda = muDoubleScalarAbs(lambda);
          D[i - 1].re = 0.0;
          D[i - 1].im = lambda;
          D[i].re = 0.0;
          D[i].im = -lambda;
          i += 2;
        } else {
          guard1 = true;
        }
      } else {
        guard1 = true;
      }
      if (guard1) {
        D[i - 1].re = 0.0;
        D[i - 1].im = 0.0;
        i++;
      }
    } else {
      exitg1 = 1;
    }
  } while (exitg1 == 0);
  b_st.site = &we_emlrtRSI;
  V.set_size(&ue_emlrtRTEI, &b_st, U.size(0), U.size(1));
  n = U.size(0) * U.size(1);
  for (istart = 0; istart < n; istart++) {
    V[istart].re = U[istart];
    V[istart].im = 0.0;
  }
  j = 1;
  n = b_A.size(0);
  do {
    exitg1 = 0;
    if (j <= n) {
      if (j != n) {
        lambda = b_A[j + b_A.size(0) * (j - 1)];
        if (lambda != 0.0) {
          if (lambda < 0.0) {
            istart = 1;
          } else {
            istart = -1;
          }
          c_st.site = &nf_emlrtRSI;
          if (n > 2147483646) {
            d_st.site = &bc_emlrtRSI;
            check_forloop_overflow_error(d_st);
          }
          for (i = 0; i < n; i++) {
            real_T ai;
            lambda = V[i + V.size(0) * (j - 1)].re;
            ai = static_cast<real_T>(istart) * V[i + V.size(0) * j].re;
            if (ai == 0.0) {
              V[i + V.size(0) * (j - 1)].re = lambda / 1.4142135623730951;
              V[i + V.size(0) * (j - 1)].im = 0.0;
            } else if (lambda == 0.0) {
              V[i + V.size(0) * (j - 1)].re = 0.0;
              V[i + V.size(0) * (j - 1)].im = ai / 1.4142135623730951;
            } else {
              V[i + V.size(0) * (j - 1)].re = lambda / 1.4142135623730951;
              V[i + V.size(0) * (j - 1)].im = ai / 1.4142135623730951;
            }
            V[i + V.size(0) * j].re = V[i + V.size(0) * (j - 1)].re;
            V[i + V.size(0) * j].im = -V[i + V.size(0) * (j - 1)].im;
          }
          j += 2;
        } else {
          j++;
        }
      } else {
        j++;
      }
    } else {
      exitg1 = 1;
    }
  } while (exitg1 == 0);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

} // namespace coder

// End of code generation (eigSkewHermitianStandard.cpp)
