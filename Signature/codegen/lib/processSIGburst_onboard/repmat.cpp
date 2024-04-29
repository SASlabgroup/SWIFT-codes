//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// repmat.cpp
//
// Code generation for function 'repmat'
//

// Include files
#include "repmat.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
void repmat(const ::coder::array<double, 2U> &a, double varargin_3,
            ::coder::array<double, 3U> &b)
{
  int i;
  int ncols;
  int nrows;
  i = static_cast<int>(varargin_3);
  b.set_size(a.size(0), a.size(1), i);
  nrows = a.size(0);
  ncols = a.size(1);
  for (int jtilecol{0}; jtilecol < i; jtilecol++) {
    int ibtile;
    ibtile = jtilecol * (nrows * ncols) - 1;
    for (int jcol{0}; jcol < ncols; jcol++) {
      int iacol_tmp;
      int ibmat;
      iacol_tmp = jcol * nrows;
      ibmat = ibtile + iacol_tmp;
      for (int k{0}; k < nrows; k++) {
        b[(ibmat + k) + 1] = a[iacol_tmp + k];
      }
    }
  }
}

} // namespace coder

// End of code generation (repmat.cpp)
