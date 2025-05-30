//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzsteqr.cpp
//
// Code generation for function 'xzsteqr'
//

// Include files
#include "xzsteqr.h"
#include "processSIGburst_onboard_lowmem_rtwutil.h"
#include "rt_nonfinite.h"
#include "xdlaev2.h"
#include "xzlartg.h"
#include "xzlascl.h"
#include "coder_array.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
static void b_rotateRight(int m, int n, ::coder::array<double, 2U> &z, int iz0,
                          int ldz, const ::coder::array<double, 1U> &cs,
                          int ic0, int is0);

static void rotateRight(int m, int n, ::coder::array<double, 2U> &z, int iz0,
                        int ldz, const ::coder::array<double, 1U> &cs, int ic0,
                        int is0);

} // namespace reflapack
} // namespace internal
} // namespace coder

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
static void b_rotateRight(int m, int n, ::coder::array<double, 2U> &z, int iz0,
                          int ldz, const ::coder::array<double, 1U> &cs,
                          int ic0, int is0)
{
  for (int j = 0; j <= n - 2; j++) {
    double ctemp;
    double stemp;
    int offsetj;
    int offsetjp1;
    ctemp = cs[(ic0 + j) - 1];
    stemp = cs[(is0 + j) - 1];
    offsetj = (j * ldz + iz0) - 2;
    offsetjp1 = ((j + 1) * ldz + iz0) - 2;
    if ((ctemp != 1.0) || (stemp != 0.0)) {
      for (int i = 0; i < m; i++) {
        double temp;
        int b_i;
        int temp_tmp;
        temp_tmp = (offsetjp1 + i) + 1;
        temp = z[temp_tmp];
        b_i = (offsetj + i) + 1;
        z[temp_tmp] = ctemp * temp - stemp * z[b_i];
        z[b_i] = stemp * temp + ctemp * z[b_i];
      }
    }
  }
}

static void rotateRight(int m, int n, ::coder::array<double, 2U> &z, int iz0,
                        int ldz, const ::coder::array<double, 1U> &cs, int ic0,
                        int is0)
{
  int i;
  i = n - 1;
  for (int j = i; j >= 1; j--) {
    double ctemp;
    double stemp;
    int offsetj;
    int offsetjp1;
    ctemp = cs[(ic0 + j) - 2];
    stemp = cs[(is0 + j) - 2];
    offsetj = ((j - 1) * ldz + iz0) - 2;
    offsetjp1 = (j * ldz + iz0) - 2;
    if ((ctemp != 1.0) || (stemp != 0.0)) {
      for (int b_i = 0; b_i < m; b_i++) {
        double temp;
        int i1;
        int temp_tmp;
        temp_tmp = (offsetjp1 + b_i) + 1;
        temp = z[temp_tmp];
        i1 = (offsetj + b_i) + 1;
        z[temp_tmp] = ctemp * temp - stemp * z[i1];
        z[i1] = stemp * temp + ctemp * z[i1];
      }
    }
  }
}

