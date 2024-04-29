//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// nanmean.cpp
//
// Code generation for function 'nanmean'
//

// Include files
#include "nanmean.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
double nanmean(double x)
{
  double b_unnamed_idx_0;
  double unnamed_idx_0;
  bool nans;
  // NANMEAN Mean value, ignoring NaNs.
  //    M = NANMEAN(X) returns the sample mean of X, treating NaNs as missing
  //    values.  For vector input, M is the mean value of the non-NaN elements
  //    in X.  For matrix input, M is a row vector containing the mean value of
  //    non-NaN elements in each column.  For N-D arrays, NANMEAN operates
  //    along the first non-singleton dimension.
  //
  //    NANMEAN(X,DIM) takes the mean along dimension DIM of X.
  //
  //    See also MEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.
  //    Copyright 1993-2004 The MathWorks, Inc.
  //    $Revision: 2.13.4.3 $  $Date: 2004/07/28 04:38:41 $
  //  Find NaNs and set them to zero
  nans = std::isnan(x);
  unnamed_idx_0 = x;
  if (nans) {
    unnamed_idx_0 = 0.0;
  }
  //  Count up non-NaNs.
  b_unnamed_idx_0 = !nans;
  if (nans) {
    b_unnamed_idx_0 = rtNaN;
  }
  //  prevent divideByZero warnings
  //  Sum up non-NaNs, and divide by the number of non-NaNs.
  if (std::isnan(unnamed_idx_0)) {
    unnamed_idx_0 = 0.0;
  }
  return unnamed_idx_0 / b_unnamed_idx_0;
}

// End of code generation (nanmean.cpp)
