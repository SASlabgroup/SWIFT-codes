//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// movsortfun.cpp
//
// Code generation for function 'movsortfun'
//

// Include files
#include "movsortfun.h"
#include "SortedBuffer.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Variable Definitions
static emlrtRSInfo wb_emlrtRSI{
    51,           // lineNo
    "movsortfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo xb_emlrtRSI{
    54,                          // lineNo
    "applyVectorFunctionNoCopy", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunctionNoCopy.m" // pathName
};

static emlrtRSInfo yb_emlrtRSI{
    110,        // lineNo
    "looper1D", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunctionNoCopy.m" // pathName
};

static emlrtRSInfo ac_emlrtRSI{
    118,        // lineNo
    "looper1D", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyVectorFunctionNoCopy.m" // pathName
};

static emlrtRSInfo dc_emlrtRSI{
    49, // lineNo
    "@(x,ind2SubX,y,ind2SubY)vmovfun(x,ind2SubX,nx,y,ind2SubY,ny,op,kleft,"
    "kright,nanflag,ep,fillval)", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo ec_emlrtRSI{
    76,        // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo fc_emlrtRSI{
    193,       // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo gc_emlrtRSI{
    187,       // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo hc_emlrtRSI{
    179,       // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo ic_emlrtRSI{
    174,       // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo jc_emlrtRSI{
    160,       // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo kc_emlrtRSI{
    135,       // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo lc_emlrtRSI{
    131,       // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo mc_emlrtRSI{
    99,        // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo nc_emlrtRSI{
    80,        // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtDCInfo c_emlrtDCI{
    76,        // lineNo
    1,         // colNo
    "vmovfun", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m", // pName
    4         // checkKind
};

static emlrtRTEInfo bd_emlrtRTEI{
    51,           // lineNo
    1,            // colNo
    "movsortfun", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pName
};

static emlrtRTEInfo cd_emlrtRTEI{
    76,           // lineNo
    1,            // colNo
    "movsortfun", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pName
};

static emlrtRSInfo qj_emlrtRSI{
    133,       // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo rj_emlrtRSI{
    166,       // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

static emlrtRSInfo sj_emlrtRSI{
    83,        // lineNo
    "vmovfun", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\movsor"
    "tfun.m" // pathName
};

// Function Definitions
namespace coder {
void movsortfun(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
                int32_T kleft, int32_T kright, ::coder::array<real_T, 2U> &y)
{
  internal::SortedBuffer s;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack st;
  int32_T i;
  int32_T k0;
  int32_T npages;
  int32_T nx;
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
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  nx = x.size(0);
  st.site = &wb_emlrtRSI;
  y.set_size(&bd_emlrtRTEI, &st, x.size(0), x.size(1));
  k0 = x.size(0) * x.size(1);
  for (i = 0; i < k0; i++) {
    y[i] = 0.0;
  }
  b_st.site = &xb_emlrtRSI;
  npages = x.size(1);
  c_st.site = &yb_emlrtRSI;
  if (x.size(1) > 2147483646) {
    d_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(d_st);
  }
  for (int32_T p{0}; p < npages; p++) {
    int32_T ny;
    int32_T workspace_ixfirst_tmp;
    ny = x.size(0);
    workspace_ixfirst_tmp = p * x.size(0);
    c_st.site = &ac_emlrtRSI;
    d_st.site = &cc_emlrtRSI;
    e_st.site = &dc_emlrtRSI;
    if ((y.size(0) != 0) && (y.size(1) != 0)) {
      real_T d;
      real_T xnew;
      real_T xold;
      int32_T iLeftLast;
      int32_T iRightLast;
      int32_T mid;
      xold = 0.0;
      xnew = 0.0;
      k0 = (kleft + kright) + 1;
      f_st.site = &ec_emlrtRSI;
      if (k0 < 0) {
        emlrtNonNegativeCheckR2012b(static_cast<real_T>(k0), &c_emlrtDCI,
                                    &f_st);
      }
      s.buf.set_size(&cd_emlrtRTEI, &f_st, k0);
      for (i = 0; i < k0; i++) {
        s.buf[i] = 0.0;
      }
      s.nbuf = 0;
      s.includenans = false;
      s.nnans = 0;
      if (kleft >= 1) {
        iLeftLast = 1;
      } else {
        iLeftLast = 1 - kleft;
      }
      if (kright + 1 > nx) {
        iRightLast = nx;
      } else {
        iRightLast = kright + 1;
      }
      f_st.site = &nc_emlrtRSI;
      if ((iLeftLast <= iRightLast) && (iRightLast > 2147483646)) {
        g_st.site = &bc_emlrtRSI;
        check_forloop_overflow_error(g_st);
      }
      for (int32_T k{iLeftLast}; k <= iRightLast; k++) {
        f_st.site = &sj_emlrtRSI;
        s.insert(f_st, x[(workspace_ixfirst_tmp + k) - 1]);
      }
      if (s.nbuf == 0) {
        y[workspace_ixfirst_tmp] = rtNaN;
      } else {
        mid = s.nbuf >> 1;
        if ((s.nbuf & 1) == 1) {
          y[workspace_ixfirst_tmp] = s.buf[mid];
        } else {
          d = s.buf[mid - 1];
          if (((d < 0.0) != (s.buf[mid] < 0.0)) || muDoubleScalarIsInf(d)) {
            y[workspace_ixfirst_tmp] = (d + s.buf[mid]) / 2.0;
          } else {
            y[workspace_ixfirst_tmp] = d + (s.buf[mid] - d) / 2.0;
          }
        }
      }
      if (k0 > nx) {
        f_st.site = &mc_emlrtRSI;
        for (int32_T k{2}; k <= ny; k++) {
          int32_T b;
          boolean_T b_remove;
          boolean_T guard1;
          boolean_T insert;
          if (k <= kleft) {
            b = 1;
          } else {
            b = k - kleft;
          }
          k0 = k + kright;
          if (k0 > ny) {
            k0 = ny;
          }
          if (b > iLeftLast) {
            xold = x[(workspace_ixfirst_tmp + iLeftLast) - 1];
            b_remove = true;
            iLeftLast = b;
          } else {
            b_remove = false;
          }
          guard1 = false;
          if (k0 > iRightLast) {
            xnew = x[(workspace_ixfirst_tmp + k0) - 1];
            insert = true;
            iRightLast = k0;
            if (b_remove) {
              f_st.site = &lc_emlrtRSI;
              s.replace(f_st, xold, xnew);
            } else {
              guard1 = true;
            }
          } else {
            insert = false;
            guard1 = true;
          }
          if (guard1) {
            if (insert) {
              f_st.site = &qj_emlrtRSI;
              s.insert(f_st, xnew);
            } else if (b_remove) {
              f_st.site = &kc_emlrtRSI;
              s.b_remove(f_st, xold);
            }
          }
          i = (workspace_ixfirst_tmp + k) - 1;
          if (s.nbuf == 0) {
            y[i] = rtNaN;
          } else {
            mid = s.nbuf >> 1;
            if ((s.nbuf & 1) == 1) {
              y[i] = s.buf[mid];
            } else {
              d = s.buf[mid - 1];
              if (((d < 0.0) != (s.buf[mid] < 0.0)) || muDoubleScalarIsInf(d)) {
                y[i] = (d + s.buf[mid]) / 2.0;
              } else {
                y[i] = d + (s.buf[mid] - d) / 2.0;
              }
            }
          }
        }
      } else {
        int32_T b;
        k0 = kleft + 2;
        iLeftLast = nx - kright;
        b = kleft + 1;
        f_st.site = &jc_emlrtRSI;
        if (kleft + 1 > 2147483646) {
          g_st.site = &bc_emlrtRSI;
          check_forloop_overflow_error(g_st);
        }
        for (int32_T k{2}; k <= b; k++) {
          f_st.site = &rj_emlrtRSI;
          s.insert(f_st, x[((workspace_ixfirst_tmp + k) + kright) - 1]);
          i = (workspace_ixfirst_tmp + k) - 1;
          if (s.nbuf == 0) {
            y[i] = rtNaN;
          } else {
            mid = s.nbuf >> 1;
            if ((s.nbuf & 1) == 1) {
              y[i] = s.buf[mid];
            } else {
              d = s.buf[mid - 1];
              if (((d < 0.0) != (s.buf[mid] < 0.0)) || muDoubleScalarIsInf(d)) {
                y[i] = (d + s.buf[mid]) / 2.0;
              } else {
                y[i] = d + (s.buf[mid] - d) / 2.0;
              }
            }
          }
        }
        f_st.site = &ic_emlrtRSI;
        if ((kleft + 2 <= iLeftLast) && (iLeftLast > 2147483646)) {
          g_st.site = &bc_emlrtRSI;
          check_forloop_overflow_error(g_st);
        }
        for (int32_T k{k0}; k <= iLeftLast; k++) {
          i = (workspace_ixfirst_tmp + k) - 1;
          f_st.site = &hc_emlrtRSI;
          s.replace(f_st, x[(i - kleft) - 1], x[i + kright]);
          if (s.nbuf == 0) {
            y[i] = rtNaN;
          } else {
            mid = s.nbuf >> 1;
            if ((s.nbuf & 1) == 1) {
              y[i] = s.buf[mid];
            } else {
              d = s.buf[mid - 1];
              if (((d < 0.0) != (s.buf[mid] < 0.0)) || muDoubleScalarIsInf(d)) {
                y[i] = (d + s.buf[mid]) / 2.0;
              } else {
                y[i] = d + (s.buf[mid] - d) / 2.0;
              }
            }
          }
        }
        k0 = iLeftLast + 1;
        f_st.site = &gc_emlrtRSI;
        if ((iLeftLast + 1 <= nx) && (nx > 2147483646)) {
          g_st.site = &bc_emlrtRSI;
          check_forloop_overflow_error(g_st);
        }
        for (int32_T k{k0}; k <= ny; k++) {
          f_st.site = &fc_emlrtRSI;
          s.b_remove(f_st, x[((workspace_ixfirst_tmp + k) - kleft) - 2]);
          i = (workspace_ixfirst_tmp + k) - 1;
          if (s.nbuf == 0) {
            y[i] = rtNaN;
          } else {
            mid = s.nbuf >> 1;
            if ((s.nbuf & 1) == 1) {
              y[i] = s.buf[mid];
            } else {
              d = s.buf[mid - 1];
              if (((d < 0.0) != (s.buf[mid] < 0.0)) || muDoubleScalarIsInf(d)) {
                y[i] = (d + s.buf[mid]) / 2.0;
              } else {
                y[i] = d + (s.buf[mid] - d) / 2.0;
              }
            }
          }
        }
      }
    }
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

} // namespace coder

// End of code generation (movsortfun.cpp)
