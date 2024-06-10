//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// interp1.cpp
//
// Code generation for function 'interp1'
//

// Include files
#include "interp1.h"
#include "eml_int_forloop_overflow_check.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"
#include "omp.h"

// Variable Definitions
static emlrtRSInfo yc_emlrtRSI{
    54,        // lineNo
    "interp1", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pathName
};

static emlrtRSInfo ad_emlrtRSI{
    309,            // lineNo
    "interp1_work", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pathName
};

static emlrtRSInfo bd_emlrtRSI{
    206,            // lineNo
    "interp1_work", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pathName
};

static emlrtRSInfo cd_emlrtRSI{
    202,            // lineNo
    "interp1_work", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pathName
};

static emlrtRSInfo dd_emlrtRSI{
    194,            // lineNo
    "interp1_work", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pathName
};

static emlrtRSInfo ed_emlrtRSI{
    164,            // lineNo
    "interp1_work", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pathName
};

static emlrtRSInfo gd_emlrtRSI{
    343,             // lineNo
    "interp1Linear", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pathName
};

static emlrtRTEInfo h_emlrtRTEI{
    208,            // lineNo
    13,             // colNo
    "interp1_work", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pName
};

static emlrtRTEInfo i_emlrtRTEI{
    166,            // lineNo
    13,             // colNo
    "interp1_work", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pName
};

static emlrtRTEInfo j_emlrtRTEI{
    139,            // lineNo
    23,             // colNo
    "interp1_work", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pName
};

static emlrtRTEInfo gd_emlrtRTEI{
    55,        // lineNo
    9,         // colNo
    "interp1", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pName
};

static emlrtRTEInfo hd_emlrtRTEI{
    55,        // lineNo
    33,        // colNo
    "interp1", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pName
};

static emlrtRTEInfo id_emlrtRTEI{
    54,        // lineNo
    5,         // colNo
    "interp1", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interp1.m" // pName
};

// Function Declarations
namespace coder {
static void interp1Linear(const emlrtStack &sp,
                          const ::coder::array<real_T, 1U> &y, int32_T nyrows,
                          const ::coder::array<real_T, 2U> &xi,
                          ::coder::array<real_T, 2U> &yi,
                          const ::coder::array<real_T, 1U> &varargin_1);

}

// Function Definitions
namespace coder {
static void interp1Linear(const emlrtStack &sp,
                          const ::coder::array<real_T, 1U> &y, int32_T nyrows,
                          const ::coder::array<real_T, 2U> &xi,
                          ::coder::array<real_T, 2U> &yi,
                          const ::coder::array<real_T, 1U> &varargin_1)
{
  emlrtStack b_st;
  emlrtStack st;
  real_T d;
  real_T maxx;
  real_T minx;
  real_T penx;
  real_T r;
  int32_T high_i;
  int32_T interp1Linear_numThreads;
  int32_T low_i;
  int32_T low_ip1;
  int32_T mid_i;
  int32_T ub_loop;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  minx = varargin_1[0];
  penx = varargin_1[varargin_1.size(0) - 2];
  maxx = varargin_1[varargin_1.size(0) - 1];
  st.site = &gd_emlrtRSI;
  if (xi.size(1) > 2147483646) {
    b_st.site = &bc_emlrtRSI;
    check_forloop_overflow_error(b_st);
  }
  ub_loop = xi.size(1) - 1;
  emlrtEnterParallelRegion((emlrtCTX)&sp,
                           static_cast<boolean_T>(omp_in_parallel()));
  interp1Linear_numThreads =
      emlrtAllocRegionTLSs(sp.tls, static_cast<boolean_T>(omp_in_parallel()),
                           omp_get_max_threads(), omp_get_num_procs());
#pragma omp parallel for num_threads(interp1Linear_numThreads) private(        \
    d, r, high_i, low_i, low_ip1, mid_i)

