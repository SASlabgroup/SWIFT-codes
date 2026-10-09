# SWIFT25 Signature-accelerometer wave recovery

This branch estimates scalar wave energy from SWIFT25's Signature
accelerometer for records with missing or invalid SBG wave products, including
the 20--21 June 2025 SBG outage. It is independent of the L2 feed-forward
fallback.

## Product separation

`Signature/reprocess_SIGheave.m` is deliberately non-destructive. It writes a
separate `SWIFT(i).signaturewaves` product for every usable Signature burst and
does not replace `sigwaveheight`, `peakwaveperiod`, or `wavespectra`. The
separate product contains:

- `sigwaveheight`, `peakwaveperiod`, and `energyperiod`;
- native-grid `freq` and `energy` through 2.5 Hz;
- `dof` and `source`;
- the measured and extrapolated frequency bands;
- a logical `tail_extrapolated` mask; and
- the fraction of variance between 0.05 and 0.10 Hz, retained as a diagnostic
  for possible low-frequency drift.

The generic routine also records the transfer, tail calibration, source files,
window count, nominal DOF, calibration mask, and fill-candidate mask in
`sinfo.postproc`.

`Process_WillapaMoored.m` makes the project-specific decision to promote only
the 302 SWIFT25 fill candidates into the canonical fields. Directional moments
remain `NaN`, and `wavespectra.source` is set to `SignatureHeave`. The full
native fallback spectrum remains in `signaturewaves`; the canonical
`wavespectra` field is interpolated only onto its existing telemetry frequency
grid, which ends near 1 Hz. As with normal SBG processing, canonical Hs is
calculated on the wider native grid rather than from the truncated telemetry
spectrum.

## Method

The Signature burst stream normally contains approximately 2,032 three-axis
accelerometer samples over 508 seconds at 4 Hz. SWIFT25's Signature AHRS is not
reliable enough to rotate acceleration into earth coordinates. For dynamic
acceleration small relative to gravity, the rotation-invariant proxy

```text
vertical acceleration proxy = norm(specific force) - g
```

approximates acceleration parallel to gravity to first order. The estimator
uses 16,384 accelerometer counts per g, 256-second Hann windows with 75 percent
overlap, and converts acceleration spectral density to elevation spectral
density by dividing by `(2*pi*f)^4`.

The recovery uses the same native frequency bins and 0.05--2.5 Hz Hs range as
`SBGwaves`:

1. Signature energy from 0.05 through 2.0 Hz is measured directly.
2. A frequency-dependent median transfer is learned from every fifth valid
   SBG/Signature overlap record. Native SBG spectra retained in `sbgwaves` are
   used so calibration is not limited by the approximately 1 Hz telemetry
   grid.
3. The unavailable 2.0--2.5 Hz portion is extrapolated as an `f^-4` tail,
   anchored to measured energy from 1.5--1.9 Hz.
4. The tail amplitude is multiplied by 0.335774, the median native-SBG to raw
   tail-variance ratio in the calibration records. This avoids the systematic
   high bias of an unnormalized tail.
5. Hs is calculated from the combined measured and extrapolated spectrum over
   0.05--2.5 Hz, exactly as a spectral integral; there is no separate scalar Hs
   correction.

The isolated 23 June SBG spike and other reference values at or above 0.5 m
are excluded from calibration. The remaining records form a disjoint holdout
set.

## Validation

The complete MATLAB path was run against the mounted SWIFT25 archive after a
non-writing run of canonical `reprocess_SBG`. For 916 holdout records, comparing
the full 0.05--2.5 Hz estimate with native SBG Hs gives:

- correlation: 0.926;
- median bias: -0.0031 m;
- mean bias: +0.0001 m;
- median absolute error: 0.0094 m;
- RMSE: 0.0199 m; and
- median Hs ratio: 0.965.

The extrapolated tail completes the spectrum but has negligible effect on Hs.
Among the 302 fill candidates, adding 2.0--2.5 Hz changes Hs by 0.0000034 m at
the median, 0.0000064 m at the mean, and at most 0.000027 m. Native SBG data
independently show that omitting frequencies above 2 Hz produces a median Hs
bias of only -0.004 percent; 99 percent of records lose less than 0.102 percent.

The integrated run finds 302 recoverable existing SWIFT records: all 300
records with no raw SBG file, one record with too little usable SBG data, and
the anomalous 23 June SBG wave record. This includes all 269 L2 records in the
continuous 20--21 June SBG outage. Two records with empty raw SBG streams on 26
and 27 June have no Signature file and remain missing. Expected time slots
absent from L2 cannot be inserted without a vetted SWIFT record skeleton.

## Limitations

- This is a scalar estimate; directional moments cannot be recovered.
- The acceleration-magnitude method contains orientation and centripetal
  contamination. The 0.05--0.10 Hz variance fraction has a median of 0.069 and
  a 95th percentile of 0.252 among fill candidates, so it is saved explicitly
  for later drift QC.
- The empirical spectral transfer and tail normalization are specific to
  SWIFT25 and this deployment.
- Frequencies above the 2 Hz Signature Nyquist limit are modeled, not measured.
- The canonical telemetry spectrum ends near 1 Hz. Use `signaturewaves` when
  the complete native 0.05--2.5 Hz fallback spectrum or tail provenance is
  needed.

## Review

Run a non-writing review with:

```matlab
[metrics,figures,diagnostics] = review_SIGheave(missiondir, ...
    plot_dir="signature_heave_review");
```

The review writes `SWIFT25_signature_heave_validation.png`,
`SWIFT25_signature_heave_effect.png`, and
`SWIFT25_signature_heave_spectral_difference.png`. The plots show the Hs
holdout comparison, the 302 candidate fills, the measured and extrapolated
spectra on the full non-overlapping native grid, and frequency-resolved bias.

All processing and review code in this workflow is MATLAB.

## Additional validation plan

The next step is to compare the estimator with the other Willapa moorings that
have simultaneous raw Signature and valid SBG bursts. This should be a
cross-mooring validation rather than adding those moorings to the existing
SWIFT25 calibration:

1. Inventory each mooring's overlapping Signature/SBG records, sample rate,
   burst duration, available Welch windows, and native SBG quality flags.
2. Apply the frozen SWIFT25 frequency transfer and tail scale to each other
   mooring without refitting. This is the primary test of whether the
   calibration transfers between instruments.
3. Separately fit a mooring-specific transfer and tail scale, using the same
   every-fifth-record calibration split. Comparing this result with the frozen
   SWIFT25 result will distinguish estimator error from instrument-specific
   calibration differences.
4. Report Hs correlation, median and mean bias, median absolute error, RMSE,
   Hs ratio, and frequency-resolved spectral bias over the same 0.05--2.5 Hz
   range. Also compare the 0.05--0.10 Hz variance fraction and fitted tail
   scale between moorings.
5. Plot time series, one-to-one Hs comparisons, and full-grid spectral
   differences for every mooring using common limits. Stratify results by
   wave height and record/window count so good aggregate statistics do not
   hide failures in short records or energetic events.
6. Keep production filling limited to SWIFT25 until the frozen calibration is
   shown to transfer. If it does not, retain deployment-specific calibration
   and document that requirement explicitly.
