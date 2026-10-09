# SWIFT25 Signature-accelerometer wave recovery

This branch contains a recovery of scalar wave energy for missing or invalid
SWIFT25 SBG records, including the 20--21 June 2025 outage. It is independent
of any L2 feed-forward fallback.

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

The MATLAB review was run against the mounted SWIFT25 archive after a
non-writing run of the canonical `reprocess_SBG` step. The 916-record
holdout results for the calibrated 0.10--0.50 Hz band are:

- Hs correlation: 0.920;
- Hs median bias: -0.0027 m;
- Hs mean bias: -0.0014 m;
- Hs median absolute error: 0.0077 m; and
- Hs RMSE: 0.0155 m.

The Hs ratio is 0.947 at the median but 1.044 at the mean. Thus, the method
is not uniformly high; a positive tail raises the mean. Across individual
holdout spectral values in the recovery band, the median Signature-minus-SBG
difference is -0.12 dB and the interquartile range is -1.86 to +1.97 dB.
The median bias of each frequency bin ranges from -0.55 to +0.37 dB, while
episodic positive differences reach +8.0 dB at the 95th percentile. This
supports event-level contamination QC rather than a uniform amplitude
rescaling.

The calibration uses 245 records; 230 valid SBG/Signature ratios are
available in each recovered frequency bin after file and spectral QC.

The integrated run recovers 302 existing SWIFT records: all 300 records with
no raw SBG file, one record with too little usable SBG data, and the anomalous
23 June SBG wave record. This includes all 269 L2 records in the continuous
20--21 June SBG outage. Of the recovered Signature spectra, 295 use four
overlapping Welch windows (nominal DOF 8), two use three windows (DOF 6),
four use two windows (DOF 4), and one uses one window (DOF 2). Two records
with empty raw SBG streams on 26 and 27 June have no Signature file and
remain missing. Expected time slots absent from L2 are reported by the SBG
audit but cannot be inserted without a vetted SWIFT record.

## Limitations

- Results are scalar and band limited, not complete wave products.
- Directional moments cannot be recovered from this method.
- Energy below 0.10 Hz remains missing.
- The low-frequency correction is empirical and SWIFT25-specific.
- Recovered `sigwaveheight` is the 0.10--0.50 Hz band Hs, not full-band Hs.
- Two raw-empty SBG records have no Signature file and remain unrecoverable;
  slots absent from L2 cannot be synthesized by this fallback.

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
[metrics,figures,diagnostics] = review_SIGheave(missiondir, ...
    plot_dir="signature_heave_review");
```

The review writes `SWIFT25_signature_heave_validation.png`,
`SWIFT25_signature_heave_effect.png`,
`SWIFT25_signature_heave_spectral_difference.png`, and the non-writing SBG
processing report into `plot_dir`. The effect plot uses shared time limits,
leaves missing spectra blank, and explicitly labels the off-scale 23 June
SBG outlier before showing its Signature replacement. The spectral-difference
plot uses discrete, non-overlapping cells over the complete 0.0098--0.994 Hz
SWIFT grid. Its full-grid Signature calibration is diagnostic only; dashed
lines mark the 0.10--0.50 Hz band retained by production recovery.

`Process_WillapaMoored.m` runs the fallback for SWIFT25 after normal L3/SBG
processing so valid SBG records are available for calibration and only
missing primary wave records are filled.

To write the recovered records to the mission L3 product:

```matlab
[SWIFT,sinfo,diagnostics] = reprocess_SIGheave(missiondir);
```

All processing and review code on this branch is MATLAB. The validation
statistics above come from the complete MATLAB path on the mounted archive.
The MATLAB Welch calculation was also checked against the independently
validated spectrum to machine precision.