  for (int32_T k = 0; k <= ub_loop; k++) {
    d = xi[k];
    if (muDoubleScalarIsNaN(d)) {
      yi[k] = rtNaN;
    } else if (d > maxx) {
      r = y[nyrows - 1];
      yi[k] = r + (d - maxx) / (maxx - penx) * (r - y[nyrows - 2]);
    } else if (d < minx) {
      yi[k] = y[0] + (d - minx) / (varargin_1[1] - minx) * (y[1] - y[0]);
    } else {
      high_i = varargin_1.size(0);
      low_i = 1;
      low_ip1 = 2;
      while (high_i > low_ip1) {
        mid_i = (low_i >> 1) + (high_i >> 1);
        if (((low_i & 1) == 1) && ((high_i & 1) == 1)) {
          mid_i++;
        }
        if (xi[k] >= varargin_1[mid_i - 1]) {
          low_i = mid_i;
          low_ip1 = mid_i + 1;
        } else {
          high_i = mid_i;
        }
      }
      r = varargin_1[low_i - 1];
      r = (xi[k] - r) / (varargin_1[low_i] - r);
      if (r == 0.0) {
        yi[k] = y[low_i - 1];
      } else if (r == 1.0) {
        yi[k] = y[low_i];
      } else {
        d = y[low_i - 1];
        if (d == y[low_i]) {
          yi[k] = d;
        } else {
          yi[k] = (1.0 - r) * d + r * y[low_i];
        }
      }
    }
  }
  emlrtExitParallelRegion((emlrtCTX)&sp,
                          static_cast<boolean_T>(omp_in_parallel()));
}

void interp1(const emlrtStack &sp, const ::coder::array<real_T, 1U> &varargin_1,
             const ::coder::array<real_T, 1U> &varargin_2,
             const ::coder::array<real_T, 2U> &varargin_3,
             ::coder::array<real_T, 2U> &Vq)
{
  array<real_T, 1U> x;
  array<real_T, 1U> y;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  int32_T n;
  int32_T nx;
  int32_T y_tmp;
  boolean_T b;
  st.prev = &sp;
  st.tls = sp.tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  st.site = &yc_emlrtRSI;
  y.set_size(&gd_emlrtRTEI, &st, varargin_2.size(0));
  n = varargin_2.size(0);
  for (y_tmp = 0; y_tmp < n; y_tmp++) {
    y[y_tmp] = varargin_2[y_tmp];
  }
  x.set_size(&hd_emlrtRTEI, &st, varargin_1.size(0));
  n = varargin_1.size(0);
  for (y_tmp = 0; y_tmp < n; y_tmp++) {
    x[y_tmp] = varargin_1[y_tmp];
  }
  nx = varargin_1.size(0);
  if (varargin_1.size(0) != varargin_2.size(0)) {
    emlrtErrorWithMessageIdR2018a(&st, &j_emlrtRTEI,
                                  "Coder:MATLAB:interp1_YInvalidNumRows",
                                  "Coder:MATLAB:interp1_YInvalidNumRows", 0);
  }
  Vq.set_size(&id_emlrtRTEI, &st, 1, varargin_3.size(1));
  n = varargin_3.size(1);
  for (y_tmp = 0; y_tmp < n; y_tmp++) {
    Vq[y_tmp] = 0.0;
  }
  b = (varargin_3.size(1) == 0);
  if (!b) {
    int32_T k;
    b_st.site = &ed_emlrtRSI;
    if (nx > 2147483646) {
      c_st.site = &bc_emlrtRSI;
      check_forloop_overflow_error(c_st);
    }
    k = 0;
    int32_T exitg1;
    do {
      exitg1 = 0;
      if (k <= nx - 1) {
        if (muDoubleScalarIsNaN(varargin_1[k])) {
          emlrtErrorWithMessageIdR2018a(&st, &i_emlrtRTEI,
                                        "MATLAB:interp1:NaNinX",
                                        "MATLAB:interp1:NaNinX", 0);
        } else {
          k++;
        }
      } else {
        if (varargin_1[1] < varargin_1[0]) {
          real_T xtmp;
          int32_T nd2;
          y_tmp = nx >> 1;
          b_st.site = &dd_emlrtRSI;
          for (nd2 = 0; nd2 < y_tmp; nd2++) {
            xtmp = x[nd2];
            n = (nx - nd2) - 1;
            x[nd2] = x[n];
            x[n] = xtmp;
          }
          b_st.site = &cd_emlrtRSI;
          n = varargin_2.size(0) - 1;
          nd2 = varargin_2.size(0) >> 1;
          for (k = 0; k < nd2; k++) {
            xtmp = y[k];
            y_tmp = n - k;
            y[k] = y[y_tmp];
            y[y_tmp] = xtmp;
          }
        }
        b_st.site = &bd_emlrtRSI;
        for (k = 2; k <= nx; k++) {
          if (x[k - 1] <= x[k - 2]) {
            emlrtErrorWithMessageIdR2018a(
                &st, &h_emlrtRTEI, "Coder:toolbox:interp1_nonMonotonicX",
                "Coder:toolbox:interp1_nonMonotonicX", 0);
          }
        }
        b_st.site = &ad_emlrtRSI;
        interp1Linear(b_st, y, varargin_2.size(0), varargin_3, Vq, x);
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

} // namespace coder

// End of code generation (interp1.cpp)
