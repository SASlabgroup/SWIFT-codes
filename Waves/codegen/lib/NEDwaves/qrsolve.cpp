//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// qrsolve.cpp
//
// Code generation for function 'qrsolve'
//

// Include files
#include "qrsolve.h"
#include "rt_nonfinite.h"
#include "xnrm2.h"
#include "coder_array.h"
#include <cmath>
#include <cstring>

// Function Declarations
static float rt_hypotf_snf(float u0, float u1);

// Function Definitions
static float rt_hypotf_snf(float u0, float u1)
{
  float a;
  float y;
  a = std::abs(u0);
  y = std::abs(u1);
  if (a < y) {
    a /= y;
    y *= std::sqrt(a * a + 1.0F);
  } else if (a > y) {
    y /= a;
    y = a * std::sqrt(y * y + 1.0F);
  } else if (!std::isnan(y)) {
    y = a * 1.41421354F;
  }
  return y;
}

namespace coder {
namespace internal {
void qrsolve(const ::coder::array<float, 2U> &A,
             const ::coder::array<float, 1U> &B, float Y[2], int *rankA)
{
  array<float, 2U> b_A;
  array<float, 1U> b_B;
  float tau_data[2];
  float temp;
  int i;
  int ii_tmp;
  int m;
  int minmana;
  int minmn;
  signed char jpvt[2];
  b_A.set_size(A.size(0), 2);
  minmana = A.size(0) * 2;
  for (i = 0; i < minmana; i++) {
    b_A[i] = A[i];
  }
  m = A.size(0);
  minmana = A.size(0);
  if (minmana > 2) {
    minmana = 2;
  }
  if (minmana - 1 >= 0) {
    std::memset(&tau_data[0], 0, minmana * sizeof(float));
  }
  if (A.size(0) == 0) {
    jpvt[0] = 1;
    jpvt[1] = 2;
  } else {
    float vn1[2];
    float vn2[2];
    float work[2];
    int ma;
    ma = A.size(0);
    minmn = A.size(0);
    if (minmn > 2) {
      minmn = 2;
    }
    jpvt[0] = 1;
    work[0] = 0.0F;
    temp = blas::xnrm2(A.size(0), A, 1);
    vn1[0] = temp;
    vn2[0] = temp;
    jpvt[1] = 2;
    work[1] = 0.0F;
    temp = blas::xnrm2(A.size(0), A, A.size(0) + 1);
    vn1[1] = temp;
    vn2[1] = temp;
    for (int b_i{0}; b_i < minmn; b_i++) {
      float atmp;
      float beta1;
      int ii;
      int ip1;
      int knt;
      int lastv;
      int mmi;
      int pvt;
      ip1 = b_i + 2;
      ii_tmp = b_i * ma;
      ii = ii_tmp + b_i;
      mmi = m - b_i;
      minmana = 0;
      if ((2 - b_i > 1) && (std::abs(vn1[1]) > std::abs(vn1[b_i]))) {
        minmana = 1;
      }
      pvt = b_i + minmana;
      if (pvt != b_i) {
        minmana = pvt * ma;
        for (lastv = 0; lastv < m; lastv++) {
          knt = minmana + lastv;
          temp = b_A[knt];
          i = ii_tmp + lastv;
          b_A[knt] = b_A[i];
          b_A[i] = temp;
        }
        minmana = jpvt[pvt];
        jpvt[pvt] = jpvt[b_i];
        jpvt[b_i] = static_cast<signed char>(minmana);
        vn1[pvt] = vn1[b_i];
        vn2[pvt] = vn2[b_i];
      }
      if (b_i + 1 < m) {
        atmp = b_A[ii];
        minmana = ii + 2;
        tau_data[b_i] = 0.0F;
        if (mmi > 0) {
          temp = blas::xnrm2(mmi - 1, b_A, ii + 2);
          if (temp != 0.0F) {
            beta1 = rt_hypotf_snf(b_A[ii], temp);
            if (b_A[ii] >= 0.0F) {
              beta1 = -beta1;
            }
            if (std::abs(beta1) < 9.86076132E-32F) {
              knt = 0;
              i = ii + mmi;
              do {
                knt++;
                for (lastv = minmana; lastv <= i; lastv++) {
                  b_A[lastv - 1] = 1.01412048E+31F * b_A[lastv - 1];
                }
                beta1 *= 1.01412048E+31F;
                atmp *= 1.01412048E+31F;
              } while ((std::abs(beta1) < 9.86076132E-32F) && (knt < 20));
              beta1 = rt_hypotf_snf(atmp, blas::xnrm2(mmi - 1, b_A, ii + 2));
              if (atmp >= 0.0F) {
                beta1 = -beta1;
              }
              tau_data[b_i] = (beta1 - atmp) / beta1;
              temp = 1.0F / (atmp - beta1);
              for (lastv = minmana; lastv <= i; lastv++) {
                b_A[lastv - 1] = temp * b_A[lastv - 1];
              }
              for (lastv = 0; lastv < knt; lastv++) {
                beta1 *= 9.86076132E-32F;
              }
              atmp = beta1;
            } else {
              tau_data[b_i] = (beta1 - b_A[ii]) / beta1;
              temp = 1.0F / (b_A[ii] - beta1);
              i = ii + mmi;
              for (lastv = minmana; lastv <= i; lastv++) {
                b_A[lastv - 1] = temp * b_A[lastv - 1];
              }
              atmp = beta1;
            }
          }
        }
        b_A[ii] = atmp;
      } else {
        tau_data[b_i] = 0.0F;
      }
      if (b_i + 1 < 2) {
        int jA;
        atmp = b_A[ii];
        b_A[ii] = 1.0F;
        jA = (ii + ma) + 1;
        if (tau_data[0] != 0.0F) {
          lastv = mmi - 1;
          minmana = (ii + mmi) - 1;
          while ((lastv + 1 > 0) && (b_A[minmana] == 0.0F)) {
            lastv--;
            minmana--;
          }
          knt = 1;
          ii_tmp = jA;
          int exitg1;
          do {
            exitg1 = 0;
            if (ii_tmp <= jA + lastv) {
              if (b_A[ii_tmp - 1] != 0.0F) {
                exitg1 = 1;
              } else {
                ii_tmp++;
              }
            } else {
              knt = 0;
              exitg1 = 1;
            }
          } while (exitg1 == 0);
        } else {
          lastv = -1;
          knt = 0;
        }
        if (lastv + 1 > 0) {
          if (knt != 0) {
            work[0] = 0.0F;
            minmana = 0;
            for (pvt = jA; ma < 0 ? pvt >= jA : pvt <= jA; pvt += ma) {
              temp = 0.0F;
              i = pvt + lastv;
              for (ii_tmp = pvt; ii_tmp <= i; ii_tmp++) {
                temp += b_A[ii_tmp - 1] * b_A[(ii + ii_tmp) - pvt];
              }
              work[minmana] += temp;
              minmana++;
            }
          }
          if (!(-tau_data[0] == 0.0F)) {
            for (ii_tmp = 0; ii_tmp < knt; ii_tmp++) {
              if (work[0] != 0.0F) {
                temp = work[0] * -tau_data[0];
                i = lastv + jA;
                for (minmana = jA; minmana <= i; minmana++) {
                  b_A[minmana - 1] =
                      b_A[minmana - 1] + b_A[(ii + minmana) - jA] * temp;
                }
              }
              jA += ma;
            }
          }
        }
        b_A[ii] = atmp;
      }
      for (ii_tmp = ip1; ii_tmp < 3; ii_tmp++) {
        minmana = b_i + ma;
        if (vn1[1] != 0.0F) {
          temp = std::abs(b_A[minmana]) / vn1[1];
          temp = 1.0F - temp * temp;
          if (temp < 0.0F) {
            temp = 0.0F;
          }
          beta1 = vn1[1] / vn2[1];
          beta1 = temp * (beta1 * beta1);
          if (beta1 <= 0.000345266977F) {
            if (b_i + 1 < m) {
              temp = blas::xnrm2(mmi - 1, b_A, minmana + 2);
              vn1[1] = temp;
              vn2[1] = temp;
            } else {
              vn1[1] = 0.0F;
              vn2[1] = 0.0F;
            }
          } else {
            vn1[1] *= std::sqrt(temp);
          }
        }
      }
    }
  }
  *rankA = 0;
  if (b_A.size(0) < 2) {
    minmn = b_A.size(0);
    minmana = 2;
  } else {
    minmn = 2;
    minmana = b_A.size(0);
  }
  if (minmn > 0) {
    temp = std::fmin(0.000345266977F,
                     1.1920929E-6F * static_cast<float>(minmana)) *
           std::abs(b_A[0]);
    while ((*rankA < minmn) &&
           (!(std::abs(b_A[*rankA + b_A.size(0) * *rankA]) <= temp))) {
      (*rankA)++;
    }
  }
  b_B.set_size(B.size(0));
  minmana = B.size(0);
  for (i = 0; i < minmana; i++) {
    b_B[i] = B[i];
  }
  Y[0] = 0.0F;
  Y[1] = 0.0F;
  m = b_A.size(0);
  minmana = b_A.size(0);
  if (minmana > 2) {
    minmana = 2;
  }
  for (ii_tmp = 0; ii_tmp < minmana; ii_tmp++) {
    if (tau_data[ii_tmp] != 0.0F) {
      temp = b_B[ii_tmp];
      i = ii_tmp + 2;
      for (int b_i{i}; b_i <= m; b_i++) {
        temp += b_A[(b_i + b_A.size(0) * ii_tmp) - 1] * b_B[b_i - 1];
      }
      temp *= tau_data[ii_tmp];
      if (temp != 0.0F) {
        b_B[ii_tmp] = b_B[ii_tmp] - temp;
        for (int b_i{i}; b_i <= m; b_i++) {
          b_B[b_i - 1] =
              b_B[b_i - 1] - b_A[(b_i + b_A.size(0) * ii_tmp) - 1] * temp;
        }
      }
    }
  }
  for (int b_i{0}; b_i < *rankA; b_i++) {
    Y[jpvt[b_i] - 1] = b_B[b_i];
  }
  for (ii_tmp = *rankA; ii_tmp >= 1; ii_tmp--) {
    minmana = jpvt[ii_tmp - 1] - 1;
    Y[minmana] /= b_A[(ii_tmp + b_A.size(0) * (ii_tmp - 1)) - 1];
    for (int b_i{0}; b_i <= ii_tmp - 2; b_i++) {
      Y[jpvt[0] - 1] -= Y[minmana] * b_A[b_A.size(0) * (ii_tmp - 1)];
    }
  }
}

} // namespace internal
} // namespace coder

// End of code generation (qrsolve.cpp)
