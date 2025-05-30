//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// processSIGburst_onboard_data.cpp
//
// Code generation for function 'processSIGburst_onboard_data'
//

// Include files
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"

// Variable Definitions
emlrtCTX emlrtRootTLSGlobal{nullptr};

const volatile char_T *emlrtBreakCheckR2012bFlagVar{nullptr};

emlrtContext emlrtContextGlobal{
    true,                                                 // bFirstTime
    false,                                                // bInitialized
    131642U,                                              // fVersionInfo
    nullptr,                                              // fErrorFunction
    "processSIGburst_onboard",                            // fFunctionName
    nullptr,                                              // fRTCallStack
    false,                                                // bDebugMode
    {2045744189U, 2170104910U, 2743257031U, 4284093946U}, // fSigWrd
    nullptr                                               // fSigMem
};

emlrtRSInfo
    rb_emlrtRSI{
        71,      // lineNo
        "power", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\power.m" // pathName
    };

emlrtRSInfo bc_emlrtRSI{
    20,                               // lineNo
    "eml_int_forloop_overflow_check", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\eml\\eml_int_forloop_"
    "overflow_check.m" // pathName
};

emlrtRSInfo cc_emlrtRSI{
    63,                               // lineNo
    "function_handle/parenReference", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\function_"
    "handle.m" // pathName
};

emlrtRSInfo hd_emlrtRSI{
    15,    // lineNo
    "sum", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\sum.m" // pathName
};

emlrtRSInfo id_emlrtRSI{
    99,        // lineNo
    "sumprod", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumpro"
    "d.m" // pathName
};

emlrtRSInfo pd_emlrtRSI{
    74,                      // lineNo
    "combineVectorElements", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\combin"
    "eVectorElements.m" // pathName
};

emlrtRSInfo qd_emlrtRSI{
    107,                // lineNo
    "blockedSummation", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blocke"
    "dSummation.m" // pathName
};

emlrtRSInfo rd_emlrtRSI{
    22,                    // lineNo
    "sumMatrixIncludeNaN", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

emlrtRSInfo td_emlrtRSI{
    42,                 // lineNo
    "sumMatrixColumns", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

emlrtRSInfo wd_emlrtRSI{
    57,                 // lineNo
    "sumMatrixColumns", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" // pathName
};

emlrtRSInfo ee_emlrtRSI{
    34,               // lineNo
    "rdivide_helper", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\rdivide_"
    "helper.m" // pathName
};

emlrtRSInfo fe_emlrtRSI{
    51,    // lineNo
    "div", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\div.m" // pathName
};

emlrtRSInfo
    pe_emlrtRSI{
        44,          // lineNo
        "vAllOrAny", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\vAllOrAny.m" // pathName
    };

emlrtRSInfo
    qe_emlrtRSI{
        103,                  // lineNo
        "flatVectorAllOrAny", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\vAllOrAny.m" // pathName
    };

emlrtRSInfo og_emlrtRSI{
    33,                           // lineNo
    "applyScalarFunctionInPlace", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyScalarFunctionInPlace.m" // pathName
};

emlrtRSInfo eh_emlrtRSI{
    28,       // lineNo
    "repmat", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m" // pathName
};

omp_lock_t emlrtLockGlobal;

omp_nest_lock_t processSIGburst_onboard_nestLockGlobal;

emlrtRTEInfo
    b_emlrtRTEI{
        82,         // lineNo
        5,          // colNo
        "fltpower", // fName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\power.m" // pName
    };

emlrtRTEInfo c_emlrtRTEI{
    46,        // lineNo
    23,        // colNo
    "sumprod", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumpro"
    "d.m" // pName
};

emlrtRTEInfo d_emlrtRTEI{
    76,        // lineNo
    9,         // colNo
    "sumprod", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumpro"
    "d.m" // pName
};

emlrtRTEInfo k_emlrtRTEI{
    13,                     // lineNo
    27,                     // colNo
    "assertCompatibleDims", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\shared\\coder\\coder\\lib\\+coder\\+"
    "internal\\assertCompatibleDims.m" // pName
};

emlrtRTEInfo n_emlrtRTEI{
    47,          // lineNo
    13,          // colNo
    "infocheck", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\infocheck.m" // pName
};

emlrtRTEInfo o_emlrtRTEI{
    44,          // lineNo
    13,          // colNo
    "infocheck", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "lapack\\infocheck.m" // pName
};

emlrtRTEInfo uf_emlrtRTEI{
    61,        // lineNo
    5,         // colNo
    "sortIdx", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m" // pName
};

emlrtRSInfo vj_emlrtRSI{
    52,    // lineNo
    "div", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\div.m" // pathName
};

covrtInstance emlrtCoverageInstance;

// End of code generation (processSIGburst_onboard_data.cpp)
