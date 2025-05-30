//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// indexShapeCheck.cpp
//
// Code generation for function 'indexShapeCheck'
//

// Include files
#include "indexShapeCheck.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"

// Variable Definitions
static emlrtRSInfo xc_emlrtRSI{
    42,                // lineNo
    "indexShapeCheck", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\indexShapeCheck.m" // pathName
};

static emlrtRSInfo ei_emlrtRSI{
    58,                // lineNo
    "indexShapeCheck", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\indexShapeCheck.m" // pathName
};

static emlrtRSInfo fi_emlrtRSI{
    51,                // lineNo
    "indexShapeCheck", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\indexShapeCheck.m" // pathName
};

static emlrtRTEInfo g_emlrtRTEI{
    122,           // lineNo
    5,             // colNo
    "errOrWarnIf", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\indexShapeCheck.m" // pName
};

// Function Definitions
namespace coder {
namespace internal {
void indexShapeCheck(const emlrtStack &sp, const int32_T matrixSize[2],
                     const int32_T indexSize[2])
{
  emlrtStack st;
  boolean_T nonSingletonDimFound;
  st.prev = &sp;
  st.tls = sp.tls;
  nonSingletonDimFound = (matrixSize[0] != 1);
  if (matrixSize[1] != 1) {
    if (nonSingletonDimFound) {
      nonSingletonDimFound = false;
    } else {
      nonSingletonDimFound = true;
    }
  }
  if (nonSingletonDimFound) {
    nonSingletonDimFound = (matrixSize[0] == 1);
    if (nonSingletonDimFound || (matrixSize[1] != 1)) {
      nonSingletonDimFound = true;
    }
    st.site = &fi_emlrtRSI;
    if (nonSingletonDimFound) {
      emlrtErrorWithMessageIdR2018a(
          &st, &g_emlrtRTEI, "Coder:FE:PotentialMatrixMatrix_MM_Logical1",
          "Coder:FE:PotentialMatrixMatrix_MM_Logical1", 0);
    }
  } else {
    nonSingletonDimFound = (indexSize[0] != 1);
    if (indexSize[1] != 1) {
      if (nonSingletonDimFound) {
        nonSingletonDimFound = false;
      } else {
        nonSingletonDimFound = true;
      }
    }
    if (nonSingletonDimFound) {
      nonSingletonDimFound = (indexSize[0] == 1);
      if (nonSingletonDimFound || (indexSize[1] != 1)) {
        nonSingletonDimFound = true;
      }
      st.site = &ei_emlrtRSI;
      if (nonSingletonDimFound) {
        emlrtErrorWithMessageIdR2018a(
            &st, &g_emlrtRTEI, "Coder:FE:PotentialMatrixMatrix_MM_Logical2",
            "Coder:FE:PotentialMatrixMatrix_MM_Logical2", 0);
      }
    }
  }
}

void indexShapeCheck(const emlrtStack &sp, int32_T matrixSize,
                     const int32_T indexSize[2])
{
  emlrtStack st;
  boolean_T c;
  st.prev = &sp;
  st.tls = sp.tls;
  if ((matrixSize == 1) && (indexSize[1] != 1)) {
    c = true;
  } else {
    c = false;
  }
  st.site = &xc_emlrtRSI;
  if (c) {
    emlrtErrorWithMessageIdR2018a(&st, &g_emlrtRTEI,
                                  "Coder:FE:PotentialVectorVector",
                                  "Coder:FE:PotentialVectorVector", 0);
  }
}

} // namespace internal
} // namespace coder

// End of code generation (indexShapeCheck.cpp)
