# SWIFT25 Signature-accelerometer wave recovery

This branch contains a recovery of scalar wave energy during the 20--21 June
2025 SWIFT25 SBG outage. It is independent of any L2 feed-forward fallback.

## Method

The Signature burst stream contains approximately 2,032 three-axis
accelerometer samples over 508 seconds (4 Hz). SWIFT25's Signature AHRS is
not reliable enough to rotate acceleration into earth coordinates. Instead,
the estimator uses the rotation-invariant acceleration magnitude. For dynamic
acceleration small relative to gravity,

```text
vertical acceleration proxy = norm(specific force) - g
```

approximates acceleration parallel to gravity to first order. The script
uses 16,384 accelerometer counts per g, computes a Welch spectrum with
256-second Hann windows and 75% overlap, and converts acceleration spectral
density to elevation spectral density by dividing by `(2*pi*f)^4`.

Only 0.10--0.50 Hz is retained. Lower frequencies contain excessive
rotational/centripetal energy. A median frequency-dependent transfer function
is estimated from every fifth valid, QC-passing L2 SBG record. Known isolated
L2 spikes are excluded with the mission-specific `Hs < 0.5 m` validation
limit. The remaining records are a disjoint holdout set.

## Validation

The 913-record holdout results for the calibrated 0.10--0.50 Hz band are:

- Hs correlation: 0.922;
- Hs median bias: -0.0027 m;
- Hs median absolute error: 0.0075 m;
- Hs RMSE: 0.0154 m;
- energy-period correlation: 0.816; and
- energy-period median absolute error: 0.125 s.

The response is stable across the outage. Calibrating only before the outage
and validating after it gives Hs correlation 0.943 and median absolute error
0.0068 m. Reversing the periods gives correlation 0.852 and median absolute
error 0.0075 m.

Full and `_partial.mat` Signature files provide estimates for all 270
existing outage records. The two entirely absent platform records cannot be
recovered. Outage results have median band-limited Hs 0.097 m and median
energy period 3.05 s.

## Limitations

- Results are scalar and band limited, not complete wave products.
- Directional moments cannot be recovered from this method.
- Energy below 0.10 Hz remains missing.
- The low-frequency correction is empirical and SWIFT25-specific.
- Recovered `sigwaveheight` is the 0.10--0.50 Hz band Hs, not full-band Hs.
- Two absent platform records have no SWIFT record or Signature file and
  remain unrecoverable.

## MATLAB processing

`Waves/SignatureHeaveWaves.m` implements the rotation-invariant acceleration
estimator. `Signature/reprocess_SIGheave.m` finds full or partial Signature
files, estimates a deployment-specific transfer function from every fifth
valid SBG/Signature overlap record, and fills only records whose primary wave
product is missing. It requires at least 20 calibration ratios in every
frequency bin. Recovered spectra contain `NaN` outside 0.10--0.50 Hz, all
directional moments remain `NaN`, and the spectrum is marked with
`wavespectra.source = 'SignatureHeave'` and `wavespectra.band = [0.10 0.50]`.
Recovery masks, calibration records, transfer values, and parameters are
also stored in `sinfo.postproc`.

For a non-writing review run:

```matlab
[metrics,fh,diagnostics] = review_SIGheave(missiondir, ...
    plot_file="SWIFT25_signature_heave.png");
```

The fallback remains opt-in while the MATLAB path is reviewed against the
archive. Run it after normal L3/SBG processing so valid SBG records are
available for calibration and only missing primary wave records are filled.

To write the recovered records to the mission L3 product:

```matlab
[SWIFT,sinfo,diagnostics] = reprocess_SIGheave(missiondir);
```

All processing and review code on this branch is MATLAB. The validation
statistics above were reproduced from the mounted archive before translating
the estimator, and the MATLAB Welch calculation was checked against the
validated spectrum to machine precision.
