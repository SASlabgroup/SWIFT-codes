//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzhgeqz.cpp
//
// Code generation for function 'xzhgeqz'
//

// Include files
#include "xzhgeqz.h"
#include "eof_data.h"
#include "rt_nonfinite.h"
#include "sqrt.h"
#include "xzlartg.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
void xzhgeqz(::coder::array<creal_T, 2U> &A, int ilo, int ihi,
             ::coder::array<creal_T, 2U> &Z, int *info,
             ::coder::array<creal_T, 1U> &alpha1,
             ::coder::array<creal_T, 1U> &beta1)
{
  creal_T ctemp;
  creal_T stemp;
  creal_T y;
  double anorm;
  double ascale;
  double b_atol;
  double bscale;
  double colscale;
  double colssq;
  double eshift_im;
  double eshift_re;
  double scale;
  double ssq;
  double t;
  int col;
  int ilast;
  int istart;
  int j;
  int jp1;
  int n;
  int nm1;
  bool compz;
  bool failed;
  bool guard1{false};
  bool guard2{false};
  *info = 0;
  compz = ((Z.size(0) != 0) && (Z.size(1) != 0));
  if ((A.size(0) == 1) && (A.size(1) == 1)) {
    ihi = 1;
  }
  n = A.size(0);
  alpha1.set_size(A.size(0));
  jp1 = A.size(0);
  for (istart = 0; istart < jp1; istart++) {
    alpha1[istart].re = 0.0;
    alpha1[istart].im = 0.0;
  }
  beta1.set_size(A.size(0));
  jp1 = A.size(0);
  for (istart = 0; istart < jp1; istart++) {
    beta1[istart].re = 1.0;
    beta1[istart].im = 0.0;
  }
  eshift_re = 0.0;
  eshift_im = 0.0;
  ctemp.re = 0.0;
  ctemp.im = 0.0;
  anorm = 0.0;
  if (ilo <= ihi) {
    scale = 3.3121686421112381E-170;
    ssq = 0.0;
    nm1 = ihi - ilo;
    for (j = 0; j <= nm1; j++) {
      colscale = 3.3121686421112381E-170;
      colssq = 0.0;
      col = (ilo + j) - 1;
      jp1 = j + 1;
      if (jp1 >= nm1) {
        jp1 = nm1;
      }
      istart = ilo + jp1;
      for (jp1 = ilo; jp1 <= istart; jp1++) {
        anorm = std::abs(A[(jp1 + A.size(0) * col) - 1].re);
        if (anorm > colscale) {
          t = colscale / anorm;
          colssq = colssq * t * t + 1.0;
          colscale = anorm;
        } else {
          t = anorm / colscale;
          colssq += t * t;
        }
        anorm = std::abs(A[(jp1 + A.size(0) * col) - 1].im);
        if (anorm > colscale) {
          t = colscale / anorm;
          colssq = colssq * t * t + 1.0;
          colscale = anorm;
        } else {
          t = anorm / colscale;
          colssq += t * t;
        }
      }
      if (scale >= colscale) {
        t = colscale / scale;
        ssq += t * t * colssq;
      } else {
        t = scale / colscale;
        ssq = colssq + t * t * ssq;
        scale = colscale;
      }
    }
    anorm = scale * std::sqrt(ssq);
  }
  t = 2.2204460492503131E-16 * anorm;
  b_atol = 2.2250738585072014E-308;
  if (t > 2.2250738585072014E-308) {
    b_atol = t;
  }
  t = 2.2250738585072014E-308;
  if (anorm > 2.2250738585072014E-308) {
    t = anorm;
  }
  ascale = 1.0 / t;
  bscale = 1.0 / std::sqrt(static_cast<double>(A.size(0)));
  failed = true;
  istart = ihi + 1;
  for (j = istart; j <= n; j++) {
    alpha1[j - 1] = A[(j + A.size(0) * (j - 1)) - 1];
  }
  guard1 = false;
  guard2 = false;
  if (ihi >= ilo) {
    int ifrstm;
    int iiter;
    int ilastm;
    int ilastm1;
    int jiter;
    bool goto60;
    bool goto70;
    bool goto90;
    col = ilo;
    istart = ilo;
    ilast = ihi - 1;
    ilastm1 = ihi - 2;
    if (compz) {
      ifrstm = 1;
      ilastm = n;
    } else {
      ifrstm = ilo;
      ilastm = ihi;
    }
    iiter = 0;
    goto60 = false;
    goto70 = false;
    goto90 = false;
    jiter = 0;
    int exitg1;
    do {
      exitg1 = 0;
      if (jiter <= 30 * ((ihi - ilo) + 1) - 1) {
        bool b_guard1{false};
        bool exitg2;
        b_guard1 = false;
        if (ilast + 1 == ilo) {
          goto60 = true;
          b_guard1 = true;
        } else if (std::abs(A[ilast + A.size(0) * ilastm1].re) +
                       std::abs(A[ilast + A.size(0) * ilastm1].im) <=
                   std::fmax(
                       2.2250738585072014E-308,
                       2.2204460492503131E-16 *
                           ((std::abs(A[ilast + A.size(0) * ilast].re) +
                             std::abs(A[ilast + A.size(0) * ilast].im)) +
                            (std::abs(A[ilastm1 + A.size(0) * ilastm1].re) +
                             std::abs(A[ilastm1 + A.size(0) * ilastm1].im))))) {
          A[ilast + A.size(0) * ilastm1].re = 0.0;
          A[ilast + A.size(0) * ilastm1].im = 0.0;
          goto60 = true;
          b_guard1 = true;
        } else {
          bool guard3{false};
          j = ilastm1;
          guard3 = false;
          exitg2 = false;
          while ((!exitg2) && (j + 1 >= ilo)) {
            if (j + 1 == ilo) {
              guard3 = true;
              exitg2 = true;
            } else if (std::abs(A[j + A.size(0) * (j - 1)].re) +
                           std::abs(A[j + A.size(0) * (j - 1)].im) <=
                       std::fmax(
                           2.2250738585072014E-308,
                           2.2204460492503131E-16 *
                               ((std::abs(A[j + A.size(0) * j].re) +
                                 std::abs(A[j + A.size(0) * j].im)) +
                                (std::abs(A[(j + A.size(0) * (j - 1)) - 1].re) +
                                 std::abs(
                                     A[(j + A.size(0) * (j - 1)) - 1].im))))) {
              A[j + A.size(0) * (j - 1)].re = 0.0;
              A[j + A.size(0) * (j - 1)].im = 0.0;
              guard3 = true;
              exitg2 = true;
            } else {
              j--;
              guard3 = false;
            }
          }
          if (guard3) {
            col = j + 1;
            goto70 = true;
          }
          if (goto70) {
            b_guard1 = true;
          } else {
            jp1 = alpha1.size(0);
            alpha1.set_size(jp1);
            for (istart = 0; istart < jp1; istart++) {
              alpha1[istart].re = rtNaN;
              alpha1[istart].im = 0.0;
            }
            jp1 = beta1.size(0);
            beta1.set_size(jp1);
            for (istart = 0; istart < jp1; istart++) {
              beta1[istart].re = rtNaN;
              beta1[istart].im = 0.0;
            }
            if (compz) {
              jp1 = Z.size(0);
              nm1 = Z.size(1);
              Z.set_size(jp1, nm1);
              for (istart = 0; istart < nm1; istart++) {
                for (col = 0; col < jp1; col++) {
                  Z[col + Z.size(0) * istart].re = rtNaN;
                  Z[col + Z.size(0) * istart].im = 0.0;
                }
              }
            }
            *info = 1;
            exitg1 = 1;
          }
        }
        if (b_guard1) {
          if (goto60) {
            goto60 = false;
            alpha1[ilast] = A[ilast + A.size(0) * ilast];
            ilast = ilastm1;
            ilastm1--;
            if (ilast + 1 < ilo) {
              failed = false;
              guard2 = true;
              exitg1 = 1;
            } else {
              iiter = 0;
              eshift_re = 0.0;
              eshift_im = 0.0;
              if (!compz) {
                ilastm = ilast + 1;
                if (ifrstm > ilast + 1) {
                  ifrstm = ilo;
                }
              }
              jiter++;
            }
          } else {
            if (goto70) {
              double ad22_im;
              double ad22_re;
              goto70 = false;
              iiter++;
              if (!compz) {
                ifrstm = col;
              }
              if (iiter - iiter / 10 * 10 != 0) {
                anorm = ascale * A[ilast + A.size(0) * ilast].re;
                t = ascale * A[ilast + A.size(0) * ilast].im;
                if (t == 0.0) {
                  ad22_re = anorm / bscale;
                  ad22_im = 0.0;
                } else if (anorm == 0.0) {
                  ad22_re = 0.0;
                  ad22_im = t / bscale;
                } else {
                  ad22_re = anorm / bscale;
                  ad22_im = t / bscale;
                }
                anorm = ascale * A[ilastm1 + A.size(0) * ilast].re;
                t = ascale * A[ilastm1 + A.size(0) * ilast].im;
                if (t == 0.0) {
                  stemp.re = anorm / bscale;
                  stemp.im = 0.0;
                } else if (anorm == 0.0) {
                  stemp.re = 0.0;
                  stemp.im = t / bscale;
                } else {
                  stemp.re = anorm / bscale;
                  stemp.im = t / bscale;
                }
                b_sqrt(&stemp);
                anorm = ascale * A[ilast + A.size(0) * ilastm1].re;
                t = ascale * A[ilast + A.size(0) * ilastm1].im;
                if (t == 0.0) {
                  y.re = anorm / bscale;
                  y.im = 0.0;
                } else if (anorm == 0.0) {
                  y.re = 0.0;
                  y.im = t / bscale;
                } else {
                  y.re = anorm / bscale;
                  y.im = t / bscale;
                }
                b_sqrt(&y);
                ctemp.re = stemp.re * y.re - stemp.im * y.im;
                ctemp.im = stemp.re * y.im + stemp.im * y.re;
                if ((ctemp.re != 0.0) || (ctemp.im != 0.0)) {
                  double x_im;
                  anorm = ascale * A[ilastm1 + A.size(0) * ilastm1].re;
                  t = ascale * A[ilastm1 + A.size(0) * ilastm1].im;
                  if (t == 0.0) {
                    anorm /= bscale;
                    t = 0.0;
                  } else if (anorm == 0.0) {
                    anorm = 0.0;
                    t /= bscale;
                  } else {
                    anorm /= bscale;
                    t /= bscale;
                  }
                  colssq = 0.5 * (anorm - ad22_re);
                  x_im = 0.5 * (t - ad22_im);
                  colscale = std::abs(colssq) + std::abs(x_im);
                  ssq = std::fmax(std::abs(ctemp.re) + std::abs(ctemp.im),
                                  colscale);
                  if (x_im == 0.0) {
                    stemp.re = colssq / ssq;
                    stemp.im = 0.0;
                  } else if (colssq == 0.0) {
                    stemp.re = 0.0;
                    stemp.im = x_im / ssq;
                  } else {
                    stemp.re = colssq / ssq;
                    stemp.im = x_im / ssq;
                  }
                  if (ctemp.im == 0.0) {
                    y.re = ctemp.re / ssq;
                    y.im = 0.0;
                  } else if (ctemp.re == 0.0) {
                    y.re = 0.0;
                    y.im = ctemp.im / ssq;
                  } else {
                    y.re = ctemp.re / ssq;
                    y.im = ctemp.im / ssq;
                  }
                  anorm = stemp.re * stemp.re - stemp.im * stemp.im;
                  t = stemp.re * stemp.im;
                  scale = y.re * y.im;
                  stemp.re = anorm + (y.re * y.re - y.im * y.im);
                  stemp.im = (t + t) + (scale + scale);
                  b_sqrt(&stemp);
                  y.re = ssq * stemp.re;
                  y.im = ssq * stemp.im;
                  if (colscale > 0.0) {
                    if (x_im == 0.0) {
                      t = colssq / colscale;
                      anorm = 0.0;
                    } else {
                      if (colssq == 0.0) {
                        t = 0.0;
                      } else {
                        t = colssq / colscale;
                      }
                      anorm = x_im / colscale;
                    }
                    if (t * y.re + anorm * y.im < 0.0) {
                      y.re = -y.re;
                      y.im = -y.im;
                    }
                  }
                  scale = colssq + y.re;
                  ssq = x_im + y.im;
                  if (ssq == 0.0) {
                    if (ctemp.im == 0.0) {
                      colssq = ctemp.re / scale;
                      anorm = 0.0;
                    } else if (ctemp.re == 0.0) {
                      colssq = 0.0;
                      anorm = ctemp.im / scale;
                    } else {
                      colssq = ctemp.re / scale;
                      anorm = ctemp.im / scale;
                    }
                  } else if (scale == 0.0) {
                    if (ctemp.re == 0.0) {
                      colssq = ctemp.im / ssq;
                      anorm = 0.0;
                    } else if (ctemp.im == 0.0) {
                      colssq = 0.0;
                      anorm = -(ctemp.re / ssq);
                    } else {
                      colssq = ctemp.im / ssq;
                      anorm = -(ctemp.re / ssq);
                    }
                  } else {
                    colscale = std::abs(scale);
                    anorm = std::abs(ssq);
                    if (colscale > anorm) {
                      t = ssq / scale;
                      anorm = scale + t * ssq;
                      colssq = (ctemp.re + t * ctemp.im) / anorm;
                      anorm = (ctemp.im - t * ctemp.re) / anorm;
                    } else if (anorm == colscale) {
                      if (scale > 0.0) {
                        t = 0.5;
                      } else {
                        t = -0.5;
                      }
                      if (ssq > 0.0) {
                        anorm = 0.5;
                      } else {
                        anorm = -0.5;
                      }
                      colssq = (ctemp.re * t + ctemp.im * anorm) / colscale;
                      anorm = (ctemp.im * t - ctemp.re * anorm) / colscale;
                    } else {
                      t = scale / ssq;
                      anorm = ssq + t * scale;
                      colssq = (t * ctemp.re + ctemp.im) / anorm;
                      anorm = (t * ctemp.im - ctemp.re) / anorm;
                    }
                  }
                  ad22_re -= ctemp.re * colssq - ctemp.im * anorm;
                  ad22_im -= ctemp.re * anorm + ctemp.im * colssq;
                }
              } else {
                if (iiter - iiter / 20 * 20 == 0) {
                  anorm = ascale * A[ilast + A.size(0) * ilast].re;
                  t = ascale * A[ilast + A.size(0) * ilast].im;
                  if (t == 0.0) {
                    anorm /= bscale;
                    t = 0.0;
                  } else if (anorm == 0.0) {
                    anorm = 0.0;
                    t /= bscale;
                  } else {
                    anorm /= bscale;
                    t /= bscale;
                  }
                  eshift_re += anorm;
                  eshift_im += t;
                } else {
                  anorm = ascale * A[ilast + A.size(0) * ilastm1].re;
                  t = ascale * A[ilast + A.size(0) * ilastm1].im;
                  if (t == 0.0) {
                    anorm /= bscale;
                    t = 0.0;
                  } else if (anorm == 0.0) {
                    anorm = 0.0;
                    t /= bscale;
                  } else {
                    anorm /= bscale;
                    t /= bscale;
                  }
                  eshift_re += anorm;
                  eshift_im += t;
                }
                ad22_re = eshift_re;
                ad22_im = eshift_im;
              }
              j = ilastm1;
              jp1 = ilastm1 + 1;
              exitg2 = false;
              while ((!exitg2) && (j + 1 > col)) {
                istart = j + 1;
                ctemp.re = ascale * A[j + A.size(0) * j].re - ad22_re * bscale;
                ctemp.im = ascale * A[j + A.size(0) * j].im - ad22_im * bscale;
                ssq = std::abs(ctemp.re) + std::abs(ctemp.im);
                colscale = ascale * (std::abs(A[jp1 + A.size(0) * j].re) +
                                     std::abs(A[jp1 + A.size(0) * j].im));
                anorm = ssq;
                if (colscale > ssq) {
                  anorm = colscale;
                }
                if ((anorm < 1.0) && (anorm != 0.0)) {
                  ssq /= anorm;
                  colscale /= anorm;
                }
                if ((std::abs(A[j + A.size(0) * (j - 1)].re) +
                     std::abs(A[j + A.size(0) * (j - 1)].im)) *
                        colscale <=
                    ssq * b_atol) {
                  goto90 = true;
                  exitg2 = true;
                } else {
                  jp1 = j;
                  j--;
                }
              }
              if (!goto90) {
                istart = col;
                ctemp.re = ascale * A[(col + A.size(0) * (col - 1)) - 1].re -
                           ad22_re * bscale;
                ctemp.im = ascale * A[(col + A.size(0) * (col - 1)) - 1].im -
                           ad22_im * bscale;
              }
              goto90 = false;
              stemp.re = ascale * A[istart + A.size(0) * (istart - 1)].re;
              stemp.im = ascale * A[istart + A.size(0) * (istart - 1)].im;
              xzlartg(ctemp, stemp, &anorm, &y);
              j = istart;
              nm1 = istart - 2;
              while (j < ilast + 1) {
                if (j > istart) {
                  xzlartg(A[(j + A.size(0) * nm1) - 1], A[j + A.size(0) * nm1],
                          &anorm, &y, &A[(j + A.size(0) * nm1) - 1]);
                  A[j + A.size(0) * nm1].re = 0.0;
                  A[j + A.size(0) * nm1].im = 0.0;
                }
                for (nm1 = j; nm1 <= ilastm; nm1++) {
                  stemp.re = anorm * A[(j + A.size(0) * (nm1 - 1)) - 1].re +
                             (y.re * A[j + A.size(0) * (nm1 - 1)].re -
                              y.im * A[j + A.size(0) * (nm1 - 1)].im);
                  stemp.im = anorm * A[(j + A.size(0) * (nm1 - 1)) - 1].im +
                             (y.re * A[j + A.size(0) * (nm1 - 1)].im +
                              y.im * A[j + A.size(0) * (nm1 - 1)].re);
                  t = A[(j + A.size(0) * (nm1 - 1)) - 1].im;
                  scale = A[(j + A.size(0) * (nm1 - 1)) - 1].re;
                  A[j + A.size(0) * (nm1 - 1)].re =
                      anorm * A[j + A.size(0) * (nm1 - 1)].re -
                      (y.re * A[(j + A.size(0) * (nm1 - 1)) - 1].re +
                       y.im * A[(j + A.size(0) * (nm1 - 1)) - 1].im);
                  A[j + A.size(0) * (nm1 - 1)].im =
                      anorm * A[j + A.size(0) * (nm1 - 1)].im -
                      (y.re * t - y.im * scale);
                  A[(j + A.size(0) * (nm1 - 1)) - 1] = stemp;
                }
                y.re = -y.re;
                y.im = -y.im;
                nm1 = j;
                if (ilast + 1 < j + 2) {
                  nm1 = ilast - 1;
                }
                for (jp1 = ifrstm; jp1 <= nm1 + 2; jp1++) {
                  stemp.re = anorm * A[(jp1 + A.size(0) * j) - 1].re +
                             (y.re * A[(jp1 + A.size(0) * (j - 1)) - 1].re -
                              y.im * A[(jp1 + A.size(0) * (j - 1)) - 1].im);
                  stemp.im = anorm * A[(jp1 + A.size(0) * j) - 1].im +
                             (y.re * A[(jp1 + A.size(0) * (j - 1)) - 1].im +
                              y.im * A[(jp1 + A.size(0) * (j - 1)) - 1].re);
                  t = A[(jp1 + A.size(0) * j) - 1].im;
                  scale = A[(jp1 + A.size(0) * j) - 1].re;
                  A[(jp1 + A.size(0) * (j - 1)) - 1].re =
                      anorm * A[(jp1 + A.size(0) * (j - 1)) - 1].re -
                      (y.re * A[(jp1 + A.size(0) * j) - 1].re + y.im * t);
                  A[(jp1 + A.size(0) * (j - 1)) - 1].im =
                      anorm * A[(jp1 + A.size(0) * (j - 1)) - 1].im -
                      (y.re * t - y.im * scale);
                  A[(jp1 + A.size(0) * j) - 1] = stemp;
                }
                if (compz) {
                  for (jp1 = 1; jp1 <= n; jp1++) {
                    stemp.re = anorm * Z[(jp1 + Z.size(0) * j) - 1].re +
                               (y.re * Z[(jp1 + Z.size(0) * (j - 1)) - 1].re -
                                y.im * Z[(jp1 + Z.size(0) * (j - 1)) - 1].im);
                    stemp.im = anorm * Z[(jp1 + Z.size(0) * j) - 1].im +
                               (y.re * Z[(jp1 + Z.size(0) * (j - 1)) - 1].im +
                                y.im * Z[(jp1 + Z.size(0) * (j - 1)) - 1].re);
                    t = Z[(jp1 + Z.size(0) * j) - 1].im;
                    scale = Z[(jp1 + Z.size(0) * j) - 1].re;
                    Z[(jp1 + Z.size(0) * (j - 1)) - 1].re =
                        anorm * Z[(jp1 + Z.size(0) * (j - 1)) - 1].re -
                        (y.re * Z[(jp1 + Z.size(0) * j) - 1].re +
                         y.im * Z[(jp1 + Z.size(0) * j) - 1].im);
                    Z[(jp1 + Z.size(0) * (j - 1)) - 1].im =
                        anorm * Z[(jp1 + Z.size(0) * (j - 1)) - 1].im -
                        (y.re * t - y.im * scale);
                    Z[(jp1 + Z.size(0) * j) - 1] = stemp;
                  }
                }
                nm1 = j - 1;
                j++;
              }
            }
            jiter++;
          }
        }
      } else {
        guard2 = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  } else {
    guard1 = true;
  }
  if (guard2) {
    if (failed) {
      *info = ilast + 1;
      for (jp1 = 0; jp1 <= ilast; jp1++) {
        alpha1[jp1].re = rtNaN;
        alpha1[jp1].im = 0.0;
        beta1[jp1].re = rtNaN;
        beta1[jp1].im = 0.0;
      }
      if (compz) {
        jp1 = Z.size(0);
        nm1 = Z.size(1);
        Z.set_size(jp1, nm1);
        for (istart = 0; istart < nm1; istart++) {
          for (col = 0; col < jp1; col++) {
            Z[col + Z.size(0) * istart].re = rtNaN;
            Z[col + Z.size(0) * istart].im = 0.0;
          }
        }
      }
    } else {
      guard1 = true;
    }
  }
  if (guard1) {
    for (j = 0; j <= ilo - 2; j++) {
      alpha1[j] = A[j + A.size(0) * j];
    }
  }
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xzhgeqz.cpp)
