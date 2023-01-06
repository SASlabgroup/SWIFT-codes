/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: rtwhalf.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jan-2023 10:46:55
 */

/* Include Files */
#include "rtwhalf.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Utility function */
uint16_T getBitfieldFromHalf(real16_T a)
{
  return a.bitPattern;
}

real16_T getHalfFromBitfield(uint16_T a)
{
  real16_T out;
  out.bitPattern = a;
  return out;
}

uint32_T getBitfieldFromFloat(float a)
{
  uint32_T bitfield;
  memcpy(&bitfield, &a, sizeof(float));
  return bitfield;
}

float getFloatFromBitfield(uint32_T a)
{
  float value;
  memcpy(&value, &a, sizeof(float));
  return value;
}

/* Convert half to float */
float halfToFloat(real16_T a)
{

  uint16_T aExpComp;
  uint32_T outSign;
  uint32_T outExpMant;
  float eExp;
  float ans;

  aExpComp = ((~a.bitPattern) & 0x7C00U);
  outSign = ((((uint32_T)a.bitPattern) & 0x8000U) << 16);
  outExpMant = ((((uint32_T)a.bitPattern) & 0x7FFFU) << 13);
  eExp = 5.192296858534828e+33f; /* 2^112 */

  if (aExpComp != 0U) {
    /* Input is finite */
    uint32_T out = (outSign | outExpMant);
    ans = (getFloatFromBitfield(out) * eExp);
  } else {
    uint32_T out = (outSign | outExpMant | 0x7F800000U);
    ans = getFloatFromBitfield(out);
  }

  return ans;
}
/* Convert float to half */
real16_T floatToHalf(float a)
{
  real16_T out;

  uint32_T input = getBitfieldFromFloat(a);
  uint32_T aExponent = (input & 0x7F800000U) >>
                       23; /* Move exponent to the unit place so that it is
                              easier to compute other exponent values */
  uint32_T aMantissa = (input & 0x007FFFFFU);

  uint16_T outSign = ((input & 0x80000000U) >> 16);
  uint16_T outExponent;
  uint16_T outMantissa;

  if (aExponent == 0x7F800000U >> 23) { /* Inf or NaN input */
    outExponent = 0x7C00U;
    outMantissa = (aMantissa == 0) ? 0 : 0x0200U;
  } else if (aExponent < 102U) { /* Smaller that 1/2 of the smallest denormal
                                    number in half precision */
    outExponent = 0;
    outMantissa = 0;
  } else if (aExponent > 142U) { /* Largest exponent in half precision is
                                    2^(15). (142 = 15 + 127) */
    outExponent = 0x7C00U;
    outMantissa = 0;
  } else {
    /* Get sticky and round bit */
    boolean_T sticky;
    boolean_T round;

    if (aExponent < 113U) { /* Answer is denormal */
      uint32_T shift_length;
      aMantissa |= 0x00800000U; /* Add hidden bit */

      shift_length = 113U - aExponent;
      sticky = ((aMantissa << (20 - shift_length)) !=
                0); /* 32 bit - (12 + shift_length) */
      round = ((aMantissa >> (12 + shift_length) & 0x00000001U) != 0);

      outExponent = 0;
      outMantissa = (uint16_T)((aMantissa >> (13 + shift_length)));
    } else {
      sticky = ((aMantissa & 0x00000FFFU) != 0);
      round = ((aMantissa & 0x00001000U) != 0);

      outExponent = (uint16_T)(aExponent - 112);
      outMantissa = (uint16_T)(aMantissa >>= 13);
    }

    /* Perform rounding to nearest even */
    if (round && (sticky || ((outMantissa & 0x0001U) != 0))) {
      outMantissa++;
    }

    if (outMantissa > 0x03FFU) { /* Rounding cause overflow */
      outExponent++;
      outMantissa = 0;
    }

    outExponent <<= 10;
  }

  out.bitPattern = (outSign | outExponent | outMantissa);
  return out;
}
/* Convert half to double */

