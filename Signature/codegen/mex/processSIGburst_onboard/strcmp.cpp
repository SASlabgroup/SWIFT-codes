//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// strcmp.cpp
//
// Code generation for function 'strcmp'
//

// Include files
#include "strcmp.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
namespace internal {
boolean_T b_strcmp(const ::coder::array<char_T, 2U> &a)
{
  static const char_T cv[4]{'m', 'e', 'a', 'n'};
  boolean_T b_bool;
  b_bool = false;
  if (a.size(1) == 4) {
    int32_T kstr;
    kstr = 0;
    int32_T exitg1;
    do {
      exitg1 = 0;
      if (kstr < 4) {
        if (a[kstr] != cv[kstr]) {
          exitg1 = 1;
        } else {
          kstr++;
        }
      } else {
        b_bool = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  return b_bool;
}

boolean_T c_strcmp(const ::coder::array<char_T, 2U> &a)
{
  static const char_T cv[5]{'c', 'u', 'b', 'i', 'c'};
  boolean_T b_bool;
  b_bool = false;
  if (a.size(1) == 5) {
    int32_T kstr;
    kstr = 0;
    int32_T exitg1;
    do {
      exitg1 = 0;
      if (kstr < 5) {
        if (a[kstr] != cv[kstr]) {
          exitg1 = 1;
        } else {
          kstr++;
        }
      } else {
        b_bool = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  return b_bool;
}

boolean_T d_strcmp(const ::coder::array<char_T, 2U> &a)
{
  static const char_T cv[6]{'l', 'i', 'n', 'e', 'a', 'r'};
  boolean_T b_bool;
  b_bool = false;
  if (a.size(1) == 6) {
    int32_T kstr;
    kstr = 0;
    int32_T exitg1;
    do {
      exitg1 = 0;
      if (kstr < 6) {
        if (a[kstr] != cv[kstr]) {
          exitg1 = 1;
        } else {
          kstr++;
        }
      } else {
        b_bool = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  return b_bool;
}

boolean_T e_strcmp(const ::coder::array<char_T, 2U> &a)
{
  static const char_T cv[3]{'l', 'o', 'g'};
  boolean_T b_bool;
  b_bool = false;
  if (a.size(1) == 3) {
    int32_T kstr;
    kstr = 0;
    int32_T exitg1;
    do {
      exitg1 = 0;
      if (kstr < 3) {
        if (a[kstr] != cv[kstr]) {
          exitg1 = 1;
        } else {
          kstr++;
        }
      } else {
        b_bool = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  return b_bool;
}

boolean_T f_strcmp(const ::coder::array<char_T, 2U> &a)
{
  static const char_T cv[7]{'l', 'o', 'g', 'm', 'e', 'a', 'n'};
  boolean_T b_bool;
  b_bool = false;
  if (a.size(1) == 7) {
    int32_T kstr;
    kstr = 0;
    int32_T exitg1;
    do {
      exitg1 = 0;
      if (kstr < 7) {
        if (a[kstr] != cv[kstr]) {
          exitg1 = 1;
        } else {
          kstr++;
        }
      } else {
        b_bool = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  return b_bool;
}

} // namespace internal
} // namespace coder

// End of code generation (strcmp.cpp)
