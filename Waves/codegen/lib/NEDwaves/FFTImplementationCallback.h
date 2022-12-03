//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// FFTImplementationCallback.h
//
// Code generation for function 'FFTImplementationCallback'
//

#ifndef FFTIMPLEMENTATIONCALLBACK_H
#define FFTIMPLEMENTATIONCALLBACK_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Type Definitions
namespace coder {
namespace internal {
namespace fft {
class FFTImplementationCallback {
public:
  static void r2br_r2dit_trig(const ::coder::array<double, 2U> &x,
                              int n1_unsigned,
                              const ::coder::array<double, 2U> &costab,
                              const ::coder::array<double, 2U> &sintab,
                              ::coder::array<creal_T, 2U> &y);
  static void dobluesteinfft(const ::coder::array<double, 2U> &x, int n2blue,
                             int nfft, const ::coder::array<double, 2U> &costab,
                             const ::coder::array<double, 2U> &sintab,
                             const ::coder::array<double, 2U> &sintabinv,
                             ::coder::array<creal_T, 2U> &y);

protected:
  static void r2br_r2dit_trig_impl(const ::coder::array<creal_T, 1U> &x,
                                   int unsigned_nRows,
                                   const ::coder::array<double, 2U> &costab,
                                   const ::coder::array<double, 2U> &sintab,
                                   ::coder::array<creal_T, 1U> &y);
  static void doHalfLengthRadix2(const ::coder::array<double, 2U> &x,
                                 int xoffInit, ::coder::array<creal_T, 1U> &y,
                                 int unsigned_nRows,
                                 const ::coder::array<double, 2U> &costab,
                                 const ::coder::array<double, 2U> &sintab);
  static void
  doHalfLengthBluestein(const ::coder::array<double, 2U> &x, int xoffInit,
                        ::coder::array<creal_T, 1U> &y, int nrowsx, int nRows,
                        int nfft, const ::coder::array<creal_T, 1U> &wwc,
                        const ::coder::array<double, 2U> &costab,
                        const ::coder::array<double, 2U> &sintab,
                        const ::coder::array<double, 2U> &costabinv,
                        const ::coder::array<double, 2U> &sintabinv);
};

} // namespace fft
} // namespace internal
} // namespace coder

#endif
// End of code generation (FFTImplementationCallback.h)
