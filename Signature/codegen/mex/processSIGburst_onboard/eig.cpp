//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eig.cpp
//
// Code generation for function 'eig'
//

// Include files
#include "eig.h"
#include "anyNonFinite.h"
#include "eigSkewHermitianStandard.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "warning.h"
#include "coder_array.h"
#include "lapacke.h"
#include <cstddef>

// Variable Definitions
static emlrtRSInfo ke_emlrtRSI{
    81,    // lineNo
    "eig", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\eig.m" // pathName
};

static emlrtRSInfo le_emlrtRSI{
    125,   // lineNo
    "eig", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\eig.m" // pathName
};

static emlrtRSInfo me_emlrtRSI{
    133,   // lineNo
    "eig", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\eig.m" // pathName
};

static emlrtRSInfo ne_emlrtRSI{
    141,   // lineNo
    "eig", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\eig.m" // pathName
};

static emlrtRSInfo re_emlrtRSI{
    24,                     // lineNo
    "eigHermitianStandard", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigHerm"
    "itianStandard.m" // pathName
};

static emlrtRSInfo se_emlrtRSI{
    40,                     // lineNo
    "eigHermitianStandard", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigHerm"
    "itianStandard.m" // pathName
};

static emlrtRSInfo te_emlrtRSI{
    10,        // lineNo
    "xsyheev", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xsyheev.m" // pathName
};

static emlrtRSInfo ue_emlrtRSI{
    61,              // lineNo
    "ceval_xsyheev", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xsyheev.m" // pathName
};

static emlrtRSInfo of_emlrtRSI{
    24,            // lineNo
    "eigStandard", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigStan"
    "dard.m" // pathName
};

static emlrtRSInfo pf_emlrtRSI{
    45,            // lineNo
    "eigStandard", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigStan"
    "dard.m" // pathName
};

static emlrtRSInfo qf_emlrtRSI{
    40,      // lineNo
    "xgeev", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pathName
};

static emlrtRSInfo rf_emlrtRSI{
    174,           // lineNo
    "ceval_xgeev", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pathName
};

static emlrtRSInfo sf_emlrtRSI{
    172,           // lineNo
    "ceval_xgeev", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pathName
};

static emlrtRSInfo tf_emlrtRSI{
    164,           // lineNo
    "ceval_xgeev", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pathName
};

static emlrtRSInfo uf_emlrtRSI{
    159,           // lineNo
    "ceval_xgeev", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pathName
};

static emlrtRTEInfo p_emlrtRTEI{
    50,    // lineNo
    27,    // colNo
    "eig", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\eig.m" // pName
};

static emlrtRTEInfo sd_emlrtRTEI{
    56,    // lineNo
    24,    // colNo
    "eig", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\eig.m" // pName
};

static emlrtRTEInfo td_emlrtRTEI{
    58,    // lineNo
    28,    // colNo
    "eig", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\eig.m" // pName
};

static emlrtRTEInfo ud_emlrtRTEI{
    40,      // lineNo
    37,      // colNo
    "xgeev", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pName
};

static emlrtRTEInfo vd_emlrtRTEI{
    99,      // lineNo
    24,      // colNo
    "xgeev", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pName
};

static emlrtRTEInfo wd_emlrtRTEI{
    102,     // lineNo
    21,      // colNo
    "xgeev", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pName
};

static emlrtRTEInfo xd_emlrtRTEI{
    131,     // lineNo
    29,      // colNo
    "xgeev", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pName
};

static emlrtRTEInfo yd_emlrtRTEI{
    132,     // lineNo
    29,      // colNo
    "xgeev", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pName
};

static emlrtRTEInfo ae_emlrtRTEI{
    134,     // lineNo
    35,      // colNo
    "xgeev", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pName
};

static emlrtRTEInfo be_emlrtRTEI{
    168,     // lineNo
    16,      // colNo
    "xgeev", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xgeev.m" // pName
};

static emlrtRTEInfo ce_emlrtRTEI{
    1,         // lineNo
    30,        // colNo
    "xsyheev", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xsyheev.m" // pName
};

static emlrtRTEInfo de_emlrtRTEI{
    47,        // lineNo
    20,        // colNo
    "xsyheev", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\xsyheev.m" // pName
};

static emlrtRTEInfo ee_emlrtRTEI{
    25,                     // lineNo
    9,                      // colNo
    "eigHermitianStandard", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigHerm"
    "itianStandard.m" // pName
};

static emlrtRTEInfo fe_emlrtRTEI{
    33,                     // lineNo
    5,                      // colNo
    "eigHermitianStandard", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eigHerm"
    "itianStandard.m" // pName
};

static emlrtRTEInfo ge_emlrtRTEI{
    85,    // lineNo
    9,     // colNo
    "eig", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\eig.m" // pName
};

