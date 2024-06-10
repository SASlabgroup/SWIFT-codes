//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// processSIGburst_onboard.cpp
//
// Code generation for function 'processSIGburst_onboard'
//

// Include files
#include "processSIGburst_onboard.h"
#include "abs.h"
#include "combineVectorElements.h"
#include "diff.h"
#include "eig.h"
#include "eml_mtimes_helper.h"
#include "error.h"
#include "find.h"
#include "indexShapeCheck.h"
#include "interp1.h"
#include "log10.h"
#include "mean.h"
#include "meshgrid.h"
#include "mldivide.h"
#include "movmedian.h"
#include "mtimes.h"
#include "nanmean.h"
#include "permute.h"
#include "power.h"
#include "processSIGburst_onboard_data.h"
#include "repmat.h"
#include "round.h"
#include "rt_nonfinite.h"
#include "sort.h"
#include "std.h"
#include "strcmp.h"
#include "coder_array.h"
#include "mwmathutil.h"
#include "omp.h"
#include <emmintrin.h>

// Variable Definitions
static emlrtRSInfo
    emlrtRSI{
        27,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    b_emlrtRSI{
        28,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    c_emlrtRSI{
        32,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    d_emlrtRSI{
        33,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    e_emlrtRSI{
        38,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    f_emlrtRSI{
        40,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    g_emlrtRSI{
        47,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    h_emlrtRSI{
        53,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    i_emlrtRSI{
        58,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    j_emlrtRSI{
        59,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    k_emlrtRSI{
        60,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    l_emlrtRSI{
        62,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    m_emlrtRSI{
        66,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    n_emlrtRSI{
        77,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    o_emlrtRSI{
        80,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    p_emlrtRSI{
        81,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    q_emlrtRSI{
        85,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    r_emlrtRSI{
        86,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    s_emlrtRSI{
        87,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    t_emlrtRSI{
        91,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    u_emlrtRSI{
        93,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    v_emlrtRSI{
        95,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    w_emlrtRSI{
        106,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    x_emlrtRSI{
        107,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    y_emlrtRSI{
        108,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    ab_emlrtRSI{
        113,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    bb_emlrtRSI{
        119,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    cb_emlrtRSI{
        120,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    db_emlrtRSI{
        127,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    eb_emlrtRSI{
        128,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    fb_emlrtRSI{
        129,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    gb_emlrtRSI{
        135,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    hb_emlrtRSI{
        136,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    ib_emlrtRSI{
        137,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    jb_emlrtRSI{
        146,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    kb_emlrtRSI{
        147,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    lb_emlrtRSI{
        148,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    mb_emlrtRSI{
        149,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    nb_emlrtRSI{
        150,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    ob_emlrtRSI{
        151,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    pb_emlrtRSI{
        154,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    qb_emlrtRSI{
        158,                       // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo tc_emlrtRSI{
    39,     // lineNo
    "find", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\find.m" // pathName
};

static emlrtRSInfo
    ge_emlrtRSI{
        94,                  // lineNo
        "eml_mtimes_helper", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_"
        "helper.m" // pathName
    };

static emlrtRSInfo
    he_emlrtRSI{
        69,                  // lineNo
        "eml_mtimes_helper", // fcnName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_"
        "helper.m" // pathName
    };

static emlrtRSInfo vf_emlrtRSI{
    37,     // lineNo
    "sort", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\sort.m" // pathName
};

static emlrtRSInfo bj_emlrtRSI{
    39,    // lineNo
    "cat", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m" // pathName
};

static emlrtRSInfo cj_emlrtRSI{
    113,        // lineNo
    "cat_impl", // fcnName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m" // pathName
};

static emlrtRTEInfo emlrtRTEI{
    288,                   // lineNo
    27,                    // colNo
    "check_non_axis_size", // fName
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m" // pName
};

static emlrtECInfo
    emlrtECI{
        -1,                        // nDims
        112,                       // lineNo
        12,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    b_emlrtECI{
        2,                         // nDims
        105,                       // lineNo
        13,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    c_emlrtECI{
        2,                         // nDims
        87,                        // lineNo
        4,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    d_emlrtECI{
        1,                         // nDims
        87,                        // lineNo
        4,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    e_emlrtECI{
        3,                         // nDims
        86,                        // lineNo
        6,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    f_emlrtECI{
        2,                         // nDims
        86,                        // lineNo
        6,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    g_emlrtECI{
        1,                         // nDims
        86,                        // lineNo
        6,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    h_emlrtECI{
        1,                         // nDims
        85,                        // lineNo
        13,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    i_emlrtECI{
        2,                         // nDims
        82,                        // lineNo
        7,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    j_emlrtECI{
        1,                         // nDims
        82,                        // lineNo
        7,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    k_emlrtECI{
        -1,                        // nDims
        66,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtBCInfo
    emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        66,                        // lineNo
        65,                        // colNo
        "alpha",                   // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    b_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        66,                        // lineNo
        56,                        // colNo
        "alpha",                   // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtDCInfo
    emlrtDCI{
        66,                        // lineNo
        56,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        1            // checkKind
    };

static emlrtBCInfo
    c_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        66,                        // lineNo
        42,                        // colNo
        "eofs",                    // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    d_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        66,                        // lineNo
        33,                        // colNo
        "eofs",                    // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtDCInfo
    b_emlrtDCI{
        66,                        // lineNo
        33,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        1            // checkKind
    };

static emlrtECInfo
    l_emlrtECI{
        2,                         // nDims
        55,                        // lineNo
        5,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    m_emlrtECI{
        -1,                        // nDims
        40,                        // lineNo
        5,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtBCInfo
    e_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        40,                        // lineNo
        15,                        // colNo
        "winterp",                 // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    f_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        40,                        // lineNo
        49,                        // colNo
        "wraw",                    // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    g_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        38,                        // lineNo
        28,                        // colNo
        "ispike",                  // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtECInfo
    n_emlrtECI{
        2,                         // nDims
        33,                        // lineNo
        14,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtECInfo
    o_emlrtECI{
        1,                         // nDims
        33,                        // lineNo
        14,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtBCInfo
    h_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        106,                       // lineNo
        12,                        // colNo
        "D",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    i_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        107,                       // lineNo
        12,                        // colNo
        "R",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    j_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        40,                        // lineNo
        43,                        // colNo
        "wraw",                    // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    k_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        51,                        // lineNo
        15,                        // colNo
        "winterp",                 // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    l_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        57,                        // lineNo
        3,                         // colNo
        "X",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    m_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        61,                        // lineNo
        15,                        // colNo
        "EOFs",                    // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    n_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        66,                        // lineNo
        9,                         // colNo
        "wpeof",                   // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    o_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        69,                        // lineNo
        7,                         // colNo
        "wpeof",                   // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    p_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        87,                        // lineNo
        4,                         // colNo
        "dW",                      // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    q_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        105,                       // lineNo
        21,                        // colNo
        "z",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    r_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        162,                       // lineNo
        5,                         // colNo
        "eps",                     // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    s_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        105,                       // lineNo
        53,                        // colNo
        "z",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    t_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        109,                       // lineNo
        13,                        // colNo
        "Di",                      // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    u_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        119,                       // lineNo
        13,                        // colNo
        "Ri",                      // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    v_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        121,                       // lineNo
        12,                        // colNo
        "Di",                      // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    w_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        158,                       // lineNo
        20,                        // colNo
        "A",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    x_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        143,                       // lineNo
        19,                        // colNo
        "d",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    y_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        144,                       // lineNo
        21,                        // colNo
        "xN",                      // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    ab_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        158,                       // lineNo
        9,                         // colNo
        "eps",                     // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    bb_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        145,                       // lineNo
        21,                        // colNo
        "x1",                      // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    cb_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        138,                       // lineNo
        15,                        // colNo
        "A",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    db_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        130,                       // lineNo
        11,                        // colNo
        "A",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtBCInfo
    eb_emlrtBCI{
        -1,                        // iFirst
        -1,                        // iLast
        151,                       // lineNo
        15,                        // colNo
        "A",                       // aName
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m", // pName
        0            // checkKind
    };

static emlrtRTEInfo
    cb_emlrtRTEI{
        20,                        // lineNo
        19,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    db_emlrtRTEI{
        20,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    eb_emlrtRTEI{
        33,                        // lineNo
        14,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    fb_emlrtRTEI{
        33,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    gb_emlrtRTEI{
        36,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    hb_emlrtRTEI{
        38,                        // lineNo
        18,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    ib_emlrtRTEI{
        38,                        // lineNo
        5,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    jb_emlrtRTEI{
        28,      // lineNo
        9,       // colNo
        "colon", // fName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\colon.m" // pName
    };

static emlrtRTEInfo
    kb_emlrtRTEI{
        40,                        // lineNo
        38,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    lb_emlrtRTEI{
        1,                         // lineNo
        16,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    mb_emlrtRTEI{
        51,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    nb_emlrtRTEI{
        53,                        // lineNo
        14,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    ob_emlrtRTEI{
        55,                        // lineNo
        5,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    pb_emlrtRTEI{
        55,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    qb_emlrtRTEI{
        61,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    rb_emlrtRTEI{
        88,                  // lineNo
        13,                  // colNo
        "eml_mtimes_helper", // fName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_"
        "helper.m" // pName
    };

static emlrtRTEInfo
    sb_emlrtRTEI{
        62,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    tb_emlrtRTEI{
        65,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    ub_emlrtRTEI{
        66,                        // lineNo
        48,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    vb_emlrtRTEI{
        66,                        // lineNo
        9,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    wb_emlrtRTEI{
        66,                        // lineNo
        26,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    xb_emlrtRTEI{
        66,                        // lineNo
        21,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    yb_emlrtRTEI{
        76,                        // lineNo
        5,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    ac_emlrtRTEI{
        80,                        // lineNo
        5,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    bc_emlrtRTEI{
        85,                        // lineNo
        13,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    cc_emlrtRTEI{
        86,                        // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    dc_emlrtRTEI{
        87,                        // lineNo
        4,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    ec_emlrtRTEI{
        93,                        // lineNo
        23,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    fc_emlrtRTEI{
        93,                        // lineNo
        9,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    gc_emlrtRTEI{
        31,            // lineNo
        30,            // colNo
        "unsafeSxfun", // fName
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\unsafeSxfun.m" // pName
    };

static emlrtRTEInfo
    hc_emlrtRTEI{
        100,                       // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    ic_emlrtRTEI{
        101,                       // lineNo
        1,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    jc_emlrtRTEI{
        105,                       // lineNo
        13,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    kc_emlrtRTEI{
        105,                       // lineNo
        45,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    lc_emlrtRTEI{
        109,                       // lineNo
        5,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    mc_emlrtRTEI{
        112,                       // lineNo
        12,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    nc_emlrtRTEI{
        112,                       // lineNo
        25,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    oc_emlrtRTEI{
        119,                       // lineNo
        10,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    pc_emlrtRTEI{
        120,                       // lineNo
        5,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    qc_emlrtRTEI{
        121,                       // lineNo
        5,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    rc_emlrtRTEI{
        145,                       // lineNo
        18,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    sc_emlrtRTEI{
        145,                       // lineNo
        13,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    tc_emlrtRTEI{
        147,                       // lineNo
        13,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    uc_emlrtRTEI{
        148,                       // lineNo
        13,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    vc_emlrtRTEI{
        149,                       // lineNo
        25,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    wc_emlrtRTEI{
        135,                       // lineNo
        13,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    xc_emlrtRTEI{
        136,                       // lineNo
        25,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    yc_emlrtRTEI{
        127,                       // lineNo
        9,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    ad_emlrtRTEI{
        128,                       // lineNo
        21,                        // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRTEInfo
    ag_emlrtRTEI{
        82,                        // lineNo
        6,                         // colNo
        "processSIGburst_onboard", // fName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pName
    };

static emlrtRSInfo
    tj_emlrtRSI{
        82,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

static emlrtRSInfo
    uj_emlrtRSI{
        55,                        // lineNo
        "processSIGburst_onboard", // fcnName
        "C:\\Users\\Kristin "
        "Zeiden\\GitHub\\MATLAB\\SWIFT-codes\\Signature\\processSIGburst_"
        "onboard.m" // pathName
    };

// Function Declarations
static void b_binary_expand_op(const emlrtStack &sp,
                               coder::array<real_T, 3U> &in1,
                               const emlrtRSInfo in2,
                               const coder::array<real_T, 2U> &in3,
                               const coder::array<real_T, 1U> &in4,
                               const coder::array<real_T, 2U> &in5);

static void b_binary_expand_op(const emlrtStack &sp,
                               coder::array<real_T, 2U> &in1,
                               const coder::array<real_T, 2U> &in2);

static void b_binary_expand_op(const emlrtStack &sp,
                               coder::array<real_T, 2U> &in1,
                               const emlrtRSInfo in2,
                               const coder::array<real_T, 2U> &in3);

static void binary_expand_op(const emlrtStack &sp,
                             coder::array<boolean_T, 3U> &in1,
                             const coder::array<real_T, 3U> &in2,
                             const coder::array<real_T, 2U> &in3);

static void minus(const emlrtStack &sp, coder::array<real_T, 3U> &in1,
                  const coder::array<real_T, 3U> &in2,
                  const coder::array<real_T, 3U> &in3);

static void minus(const emlrtStack &sp, coder::array<real_T, 2U> &in1,
                  const coder::array<real_T, 2U> &in2);

// Function Definitions
static void b_binary_expand_op(const emlrtStack &sp,
                               coder::array<real_T, 3U> &in1,
                               const emlrtRSInfo in2,
                               const coder::array<real_T, 2U> &in3,
                               const coder::array<real_T, 1U> &in4,
                               const coder::array<real_T, 2U> &in5)
{
  coder::array<real_T, 2U> b_in3;
  emlrtStack st;
  int32_T b_loop_ub;
  int32_T in4_idx_0;
  int32_T loop_ub;
  int32_T stride_0_0;
  st.prev = &sp;
  st.tls = sp.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  in4_idx_0 = in4.size(0);
  if (in4_idx_0 == 1) {
    loop_ub = in3.size(0);
  } else {
    loop_ub = in4_idx_0;
  }
  b_in3.set_size(&bc_emlrtRTEI, &sp, loop_ub, in3.size(1));
  stride_0_0 = (in3.size(0) != 1);
  in4_idx_0 = (in4_idx_0 != 1);
  b_loop_ub = in3.size(1);
  for (int32_T i{0}; i < b_loop_ub; i++) {
    for (int32_T i1{0}; i1 < loop_ub; i1++) {
      b_in3[i1 + b_in3.size(0) * i] =
          in3[i1 * stride_0_0 + in3.size(0) * i] - in4[i1 * in4_idx_0];
    }
  }
  st.site = const_cast<emlrtRSInfo *>(&in2);
  coder::repmat(st, b_in3, static_cast<real_T>(in5.size(0)), in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

static void b_binary_expand_op(const emlrtStack &sp,
                               coder::array<real_T, 2U> &in1,
                               const coder::array<real_T, 2U> &in2)
{
  coder::array<real_T, 2U> b_in1;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  if (in2.size(0) == 1) {
    loop_ub = in1.size(0);
  } else {
    loop_ub = in2.size(0);
  }
  if (in2.size(1) == 1) {
    b_loop_ub = in1.size(1);
  } else {
    b_loop_ub = in2.size(1);
  }
  b_in1.set_size(&ag_emlrtRTEI, &sp, loop_ub, b_loop_ub);
  stride_0_0 = (in1.size(0) != 1);
  stride_0_1 = (in1.size(1) != 1);
  stride_1_0 = (in2.size(0) != 1);
  stride_1_1 = (in2.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (int32_T i{0}; i < b_loop_ub; i++) {
    for (int32_T i1{0}; i1 < loop_ub; i1++) {
      b_in1[i1 + b_in1.size(0) * i] =
          (in1[i1 * stride_0_0 + in1.size(0) * aux_0_1] +
           in2[i1 * stride_1_0 + in2.size(0) * aux_1_1]) /
          2.0;
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  in1.set_size(&ag_emlrtRTEI, &sp, b_in1.size(0), b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (int32_T i{0}; i < loop_ub; i++) {
    b_loop_ub = b_in1.size(0);
    for (int32_T i1{0}; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in1[i1 + b_in1.size(0) * i];
    }
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

static void b_binary_expand_op(const emlrtStack &sp,
                               coder::array<real_T, 2U> &in1,
                               const emlrtRSInfo in2,
                               const coder::array<real_T, 2U> &in3)
{
  coder::array<real_T, 2U> b_in3;
  emlrtStack st;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  st.prev = &sp;
  st.tls = sp.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  if (in1.size(0) == 1) {
    loop_ub = in3.size(0);
  } else {
    loop_ub = in1.size(0);
  }
  if (in1.size(1) == 1) {
    b_loop_ub = in3.size(1);
  } else {
    b_loop_ub = in1.size(1);
  }
  b_in3.set_size(&eb_emlrtRTEI, &sp, loop_ub, b_loop_ub);
  stride_0_0 = (in3.size(0) != 1);
  stride_0_1 = (in3.size(1) != 1);
  stride_1_0 = (in1.size(0) != 1);
  stride_1_1 = (in1.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (int32_T i{0}; i < b_loop_ub; i++) {
    for (int32_T i1{0}; i1 < loop_ub; i1++) {
      b_in3[i1 + b_in3.size(0) * i] =
          in3[i1 * stride_0_0 + in3.size(0) * aux_0_1] -
          in1[i1 * stride_1_0 + in1.size(0) * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  st.site = const_cast<emlrtRSInfo *>(&in2);
  coder::b_abs(st, b_in3, in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

static void binary_expand_op(const emlrtStack &sp,
                             coder::array<boolean_T, 3U> &in1,
                             const coder::array<real_T, 3U> &in2,
                             const coder::array<real_T, 2U> &in3)
{
  int32_T b_loop_ub;
  int32_T c_loop_ub;
  int32_T in3_idx_0;
  int32_T in3_idx_1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  in3_idx_0 = in3.size(0);
  in3_idx_1 = in3.size(1);
  if (in3_idx_0 == 1) {
    loop_ub = in2.size(0);
  } else {
    loop_ub = in3_idx_0;
  }
  in1.set_size(&dc_emlrtRTEI, &sp, loop_ub, in1.size(1), in1.size(2));
  if (in3_idx_1 == 1) {
    b_loop_ub = in2.size(1);
  } else {
    b_loop_ub = in3_idx_1;
  }
  in1.set_size(&dc_emlrtRTEI, &sp, in1.size(0), b_loop_ub, in2.size(2));
  stride_0_0 = (in2.size(0) != 1);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_0 = (in3_idx_0 != 1);
  in3_idx_1 = (in3_idx_1 != 1);
  c_loop_ub = in2.size(2);
  for (int32_T i{0}; i < c_loop_ub; i++) {
    int32_T aux_0_1;
    int32_T aux_1_1;
    aux_0_1 = 0;
    aux_1_1 = 0;
    for (int32_T i1{0}; i1 < b_loop_ub; i1++) {
      for (int32_T i2{0}; i2 < loop_ub; i2++) {
        in1[(i2 + in1.size(0) * i1) + in1.size(0) * in1.size(1) * i] =
            (in2[(i2 * stride_0_0 + in2.size(0) * aux_0_1) +
                 in2.size(0) * in2.size(1) * i] >
             in3[i2 * stride_1_0 + in3_idx_0 * aux_1_1]);
      }
      aux_1_1 += in3_idx_1;
      aux_0_1 += stride_0_1;
    }
  }
}

static void minus(const emlrtStack &sp, coder::array<real_T, 3U> &in1,
                  const coder::array<real_T, 3U> &in2,
                  const coder::array<real_T, 3U> &in3)
{
  int32_T aux_0_2;
  int32_T aux_1_2;
  int32_T b_loop_ub;
  int32_T c_loop_ub;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_0_2;
  int32_T stride_1_0;
  int32_T stride_1_1;
  int32_T stride_1_2;
  if (in3.size(0) == 1) {
    loop_ub = in2.size(0);
  } else {
    loop_ub = in3.size(0);
  }
  in1.set_size(&cc_emlrtRTEI, &sp, loop_ub, in1.size(1), in1.size(2));
  if (in3.size(1) == 1) {
    b_loop_ub = in2.size(1);
  } else {
    b_loop_ub = in3.size(1);
  }
  in1.set_size(&cc_emlrtRTEI, &sp, in1.size(0), b_loop_ub, in1.size(2));
  if (in3.size(2) == 1) {
    c_loop_ub = in2.size(2);
  } else {
    c_loop_ub = in3.size(2);
  }
  in1.set_size(&cc_emlrtRTEI, &sp, in1.size(0), in1.size(1), c_loop_ub);
  stride_0_0 = (in2.size(0) != 1);
  stride_0_1 = (in2.size(1) != 1);
  stride_0_2 = (in2.size(2) != 1);
  stride_1_0 = (in3.size(0) != 1);
  stride_1_1 = (in3.size(1) != 1);
  stride_1_2 = (in3.size(2) != 1);
  aux_0_2 = 0;
  aux_1_2 = 0;
  for (int32_T i{0}; i < c_loop_ub; i++) {
    int32_T aux_0_1;
    int32_T aux_1_1;
    aux_0_1 = 0;
    aux_1_1 = 0;
    for (int32_T i1{0}; i1 < b_loop_ub; i1++) {
      for (int32_T i2{0}; i2 < loop_ub; i2++) {
        in1[(i2 + in1.size(0) * i1) + in1.size(0) * in1.size(1) * i] =
            in2[(i2 * stride_0_0 + in2.size(0) * aux_0_1) +
                in2.size(0) * in2.size(1) * aux_0_2] -
            in3[(i2 * stride_1_0 + in3.size(0) * aux_1_1) +
                in3.size(0) * in3.size(1) * aux_1_2];
      }
      aux_1_1 += stride_1_1;
      aux_0_1 += stride_0_1;
    }
    aux_1_2 += stride_1_2;
    aux_0_2 += stride_0_2;
  }
}

static void minus(const emlrtStack &sp, coder::array<real_T, 2U> &in1,
                  const coder::array<real_T, 2U> &in2)
{
  coder::array<real_T, 2U> b_in1;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T loop_ub;
  int32_T stride_0_1;
  int32_T stride_1_1;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)&sp);
  if (in2.size(1) == 1) {
    loop_ub = in1.size(1);
  } else {
    loop_ub = in2.size(1);
  }
  b_in1.set_size(&ob_emlrtRTEI, &sp, in1.size(0), loop_ub);
  stride_0_1 = (in1.size(1) != 1);
  stride_1_1 = (in2.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (int32_T i{0}; i < loop_ub; i++) {
    int32_T scalarLB;
    int32_T vectorUB;
    b_loop_ub = in1.size(0);
    scalarLB = (b_loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (int32_T i1{0}; i1 <= vectorUB; i1 += 2) {
      __m128d r;
      r = _mm_loadu_pd(&in1[i1 + in1.size(0) * aux_0_1]);
      _mm_storeu_pd(&b_in1[i1 + b_in1.size(0) * i],
                    _mm_sub_pd(r, _mm_set1_pd(in2[aux_1_1])));
    }
    for (int32_T i1{scalarLB}; i1 < b_loop_ub; i1++) {
      b_in1[i1 + b_in1.size(0) * i] =
          in1[i1 + in1.size(0) * aux_0_1] - in2[aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  in1.set_size(&ob_emlrtRTEI, &sp, b_in1.size(0), b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (int32_T i{0}; i < loop_ub; i++) {
    b_loop_ub = b_in1.size(0);
    for (int32_T i1{0}; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in1[i1 + b_in1.size(0) * i];
    }
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)&sp);
}

emlrtCTX emlrtGetRootTLSGlobal()
{
  return emlrtRootTLSGlobal;
}

void emlrtLockerFunction(EmlrtLockeeFunction aLockee, emlrtConstCTX aTLS,
                         void *aData)
{
  omp_set_lock(&emlrtLockGlobal);
  emlrtCallLockeeFunction(aLockee, aTLS, aData);
  omp_unset_lock(&emlrtLockGlobal);
}

void processSIGburst_onboard(const emlrtStack *sp,
                             const coder::array<real_T, 2U> &wraw, real_T cs,
                             real_T dz, real_T bz, real_T neoflp, real_T rmin,
                             real_T rmax, real_T nzfit,
                             const coder::array<char_T, 2U> &avgtype,
                             const coder::array<char_T, 2U> &fittype,
                             coder::array<real_T, 2U> &eps)
{
  __m128d r;
  __m128d r2;
  coder::array<creal_T, 2U> EOFs;
  coder::array<creal_T, 2U> alpha;
  coder::array<creal_T, 2U> c_X;
  coder::array<creal_T, 2U> eofs;
  coder::array<creal_T, 1U> E;
  coder::array<real_T, 3U> dW;
  coder::array<real_T, 3U> r3;
  coder::array<real_T, 3U> r4;
  coder::array<real_T, 2U> D;
  coder::array<real_T, 2U> G;
  coder::array<real_T, 2U> Gg;
  coder::array<real_T, 2U> R;
  coder::array<real_T, 2U> X;
  coder::array<real_T, 2U> Xm;
  coder::array<real_T, 2U> Z0;
  coder::array<real_T, 2U> b_G;
  coder::array<real_T, 2U> b_Gg;
  coder::array<real_T, 2U> b_X;
  coder::array<real_T, 2U> c_G;
  coder::array<real_T, 2U> d_G;
  coder::array<real_T, 2U> wfilt;
  coder::array<real_T, 2U> y;
  coder::array<real_T, 1U> Di;
  coder::array<real_T, 1U> d;
  coder::array<real_T, 1U> igood;
  coder::array<real_T, 1U> x1;
  coder::array<real_T, 1U> z;
  coder::array<int32_T, 2U> b_nz;
  coder::array<int32_T, 2U> r1;
  coder::array<int32_T, 1U> ii;
  coder::array<int32_T, 1U> r6;
  coder::array<int32_T, 1U> r8;
  coder::array<int32_T, 1U> r9;
  coder::array<boolean_T, 3U> r5;
  coder::array<boolean_T, 2U> iplot;
  coder::array<boolean_T, 2U> ispike;
  coder::array<boolean_T, 1U> ifit;
  coder::array<boolean_T, 1U> r7;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T m[2];
  real_T X_re_tmp;
  real_T a;
  real_T b_X_re_tmp;
  int32_T b_m[2];
  int32_T b_loop_ub_tmp;
  int32_T i;
  int32_T i1;
  int32_T ibin;
  int32_T loop_ub;
  int32_T loop_ub_tmp;
  int32_T nz;
  int32_T scalarLB;
  int32_T vectorUB;
  int32_T y_size_idx_0;
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  covrtLogFcn(&emlrtCoverageInstance, 0, 0);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0, 0);
  //  w = nbin x nping HR velocity data
  //  cs = 1 x nping sound speed, from HR data
  //  dz = 1 x 1 bin size (m);
  //  bz = 1 x 1 blanking distance (m);
  //  neoflp = 1 x 1 number of low-mode EOFs to filter from the data;
  //  ONBOARD NOTES:
  //  No plotting
  //  Replace 'opt' structure input with variables
  //  Burst variables are now inputs
  //  No need to check dimensions as prespecified
  //  Don't interpolate through bad pings
  //   ---- bad pings are currently tossed before computing eps
  //  N pings + N z-bins
  nz = wraw.size(0);
  if (wraw.size(0) < 1) {
    Xm.set_size(&cb_emlrtRTEI, sp, 1, 0);
  } else {
    Xm.set_size(&cb_emlrtRTEI, sp, 1, wraw.size(0));
    loop_ub = wraw.size(0) - 1;
    for (i = 0; i <= loop_ub; i++) {
      Xm[i] = static_cast<real_T>(i) + 1.0;
    }
  }
  y_size_idx_0 = Xm.size(1);
  z.set_size(&db_emlrtRTEI, sp, Xm.size(1));
  loop_ub = Xm.size(1);
  scalarLB = (Xm.size(1) / 2) << 1;
  vectorUB = scalarLB - 2;
  for (i = 0; i <= vectorUB; i += 2) {
    r = _mm_loadu_pd(&Xm[i]);
    _mm_storeu_pd(&z[i], _mm_add_pd(_mm_set1_pd(bz + 0.2),
                                    _mm_mul_pd(_mm_set1_pd(dz), r)));
  }
  for (i = scalarLB; i < loop_ub; i++) {
    z[i] = (bz + 0.2) + dz * Xm[i];
  }
  // %%%%%% Despike %%%%%%%
  //  Find Spikes (phase-shift threshold, Shcherbina 2018)
  //  m, pulse distance
  //  Hz, pulse carrier frequency (1 MHz for Sig 1000)
  st.site = &emlrtRSI;
  a = nanmean(cs);
  st.site = &b_emlrtRSI;
  b_st.site = &rb_emlrtRSI;
  //  m/s
  //  1 m
  //  Identify Spikes
  st.site = &c_emlrtRSI;
  coder::movmedian(st, wraw, muDoubleScalarRound(1.0 / dz), wfilt);
  //  was medfilt1
  if ((wraw.size(0) != wfilt.size(0)) &&
      ((wraw.size(0) != 1) && (wfilt.size(0) != 1))) {
    emlrtDimSizeImpxCheckR2021b(wraw.size(0), wfilt.size(0), &o_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((wraw.size(1) != wfilt.size(1)) &&
      ((wraw.size(1) != 1) && (wfilt.size(1) != 1))) {
    emlrtDimSizeImpxCheckR2021b(wraw.size(1), wfilt.size(1), &n_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((wraw.size(0) == wfilt.size(0)) && (wraw.size(1) == wfilt.size(1))) {
    R.set_size(&eb_emlrtRTEI, sp, wraw.size(0), wraw.size(1));
    loop_ub = wraw.size(0) * wraw.size(1);
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&wfilt[i]);
      _mm_storeu_pd(&R[i], _mm_sub_pd(_mm_loadu_pd(&wraw[i]), r));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      R[i] = wraw[i] - wfilt[i];
    }
    st.site = &d_emlrtRSI;
    coder::b_abs(st, R, wfilt);
  } else {
    st.site = &d_emlrtRSI;
    b_binary_expand_op(st, wfilt, d_emlrtRSI, wraw);
  }
  ispike.set_size(&fb_emlrtRTEI, sp, wfilt.size(0), wfilt.size(1));
  a = a * a / (4.0E+6 * (bz + dz * static_cast<real_T>(wraw.size(0)))) / 2.0;
  loop_ub_tmp = wfilt.size(0) * wfilt.size(1);
  for (i = 0; i < loop_ub_tmp; i++) {
    ispike[i] = (wfilt[i] > a);
  }
  //  Fill with linear interpolation
  wfilt.set_size(&gb_emlrtRTEI, sp, wraw.size(0), wraw.size(1));
  loop_ub = wraw.size(0) * wraw.size(1);
  for (i = 0; i < loop_ub; i++) {
    wfilt[i] = rtNaN;
  }
  i = wraw.size(1);
  for (scalarLB = 0; scalarLB < i; scalarLB++) {
    covrtLogFor(&emlrtCoverageInstance, 0, 0, 0, 1);
    covrtLogBasicBlock(&emlrtCoverageInstance, 0, 1);
    st.site = &e_emlrtRSI;
    if (scalarLB + 1 > ispike.size(1)) {
      emlrtDynamicBoundsCheckR2012b(scalarLB + 1, 1, ispike.size(1),
                                    &g_emlrtBCI, &st);
    }
    loop_ub = ispike.size(0);
    ifit.set_size(&hb_emlrtRTEI, &st, ispike.size(0));
    for (i1 = 0; i1 < loop_ub; i1++) {
      ifit[i1] = !ispike[i1 + ispike.size(0) * scalarLB];
    }
    b_st.site = &tc_emlrtRSI;
    coder::eml_find(b_st, ifit, ii);
    igood.set_size(&ib_emlrtRTEI, &st, ii.size(0));
    loop_ub = ii.size(0);
    for (i1 = 0; i1 < loop_ub; i1++) {
      igood[i1] = ii[i1];
    }
    if (covrtLogIf(&emlrtCoverageInstance, 0, 0, 0, igood.size(0) > 3)) {
      covrtLogBasicBlock(&emlrtCoverageInstance, 0, 2);
      if (scalarLB + 1 > wfilt.size(1)) {
        emlrtDynamicBoundsCheckR2012b(scalarLB + 1, 1, wfilt.size(1),
                                      &e_emlrtBCI, (emlrtConstCTX)sp);
      }
      if (nz < 1) {
        y.set_size(&jb_emlrtRTEI, sp, 1, 0);
      } else {
        y.set_size(&jb_emlrtRTEI, sp, 1, nz);
        loop_ub = nz - 1;
        for (i1 = 0; i1 <= loop_ub; i1++) {
          y[i1] = static_cast<real_T>(i1) + 1.0;
        }
      }
      if (scalarLB + 1 > wraw.size(1)) {
        emlrtDynamicBoundsCheckR2012b(scalarLB + 1, 1, wraw.size(1),
                                      &f_emlrtBCI, (emlrtConstCTX)sp);
      }
      d.set_size(&kb_emlrtRTEI, sp, igood.size(0));
      loop_ub = igood.size(0);
      for (i1 = 0; i1 < loop_ub; i1++) {
        ibin = static_cast<int32_T>(igood[i1]);
        if ((ibin < 1) || (ibin > wraw.size(0))) {
          emlrtDynamicBoundsCheckR2012b(ibin, 1, wraw.size(0), &j_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        d[i1] = wraw[(ibin + wraw.size(0) * scalarLB) - 1];
      }
      st.site = &f_emlrtRSI;
      coder::interp1(st, igood, d, y, Xm);
      emlrtSubAssignSizeCheckR2012b(wfilt.size(), 1, Xm.size(), 2, &m_emlrtECI,
                                    (emlrtCTX)sp);
      loop_ub = wfilt.size(0);
      for (i1 = 0; i1 < loop_ub; i1++) {
        wfilt[i1 + wfilt.size(0) * scalarLB] = Xm[i1];
      }
    }
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b((emlrtConstCTX)sp);
    }
  }
  covrtLogFor(&emlrtCoverageInstance, 0, 0, 0, 0);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0, 3);
  // %%%%% EOF High-pass %%%%%%
  //  Identify badpings with greater than 50% spikes
  st.site = &g_emlrtRSI;
  b_st.site = &hd_emlrtRSI;
  if ((ispike.size(0) == 1) && (ispike.size(1) != 1)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &c_emlrtRTEI,
                                  "Coder:toolbox:autoDimIncompatibility",
                                  "Coder:toolbox:autoDimIncompatibility", 0);
  }
  p = false;
  if ((ispike.size(0) == 0) && (ispike.size(1) == 0)) {
    p = true;
  }
  if (p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &d_emlrtRTEI,
                                  "Coder:toolbox:UnsupportedSpecialEmpty",
                                  "Coder:toolbox:UnsupportedSpecialEmpty", 0);
  }
  c_st.site = &id_emlrtRSI;
  coder::combineVectorElements(c_st, ispike, b_nz);
  //
  //  Compute EOFs from good pings
  // [eofs,alpha,~,~] = eof(winterp(:,~badping)');
  scalarLB = b_nz.size(1) - 1;
  vectorUB = 0;
  for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
    if (!(static_cast<real_T>(b_nz[b_i]) / static_cast<real_T>(wraw.size(0)) >
          0.5)) {
      vectorUB++;
    }
  }
  r1.set_size(&lb_emlrtRTEI, sp, 1, vectorUB);
  vectorUB = 0;
  for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
    if (!(static_cast<real_T>(b_nz[b_i]) / static_cast<real_T>(wraw.size(0)) >
          0.5)) {
      r1[vectorUB] = b_i;
      vectorUB++;
    }
  }
  X.set_size(&mb_emlrtRTEI, sp, r1.size(1), wfilt.size(0));
  loop_ub = wfilt.size(0);
  for (i = 0; i < loop_ub; i++) {
    nz = r1.size(1);
    for (i1 = 0; i1 < nz; i1++) {
      if (r1[i1] > wfilt.size(1) - 1) {
        emlrtDynamicBoundsCheckR2012b(r1[i1], 0, wfilt.size(1) - 1, &k_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      X[i1 + X.size(0) * i] = wfilt[i + wfilt.size(0) * r1[i1]];
    }
  }
  //  [nsamp,~] = size(X);
  b_X.set_size(&nb_emlrtRTEI, sp, X.size(0), X.size(1));
  loop_ub = X.size(0) * X.size(1) - 1;
  for (i = 0; i <= loop_ub; i++) {
    b_X[i] = X[i];
  }
  st.site = &h_emlrtRSI;
  nanmean(st, b_X, Xm);
  //  X0 = repmat(Xm,nsamp,1);
  if ((X.size(1) != Xm.size(1)) && ((X.size(1) != 1) && (Xm.size(1) != 1))) {
    emlrtDimSizeImpxCheckR2021b(X.size(1), Xm.size(1), &l_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (X.size(1) == Xm.size(1)) {
    R.set_size(&ob_emlrtRTEI, sp, X.size(0), X.size(1));
    loop_ub = X.size(1);
    for (i = 0; i < loop_ub; i++) {
      nz = X.size(0);
      scalarLB = (X.size(0) / 2) << 1;
      vectorUB = scalarLB - 2;
      for (i1 = 0; i1 <= vectorUB; i1 += 2) {
        r = _mm_loadu_pd(&X[i1 + X.size(0) * i]);
        _mm_storeu_pd(&R[i1 + R.size(0) * i],
                      _mm_sub_pd(r, _mm_set1_pd(Xm[i])));
      }
      for (i1 = scalarLB; i1 < nz; i1++) {
        R[i1 + R.size(0) * i] = X[i1 + X.size(0) * i] - Xm[i];
      }
    }
    X.set_size(&pb_emlrtRTEI, sp, R.size(0), R.size(1));
    loop_ub = R.size(0) * R.size(1);
    for (i = 0; i < loop_ub; i++) {
      X[i] = R[i];
    }
  } else {
    st.site = &uj_emlrtRSI;
    minus(st, X, Xm);
  }
  // inan = isnan(X);
  scalarLB = X.size(0) * X.size(1) - 1;
  for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
    if (muDoubleScalarIsNaN(X[b_i])) {
      i = X.size(0) * X.size(1) - 1;
      if (b_i > i) {
        emlrtDynamicBoundsCheckR2012b(b_i, 0, i, &l_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      X[b_i] = 0.0;
    }
  }
  st.site = &i_emlrtRSI;
  b_st.site = &he_emlrtRSI;
  coder::dynamic_size_checks(b_st, X, X, X.size(0), X.size(0));
  b_st.site = &ge_emlrtRSI;
  coder::internal::blas::mtimes(b_st, X, X, R);
  st.site = &j_emlrtRSI;
  coder::eig(st, R, EOFs, E);
  st.site = &k_emlrtRSI;
  b_st.site = &vf_emlrtRSI;
  coder::internal::sort(b_st, E, ii);
  eofs.set_size(&qb_emlrtRTEI, sp, EOFs.size(0), ii.size(0));
  loop_ub = ii.size(0);
  for (i = 0; i < loop_ub; i++) {
    nz = EOFs.size(0);
    for (i1 = 0; i1 < nz; i1++) {
      p = ((ii[i] < 1) || (ii[i] > EOFs.size(1)));
      if (p) {
        emlrtDynamicBoundsCheckR2012b(ii[i], 1, EOFs.size(1), &m_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      eofs[i1 + eofs.size(0) * i].re = EOFs[i1 + EOFs.size(0) * (ii[i] - 1)].re;
      eofs[i1 + eofs.size(0) * i].im = EOFs[i1 + EOFs.size(0) * (ii[i] - 1)].im;
    }
  }
  st.site = &l_emlrtRSI;
  b_st.site = &he_emlrtRSI;
  coder::dynamic_size_checks(b_st, X, eofs, X.size(1), EOFs.size(0));
  c_X.set_size(&rb_emlrtRTEI, &st, X.size(0), X.size(1));
  loop_ub = X.size(0) * X.size(1);
  for (i = 0; i < loop_ub; i++) {
    c_X[i].re = X[i];
    c_X[i].im = 0.0;
  }
  alpha.set_size(&sb_emlrtRTEI, &st, c_X.size(0), eofs.size(1));
  loop_ub = c_X.size(0);
  for (i = 0; i < loop_ub; i++) {
    nz = eofs.size(1);
    for (i1 = 0; i1 < nz; i1++) {
      alpha[i + alpha.size(0) * i1].re = 0.0;
      alpha[i + alpha.size(0) * i1].im = 0.0;
      vectorUB = c_X.size(1);
      for (ibin = 0; ibin < vectorUB; ibin++) {
        real_T c_X_re_tmp;
        a = c_X[i + c_X.size(0) * ibin].re;
        X_re_tmp = eofs[ibin + eofs.size(0) * i1].im;
        b_X_re_tmp = c_X[i + c_X.size(0) * ibin].im;
        c_X_re_tmp = eofs[ibin + eofs.size(0) * i1].re;
        alpha[i + alpha.size(0) * i1].re =
            alpha[i + alpha.size(0) * i1].re +
            (a * c_X_re_tmp - b_X_re_tmp * X_re_tmp);
        alpha[i + alpha.size(0) * i1].im =
            alpha[i + alpha.size(0) * i1].im +
            (a * X_re_tmp + b_X_re_tmp * c_X_re_tmp);
      }
    }
  }
  //  Reconstruct w/high-mode EOFs
  m[0] = wfilt.size(0);
  i = wfilt.size(1);
  X.set_size(&tb_emlrtRTEI, sp, wfilt.size(0), wfilt.size(1));
  loop_ub = wfilt.size(0) * wfilt.size(1);
  for (i1 = 0; i1 < loop_ub; i1++) {
    X[i1] = rtNaN;
  }
  if (neoflp + 1.0 > ii.size(0)) {
    i1 = 0;
    ibin = 0;
  } else {
    if (neoflp + 1.0 !=
        static_cast<int32_T>(muDoubleScalarFloor(neoflp + 1.0))) {
      emlrtIntegerCheckR2012b(neoflp + 1.0, &b_emlrtDCI, (emlrtConstCTX)sp);
    }
    if ((static_cast<int32_T>(neoflp + 1.0) < 1) ||
        (static_cast<int32_T>(neoflp + 1.0) > ii.size(0))) {
      emlrtDynamicBoundsCheckR2012b(static_cast<int32_T>(neoflp + 1.0), 1,
                                    ii.size(0), &d_emlrtBCI, (emlrtConstCTX)sp);
    }
    i1 = static_cast<int32_T>(neoflp + 1.0) - 1;
    if (ii.size(0) < 1) {
      emlrtDynamicBoundsCheckR2012b(ii.size(0), 1, ii.size(0), &c_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    ibin = ii.size(0);
  }
  if (neoflp + 1.0 > alpha.size(1)) {
    scalarLB = 0;
    vectorUB = 0;
  } else {
    if (neoflp + 1.0 !=
        static_cast<int32_T>(muDoubleScalarFloor(neoflp + 1.0))) {
      emlrtIntegerCheckR2012b(neoflp + 1.0, &emlrtDCI, (emlrtConstCTX)sp);
    }
    if ((static_cast<int32_T>(neoflp + 1.0) < 1) ||
        (static_cast<int32_T>(neoflp + 1.0) > alpha.size(1))) {
      emlrtDynamicBoundsCheckR2012b(static_cast<int32_T>(neoflp + 1.0), 1,
                                    alpha.size(1), &b_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    scalarLB = static_cast<int32_T>(neoflp + 1.0) - 1;
    if (alpha.size(1) < 1) {
      emlrtDynamicBoundsCheckR2012b(alpha.size(1), 1, alpha.size(1), &emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    vectorUB = alpha.size(1);
  }
  loop_ub = vectorUB - scalarLB;
  c_X.set_size(&ub_emlrtRTEI, sp, alpha.size(0), loop_ub);
  for (vectorUB = 0; vectorUB < loop_ub; vectorUB++) {
    nz = alpha.size(0);
    for (int32_T b_i{0}; b_i < nz; b_i++) {
      c_X[b_i + c_X.size(0) * vectorUB] =
          alpha[b_i + alpha.size(0) * (scalarLB + vectorUB)];
    }
  }
  ii.set_size(&vb_emlrtRTEI, sp, r1.size(1));
  nz = r1.size(1);
  for (scalarLB = 0; scalarLB < nz; scalarLB++) {
    if (r1[scalarLB] > i - 1) {
      emlrtDynamicBoundsCheckR2012b(r1[scalarLB], 0, i - 1, &n_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    ii[scalarLB] = r1[scalarLB];
  }
  st.site = &m_emlrtRSI;
  scalarLB = EOFs.size(0);
  nz = ibin - i1;
  EOFs.set_size(&wb_emlrtRTEI, &st, scalarLB, nz);
  for (i = 0; i < nz; i++) {
    for (ibin = 0; ibin < scalarLB; ibin++) {
      EOFs[ibin + EOFs.size(0) * i] = eofs[ibin + eofs.size(0) * (i1 + i)];
    }
  }
  b_st.site = &he_emlrtRSI;
  coder::dynamic_size_checks(b_st, EOFs, c_X, nz, loop_ub);
  b_st.site = &ge_emlrtRSI;
  coder::internal::blas::mtimes(b_st, EOFs, c_X, alpha);
  wfilt.set_size(&xb_emlrtRTEI, sp, alpha.size(0), alpha.size(1));
  loop_ub = alpha.size(0) * alpha.size(1);
  for (i = 0; i < loop_ub; i++) {
    wfilt[i] = alpha[i].re;
  }
  b_m[0] = static_cast<int32_T>(m[0]);
  b_m[1] = ii.size(0);
  emlrtSubAssignSizeCheckR2012b(&b_m[0], 2, wfilt.size(), 2, &k_emlrtECI,
                                (emlrtCTX)sp);
  loop_ub = wfilt.size(1);
  for (i = 0; i < loop_ub; i++) {
    nz = wfilt.size(0);
    for (i1 = 0; i1 < nz; i1++) {
      X[i1 + X.size(0) * ii[i]] = wfilt[i1 + wfilt.size(0) * i];
    }
  }
  //  Remove spikes
  scalarLB = loop_ub_tmp - 1;
  for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
    if (ispike[b_i]) {
      i = X.size(0) * X.size(1) - 1;
      if (b_i > i) {
        emlrtDynamicBoundsCheckR2012b(b_i, 0, i, &o_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      X[b_i] = rtNaN;
    }
  }
  // %%%%% Compute Dissipation Rate %%%%%%
  //  Matrices of all possible data pair separation distances (R), and
  //  corresponding mean vertical position (Z0)
  y.set_size(&yb_emlrtRTEI, sp, 1, z.size(0));
  loop_ub = z.size(0);
  for (i = 0; i < loop_ub; i++) {
    y[i] = z[i];
  }
  st.site = &n_emlrtRSI;
  coder::diff(st, y, Xm);
  st.site = &n_emlrtRSI;
  dz = coder::mean(st, Xm);
  // R = round(R,2);
  b_m[0] = z.size(0);
  R.set_size(&ac_emlrtRTEI, sp, z.size(0), z.size(0));
  loop_ub = z.size(0);
  for (i = 0; i < loop_ub; i++) {
    nz = b_m[0];
    scalarLB = (b_m[0] / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i1 = 0; i1 <= vectorUB; i1 += 2) {
      r = _mm_loadu_pd(&z[i1]);
      _mm_storeu_pd(
          &R[i1 + R.size(0) * i],
          _mm_mul_pd(_mm_sub_pd(_mm_set1_pd(z[i]), r), _mm_set1_pd(100.0)));
    }
    for (i1 = scalarLB; i1 < nz; i1++) {
      R[i1 + R.size(0) * i] = (z[i] - z[i1]) * 100.0;
    }
  }
  st.site = &o_emlrtRSI;
  coder::b_round(st, R);
  loop_ub = R.size(0) * R.size(1);
  scalarLB = (loop_ub / 2) << 1;
  vectorUB = scalarLB - 2;
  for (i = 0; i <= vectorUB; i += 2) {
    r = _mm_loadu_pd(&R[i]);
    _mm_storeu_pd(&R[i], _mm_div_pd(r, _mm_set1_pd(100.0)));
  }
  for (i = scalarLB; i < loop_ub; i++) {
    R[i] = R[i] / 100.0;
  }
  y.set_size(&yb_emlrtRTEI, sp, 1, z.size(0));
  loop_ub = z.size(0);
  for (i = 0; i < loop_ub; i++) {
    y[i] = z[i];
  }
  st.site = &p_emlrtRSI;
  coder::meshgrid(st, y, Z0, wfilt);
  if ((Z0.size(0) != wfilt.size(0)) &&
      ((Z0.size(0) != 1) && (wfilt.size(0) != 1))) {
    emlrtDimSizeImpxCheckR2021b(Z0.size(0), wfilt.size(0), &j_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((Z0.size(1) != wfilt.size(1)) &&
      ((Z0.size(1) != 1) && (wfilt.size(1) != 1))) {
    emlrtDimSizeImpxCheckR2021b(Z0.size(1), wfilt.size(1), &i_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((Z0.size(0) == wfilt.size(0)) && (Z0.size(1) == wfilt.size(1))) {
    loop_ub = Z0.size(0) * Z0.size(1);
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&Z0[i]);
      r2 = _mm_loadu_pd(&wfilt[i]);
      _mm_storeu_pd(&Z0[i], _mm_div_pd(_mm_add_pd(r, r2), _mm_set1_pd(2.0)));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      Z0[i] = (Z0[i] + wfilt[i]) / 2.0;
    }
  } else {
    st.site = &tj_emlrtRSI;
    b_binary_expand_op(st, Z0, wfilt);
  }
  //  Matrices of all possible data pair velocity differences for each ping.
  st.site = &q_emlrtRSI;
  coder::mean(st, X, igood);
  if ((X.size(0) != igood.size(0)) &&
      ((X.size(0) != 1) && (igood.size(0) != 1))) {
    emlrtDimSizeImpxCheckR2021b(X.size(0), igood.size(0), &h_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (X.size(0) == igood.size(0)) {
    b_X.set_size(&bc_emlrtRTEI, sp, X.size(0), X.size(1));
    loop_ub = X.size(1);
    for (i = 0; i < loop_ub; i++) {
      nz = X.size(0);
      scalarLB = (X.size(0) / 2) << 1;
      vectorUB = scalarLB - 2;
      for (i1 = 0; i1 <= vectorUB; i1 += 2) {
        r = _mm_loadu_pd(&X[i1 + X.size(0) * i]);
        r2 = _mm_loadu_pd(&igood[i1]);
        _mm_storeu_pd(&b_X[i1 + b_X.size(0) * i], _mm_sub_pd(r, r2));
      }
      for (i1 = scalarLB; i1 < nz; i1++) {
        b_X[i1 + b_X.size(0) * i] = X[i1 + X.size(0) * i] - igood[i1];
      }
    }
    X.set_size(&bc_emlrtRTEI, sp, b_X.size(0), b_X.size(1));
    loop_ub = b_X.size(1);
    for (i = 0; i < loop_ub; i++) {
      nz = b_X.size(0);
      for (i1 = 0; i1 < nz; i1++) {
        X[i1 + X.size(0) * i] = b_X[i1 + b_X.size(0) * i];
      }
    }
    st.site = &q_emlrtRSI;
    coder::repmat(st, X, static_cast<real_T>(wraw.size(0)), dW);
  } else {
    st.site = &q_emlrtRSI;
    b_binary_expand_op(st, dW, q_emlrtRSI, X, igood, wraw);
  }
  st.site = &r_emlrtRSI;
  coder::permute(st, dW, r3);
  st.site = &r_emlrtRSI;
  coder::b_permute(st, dW, r4);
  if ((r3.size(0) != r4.size(0)) && ((r3.size(0) != 1) && (r4.size(0) != 1))) {
    emlrtDimSizeImpxCheckR2021b(r3.size(0), r4.size(0), &g_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((r3.size(1) != r4.size(1)) && ((r3.size(1) != 1) && (r4.size(1) != 1))) {
    emlrtDimSizeImpxCheckR2021b(r3.size(1), r4.size(1), &f_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((r3.size(2) != r4.size(2)) && ((r3.size(2) != 1) && (r4.size(2) != 1))) {
    emlrtDimSizeImpxCheckR2021b(r3.size(2), r4.size(2), &e_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((r3.size(0) == r4.size(0)) && (r3.size(1) == r4.size(1)) &&
      (r3.size(2) == r4.size(2))) {
    dW.set_size(&cc_emlrtRTEI, sp, r3.size(0), r3.size(1), r3.size(2));
    loop_ub = r3.size(0) * r3.size(1) * r3.size(2);
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&r3[i]);
      r2 = _mm_loadu_pd(&r4[i]);
      _mm_storeu_pd(&dW[i], _mm_sub_pd(r, r2));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      dW[i] = r3[i] - r4[i];
    }
  } else {
    st.site = &r_emlrtRSI;
    minus(st, dW, r3, r4);
  }
  st.site = &s_emlrtRSI;
  coder::b_abs(st, dW, r3);
  st.site = &s_emlrtRSI;
  coder::b_std(st, dW, wfilt);
  loop_ub = wfilt.size(0) * wfilt.size(1);
  scalarLB = (loop_ub / 2) << 1;
  vectorUB = scalarLB - 2;
  for (i = 0; i <= vectorUB; i += 2) {
    r = _mm_loadu_pd(&wfilt[i]);
    _mm_storeu_pd(&wfilt[i], _mm_mul_pd(_mm_set1_pd(5.0), r));
  }
  for (i = scalarLB; i < loop_ub; i++) {
    wfilt[i] = 5.0 * wfilt[i];
  }
  if ((r3.size(0) != wfilt.size(0)) &&
      ((r3.size(0) != 1) && (wfilt.size(0) != 1))) {
    emlrtDimSizeImpxCheckR2021b(r3.size(0), wfilt.size(0), &d_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((r3.size(1) != wfilt.size(1)) &&
      ((r3.size(1) != 1) && (wfilt.size(1) != 1))) {
    emlrtDimSizeImpxCheckR2021b(r3.size(1), wfilt.size(1), &c_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((r3.size(0) == wfilt.size(0)) && (r3.size(1) == wfilt.size(1))) {
    scalarLB = wfilt.size(0);
    r5.set_size(&dc_emlrtRTEI, sp, r3.size(0), r3.size(1), r3.size(2));
    loop_ub = r3.size(2);
    for (i = 0; i < loop_ub; i++) {
      nz = r3.size(1);
      for (i1 = 0; i1 < nz; i1++) {
        vectorUB = r3.size(0);
        for (ibin = 0; ibin < vectorUB; ibin++) {
          r5[(ibin + r5.size(0) * i1) + r5.size(0) * r5.size(1) * i] =
              (r3[(ibin + r3.size(0) * i1) + r3.size(0) * r3.size(1) * i] >
               wfilt[ibin + scalarLB * i1]);
        }
      }
    }
  } else {
    st.site = &s_emlrtRSI;
    binary_expand_op(st, r5, r3, wfilt);
  }
  scalarLB = r5.size(0) * (r5.size(1) * r5.size(2)) - 1;
  for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
    if (r5[b_i]) {
      i = dW.size(0) * dW.size(1) * dW.size(2) - 1;
      if (b_i > i) {
        emlrtDynamicBoundsCheckR2012b(b_i, 0, i, &p_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      dW[b_i] = rtNaN;
    }
  }
  //  Take mean (or median, or mean-of-the-logs) squared velocity difference to
  //  get D(z,r)
  if (covrtLogIf(&emlrtCoverageInstance, 0, 0, 1,
                 coder::internal::b_strcmp(avgtype))) {
    covrtLogBasicBlock(&emlrtCoverageInstance, 0, 4);
    st.site = &t_emlrtRSI;
    b_st.site = &rb_emlrtRSI;
    r3.set_size(&gc_emlrtRTEI, sp, dW.size(0), dW.size(1), dW.size(2));
    loop_ub = dW.size(0) * dW.size(1) * dW.size(2);
    for (i = 0; i < loop_ub; i++) {
      a = dW[i];
      r3[i] = a * a;
    }
    st.site = &t_emlrtRSI;
    coder::mean(st, r3, D);
  } else if (covrtLogIf(&emlrtCoverageInstance, 0, 0, 2,
                        coder::internal::f_strcmp(avgtype))) {
    covrtLogBasicBlock(&emlrtCoverageInstance, 0, 5);
    st.site = &u_emlrtRSI;
    b_st.site = &rb_emlrtRSI;
    r3.set_size(&ec_emlrtRTEI, sp, dW.size(0), dW.size(1), dW.size(2));
    loop_ub = dW.size(0) * dW.size(1) * dW.size(2);
    for (i = 0; i < loop_ub; i++) {
      a = dW[i];
      r3[i] = a * a;
    }
    st.site = &u_emlrtRSI;
    coder::b_log10(st, r3);
    st.site = &u_emlrtRSI;
    coder::mean(st, r3, wfilt);
    D.set_size(&fc_emlrtRTEI, sp, wfilt.size(0), wfilt.size(1));
    loop_ub = wfilt.size(0) * wfilt.size(1);
    for (i = 0; i < loop_ub; i++) {
      a = wfilt[i];
      D[i] = muDoubleScalarPower(10.0, a);
    }
  } else {
    st.site = &v_emlrtRSI;
    coder::c_error(st);
  }
  covrtLogBasicBlock(&emlrtCoverageInstance, 0, 6);
  // Fit structure function to theoretical curve
  eps.set_size(&hc_emlrtRTEI, sp, 1, z.size(0));
  loop_ub = z.size(0);
  for (i = 0; i < loop_ub; i++) {
    eps[i] = rtNaN;
  }
  Xm.set_size(&ic_emlrtRTEI, sp, 1, z.size(0));
  loop_ub = z.size(0);
  for (i = 0; i < loop_ub; i++) {
    Xm[i] = rtNaN;
  }
  if (y_size_idx_0 - 1 >= 0) {
    b_loop_ub_tmp = Z0.size(0) * Z0.size(1);
  }
  for (ibin = 0; ibin < y_size_idx_0; ibin++) {
    int32_T iv[2];
    covrtLogFor(&emlrtCoverageInstance, 0, 0, 1, 1);
    covrtLogBasicBlock(&emlrtCoverageInstance, 0, 7);
    // Find points in z0 bin
    iplot.set_size(&jc_emlrtRTEI, sp, Z0.size(0), Z0.size(1));
    if (ibin + 1 > z.size(0)) {
      emlrtDynamicBoundsCheckR2012b(ibin + 1, 1, z.size(0), &q_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    a = z[ibin];
    X_re_tmp = 1.1 * nzfit * dz / 2.0;
    b_X_re_tmp = a - X_re_tmp;
    for (i = 0; i < b_loop_ub_tmp; i++) {
      iplot[i] = (Z0[i] >= b_X_re_tmp);
    }
    ispike.set_size(&kc_emlrtRTEI, sp, Z0.size(0), Z0.size(1));
    if (ibin + 1 > z.size(0)) {
      emlrtDynamicBoundsCheckR2012b(ibin + 1, 1, z.size(0), &s_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    b_X_re_tmp = a + X_re_tmp;
    for (i = 0; i < b_loop_ub_tmp; i++) {
      ispike[i] = (Z0[i] <= b_X_re_tmp);
    }
    if ((iplot.size(0) != ispike.size(0)) ||
        (iplot.size(1) != ispike.size(1))) {
      emlrtSizeEqCheckNDErrorR2021b(iplot.size(), ispike.size(), &b_emlrtECI,
                                    (emlrtCTX)sp);
    }
    loop_ub_tmp = iplot.size(0) * iplot.size(1);
    for (i = 0; i < loop_ub_tmp; i++) {
      iplot[i] = (iplot[i] && ispike[i]);
    }
    b_m[0] = (*(int32_T(*)[2])D.size())[0];
    b_m[1] = (*(int32_T(*)[2])D.size())[1];
    iv[0] = (*(int32_T(*)[2])iplot.size())[0];
    iv[1] = (*(int32_T(*)[2])iplot.size())[1];
    st.site = &w_emlrtRSI;
    coder::internal::indexShapeCheck(st, b_m, iv);
    scalarLB = loop_ub_tmp - 1;
    for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
      if (iplot[b_i]) {
        i = D.size(0) * D.size(1) - 1;
        if (b_i > i) {
          emlrtDynamicBoundsCheckR2012b(b_i, 0, i, &h_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
      }
    }
    b_m[0] = (*(int32_T(*)[2])R.size())[0];
    b_m[1] = (*(int32_T(*)[2])R.size())[1];
    iv[0] = (*(int32_T(*)[2])iplot.size())[0];
    iv[1] = (*(int32_T(*)[2])iplot.size())[1];
    st.site = &x_emlrtRSI;
    coder::internal::indexShapeCheck(st, b_m, iv);
    for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
      if (iplot[b_i]) {
        i = R.size(0) * R.size(1) - 1;
        if (b_i > i) {
          emlrtDynamicBoundsCheckR2012b(b_i, 0, i, &i_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
      }
    }
    st.site = &y_emlrtRSI;
    vectorUB = 0;
    for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
      if (iplot[b_i]) {
        vectorUB++;
      }
    }
    igood.set_size(&lb_emlrtRTEI, &st, vectorUB);
    vectorUB = 0;
    for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
      if (iplot[b_i]) {
        igood[vectorUB] = R[b_i];
        vectorUB++;
      }
    }
    b_st.site = &vf_emlrtRSI;
    coder::internal::sort(b_st, igood, ii);
    vectorUB = 0;
    for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
      if (iplot[b_i]) {
        vectorUB++;
      }
    }
    r6.set_size(&lb_emlrtRTEI, sp, vectorUB);
    vectorUB = 0;
    for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
      if (iplot[b_i]) {
        r6[vectorUB] = b_i;
        vectorUB++;
      }
    }
    Di.set_size(&lc_emlrtRTEI, sp, ii.size(0));
    loop_ub = ii.size(0);
    for (i = 0; i < loop_ub; i++) {
      if ((ii[i] < 1) || (ii[i] > r6.size(0))) {
        emlrtDynamicBoundsCheckR2012b(ii[i], 1, r6.size(0), &t_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      Di[i] = D[r6[ii[i] - 1]];
    }
    // Select points within specified separation scale range
    loop_ub = igood.size(0);
    ifit.set_size(&mc_emlrtRTEI, sp, igood.size(0));
    r7.set_size(&nc_emlrtRTEI, sp, igood.size(0));
    for (i = 0; i < loop_ub; i++) {
      ifit[i] = (igood[i] <= rmax);
      r7[i] = (igood[i] >= rmin);
    }
    if (ifit.size(0) != r7.size(0)) {
      emlrtSizeEqCheck1DR2012b(ifit.size(0), r7.size(0), &emlrtECI,
                               (emlrtConstCTX)sp);
    }
    loop_ub = ifit.size(0);
    for (i = 0; i < loop_ub; i++) {
      ifit[i] = (ifit[i] && r7[i]);
    }
    st.site = &ab_emlrtRSI;
    b_st.site = &hd_emlrtRSI;
    c_st.site = &id_emlrtRSI;
    nz = coder::b_combineVectorElements(c_st, ifit);
    if (covrtLogIf(&emlrtCoverageInstance, 0, 0, 3, nz < 3)) {
      covrtLogBasicBlock(&emlrtCoverageInstance, 0, 8);
      //  Must contain more than 3 points
    } else {
      covrtLogBasicBlock(&emlrtCoverageInstance, 0, 9);
      scalarLB = ifit.size(0) - 1;
      vectorUB = 0;
      for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
        if (ifit[b_i]) {
          vectorUB++;
        }
      }
      r8.set_size(&lb_emlrtRTEI, sp, vectorUB);
      vectorUB = 0;
      for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
        if (ifit[b_i]) {
          r8[vectorUB] = b_i;
          vectorUB++;
        }
      }
      loop_ub = r8.size(0);
      d.set_size(&oc_emlrtRTEI, sp, r8.size(0));
      for (i = 0; i < loop_ub; i++) {
        if (r8[i] > scalarLB) {
          emlrtDynamicBoundsCheckR2012b(r8[i], 0, scalarLB, &u_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        d[i] = igood[r8[i]];
      }
      st.site = &bb_emlrtRSI;
      coder::power(st, d, x1);
      st.site = &cb_emlrtRSI;
      b_st.site = &rb_emlrtRSI;
      igood.set_size(&pc_emlrtRTEI, &b_st, x1.size(0));
      loop_ub = x1.size(0);
      for (i = 0; i < loop_ub; i++) {
        a = x1[i];
        igood[i] = muDoubleScalarPower(a, 3.0);
      }
      loop_ub = r8.size(0);
      d.set_size(&qc_emlrtRTEI, sp, r8.size(0));
      for (i = 0; i < loop_ub; i++) {
        if (r8[i] > ii.size(0) - 1) {
          emlrtDynamicBoundsCheckR2012b(r8[i], 0, ii.size(0) - 1, &v_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        d[i] = Di[r8[i]];
      }
      // Fit Structure function to theoretical curves
      if (covrtLogIf(&emlrtCoverageInstance, 0, 0, 4,
                     coder::internal::c_strcmp(fittype))) {
        real_T c_y[9];
        real_T c_m[3];
        covrtLogBasicBlock(&emlrtCoverageInstance, 0, 10);
        //  Fit structure function to D(z,r) = Br^2 + Ar^(2/3) + N
        st.site = &db_emlrtRSI;
        b_st.site = &bj_emlrtRSI;
        c_st.site = &cj_emlrtRSI;
        loop_ub = igood.size(0);
        if (x1.size(0) != igood.size(0)) {
          emlrtErrorWithMessageIdR2018a(
              &c_st, &emlrtRTEI, "MATLAB:catenate:matrixDimensionMismatch",
              "MATLAB:catenate:matrixDimensionMismatch", 0);
        }
        if (nz != igood.size(0)) {
          emlrtErrorWithMessageIdR2018a(
              &c_st, &emlrtRTEI, "MATLAB:catenate:matrixDimensionMismatch",
              "MATLAB:catenate:matrixDimensionMismatch", 0);
        }
        b_G.set_size(&yc_emlrtRTEI, &b_st, igood.size(0), 3);
        for (i = 0; i < loop_ub; i++) {
          b_G[i] = igood[i];
          b_G[i + b_G.size(0)] = x1[i];
        }
        for (i = 0; i < nz; i++) {
          b_G[i + b_G.size(0) * 2] = 1.0;
        }
        st.site = &eb_emlrtRSI;
        b_st.site = &he_emlrtRSI;
        b_st.site = &ge_emlrtRSI;
        coder::internal::blas::mtimes(b_G, b_G, c_y);
        d_G.set_size(&ad_emlrtRTEI, sp, 3, b_G.size(0));
        loop_ub = b_G.size(0);
        for (i = 0; i < loop_ub; i++) {
          d_G[3 * i] = b_G[i];
          d_G[3 * i + 1] = b_G[i + b_G.size(0)];
          d_G[3 * i + 2] = b_G[i + b_G.size(0) * 2];
        }
        st.site = &eb_emlrtRSI;
        coder::mldivide(st, c_y, d_G, b_Gg);
        st.site = &fb_emlrtRSI;
        b_st.site = &he_emlrtRSI;
        coder::dynamic_size_checks(b_st, d, b_Gg.size(1), r8.size(0));
        b_st.site = &ge_emlrtRSI;
        coder::internal::blas::mtimes(b_Gg, d, c_m);
        if (ibin + 1 > Xm.size(1)) {
          emlrtDynamicBoundsCheckR2012b(ibin + 1, 1, Xm.size(1), &db_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        Xm[ibin] = c_m[1];
      } else if (covrtLogIf(&emlrtCoverageInstance, 0, 0, 5,
                            coder::internal::d_strcmp(fittype))) {
        real_T b_y[4];
        covrtLogBasicBlock(&emlrtCoverageInstance, 0, 11);
        //  Fit structure function to D(z,r) = Ar^(2/3) + N
        st.site = &gb_emlrtRSI;
        b_st.site = &bj_emlrtRSI;
        c_st.site = &cj_emlrtRSI;
        if (nz != x1.size(0)) {
          emlrtErrorWithMessageIdR2018a(
              &c_st, &emlrtRTEI, "MATLAB:catenate:matrixDimensionMismatch",
              "MATLAB:catenate:matrixDimensionMismatch", 0);
        }
        G.set_size(&wc_emlrtRTEI, &b_st, x1.size(0), 2);
        loop_ub = x1.size(0);
        for (i = 0; i < loop_ub; i++) {
          G[i] = x1[i];
        }
        for (i = 0; i < nz; i++) {
          G[i + G.size(0)] = 1.0;
        }
        st.site = &hb_emlrtRSI;
        b_st.site = &he_emlrtRSI;
        b_st.site = &ge_emlrtRSI;
        coder::internal::blas::b_mtimes(G, G, b_y);
        c_G.set_size(&xc_emlrtRTEI, sp, 2, G.size(0));
        loop_ub = G.size(0);
        for (i = 0; i < loop_ub; i++) {
          c_G[2 * i] = G[i];
          c_G[2 * i + 1] = G[i + G.size(0)];
        }
        st.site = &hb_emlrtRSI;
        coder::b_mldivide(st, b_y, c_G, Gg);
        st.site = &ib_emlrtRSI;
        b_st.site = &he_emlrtRSI;
        coder::dynamic_size_checks(b_st, d, Gg.size(1), r8.size(0));
        b_st.site = &ge_emlrtRSI;
        coder::internal::blas::b_mtimes(Gg, d, m);
        if (ibin + 1 > Xm.size(1)) {
          emlrtDynamicBoundsCheckR2012b(ibin + 1, 1, Xm.size(1), &cb_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        Xm[ibin] = m[0];
      } else if (covrtLogIf(&emlrtCoverageInstance, 0, 0, 6,
                            coder::internal::e_strcmp(fittype))) {
        real_T b_y[4];
        covrtLogBasicBlock(&emlrtCoverageInstance, 0, 12);
        //  Don't presume a slope
        scalarLB = x1.size(0) - 1;
        vectorUB = 0;
        for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
          if (x1[b_i] > 0.0) {
            vectorUB++;
          }
        }
        r9.set_size(&lb_emlrtRTEI, sp, vectorUB);
        vectorUB = 0;
        for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
          if (x1[b_i] > 0.0) {
            r9[vectorUB] = b_i;
            vectorUB++;
          }
        }
        loop_ub = r9.size(0);
        for (i = 0; i < loop_ub; i++) {
          if (r9[i] > r8.size(0) - 1) {
            emlrtDynamicBoundsCheckR2012b(r9[i], 0, r8.size(0) - 1, &x_emlrtBCI,
                                          (emlrtConstCTX)sp);
          }
        }
        loop_ub = r9.size(0);
        for (i = 0; i < loop_ub; i++) {
          if (r9[i] > nz - 1) {
            emlrtDynamicBoundsCheckR2012b(r9[i], 0, nz - 1, &y_emlrtBCI,
                                          (emlrtConstCTX)sp);
          }
        }
        loop_ub = r9.size(0);
        d.set_size(&rc_emlrtRTEI, sp, r9.size(0));
        for (i = 0; i < loop_ub; i++) {
          if (r9[i] > scalarLB) {
            emlrtDynamicBoundsCheckR2012b(r9[i], 0, scalarLB, &bb_emlrtBCI,
                                          (emlrtConstCTX)sp);
          }
          d[i] = x1[r9[i]];
        }
        x1.set_size(&sc_emlrtRTEI, sp, d.size(0));
        loop_ub = d.size(0);
        for (i = 0; i < loop_ub; i++) {
          x1[i] = d[i];
        }
        st.site = &jb_emlrtRSI;
        coder::b_log10(st, x1);
        loop_ub = r9.size(0);
        igood.set_size(&tc_emlrtRTEI, sp, r9.size(0));
        for (i = 0; i < loop_ub; i++) {
          igood[i] = Di[r8[r9[i]]];
        }
        st.site = &kb_emlrtRSI;
        coder::b_log10(st, igood);
        st.site = &lb_emlrtRSI;
        b_st.site = &bj_emlrtRSI;
        c_st.site = &cj_emlrtRSI;
        if (r9.size(0) != x1.size(0)) {
          emlrtErrorWithMessageIdR2018a(
              &c_st, &emlrtRTEI, "MATLAB:catenate:matrixDimensionMismatch",
              "MATLAB:catenate:matrixDimensionMismatch", 0);
        }
        G.set_size(&uc_emlrtRTEI, &b_st, x1.size(0), 2);
        loop_ub = x1.size(0);
        for (i = 0; i < loop_ub; i++) {
          G[i] = x1[i];
        }
        loop_ub = r9.size(0);
        for (i = 0; i < loop_ub; i++) {
          G[i + G.size(0)] = 1.0;
        }
        st.site = &mb_emlrtRSI;
        b_st.site = &he_emlrtRSI;
        b_st.site = &ge_emlrtRSI;
        coder::internal::blas::b_mtimes(G, G, b_y);
        c_G.set_size(&vc_emlrtRTEI, sp, 2, G.size(0));
        loop_ub = G.size(0);
        for (i = 0; i < loop_ub; i++) {
          c_G[2 * i] = G[i];
          c_G[2 * i + 1] = G[i + G.size(0)];
        }
        st.site = &mb_emlrtRSI;
        coder::b_mldivide(st, b_y, c_G, Gg);
        st.site = &nb_emlrtRSI;
        b_st.site = &he_emlrtRSI;
        coder::dynamic_size_checks(b_st, igood, Gg.size(1), igood.size(0));
        b_st.site = &ge_emlrtRSI;
        coder::internal::blas::b_mtimes(Gg, igood, m);
        st.site = &ob_emlrtRSI;
        b_st.site = &rb_emlrtRSI;
        if (ibin + 1 > Xm.size(1)) {
          emlrtDynamicBoundsCheckR2012b(ibin + 1, 1, Xm.size(1), &eb_emlrtBCI,
                                        &b_st);
        }
        Xm[ibin] = muDoubleScalarPower(10.0, m[1]);
      } else {
        st.site = &pb_emlrtRSI;
        coder::d_error(st);
      }
      covrtLogBasicBlock(&emlrtCoverageInstance, 0, 13);
      st.site = &qb_emlrtRSI;
      if (ibin + 1 > Xm.size(1)) {
        emlrtDynamicBoundsCheckR2012b(ibin + 1, 1, Xm.size(1), &w_emlrtBCI,
                                      &st);
      }
      a = Xm[ibin] / 2.1;
      b_st.site = &rb_emlrtRSI;
      if (a < 0.0) {
        emlrtErrorWithMessageIdR2018a(&b_st, &b_emlrtRTEI,
                                      "Coder:toolbox:power_domainError",
                                      "Coder:toolbox:power_domainError", 0);
      }
      if (ibin + 1 > eps.size(1)) {
        emlrtDynamicBoundsCheckR2012b(ibin + 1, 1, eps.size(1), &ab_emlrtBCI,
                                      &b_st);
      }
      eps[ibin] = muDoubleScalarPower(a, 1.5);
    }
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b((emlrtConstCTX)sp);
    }
  }
  covrtLogFor(&emlrtCoverageInstance, 0, 0, 1, 0);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0, 14);
  //  Remove unphysical values
  scalarLB = Xm.size(1) - 1;
  for (int32_T b_i{0}; b_i <= scalarLB; b_i++) {
    if (Xm[b_i] < 0.0) {
      if (b_i > eps.size(1) - 1) {
        emlrtDynamicBoundsCheckR2012b(b_i, 0, eps.size(1) - 1, &r_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      eps[b_i] = rtNaN;
    }
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

// End of code generation (processSIGburst_onboard.cpp)