int xzsteqr(::coder::array<double, 1U> &d, ::coder::array<double, 1U> &e,
            ::coder::array<double, 2U> &z)
{
  array<double, 1U> work;
  double c;
  double r;
  double s;
  double tst;
  int info;
  int n;
  info = 0;
  n = d.size(0);
  if (n > 1) {
    int i;
    int jtot;
    int l1;
    int ldz;
    int lwork;
    int nmaxit;
    lwork = (n << 1) - 3;
    work.set_size(lwork + 1);
    for (i = 0; i <= lwork; i++) {
      work[i] = 0.0;
    }
    nmaxit = n * 30;
    jtot = 0;
    l1 = 1;
    ldz = z.size(0);
    int exitg1;
    do {
      exitg1 = 0;
      if (l1 > n) {
        for (nmaxit = 2; nmaxit <= n; nmaxit++) {
          double p;
          jtot = nmaxit - 1;
          tst = d[nmaxit - 2];
          p = tst;
          for (lwork = nmaxit; lwork <= n; lwork++) {
            c = d[lwork - 1];
            if (c < p) {
              jtot = lwork;
              p = c;
            }
          }
          if (jtot != nmaxit - 1) {
            int iy;
            d[jtot - 1] = tst;
            d[nmaxit - 2] = p;
            lwork = (nmaxit - 2) * n;
            iy = (jtot - 1) * n;
            for (jtot = 0; jtot < n; jtot++) {
              int iscale;
              iscale = lwork + jtot;
              tst = z[iscale];
              i = iy + jtot;
              z[iscale] = z[i];
              z[i] = tst;
            }
          }
        }
        exitg1 = 1;
      } else {
        int l;
        int lend;
        int lendsv;
        int lsv;
        int m;
        bool exitg2;
        if (l1 > 1) {
          e[l1 - 2] = 0.0;
        }
        m = l1;
        exitg2 = false;
        while ((!exitg2) && (m < n)) {
          tst = std::abs(e[m - 1]);
          if (tst == 0.0) {
            exitg2 = true;
          } else if (tst <= std::sqrt(std::abs(d[m - 1])) *
                                std::sqrt(std::abs(d[m])) *
                                2.2204460492503131E-16) {
            e[m - 1] = 0.0;
            exitg2 = true;
          } else {
            m++;
          }
        }
        l = l1 - 1;
        lsv = l1;
        lend = m;
        lendsv = m;
        l1 = m + 1;
        if (m != l + 1) {
          double anorm;
          int b_i;
          int iscale;
          int iy;
          iy = m - l;
          if (iy <= 0) {
            anorm = 0.0;
          } else {
            anorm = std::abs(d[(l + iy) - 1]);
            b_i = 0;
            exitg2 = false;
            while ((!exitg2) && (b_i <= iy - 2)) {
              lwork = l + b_i;
              tst = std::abs(d[lwork]);
              if (rtIsNaN(tst)) {
                anorm = rtNaN;
                exitg2 = true;
              } else {
                if (tst > anorm) {
                  anorm = tst;
                }
                tst = std::abs(e[lwork]);
                if (rtIsNaN(tst)) {
                  anorm = rtNaN;
                  exitg2 = true;
                } else {
                  if (tst > anorm) {
                    anorm = tst;
                  }
                  b_i++;
                }
              }
            }
          }
          iscale = 0;
          if (!(anorm == 0.0)) {
            if (rtIsInf(anorm) || rtIsNaN(anorm)) {
              lwork = d.size(0);
              d.set_size(lwork);
              for (i = 0; i < lwork; i++) {
                d[i] = rtNaN;
              }
              lwork = z.size(0);
              iy = z.size(1);
              z.set_size(lwork, iy);
              for (i = 0; i < iy; i++) {
                for (iscale = 0; iscale < lwork; iscale++) {
                  z[iscale + z.size(0) * i] = rtNaN;
                }
              }
              exitg1 = 1;
            } else {
              if (anorm > 2.2346346549904327E+153) {
                iscale = 1;
                xzlascl(anorm, 2.2346346549904327E+153, iy, d, l + 1);
                xzlascl(anorm, 2.2346346549904327E+153, iy - 1, e, l + 1);
              } else if (anorm < 3.02546243347603E-123) {
                iscale = 2;
                xzlascl(anorm, 3.02546243347603E-123, iy, d, l + 1);
                xzlascl(anorm, 3.02546243347603E-123, iy - 1, e, l + 1);
              }
              if (std::abs(d[m - 1]) < std::abs(d[l])) {
                lend = lsv;
                l = m - 1;
              }
              if (lend > l + 1) {
                int exitg4;
                do {
                  exitg4 = 0;
                  if (l + 1 != lend) {
                    m = l + 1;
                    exitg2 = false;
                    while ((!exitg2) && (m < lend)) {
                      tst = std::abs(e[m - 1]);
                      if (tst * tst <= 4.9303806576313238E-32 *
                                               std::abs(d[m - 1]) *
                                               std::abs(d[m]) +
                                           2.2250738585072014E-308) {
                        exitg2 = true;
                      } else {
                        m++;
                      }
                    }
                  } else {
                    m = lend;
                  }
                  if (m < lend) {
                    e[m - 1] = 0.0;
                  }
                  if (m == l + 1) {
                    l++;
                    if (l + 1 > lend) {
                      exitg4 = 1;
                    }
                  } else if (m == l + 2) {
                    d[l] = xdlaev2(d[l], e[l], d[l + 1], &c, &work[l], &tst);
                    d[l + 1] = c;
                    lwork = n + l;
                    work[lwork - 1] = tst;
                    rotateRight(n, 2, z, l * ldz + 1, ldz, work, l + 1, lwork);
                    e[l] = 0.0;
                    l += 2;
                    if (l + 1 > lend) {
                      exitg4 = 1;
                    }
                  } else if (jtot == nmaxit) {
                    exitg4 = 1;
                  } else {
                    double g;
                    double p;
                    jtot++;
                    g = (d[l + 1] - d[l]) / (2.0 * e[l]);
                    c = rt_hypotd_snf(g, 1.0);
                    if (!(g >= 0.0)) {
                      c = -c;
                    }
                    g = (d[m - 1] - d[l]) + e[l] / (g + c);
                    tst = 1.0;
                    c = 1.0;
                    p = 0.0;
                    i = m - 1;
                    for (b_i = i; b_i >= l + 1; b_i--) {
                      double b;
                      double b_tmp;
                      b_tmp = e[b_i - 1];
                      b = c * b_tmp;
                      c = xzlartg(g, tst * b_tmp, &s, &r);
                      tst = s;
                      if (b_i != m - 1) {
                        e[b_i] = r;
                      }
                      g = d[b_i] - p;
                      r = (d[b_i - 1] - g) * s + 2.0 * c * b;
                      p = s * r;
                      d[b_i] = g + p;
                      g = c * r - b;
                      work[b_i - 1] = c;
                      work[(n + b_i) - 2] = -s;
                    }
                    rotateRight(n, m - l, z, l * ldz + 1, ldz, work, l + 1,
                                n + l);
                    d[l] = d[l] - p;
                    e[l] = g;
                  }
                } while (exitg4 == 0);
              } else {
                int exitg3;
                do {
                  exitg3 = 0;
                  if (l + 1 != lend) {
                    m = l + 1;
                    exitg2 = false;
                    while ((!exitg2) && (m > lend)) {
                      tst = std::abs(e[m - 2]);
                      if (tst * tst <= 4.9303806576313238E-32 *
                                               std::abs(d[m - 1]) *
                                               std::abs(d[m - 2]) +
                                           2.2250738585072014E-308) {
                        exitg2 = true;
                      } else {
                        m--;
                      }
                    }
                  } else {
                    m = lend;
                  }
                  if (m > lend) {
                    e[m - 2] = 0.0;
                  }
                  if (m == l + 1) {
                    l--;
                    if (l + 1 < lend) {
                      exitg3 = 1;
                    }
                  } else if (m == l) {
                    d[l - 1] = xdlaev2(d[l - 1], e[l - 1], d[l], &c,
                                       &work[m - 1], &tst);
                    d[l] = c;
                    lwork = n + m;
                    work[lwork - 2] = tst;
                    b_rotateRight(n, 2, z, (l - 1) * ldz + 1, ldz, work, m,
                                  lwork - 1);
                    e[l - 1] = 0.0;
                    l -= 2;
                    if (l + 1 < lend) {
                      exitg3 = 1;
                    }
                  } else if (jtot == nmaxit) {
                    exitg3 = 1;
                  } else {
                    double g;
                    double p;
                    jtot++;
                    tst = e[l - 1];
                    g = (d[l - 1] - d[l]) / (2.0 * tst);
                    c = rt_hypotd_snf(g, 1.0);
                    if (!(g >= 0.0)) {
                      c = -c;
                    }
                    g = (d[m - 1] - d[l]) + tst / (g + c);
                    tst = 1.0;
                    c = 1.0;
                    p = 0.0;
                    for (b_i = m; b_i <= l; b_i++) {
                      double b;
                      double b_tmp;
                      b_tmp = e[b_i - 1];
                      b = c * b_tmp;
                      c = xzlartg(g, tst * b_tmp, &s, &r);
                      tst = s;
                      if (b_i != m) {
                        e[b_i - 2] = r;
                      }
                      g = d[b_i - 1] - p;
                      r = (d[b_i] - g) * s + 2.0 * c * b;
                      p = s * r;
                      d[b_i - 1] = g + p;
                      g = c * r - b;
                      work[b_i - 1] = c;
                      work[(n + b_i) - 2] = s;
                    }
                    b_rotateRight(n, (l - m) + 2, z, (m - 1) * ldz + 1, ldz,
                                  work, m, (n + m) - 1);
                    d[l] = d[l] - p;
                    e[l - 1] = g;
                  }
                } while (exitg3 == 0);
              }
              if (iscale == 1) {
                i = lendsv - lsv;
                xzlascl(2.2346346549904327E+153, anorm, i + 1, d, lsv);
                xzlascl(2.2346346549904327E+153, anorm, i, e, lsv);
              } else if (iscale == 2) {
                i = lendsv - lsv;
                xzlascl(3.02546243347603E-123, anorm, i + 1, d, lsv);
                xzlascl(3.02546243347603E-123, anorm, i, e, lsv);
              }
              if (jtot >= nmaxit) {
                for (b_i = 0; b_i <= n - 2; b_i++) {
                  if (e[b_i] != 0.0) {
                    info++;
                  }
                }
                exitg1 = 1;
              }
            }
          }
        }
      }
    } while (exitg1 == 0);
  }
  return info;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xzsteqr.cpp)
