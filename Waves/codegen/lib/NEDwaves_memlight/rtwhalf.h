/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: rtwhalf.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jan-2023 10:46:55
 */

#ifndef RTWHALF_H
#define RTWHALF_H

/* Include Files */

#ifdef MATLAB_MEX_FILE
#include "tmwtypes.h"
#else
#include "rtwtypes.h"
#endif
#ifndef __cplusplus

/* C type definition */

typedef struct {
  uint16_T bitPattern;
} real16_T;

#else

/* C++ type definition */
class real16_T {
public:
#if __cplusplus >= 201103L || _MSC_VER >= 1900
  real16_T() = default;
#else
  inline real16_T()
  {
  }
#endif

  /* Casting operations */
  explicit real16_T(float a);
  explicit real16_T(double a);
#if __cplusplus >= 201103L || _MSC_VER >= 1900
  explicit operator float() const;
  explicit operator double() const;
#else
  operator float() const;
  operator double() const;
#endif

  /* Basic arithmetic operators */
  real16_T operator+(real16_T a) const;
  real16_T operator-(real16_T a) const;
  real16_T operator*(real16_T a) const;
  real16_T operator/(real16_T a) const;

  real16_T operator+() const;
  real16_T operator-() const;

  real16_T &operator++();
  real16_T operator++(int);
  real16_T &operator--();
  real16_T operator--(int);

  /* Relational operators */
  boolean_T operator==(real16_T a) const;
  boolean_T operator!=(real16_T a) const;
  boolean_T operator>=(real16_T a) const;
  boolean_T operator>(real16_T a) const;
  boolean_T operator<=(real16_T a) const;
  boolean_T operator<(real16_T a) const;

  /* Assignments */
  real16_T &operator+=(real16_T a);
  real16_T &operator-=(real16_T a);
  real16_T &operator*=(real16_T a);
  real16_T &operator/=(real16_T a);

  /* Internal storage */
public:
  uint16_T bitPattern;
};
#endif

typedef struct {
  real16_T re;
  real16_T im;
} creal16_T;

/* Utility functions */
uint16_T getBitfieldFromHalf(real16_T a);
real16_T getHalfFromBitfield(uint16_T a);

uint32_T getBitfieldFromFloat(float a);
float getFloatFromBitfield(uint32_T a);

/* Data Type Conversion */
float halfToFloat(real16_T a);
double halfToDouble(real16_T a);

real16_T floatToHalf(float a);
real16_T doubleToHalf(double a);

/* Math functions */
real16_T sin_half(real16_T a);
real16_T cos_half(real16_T a);
real16_T ceil_half(real16_T a);
real16_T fix_half(real16_T a);
real16_T floor_half(real16_T a);
real16_T exp_half(real16_T a);
real16_T log_half(real16_T a);
real16_T log10_half(real16_T a);
real16_T sqrt_half(real16_T a);
#endif
/*
 * File trailer for rtwhalf.h
 *
 * [EOF]
 */