double halfToDouble(real16_T a)
{
  return ((double)halfToFloat(a));
}

/* Convert double to half */

real16_T doubleToHalf(double a)
{
  real16_T out;

  const uint32_T *aBitsPointer;
  uint32_T mostSignificantChunk;
  uint32_T aMantissaFirstChunk;
  uint32_T aMantissaSecondChunk;
  uint16_T aExponent;
  uint16_T outSign;
  uint16_T outExponent;
  uint16_T outMantissa;
  real64_T one = 1.0;
  uint32_T endianAdjustment = *((uint32_T *)&one);
  aBitsPointer = (uint32_T *)&a;
  if (endianAdjustment) {
    mostSignificantChunk = *(aBitsPointer++);
    aMantissaSecondChunk = *aBitsPointer;
  } else {
    aMantissaSecondChunk = *(aBitsPointer++);
    mostSignificantChunk = *aBitsPointer;
  }

  /* Move exponent to the unit place so that it is easier to compute other
   * exponent values */
  aExponent = (uint16_T)((mostSignificantChunk & 0x7FF00000UL) >> (52 - 32));
  aMantissaFirstChunk = (mostSignificantChunk & 0x000FFFFFUL);
  outSign = (uint16_T)((mostSignificantChunk & 0x80000000UL) >> (48 - 32));
  if (aExponent ==
      (uint16_T)(0x7FF00000UL >> (52 - 32))) { /* Inf or NaN input */
    outExponent = 0x7C00U;
    outMantissa =
        (aMantissaFirstChunk == 0 && aMantissaSecondChunk == 0) ? 0 : 0x0200U;
  } else if (aExponent < 998U) { /* Smaller than 1/2 of the smallest denormal
                                    number in half precision */
    outExponent = 0;
    outMantissa = 0;
  } else if (aExponent > 1038U) { /* Largest exponent in half precision is
                                     2^(15). (1038 = 15 + 1023) */
    outExponent = 0x7C00U;
    outMantissa = 0;
  } else {
    /* Get sticky and round bit */
    boolean_T sticky;
    boolean_T round;

    if (aExponent < 1009U) { /* Answer is denormal */
      uint16_T shift_length;
      aMantissaFirstChunk |= 0x00100000UL; /* Add hidden bit */
      shift_length = 1009U - aExponent;
      sticky = ((aMantissaFirstChunk << (23 - shift_length)) != 0) &&
               ((aMantissaSecondChunk >> (23 - shift_length)) != 0);
      round = ((aMantissaFirstChunk >> (41 - 32 + shift_length) &
                0x00000001UL) != 0);
      outExponent = 0;
      outMantissa =
          (uint16_T)((aMantissaFirstChunk >> (42 - 32 + shift_length)));
    } else {
      sticky = ((aMantissaFirstChunk & 0x000001FFUL) != 0 ||
                aMantissaSecondChunk != 0);
      round = ((aMantissaFirstChunk & 0x00000200UL) != 0);
      outExponent = (uint16_T)(aExponent - 1008);
      outMantissa = (uint16_T)(aMantissaFirstChunk >>= (42 - 32));
    }

    /* Perform rounding to nearest even */
    if (round && (sticky || ((outMantissa & 0x0001U) != 0))) {
      outMantissa++;
    }

    if (outMantissa > 0x03FFU) { /* Rounding cause overflow */
      outExponent++;
      outMantissa = 0;
    }
    outExponent <<= 10;
  }

  out.bitPattern = (outSign | outExponent | outMantissa);
  return out;
}

#ifdef __cplusplus

/* Basic Arithmetic Operations */
real16_T real16_T::operator+(real16_T a) const
{
  return real16_T(this->operator float() + static_cast<float>(a));
}

real16_T real16_T::operator-(real16_T a) const
{
  return real16_T(this->operator float() - static_cast<float>(a));
}
real16_T real16_T::operator*(real16_T a) const
{
  return real16_T(this->operator float() * static_cast<float>(a));
}
real16_T real16_T::operator/(real16_T a) const
{
  return real16_T(this->operator float() / static_cast<float>(a));
}

