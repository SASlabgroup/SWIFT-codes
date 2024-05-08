//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xdlaln2.cpp
//
// Code generation for function 'xdlaln2'
//

// Include files
#include "xdlaln2.h"
#include "rt_nonfinite.h"
#include "xdladiv.h"
#include "coder_array.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
double xdlaln2(int na, int nw, double smin, const ::coder::array<double, 2U> &A,
               int ia0, int lda, const ::coder::array<double, 2U> &B, int ib0,
               int ldb, double wr, double wi, double X[4], double *xnorm)
{
  static const signed char ipivot[16] = {1, 2, 3, 4, 2, 1, 4, 3,
                                         3, 4, 1, 2, 4, 3, 2, 1};
  double lr21;
  double scale;
  double smini;
  if (smin >= 4.4501477170144028E-308) {
    smini = smin;
  } else {
    smini = 4.4501477170144028E-308;
  }
  scale = 1.0;
  if (na == 1) {
    if (nw == 1) {
      double cr21;
      double cr22;
      double ur12;
      ur12 = A[ia0 - 1] - wr;
      cr22 = std::abs(ur12);
      if (cr22 < smini) {
        ur12 = smini;
        cr22 = smini;
      }
      cr21 = B[ib0 - 1];
      lr21 = std::abs(cr21);
      if ((cr22 < 1.0) && (lr21 > 1.0) &&
          (lr21 > 2.2471164185778949E+307 * cr22)) {
        scale = 1.0 / lr21;
      }
      X[0] = cr21 * scale / ur12;
      *xnorm = std::abs(X[0]);
    } else {
      double bbnd;
      double cr21;
      double cr22;
      double temp;
      double ur12;
      ur12 = A[ia0 - 1] - wr;
      temp = -wi;
      cr22 = std::abs(ur12) + std::abs(-wi);
      if (cr22 < smini) {
        ur12 = smini;
        temp = 0.0;
        cr22 = smini;
      }
      cr21 = B[ib0 - 1];
      bbnd = B[(ib0 + ldb) - 1];
      lr21 = std::abs(cr21) + std::abs(bbnd);
      if ((cr22 < 1.0) && (lr21 > 1.0) &&
          (lr21 > 2.2471164185778949E+307 * cr22)) {
        scale = 1.0 / lr21;
      }
      X[0] = xdladiv(scale * cr21, scale * bbnd, ur12, temp, &X[2]);
      *xnorm = std::abs(X[0]) + std::abs(X[2]);
    }
  } else {
    double cr[4];
    int cr_tmp;
    cr[0] = A[ia0 - 1] - wr;
    cr_tmp = ia0 + lda;
    cr[3] = A[cr_tmp] - wr;
    cr[1] = A[ia0];
    cr[2] = A[cr_tmp - 1];
    if (nw == 1) {
      double cmax;
      double cr21;
      int icmax;
      cmax = 0.0;
      icmax = -1;
      cr21 = std::abs(cr[0]);
      if (cr21 > 0.0) {
        cmax = cr21;
        icmax = 0;
      }
      cr21 = std::abs(cr[1]);
      if (cr21 > cmax) {
        cmax = cr21;
        icmax = 1;
      }
      cr21 = std::abs(cr[2]);
      if (cr21 > cmax) {
        cmax = cr21;
        icmax = 2;
      }
      cr21 = std::abs(cr[3]);
      if (cr21 > cmax) {
        cmax = cr21;
        icmax = 3;
      }
      if (cmax < smini) {
        double cr22;
        double temp;
        double u0;
        cr21 = B[ib0 - 1];
        u0 = std::abs(cr21);
        cr22 = std::abs(B[ib0]);
        if ((u0 >= cr22) || rtIsNaN(cr22)) {
          lr21 = u0;
        } else {
          lr21 = cr22;
        }
        if ((smini < 1.0) && (lr21 > 1.0) &&
            (lr21 > 2.2471164185778949E+307 * smini)) {
          scale = 1.0 / lr21;
        }
        temp = scale / smini;
        X[0] = temp * cr21;
        X[1] = temp * B[ib0];
        *xnorm = temp * lr21;
      } else {
        double bbnd;
        double br1;
        double br2;
        double cr22;
        double u0;
        double ur11r;
        double ur12;
        double ur22;
        int ur12_tmp;
        ur12_tmp = icmax << 2;
        ur12 = cr[ipivot[ur12_tmp + 2] - 1];
        ur11r = 1.0 / cr[icmax];
        lr21 = ur11r * cr[ipivot[ur12_tmp + 1] - 1];
        ur22 = cr[ipivot[ur12_tmp + 3] - 1] - ur12 * lr21;
        if (std::abs(ur22) < smini) {
          ur22 = smini;
        }
        if ((icmax + 1 == 2) || (icmax + 1 == 4)) {
          br1 = B[ib0];
          br2 = B[ib0 - 1];
        } else {
          br1 = B[ib0 - 1];
          br2 = B[ib0];
        }
        br2 -= lr21 * br1;
        u0 = std::abs(br1 * (ur22 * ur11r));
        cr22 = std::abs(br2);
        if ((u0 >= cr22) || rtIsNaN(cr22)) {
          bbnd = u0;
        } else {
          bbnd = cr22;
        }
        if (bbnd > 1.0) {
          cr21 = std::abs(ur22);
          if ((cr21 < 1.0) && (bbnd >= 2.2471164185778949E+307 * cr21)) {
            scale = 1.0 / bbnd;
          }
        }
        cr22 = br2 * scale / ur22;
        ur12 = scale * br1 * ur11r - cr22 * (ur11r * ur12);
        if ((icmax + 1 == 3) || (icmax + 1 == 4)) {
          X[0] = cr22;
          X[1] = ur12;
        } else {
          X[0] = ur12;
          X[1] = cr22;
        }
        u0 = std::abs(ur12);
        cr22 = std::abs(cr22);
        if ((u0 >= cr22) || rtIsNaN(cr22)) {
          *xnorm = u0;
        } else {
          *xnorm = cr22;
        }
        if ((*xnorm > 1.0) && (cmax > 1.0) &&
            (*xnorm > 2.2471164185778949E+307 / cmax)) {
          double temp;
          temp = cmax / 2.2471164185778949E+307;
          X[0] *= temp;
          X[1] *= temp;
          *xnorm *= temp;
          scale *= temp;
        }
      }
    } else {
      double ci[4];
      double cmax;
      double cr21;
      double temp;
      int icmax;
      ci[0] = -wi;
      ci[1] = 0.0;
      ci[2] = 0.0;
      ci[3] = -wi;
      cmax = 0.0;
      icmax = -1;
      cr21 = std::abs(-wi);
      temp = std::abs(cr[0]) + cr21;
      if (temp > 0.0) {
        cmax = temp;
        icmax = 0;
      }
      temp = std::abs(cr[1]);
      if (temp > cmax) {
        cmax = temp;
        icmax = 1;
      }
      temp = std::abs(cr[2]);
      if (temp > cmax) {
        cmax = temp;
        icmax = 2;
      }
      temp = std::abs(cr[3]) + cr21;
      if (temp > cmax) {
        cmax = temp;
        icmax = 3;
      }
      if (cmax < smini) {
        double bbnd;
        double cr22;
        double u0;
        double ur12;
        cr_tmp = ib0 + ldb;
        cr21 = B[ib0 - 1];
        bbnd = B[cr_tmp - 1];
        u0 = std::abs(cr21) + std::abs(bbnd);
        ur12 = B[cr_tmp];
        cr22 = std::abs(B[ib0]) + std::abs(ur12);
        if ((u0 >= cr22) || rtIsNaN(cr22)) {
          lr21 = u0;
        } else {
          lr21 = cr22;
        }
        if ((smini < 1.0) && (lr21 > 1.0) &&
            (lr21 > 2.2471164185778949E+307 * smini)) {
          scale = 1.0 / lr21;
        }
        temp = scale / smini;
        X[0] = temp * cr21;
        X[1] = temp * B[ib0];
        X[2] = temp * bbnd;
        X[3] = temp * ur12;
        *xnorm = temp * lr21;
      } else {
        double bbnd;
        double br1;
        double br2;
        double cr22;
        double u0;
        double ui11r;
        double ui12s;
        double ui22;
        double ur11r;
        double ur12;
        double ur12s;
        double ur22;
        int cr21_tmp;
        int ur12_tmp;
        cr_tmp = icmax << 2;
        cr21_tmp = ipivot[cr_tmp + 1] - 1;
        cr21 = cr[cr21_tmp];
        ur12_tmp = ipivot[cr_tmp + 2] - 1;
        ur12 = cr[ur12_tmp];
        temp = ci[ur12_tmp];
        cr_tmp = ipivot[cr_tmp + 3] - 1;
        cr22 = cr[cr_tmp];
        if ((icmax + 1 == 1) || (icmax + 1 == 4)) {
          if (std::abs(cr[icmax]) > std::abs(ci[icmax])) {
            temp = ci[icmax] / cr[icmax];
            ur11r = 1.0 / (cr[icmax] * (temp * temp + 1.0));
            ui11r = -temp * ur11r;
          } else {
            temp = cr[icmax] / ci[icmax];
            ui11r = -1.0 / (ci[icmax] * (temp * temp + 1.0));
            ur11r = -temp * ui11r;
          }
          lr21 = cr21 * ur11r;
          cr21 *= ui11r;
          ur12s = ur12 * ur11r;
          ui12s = ur12 * ui11r;
          ur22 = cr22 - ur12 * lr21;
          ui22 = ci[cr_tmp] - ur12 * cr21;
        } else {
          ur11r = 1.0 / cr[icmax];
          ui11r = 0.0;
          lr21 = cr21 * ur11r;
          cr21 = ci[cr21_tmp] * ur11r;
          ur12s = ur12 * ur11r;
          ui12s = temp * ur11r;
          ur22 = (cr22 - ur12 * lr21) + temp * cr21;
          ui22 = -ur12 * cr21 - temp * lr21;
        }
        ur12 = std::abs(ur22) + std::abs(ui22);
        if (ur12 < smini) {
          ur22 = smini;
          ui22 = 0.0;
        }
        if ((icmax + 1 == 2) || (icmax + 1 == 4)) {
          br2 = B[ib0 - 1];
          br1 = B[ib0];
          cr_tmp = ib0 + ldb;
          temp = B[cr_tmp - 1];
          smini = B[cr_tmp];
        } else {
          br1 = B[ib0 - 1];
          br2 = B[ib0];
          cr_tmp = ib0 + ldb;
          smini = B[cr_tmp - 1];
          temp = B[cr_tmp];
        }
        br2 = (br2 - lr21 * br1) + cr21 * smini;
        temp = (temp - cr21 * br1) - lr21 * smini;
        u0 = (std::abs(br1) + std::abs(smini)) *
             (ur12 * (std::abs(ur11r) + std::abs(ui11r)));
        cr22 = std::abs(br2) + std::abs(temp);
        if ((u0 >= cr22) || rtIsNaN(cr22)) {
          bbnd = u0;
        } else {
          bbnd = cr22;
        }
        if ((bbnd > 1.0) && (ur12 < 1.0) &&
            (bbnd >= 2.2471164185778949E+307 * ur12)) {
          scale = 1.0 / bbnd;
          br1 *= scale;
          smini *= scale;
          br2 *= scale;
          temp *= scale;
        }
        cr22 = xdladiv(br2, temp, ur22, ui22, &lr21);
        ur12 = ((ur11r * br1 - ui11r * smini) - ur12s * cr22) + ui12s * lr21;
        cr21 = ((ui11r * br1 + ur11r * smini) - ui12s * cr22) - ur12s * lr21;
        if ((icmax + 1 == 3) || (icmax + 1 == 4)) {
          X[0] = cr22;
          X[1] = ur12;
          X[2] = lr21;
          X[3] = cr21;
        } else {
          X[0] = ur12;
          X[1] = cr22;
          X[2] = cr21;
          X[3] = lr21;
        }
        u0 = std::abs(ur12) + std::abs(cr21);
        cr22 = std::abs(cr22) + std::abs(lr21);
        if ((u0 >= cr22) || rtIsNaN(cr22)) {
          *xnorm = u0;
        } else {
          *xnorm = cr22;
        }
        if ((*xnorm > 1.0) && (cmax > 1.0) &&
            (*xnorm > 2.2471164185778949E+307 / cmax)) {
          temp = cmax / 2.2471164185778949E+307;
          X[0] *= temp;
          X[1] *= temp;
          X[2] *= temp;
          X[3] *= temp;
          *xnorm *= temp;
          scale *= temp;
        }
      }
    }
  }
  return scale;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xdlaln2.cpp)
