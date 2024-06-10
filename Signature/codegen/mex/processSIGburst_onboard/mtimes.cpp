//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mtimes.cpp
//
// Code generation for function 'mtimes'
//

// Include files
#include "mtimes.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "blas.h"
#include "coder_array.h"
#include <cstddef>

// Variable Definitions
static emlrtRSInfo ie_emlrtRSI{
    142,      // lineNo
    "mtimes", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "blas\\mtimes.m" // pathName
};

static emlrtRSInfo je_emlrtRSI{
    178,           // lineNo
    "mtimes_blas", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "blas\\mtimes.m" // pathName
};

static emlrtRTEInfo qd_emlrtRTEI{
    218,      // lineNo
    20,       // colNo
    "mtimes", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "blas\\mtimes.m" // pName
};

static emlrtRTEInfo rd_emlrtRTEI{
    140,      // lineNo
    5,        // colNo
    "mtimes", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "blas\\mtimes.m" // pName
};

// Function Definitions
namespace coder {
namespace internal {
namespace blas {
void b_mtimes(const ::coder::array<real_T, 2U> &A,
              const ::coder::array<real_T, 2U> &B, real_T C[4])
{
  ptrdiff_t k_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  ptrdiff_t ldc_t;
  ptrdiff_t m_t;
  ptrdiff_t n_t;
  real_T alpha1;
  real_T beta1;
  char_T TRANSA1;
  char_T TRANSB1;
  if ((A.size(0) == 0) || (B.size(0) == 0)) {
    C[0] = 0.0;
    C[1] = 0.0;
    C[2] = 0.0;
    C[3] = 0.0;
  } else {
    TRANSB1 = 'N';
    TRANSA1 = 'T';
    alpha1 = 1.0;
    beta1 = 0.0;
    m_t = (ptrdiff_t)2;
    n_t = (ptrdiff_t)2;
    k_t = (ptrdiff_t)A.size(0);
    lda_t = (ptrdiff_t)A.size(0);
    ldb_t = (ptrdiff_t)B.size(0);
    ldc_t = (ptrdiff_t)2;
    dgemm(&TRANSA1, &TRANSB1, &m_t, &n_t, &k_t, &alpha1,
          &(((::coder::array<real_T, 2U> *)&A)->data())[0], &lda_t,
          &(((::coder::array<real_T, 2U> *)&B)->data())[0], &ldb_t, &beta1,
          &C[0], &ldc_t);
  }
}

void b_mtimes(const ::coder::array<real_T, 2U> &A,
              const ::coder::array<real_T, 1U> &B, real_T C[2])
{
  ptrdiff_t k_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  ptrdiff_t ldc_t;
  ptrdiff_t m_t;
  ptrdiff_t n_t;
  real_T alpha1;
  real_T beta1;
  char_T TRANSA1;
  char_T TRANSB1;
  if ((A.size(1) == 0) || (B.size(0) == 0)) {
    C[0] = 0.0;
    C[1] = 0.0;
  } else {
    TRANSB1 = 'N';
    TRANSA1 = 'N';
    alpha1 = 1.0;
    beta1 = 0.0;
    m_t = (ptrdiff_t)2;
    n_t = (ptrdiff_t)1;
    k_t = (ptrdiff_t)A.size(1);
    lda_t = (ptrdiff_t)2;
    ldb_t = (ptrdiff_t)B.size(0);
    ldc_t = (ptrdiff_t)2;
    dgemm(&TRANSA1, &TRANSB1, &m_t, &n_t, &k_t, &alpha1,
          &(((::coder::array<real_T, 2U> *)&A)->data())[0], &lda_t,
          &(((::coder::array<real_T, 1U> *)&B)->data())[0], &ldb_t, &beta1,
          &C[0], &ldc_t);
  }
}

void mtimes(const emlrtStack &sp, const ::coder::array<creal_T, 2U> &A,
            const ::coder::array<creal_T, 2U> &B,
            ::coder::array<creal_T, 2U> &C)
{
  static const creal_T alpha1{
      1.0, // re
      0.0  // im
  };
  static const creal_T beta1{
      0.0, // re
      0.0  // im
  };
  ptrdiff_t k_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  ptrdiff_t ldc_t;
  ptrdiff_t m_t;
  ptrdiff_t n_t;
  emlrtStack b_st;
  emlrtStack st;
  char_T TRANSA1;
  char_T TRANSB1;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if ((A.size(0) == 0) || (A.size(1) == 0) || (B.size(0) == 0) ||
      (B.size(1) == 0)) {
    int32_T loop_ub;
    C.set_size(&rd_emlrtRTEI, &sp, A.size(0), B.size(0));
    loop_ub = A.size(0) * B.size(0);
    for (int32_T i{0}; i < loop_ub; i++) {
      C[i] = beta1;
    }
  } else {
    st.site = &ie_emlrtRSI;
    b_st.site = &je_emlrtRSI;
    TRANSB1 = 'C';
    TRANSA1 = 'N';
    m_t = (ptrdiff_t)A.size(0);
    n_t = (ptrdiff_t)B.size(0);
    k_t = (ptrdiff_t)A.size(1);
    lda_t = (ptrdiff_t)A.size(0);
    ldb_t = (ptrdiff_t)B.size(0);
    ldc_t = (ptrdiff_t)A.size(0);
    C.set_size(&qd_emlrtRTEI, &b_st, A.size(0), B.size(0));
    zgemm(&TRANSA1, &TRANSB1, &m_t, &n_t, &k_t, (real_T *)&alpha1,
          (real_T *)&(((::coder::array<creal_T, 2U> *)&A)->data())[0], &lda_t,
          (real_T *)&(((::coder::array<creal_T, 2U> *)&B)->data())[0], &ldb_t,
          (real_T *)&beta1, (real_T *)&(C.data())[0], &ldc_t);
  }
}

void mtimes(const emlrtStack &sp, const ::coder::array<real_T, 2U> &A,
            const ::coder::array<real_T, 2U> &B, ::coder::array<real_T, 2U> &C)
{
  ptrdiff_t k_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  ptrdiff_t ldc_t;
  ptrdiff_t m_t;
  ptrdiff_t n_t;
  emlrtStack b_st;
  emlrtStack st;
  real_T alpha1;
  real_T beta1;
  char_T TRANSA1;
  char_T TRANSB1;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if ((A.size(0) == 0) || (A.size(1) == 0) || (B.size(0) == 0) ||
      (B.size(1) == 0)) {
    int32_T loop_ub;
    C.set_size(&rd_emlrtRTEI, &sp, A.size(1), B.size(1));
    loop_ub = A.size(1) * B.size(1);
    for (int32_T i{0}; i < loop_ub; i++) {
      C[i] = 0.0;
    }
  } else {
    st.site = &ie_emlrtRSI;
    b_st.site = &je_emlrtRSI;
    TRANSB1 = 'N';
    TRANSA1 = 'T';
    alpha1 = 1.0;
    beta1 = 0.0;
    m_t = (ptrdiff_t)A.size(1);
    n_t = (ptrdiff_t)B.size(1);
    k_t = (ptrdiff_t)A.size(0);
    lda_t = (ptrdiff_t)A.size(0);
    ldb_t = (ptrdiff_t)B.size(0);
    ldc_t = (ptrdiff_t)A.size(1);
    C.set_size(&qd_emlrtRTEI, &b_st, A.size(1), B.size(1));
    dgemm(&TRANSA1, &TRANSB1, &m_t, &n_t, &k_t, &alpha1,
          &(((::coder::array<real_T, 2U> *)&A)->data())[0], &lda_t,
          &(((::coder::array<real_T, 2U> *)&B)->data())[0], &ldb_t, &beta1,
          &(C.data())[0], &ldc_t);
  }
}

void mtimes(const ::coder::array<real_T, 2U> &A,
            const ::coder::array<real_T, 2U> &B, real_T C[9])
{
  ptrdiff_t k_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  ptrdiff_t ldc_t;
  ptrdiff_t m_t;
  ptrdiff_t n_t;
  real_T alpha1;
  real_T beta1;
  char_T TRANSA1;
  char_T TRANSB1;
  TRANSB1 = 'N';
  TRANSA1 = 'T';
  alpha1 = 1.0;
  beta1 = 0.0;
  m_t = (ptrdiff_t)3;
  n_t = (ptrdiff_t)3;
  k_t = (ptrdiff_t)A.size(0);
  lda_t = (ptrdiff_t)A.size(0);
  ldb_t = (ptrdiff_t)B.size(0);
  ldc_t = (ptrdiff_t)3;
  dgemm(&TRANSA1, &TRANSB1, &m_t, &n_t, &k_t, &alpha1,
        &(((::coder::array<real_T, 2U> *)&A)->data())[0], &lda_t,
        &(((::coder::array<real_T, 2U> *)&B)->data())[0], &ldb_t, &beta1, &C[0],
        &ldc_t);
}

void mtimes(const ::coder::array<real_T, 2U> &A,
            const ::coder::array<real_T, 1U> &B, real_T C[3])
{
  ptrdiff_t k_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  ptrdiff_t ldc_t;
  ptrdiff_t m_t;
  ptrdiff_t n_t;
  real_T alpha1;
  real_T beta1;
  char_T TRANSA1;
  char_T TRANSB1;
  if (B.size(0) == 0) {
    C[0] = 0.0;
    C[1] = 0.0;
    C[2] = 0.0;
  } else {
    TRANSB1 = 'N';
    TRANSA1 = 'N';
    alpha1 = 1.0;
    beta1 = 0.0;
    m_t = (ptrdiff_t)3;
    n_t = (ptrdiff_t)1;
    k_t = (ptrdiff_t)A.size(1);
    lda_t = (ptrdiff_t)3;
    ldb_t = (ptrdiff_t)B.size(0);
    ldc_t = (ptrdiff_t)3;
    dgemm(&TRANSA1, &TRANSB1, &m_t, &n_t, &k_t, &alpha1,
          &(((::coder::array<real_T, 2U> *)&A)->data())[0], &lda_t,
          &(((::coder::array<real_T, 1U> *)&B)->data())[0], &ldb_t, &beta1,
          &C[0], &ldc_t);
  }
}

} // namespace blas
} // namespace internal
} // namespace coder

// End of code generation (mtimes.cpp)