real16_T real16_T::operator+() const
{
  return (*this);
}

real16_T real16_T::operator-() const
{
  real16_T tmp;
  tmp.bitPattern = (bitPattern ^ 0x8000U);
  return tmp;
}

real16_T &real16_T::operator++()
{
  real16_T tmp(this->operator float() + 1.0f);
  bitPattern = tmp.bitPattern;
  return (*this);
}
real16_T real16_T::operator++(int)
{
  real16_T old(*this);
  real16_T tmp(this->operator float() + 1.0f);
  bitPattern = tmp.bitPattern;
  return old;
}
real16_T &real16_T::operator--()
{
  real16_T tmp(this->operator float() - 1.0f);
  bitPattern = tmp.bitPattern;
  return (*this);
}
real16_T real16_T::operator--(int)
{
  real16_T old(*this);
  real16_T tmp(this->operator float() - 1.0f);
  bitPattern = tmp.bitPattern;
  return old;
}

real16_T &real16_T::operator+=(real16_T a)
{
  real16_T tmp(this->operator float() + static_cast<float>(a));
  bitPattern = tmp.bitPattern;
  return (*this);
}
real16_T &real16_T::operator-=(real16_T a)
{
  real16_T tmp(this->operator float() - static_cast<float>(a));
  bitPattern = tmp.bitPattern;
  return (*this);
}
real16_T &real16_T::operator*=(real16_T a)
{
  real16_T tmp(this->operator float() * static_cast<float>(a));
  bitPattern = tmp.bitPattern;
  return (*this);
}
real16_T &real16_T::operator/=(real16_T a)
{
  real16_T tmp(this->operator float() / static_cast<float>(a));
  bitPattern = tmp.bitPattern;
  return (*this);
}

#endif

#ifdef __cplusplus

/* Relational Operations */
boolean_T real16_T::operator==(real16_T a) const
{
  return (this->operator float() == static_cast<float>(a));
}

boolean_T real16_T::operator!=(real16_T a) const
{
  return (this->operator float() != static_cast<float>(a));
}

boolean_T real16_T::operator>=(real16_T a) const
{
  return (this->operator float() >= static_cast<float>(a));
}

boolean_T real16_T::operator>(real16_T a) const
{
  return (this->operator float() > static_cast<float>(a));
}

boolean_T real16_T::operator<=(real16_T a) const
{
  return (this->operator float() <= static_cast<float>(a));
}

boolean_T real16_T::operator<(real16_T a) const
{
  return (this->operator float() < static_cast<float>(a));
}

#endif

/* Math function definitions */

real16_T sin_half(real16_T a)
{
  return doubleToHalf(sin(halfToDouble(a)));
}

real16_T cos_half(real16_T a)
{
  return doubleToHalf(cos(halfToDouble(a)));
}

real16_T ceil_half(real16_T a)
{
  return doubleToHalf(ceil(halfToDouble(a)));
}

real16_T fix_half(real16_T a)
{
  double temp = halfToDouble(a);
  if (temp < 0.0) {
    return doubleToHalf(ceil(temp));
  } else {
    return doubleToHalf(floor(temp));
  }
}

real16_T floor_half(real16_T a)
{
  return doubleToHalf(floor(halfToDouble(a)));
}

real16_T exp_half(real16_T a)
{
  return doubleToHalf(exp(halfToDouble(a)));
}

real16_T log_half(real16_T a)
{
  return doubleToHalf(log(halfToDouble(a)));
}

real16_T log10_half(real16_T a)
{
  return doubleToHalf(log10(halfToDouble(a)));
}

real16_T sqrt_half(real16_T a)
{
  return doubleToHalf(sqrt(halfToDouble(a)));
}

/*
 * File trailer for rtwhalf.c
 *
 * [EOF]
 */
