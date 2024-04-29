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
#include "eigHermitianStandard.h"
#include "eof_data.h"
#include "eof_rtwutil.h"
#include "rt_nonfinite.h"
#include "xzggbal.h"
#include "xzhgeqz.h"
#include "xzlartg.h"
#include "xztgevc.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
void eig(const ::coder::array<double, 2U> &A, ::coder::array<creal_T, 2U> &V,
         ::coder::array<creal_T, 1U> &D)
{
  array<creal_T, 2U> At;
  array<creal_T, 1U> beta1;
  array<double, 2U> b_I;
  array<double, 1U> b_D;
  array<int, 1U> rscale;
  creal_T tmp;
  double cfromc;
  int ihi;
  int ilo;
  int nx;
  V.set_size(A.size(0), A.size(0));
  D.set_size(A.size(0));
  if ((A.size(0) != 0) && (A.size(1) != 0)) {
    int k;
    bool ilascl;
    nx = A.size(0) * A.size(1);
    ilascl = true;
    for (k = 0; k < nx; k++) {
      if ((!ilascl) || (std::isinf(A[k]) || std::isnan(A[k]))) {
        ilascl = false;
      }
    }
    if (!ilascl) {
      V.set_size(A.size(0), A.size(0));
      nx = A.size(0) * A.size(0);
      for (k = 0; k < nx; k++) {
        V[k].re = rtNaN;
        V[k].im = 0.0;
      }
      D.set_size(A.size(0));
      nx = A.size(0);
      for (k = 0; k < nx; k++) {
        D[k].re = rtNaN;
        D[k].im = 0.0;
      }
    } else {
      int i;
      int j;
      bool exitg2;
      ilascl = (A.size(0) == A.size(1));
      if (ilascl) {
        j = 0;
        exitg2 = false;
        while ((!exitg2) && (j <= A.size(1) - 1)) {
          int exitg1;
          i = 0;
          do {
            exitg1 = 0;
            if (i <= j) {
              if (!(A[i + A.size(0) * j] == A[j + A.size(0) * i])) {
                ilascl = false;
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
      if (ilascl) {
        eigHermitianStandard(A, b_I, b_D);
        V.set_size(b_I.size(0), b_I.size(1));
        nx = b_I.size(0) * b_I.size(1);
        for (k = 0; k < nx; k++) {
          V[k].re = b_I[k];
          V[k].im = 0.0;
        }
        D.set_size(b_D.size(0));
        nx = b_D.size(0);
        for (k = 0; k < nx; k++) {
          D[k].re = b_D[k];
          D[k].im = 0.0;
        }
      } else {
        double a;
        double absxk;
        double ai;
        double anrm;
        double anrmto;
        double cto1;
        double stemp_re;
        int jcolp1;
        int jrow;
        int n;
        At.set_size(A.size(0), A.size(1));
        nx = A.size(0) * A.size(1);
        for (k = 0; k < nx; k++) {
          At[k].re = A[k];
          At[k].im = 0.0;
        }
        n = At.size(0) - 1;
        anrm = 0.0;
        k = 0;
        exitg2 = false;
        while ((!exitg2) && (k <= At.size(0) * At.size(1) - 1)) {
          absxk = rt_hypotd_snf(At[k].re, At[k].im);
          if (std::isnan(absxk)) {
            anrm = rtNaN;
            exitg2 = true;
          } else {
            if (absxk > anrm) {
              anrm = absxk;
            }
            k++;
          }
        }
        if (std::isinf(anrm) || std::isnan(anrm)) {
          D.set_size(At.size(0));
          nx = At.size(0);
          for (k = 0; k < nx; k++) {
            D[k].re = rtNaN;
            D[k].im = 0.0;
          }
          beta1.set_size(At.size(0));
          nx = At.size(0);
          for (k = 0; k < nx; k++) {
            beta1[k].re = rtNaN;
            beta1[k].im = 0.0;
          }
          V.set_size(At.size(0), At.size(0));
          nx = At.size(0) * At.size(0);
          for (k = 0; k < nx; k++) {
            V[k].re = rtNaN;
            V[k].im = 0.0;
          }
        } else {
          int b_n;
          bool guard1{false};
          bool notdone;
          ilascl = false;
          anrmto = anrm;
          guard1 = false;
          if ((anrm > 0.0) && (anrm < 6.7178761075670888E-139)) {
            anrmto = 6.7178761075670888E-139;
            ilascl = true;
            guard1 = true;
          } else if (anrm > 1.4885657073574029E+138) {
            anrmto = 1.4885657073574029E+138;
            ilascl = true;
            guard1 = true;
          }
          if (guard1) {
            cfromc = anrm;
            absxk = anrmto;
            notdone = true;
            while (notdone) {
              stemp_re = cfromc * 2.0041683600089728E-292;
              cto1 = absxk / 4.9896007738368E+291;
              if ((stemp_re > absxk) && (absxk != 0.0)) {
                a = 2.0041683600089728E-292;
                cfromc = stemp_re;
              } else if (cto1 > cfromc) {
                a = 4.9896007738368E+291;
                absxk = cto1;
              } else {
                a = absxk / cfromc;
                notdone = false;
              }
              nx = At.size(0) * At.size(1);
              for (k = 0; k < nx; k++) {
                At[k].re = a * At[k].re;
                At[k].im = a * At[k].im;
              }
            }
          }
          internal::reflapack::xzggbal(At, &ilo, &ihi, rscale);
          b_n = At.size(0);
          b_I.set_size(At.size(0), At.size(0));
          nx = At.size(0) * At.size(0);
          for (k = 0; k < nx; k++) {
            b_I[k] = 0.0;
          }
          if (At.size(0) > 0) {
            for (k = 0; k < b_n; k++) {
              b_I[k + b_I.size(0) * k] = 1.0;
            }
          }
          V.set_size(b_I.size(0), b_I.size(1));
          nx = b_I.size(0) * b_I.size(1);
          for (k = 0; k < nx; k++) {
            V[k].re = b_I[k];
            V[k].im = 0.0;
          }
          if ((At.size(0) > 1) && (ihi >= ilo + 2)) {
            for (nx = ilo - 1; nx + 1 < ihi - 1; nx++) {
              jcolp1 = nx + 2;
              for (jrow = ihi - 1; jrow + 1 > nx + 2; jrow--) {
                internal::reflapack::xzlartg(At[(jrow + At.size(0) * nx) - 1],
                                             At[jrow + At.size(0) * nx],
                                             &cfromc, &tmp,
                                             &At[(jrow + At.size(0) * nx) - 1]);
                At[jrow + At.size(0) * nx].re = 0.0;
                At[jrow + At.size(0) * nx].im = 0.0;
                for (j = jcolp1; j <= b_n; j++) {
                  stemp_re = cfromc * At[(jrow + At.size(0) * (j - 1)) - 1].re +
                             (tmp.re * At[jrow + At.size(0) * (j - 1)].re -
                              tmp.im * At[jrow + At.size(0) * (j - 1)].im);
                  absxk = cfromc * At[(jrow + At.size(0) * (j - 1)) - 1].im +
                          (tmp.re * At[jrow + At.size(0) * (j - 1)].im +
                           tmp.im * At[jrow + At.size(0) * (j - 1)].re);
                  cto1 = At[(jrow + At.size(0) * (j - 1)) - 1].re;
                  At[jrow + At.size(0) * (j - 1)].re =
                      cfromc * At[jrow + At.size(0) * (j - 1)].re -
                      (tmp.re * At[(jrow + At.size(0) * (j - 1)) - 1].re +
                       tmp.im * At[(jrow + At.size(0) * (j - 1)) - 1].im);
                  At[jrow + At.size(0) * (j - 1)].im =
                      cfromc * At[jrow + At.size(0) * (j - 1)].im -
                      (tmp.re * At[(jrow + At.size(0) * (j - 1)) - 1].im -
                       tmp.im * cto1);
                  At[(jrow + At.size(0) * (j - 1)) - 1].re = stemp_re;
                  At[(jrow + At.size(0) * (j - 1)) - 1].im = absxk;
                }
                tmp.re = -tmp.re;
                tmp.im = -tmp.im;
                for (i = 1; i <= ihi; i++) {
                  stemp_re =
                      cfromc * At[(i + At.size(0) * jrow) - 1].re +
                      (tmp.re * At[(i + At.size(0) * (jrow - 1)) - 1].re -
                       tmp.im * At[(i + At.size(0) * (jrow - 1)) - 1].im);
                  absxk = cfromc * At[(i + At.size(0) * jrow) - 1].im +
                          (tmp.re * At[(i + At.size(0) * (jrow - 1)) - 1].im +
                           tmp.im * At[(i + At.size(0) * (jrow - 1)) - 1].re);
                  cto1 = At[(i + At.size(0) * jrow) - 1].re;
                  At[(i + At.size(0) * (jrow - 1)) - 1].re =
                      cfromc * At[(i + At.size(0) * (jrow - 1)) - 1].re -
                      (tmp.re * At[(i + At.size(0) * jrow) - 1].re +
                       tmp.im * At[(i + At.size(0) * jrow) - 1].im);
                  At[(i + At.size(0) * (jrow - 1)) - 1].im =
                      cfromc * At[(i + At.size(0) * (jrow - 1)) - 1].im -
                      (tmp.re * At[(i + At.size(0) * jrow) - 1].im -
                       tmp.im * cto1);
                  At[(i + At.size(0) * jrow) - 1].re = stemp_re;
                  At[(i + At.size(0) * jrow) - 1].im = absxk;
                }
                for (i = 1; i <= b_n; i++) {
                  stemp_re = cfromc * V[(i + V.size(0) * jrow) - 1].re +
                             (tmp.re * V[(i + V.size(0) * (jrow - 1)) - 1].re -
                              tmp.im * V[(i + V.size(0) * (jrow - 1)) - 1].im);
                  absxk = cfromc * V[(i + V.size(0) * jrow) - 1].im +
                          (tmp.re * V[(i + V.size(0) * (jrow - 1)) - 1].im +
                           tmp.im * V[(i + V.size(0) * (jrow - 1)) - 1].re);
                  cto1 = V[(i + V.size(0) * jrow) - 1].re;
                  V[(i + V.size(0) * (jrow - 1)) - 1].re =
                      cfromc * V[(i + V.size(0) * (jrow - 1)) - 1].re -
                      (tmp.re * V[(i + V.size(0) * jrow) - 1].re +
                       tmp.im * V[(i + V.size(0) * jrow) - 1].im);
                  V[(i + V.size(0) * (jrow - 1)) - 1].im =
                      cfromc * V[(i + V.size(0) * (jrow - 1)) - 1].im -
                      (tmp.re * V[(i + V.size(0) * jrow) - 1].im -
                       tmp.im * cto1);
                  V[(i + V.size(0) * jrow) - 1].re = stemp_re;
                  V[(i + V.size(0) * jrow) - 1].im = absxk;
                }
              }
            }
          }
          internal::reflapack::xzhgeqz(At, ilo, ihi, V, &nx, D, beta1);
          if (nx == 0) {
            internal::reflapack::xztgevc(At, V);
            b_n = V.size(0);
            jcolp1 = V.size(1) - 1;
            if (ilo > 1) {
              for (i = ilo - 2; i + 1 >= 1; i--) {
                k = rscale[i] - 1;
                if (rscale[i] != i + 1) {
                  for (j = 0; j <= jcolp1; j++) {
                    tmp = V[i + V.size(0) * j];
                    V[i + V.size(0) * j] = V[k + V.size(0) * j];
                    V[k + V.size(0) * j] = tmp;
                  }
                }
              }
            }
            if (ihi < b_n) {
              k = ihi + 1;
              for (i = k; i <= b_n; i++) {
                nx = rscale[i - 1];
                if (nx != i) {
                  for (j = 0; j <= jcolp1; j++) {
                    tmp = V[(i + V.size(0) * j) - 1];
                    V[(i + V.size(0) * j) - 1] = V[(nx + V.size(0) * j) - 1];
                    V[(nx + V.size(0) * j) - 1] = tmp;
                  }
                }
              }
            }
            for (nx = 0; nx <= n; nx++) {
              cfromc = std::abs(V[V.size(0) * nx].re) +
                       std::abs(V[V.size(0) * nx].im);
              if (n + 1 > 1) {
                for (jcolp1 = 0; jcolp1 < n; jcolp1++) {
                  stemp_re = std::abs(V[(jcolp1 + V.size(0) * nx) + 1].re) +
                             std::abs(V[(jcolp1 + V.size(0) * nx) + 1].im);
                  if (stemp_re > cfromc) {
                    cfromc = stemp_re;
                  }
                }
              }
              if (cfromc >= 6.7178761075670888E-139) {
                cfromc = 1.0 / cfromc;
                for (jcolp1 = 0; jcolp1 <= n; jcolp1++) {
                  V[jcolp1 + V.size(0) * nx].re =
                      cfromc * V[jcolp1 + V.size(0) * nx].re;
                  V[jcolp1 + V.size(0) * nx].im =
                      cfromc * V[jcolp1 + V.size(0) * nx].im;
                }
              }
            }
            if (ilascl) {
              notdone = true;
              while (notdone) {
                stemp_re = anrmto * 2.0041683600089728E-292;
                cto1 = anrm / 4.9896007738368E+291;
                if ((stemp_re > anrm) && (anrm != 0.0)) {
                  a = 2.0041683600089728E-292;
                  anrmto = stemp_re;
                } else if (cto1 > anrmto) {
                  a = 4.9896007738368E+291;
                  anrm = cto1;
                } else {
                  a = anrm / anrmto;
                  notdone = false;
                }
                nx = D.size(0);
                for (k = 0; k < nx; k++) {
                  D[k].re = a * D[k].re;
                  D[k].im = a * D[k].im;
                }
              }
            }
          }
        }
        n = A.size(0);
        jcolp1 = (A.size(0) - 1) * A.size(0) + 1;
        for (jrow = 1; n < 0 ? jrow >= jcolp1 : jrow <= jcolp1; jrow += n) {
          cto1 = 0.0;
          if (n == 1) {
            cto1 = rt_hypotd_snf(V[jrow - 1].re, V[jrow - 1].im);
          } else {
            cfromc = 3.3121686421112381E-170;
            nx = (jrow + n) - 1;
            for (k = jrow; k <= nx; k++) {
              absxk = std::abs(V[k - 1].re);
              if (absxk > cfromc) {
                stemp_re = cfromc / absxk;
                cto1 = cto1 * stemp_re * stemp_re + 1.0;
                cfromc = absxk;
              } else {
                stemp_re = absxk / cfromc;
                cto1 += stemp_re * stemp_re;
              }
              absxk = std::abs(V[k - 1].im);
              if (absxk > cfromc) {
                stemp_re = cfromc / absxk;
                cto1 = cto1 * stemp_re * stemp_re + 1.0;
                cfromc = absxk;
              } else {
                stemp_re = absxk / cfromc;
                cto1 += stemp_re * stemp_re;
              }
            }
            cto1 = cfromc * std::sqrt(cto1);
          }
          k = (jrow + n) - 1;
          for (j = jrow; j <= k; j++) {
            anrm = V[j - 1].re;
            ai = V[j - 1].im;
            if (ai == 0.0) {
              anrmto = anrm / cto1;
              cfromc = 0.0;
            } else if (anrm == 0.0) {
              anrmto = 0.0;
              cfromc = ai / cto1;
            } else {
              anrmto = anrm / cto1;
              cfromc = ai / cto1;
            }
            V[j - 1].re = anrmto;
            V[j - 1].im = cfromc;
          }
        }
        nx = D.size(0);
        for (k = 0; k < nx; k++) {
          anrm = D[k].re;
          ai = D[k].im;
          stemp_re = beta1[k].re;
          cto1 = beta1[k].im;
          if (cto1 == 0.0) {
            if (ai == 0.0) {
              anrmto = anrm / stemp_re;
              cfromc = 0.0;
            } else if (anrm == 0.0) {
              anrmto = 0.0;
              cfromc = ai / stemp_re;
            } else {
              anrmto = anrm / stemp_re;
              cfromc = ai / stemp_re;
            }
          } else if (stemp_re == 0.0) {
            if (anrm == 0.0) {
              anrmto = ai / cto1;
              cfromc = 0.0;
            } else if (ai == 0.0) {
              anrmto = 0.0;
              cfromc = -(anrm / cto1);
            } else {
              anrmto = ai / cto1;
              cfromc = -(anrm / cto1);
            }
          } else {
            a = std::abs(stemp_re);
            cfromc = std::abs(cto1);
            if (a > cfromc) {
              absxk = cto1 / stemp_re;
              cfromc = stemp_re + absxk * cto1;
              anrmto = (anrm + absxk * ai) / cfromc;
              cfromc = (ai - absxk * anrm) / cfromc;
            } else if (cfromc == a) {
              if (stemp_re > 0.0) {
                absxk = 0.5;
              } else {
                absxk = -0.5;
              }
              if (cto1 > 0.0) {
                cfromc = 0.5;
              } else {
                cfromc = -0.5;
              }
              anrmto = (anrm * absxk + ai * cfromc) / a;
              cfromc = (ai * absxk - anrm * cfromc) / a;
            } else {
              absxk = stemp_re / cto1;
              cfromc = cto1 + absxk * stemp_re;
              anrmto = (absxk * anrm + ai) / cfromc;
              cfromc = (absxk * ai - anrm) / cfromc;
            }
          }
          D[k].re = anrmto;
          D[k].im = cfromc;
        }
      }
    }
  }
}

} // namespace coder

// End of code generation (eig.cpp)
