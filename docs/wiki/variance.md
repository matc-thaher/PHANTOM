# Variance

The matter variance \(\sigma^2(R, z)\) is central to the Press-Schechter mass function, peak-height calculations, and halo concentration models in PHANTOM. The relevant files are `sigma_R.m`, `sigma_R2_given_Pk.m`, `variance_window.m`, and `normalize_A_to_sigma8.m`.

---

## sigma_R — RMS Variance σ(R, z)

**File:** `sigma_R.m`

Computes the RMS linear density variance smoothed on scale R at redshift z:

\[
\sigma(R, z) = \sqrt{\sigma^2(R, z)}
\]

```matlab
s = sigma_R(R, z, cosmo)
s = sigma_R(R, z, cosmo, filter_name)
```

- `R` : smoothing scale [Mpc/h], scalar or vector
- `z` : redshift, scalar
- `filter_name` : optional; overrides `cosmo.variance_filter`

This function delegates to `sigma_R2_given_Pk` using `cosmo.Pk0` as the power spectrum handle.

After `cosmology()` is called, the handle `cosmo.sigmaR(R, z)` wraps this function directly. Similarly, `cosmo.sigmaM(M, z)` first converts mass to radius via `cosmo.R_of_M(M)` and then calls `cosmo.sigmaR`.

---

## sigma_R2_given_Pk — Core Variance Integral

**File:** `sigma_R2_given_Pk.m`

Evaluates the variance integral for an arbitrary power spectrum handle:

\[
\sigma^2(R, z) = \frac{D(z)^2}{D(0)^2} \frac{1}{2\pi^2} \int_0^\infty P_0(k)\, W^2(kR)\, k^3 \, \mathrm{d}\ln k
\]

where \(W(kR)\) is the Fourier-space window function corresponding to the chosen filter.

The integral is evaluated on a fixed log-k grid of 1024 points using the trapezoidal rule. This vectorised approach evaluates all R values simultaneously via matrix broadcasting \([N_k \times N_R]\), giving a significant speed gain over per-R scalar integration.

**Integration limits:**
- For `eh98`, `sugiyama95`, `viel05`, `bode01`, `schive25`: `k` ∈ [10⁻⁶, 10⁴] h/Mpc
- For `camb`: bounded to the tabulated k range from `cosmo.k_camb`
- For `axioncamb`: bounded to the tabulated k range from `cosmo.k_axioncamb`

```matlab
s2 = sigma_R2_given_Pk(R, z, cosmo, Pk_handle, filter_name)
```

---

## variance_window — Fourier Window Functions

**File:** `variance_window.m`

Returns the Fourier-space window function \(W(kR)\) for the variance integral. Five filter types are implemented.

```matlab
W = variance_window(kR, filter_name)
W = variance_window(kR, filter_name, filter_params)
```

### Filter Definitions

| Filter | \(W(kR)\) | Reference |
|---|---|---|
| `tophat` | \(\frac{3[\sin(kR) - kR\cos(kR)]}{(kR)^3}\) | Standard |
| `gaussian` | \(\exp[-(kR)^2/2]\) | Standard |
| `sharpk` | \(\Theta(1 - kR)\) (Heaviside step) | Bond (1991), Diemer (2018) |
| `smoothk` | \([1 + (kR)^\beta]^{-1}\) | Leo et al. (2018), JCAP 2018 |
| `vsmk` | Variable-slope smooth-k (see below) | Ruderman et al. (2026) |

### Variable Smooth-k (vsmk)

The `vsmk` filter from Ruderman et al. (2026) uses a variable slope that transitions between \(\beta_1\) (small k) and \(\beta_2\) (large k):

\[
W_\mathrm{vsmk}(kR) = \left[1 + (kR)^{\beta(kR)}\right]^{-1}
\]

where the local slope \(\beta(kR)\) transitions smoothly near \(kR = \mu\). Default parameters calibrated for FDM:

| Parameter | Default | Description |
|---|---|---|
| `beta1` | 4.8 | Low-k slope |
| `beta2` | 3.6 | High-k slope |
| `mu` | 2.1 | Transition scale |
| `delta` | 12 | Transition sharpness |

These can be overridden by passing a `filter_params` struct.

### Mass-Radius Calibration Constant

The calibration constant `cosmo.filter_c` enters **only** the mass-radius relation, not the window function itself:

\[
M = \frac{4\pi}{3}\,\rho_m\,(c\,R)^3 \implies R = \frac{1}{c}\left(\frac{3M}{4\pi\,\rho_m}\right)^{1/3}
\]

Recommended values from the literature:

| Filter | `filter_c` | Source |
|---|---|---|
| `tophat` | 1.0 | — |
| `gaussian` | 1.0 | — |
| `sharpk` | 2.5–2.7 | Leo et al. (2018), Ruderman et al. (2026) |
| `smoothk` | 3.0–3.7 | Leo et al. (2018) |
| `vsmk` | 3.6 | Ruderman et al. (2026) |

---

## normalize_A_to_sigma8 — Power Spectrum Normalization

**File:** `normalize_A_to_sigma8.m`

Computes the amplitude A such that \(\sigma(8\,h^{-1}\,\mathrm{Mpc},\,0) = \sigma_8\):

\[
A = \left(\frac{\sigma_8}{\sigma_\mathrm{unit}(R=8)}\right)^2
\]

where \(\sigma_\mathrm{unit}^2\) is computed from the unnormalized power spectrum \(P_\mathrm{unnorm}(k) = k^{n_s} T(k)^2\).

This is called automatically inside `attach_linear_components` for all analytic transfer function models. For `camb` and `axioncamb`, the raw tabulated spectrum is used directly without re-normalization.

```matlab
A = normalize_A_to_sigma8(cosmo)
```

---

## sigmaM_WDM — WDM Mass Variance

**File:** `sigmaM_WDM.m`

Computes \(\sigma(M)\) for a WDM cosmology. Used in halo mass function calculations involving sharp-k filtered WDM spectra. Internally calls `sigma_R2_given_Pk` with the WDM power spectrum.

---

## Example

```matlab
cosmo = cosmology('Planck18');

% variance at 8 Mpc/h (should recover sigma8)
s8 = cosmo.sigmaR(8.0, 0)

% variance as a function of halo mass at z=1
M  = logspace(8, 15, 100);
sM = cosmo.sigmaM(M, 1.0);

% peak height
nu = cosmo.delta_c(1.0) ./ sM;
```

---

## Related Pages

- [cosmology.md](cosmology.md)
- [transfer_functions.md](transfer_functions.md)
- [growth_factor.md](growth_factor.md)
- [collapse_and_thresholds.md](collapse_and_thresholds.md)
