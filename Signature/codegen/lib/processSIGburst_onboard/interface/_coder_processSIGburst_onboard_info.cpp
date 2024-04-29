//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_processSIGburst_onboard_info.cpp
//
// Code generation for function 'processSIGburst_onboard'
//

// Include files
#include "_coder_processSIGburst_onboard_info.h"
#include "emlrt.h"
#include "tmwtypes.h"

// Function Declarations
static const mxArray *emlrtMexFcnResolvedFunctionsInfo();

// Function Definitions
static const mxArray *emlrtMexFcnResolvedFunctionsInfo()
{
  const mxArray *nameCaptureInfo;
  const char_T *data[6]{
      "789ced55cd6e13311076a0fc5c8070e18ed41b2552222104b7909f76aba424ec160ab80a"
      "fbe3345676edd4f6d2949780c7e0c82370e0006fc0850b4fc26eec6d"
      "924dcd464a59a42a73d8f1e88bfd7d33138f41c168170000b781b4af77a5bfa5e2a2f257"
      "c0bca5f182f257537162d7c0c6dcbe04ffa8bc4b89406321036207e8",
      "6ca747034c6c22acd311020c71eabf47de04e9631f593840e66cb017474173063a0b6228"
      "5ed706c81d9a6100d8804f15fab3c1b41e9a7c3796acc76b4d3d8a29"
      "fc6de3b0f614ee73c4381cf6b1f800b7b118840e6c57ad56f5196c86c41598120ecd5746"
      "d37ae8520f456b7c446c113204478cba8873d3d87642c6458f1287da",
      "cc2b05a97cdead98cf0d6d3e12893a15209b5c18df752d9f443c1a3a3e9ae6f76545be96"
      "966f1e5fec579dd19143c78b0dab59f58eec0e2647d0155e2f6e5605"
      "aa52c91665d5ebce92fad37efafb9b13ff5b7c2be4c907bef35fb9f229fb5f7c63cd79cb"
      "feffee69f88a29dce877ade3faf8b8d2e1a2c9f7cbbbad5df3f9ce54",
      "472783274b07d0c4799d9fdb3d365a078dc3cdc016beed304ac5261494faf14546810f7d"
      "ec4089c111f54ffb2181387aa8d8a85c0a0aa660d18db6681b8901f5"
      "8cfaacfe4f2beadfcad09fe0f13bc04a134dc4f6e522526a0ba4d6521c6f9070a93993a5"
      "2f6d3a7d895dd43bdacbe04bf0b89f7be7f7930f6c863c38a998fa3e",
      "502ea99f5ac902c2850246a33aafb9d2bdff33df397d50fd912b9fb2cb3ea7db46e7d14b"
      "841fbf79d2aebc7029eb0665835da239fd59b37fd93aee68ce2fa6f0"
      "55e6b45af54e281baee7f3bcade7f3f9f9ace7b3b4f57cfe3b4f960ea089fff5f97f0091"
      "df4f67",
      ""};
  nameCaptureInfo = nullptr;
  emlrtNameCaptureMxArrayR2016a(&data[0], 4568U, &nameCaptureInfo);
  return nameCaptureInfo;
}

mxArray *emlrtMexFcnProperties()
{
  mxArray *xEntryPoints;
  mxArray *xInputs;
  mxArray *xResult;
  const char_T *propFieldName[7]{
      "Version",      "ResolvedFunctions", "Checksum",    "EntryPoints",
      "CoverageInfo", "IsPolymorphic",     "PropertyList"};
  const char_T *epFieldName[6]{
      "Name",           "NumberOfInputs", "NumberOfOutputs",
      "ConstantInputs", "FullPath",       "TimeStamp"};
  xEntryPoints =
      emlrtCreateStructMatrix(1, 1, 6, (const char_T **)&epFieldName[0]);
  xInputs = emlrtCreateLogicalMatrix(1, 10);
  emlrtSetField(xEntryPoints, 0, "Name",
                emlrtMxCreateString("processSIGburst_onboard"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs",
                emlrtMxCreateDoubleScalar(10.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs",
                emlrtMxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(
      xEntryPoints, 0, "FullPath",
      emlrtMxCreateString("C:\\Users\\kfitz\\Github\\MATLAB\\Functions\\SWIFT-"
                          "codes\\Signature\\processSIGburst_onboard.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp",
                emlrtMxCreateDoubleScalar(739371.53973379626));
  xResult =
      emlrtCreateStructMatrix(1, 1, 7, (const char_T **)&propFieldName[0]);
  emlrtSetField(xResult, 0, "Version",
                emlrtMxCreateString("9.14.0.2489007 (R2023a) Update 6"));
  emlrtSetField(xResult, 0, "ResolvedFunctions",
                (mxArray *)emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "Checksum",
                emlrtMxCreateString("ihubGURWpOzIOqyLTTzzME"));
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

// End of code generation (_coder_processSIGburst_onboard_info.cpp)