static emlrtRTEInfo he_emlrtRTEI{
    87,    // lineNo
    13,    // colNo
    "eig", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\eig.m" // pName
};

// Function Definitions
namespace coder {
void eig(const emlrtStack &sp, const ::coder::array<real_T, 2U> &A,
         ::coder::array<creal_T, 2U> &V, ::coder::array<creal_T, 1U> &D)
{
  static const char_T b_fname[14]{'L', 'A', 'P', 'A', 'C', 'K', 'E',
                                  '_', 'd', 'g', 'e', 'e', 'v', 'x'};
  static const char_T fname[13]{'L', 'A', 'P', 'A', 'C', 'K', 'E',
                                '_', 'd', 's', 'y', 'e', 'v'};
  ptrdiff_t ihi_t;
  ptrdiff_t ilo_t;
  array<real_T, 2U> b_A;
  array<real_T, 2U> vright;
  array<real_T, 1U> scale;
  array<real_T, 1U> wimag;
  array<real_T, 1U> wreal;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  real_T abnrm;
  real_T rconde;
  real_T rcondv;
  real_T vleft;
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
  if (A.size(0) != A.size(1)) {
    emlrtErrorWithMessageIdR2018a(&sp, &p_emlrtRTEI,
                                  "MATLAB:eig:inputMustBeSquareStandard",
                                  "MATLAB:eig:inputMustBeSquareStandard", 0);
  }
  V.set_size(&sd_emlrtRTEI, &sp, A.size(0), A.size(0));
  D.set_size(&td_emlrtRTEI, &sp, A.size(0));
  if ((A.size(0) != 0) && (A.size(1) != 0)) {
    st.site = &ke_emlrtRSI;
    if (internal::anyNonFinite(st, A)) {
      int32_T j;
      V.set_size(&ge_emlrtRTEI, &sp, A.size(0), A.size(0));
      j = A.size(0) * A.size(0);
      for (int32_T i{0}; i < j; i++) {
        V[i].re = rtNaN;
        V[i].im = 0.0;
      }
      D.set_size(&he_emlrtRTEI, &sp, A.size(0));
      j = A.size(0);
      for (int32_T i{0}; i < j; i++) {
        D[i].re = rtNaN;
        D[i].im = 0.0;
      }
    } else {
      int32_T exitg1;
      int32_T i;
      int32_T j;
      boolean_T exitg2;
      boolean_T p;
      p = (A.size(0) == A.size(1));
      if (p) {
        j = 0;
        exitg2 = false;
        while ((!exitg2) && (j <= A.size(1) - 1)) {
          i = 0;
          do {
            exitg1 = 0;
            if (i <= j) {
              if (!(A[i + A.size(0) * j] == A[j + A.size(0) * i])) {
                p = false;
                exitg1 = 1;
              } else {
                i++;
              }
            } else {
              j++;
              exitg1 = 2;
            }
          } while (exitg1 == 0);
          if (exitg1 == 1) {
            exitg2 = true;
          }
        }
      }
      if (p) {
        ptrdiff_t info_t;
        st.site = &le_emlrtRSI;
        b_st.site = &re_emlrtRSI;
        b_A.set_size(&ce_emlrtRTEI, &b_st, A.size(0), A.size(1));
        j = A.size(0) * A.size(1);
        for (i = 0; i < j; i++) {
          b_A[i] = A[i];
        }
        c_st.site = &te_emlrtRSI;
        ilo_t = (ptrdiff_t)b_A.size(0);
        scale.set_size(&de_emlrtRTEI, &c_st, b_A.size(0));
        info_t = LAPACKE_dsyev(102, 'V', 'L', ilo_t, &(b_A.data())[0], ilo_t,
                               &(scale.data())[0]);
        d_st.site = &ue_emlrtRSI;
        if ((int32_T)info_t < 0) {
          if ((int32_T)info_t == -1010) {
            emlrtErrorWithMessageIdR2018a(&d_st, &o_emlrtRTEI, "MATLAB:nomem",
                                          "MATLAB:nomem", 0);
          } else {
            emlrtErrorWithMessageIdR2018a(
                &d_st, &n_emlrtRTEI, "Coder:toolbox:LAPACKCallErrorInfo",
                "Coder:toolbox:LAPACKCallErrorInfo", 5, 4, 13, &fname[0], 12,
                (int32_T)info_t);
          }
        }
        D.set_size(&ee_emlrtRTEI, &st, scale.size(0));
        j = scale.size(0);
        for (i = 0; i < j; i++) {
          D[i].re = scale[i];
          D[i].im = 0.0;
        }
        V.set_size(&fe_emlrtRTEI, &st, b_A.size(0), b_A.size(1));
        j = b_A.size(0) * b_A.size(1);
        for (i = 0; i < j; i++) {
          V[i].re = b_A[i];
          V[i].im = 0.0;
        }
        if (((int32_T)info_t != 0) && (!emlrtSetWarningFlag(&st))) {
          b_st.site = &se_emlrtRSI;
          internal::warning(b_st);
        }
      } else {
        p = (A.size(0) == A.size(1));
        if (p) {
          j = 0;
          exitg2 = false;
          while ((!exitg2) && (j <= A.size(1) - 1)) {
            i = 0;
            do {
              exitg1 = 0;
              if (i <= j) {
                if (!(A[i + A.size(0) * j] == -A[j + A.size(0) * i])) {
                  p = false;
                  exitg1 = 1;
                } else {
                  i++;
                }
              } else {
                j++;
                exitg1 = 2;
              }
            } while (exitg1 == 0);
            if (exitg1 == 1) {
              exitg2 = true;
            }
          }
        }
        if (p) {
          st.site = &me_emlrtRSI;
          eigSkewHermitianStandard(st, A, V, D);
        } else {
          ptrdiff_t info_t;
          int32_T n;
          st.site = &ne_emlrtRSI;
          b_st.site = &of_emlrtRSI;
          c_st.site = &qf_emlrtRSI;
          b_A.set_size(&ud_emlrtRTEI, &c_st, A.size(0), A.size(1));
          j = A.size(0) * A.size(1);
          for (i = 0; i < j; i++) {
            b_A[i] = A[i];
          }
          n = A.size(1);
          scale.set_size(&vd_emlrtRTEI, &c_st, A.size(1));
          D.set_size(&wd_emlrtRTEI, &c_st, A.size(1));
          wreal.set_size(&xd_emlrtRTEI, &c_st, A.size(1));
          wimag.set_size(&yd_emlrtRTEI, &c_st, A.size(1));
          vright.set_size(&ae_emlrtRTEI, &c_st, A.size(1), A.size(1));
          info_t = LAPACKE_dgeevx(
              102, 'B', 'N', 'V', 'N', (ptrdiff_t)A.size(1), &(b_A.data())[0],
              (ptrdiff_t)A.size(0), &(wreal.data())[0], &(wimag.data())[0],
              &vleft, (ptrdiff_t)1, &(vright.data())[0], (ptrdiff_t)A.size(1),
              &ilo_t, &ihi_t, &(scale.data())[0], &abnrm, &rconde, &rcondv);
          d_st.site = &uf_emlrtRSI;
          if ((int32_T)info_t < 0) {
            if ((int32_T)info_t == -1010) {
              emlrtErrorWithMessageIdR2018a(&d_st, &o_emlrtRTEI, "MATLAB:nomem",
                                            "MATLAB:nomem", 0);
            } else {
              emlrtErrorWithMessageIdR2018a(
                  &d_st, &n_emlrtRTEI, "Coder:toolbox:LAPACKCallErrorInfo",
                  "Coder:toolbox:LAPACKCallErrorInfo", 5, 4, 14, &b_fname[0],
                  12, (int32_T)info_t);
            }
          }
          d_st.site = &tf_emlrtRSI;
          if (A.size(1) > 2147483646) {
            e_st.site = &bc_emlrtRSI;
            check_forloop_overflow_error(e_st);
          }
          for (i = 0; i < n; i++) {
            D[i].re = wreal[i];
            D[i].im = wimag[i];
          }
          V.set_size(&be_emlrtRTEI, &c_st, vright.size(0), vright.size(1));
          j = vright.size(0) * vright.size(1);
          for (i = 0; i < j; i++) {
            V[i].re = vright[i];
            V[i].im = 0.0;
          }
          d_st.site = &sf_emlrtRSI;
          for (i = 2; i <= n; i++) {
            if ((wimag[i - 2] > 0.0) && (wimag[i - 1] < 0.0)) {
              d_st.site = &rf_emlrtRSI;
              if (n > 2147483646) {
                e_st.site = &bc_emlrtRSI;
                check_forloop_overflow_error(e_st);
              }
              for (j = 0; j < n; j++) {
                vleft = V[j + V.size(0) * (i - 2)].re;
                abnrm = V[j + V.size(0) * (i - 1)].re;
                V[j + V.size(0) * (i - 2)].re = vleft;
                V[j + V.size(0) * (i - 2)].im = abnrm;
                V[j + V.size(0) * (i - 1)].re = vleft;
                V[j + V.size(0) * (i - 1)].im = -abnrm;
              }
            }
          }
          if (((int32_T)info_t != 0) && (!emlrtSetWarningFlag(&st))) {
            b_st.site = &pf_emlrtRSI;
            internal::warning(b_st);
          }
        }
      }
    }
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

} // namespace coder

// End of code generation (eig.cpp)
