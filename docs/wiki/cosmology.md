# cosmology

`cosmology.m` — `src/utils/cosmology.m`

## Overview

`cosmology` is the primary entry point for constructing a cosmological model in PHANTOM. It returns a `cosmo` struct fully populated with input parameters, fixed physical constants, and a complete set of function handles for background expansion, power spectra, variance, growth, distances, and time calculations. Every downstream routine in PHANTOM consumes this struct.

```matlab
cosmo = cosmology()                    % defaults to Planck18
cosmo = cosmology('wmap9')
cosmo = cosmology('custom', user)      % pass your own struct
```

## Preset Cosmologies

The following named presets are available. Each stores five primary parameters: `Omega_m`, `Omega_b`, `h`, `ns`, `sigma8`.

| Name | `Omega_m` | `h` | `sigma8` | Notes |
|---|---|---|---|---|
| `Planck18` | 0.3111 | 0.6766 | 0.8102 | TT,TE,EE+lowE+lensing+BAO |
| `Planck18-only` | 0.3153 | 0.6736 | 0.8111 | CMB only |
| `Planck15` | 0.3089 | 0.6774 | 0.8159 | Identical to Uchuu |
| `Planck13` | 0.3071 | 0.6777 | 0.8288 | |
| `WMAP9` | 0.2865 | 0.6932 | 0.8200 | WMAP9+BAO |
| `WMAP7` | 0.2743 | 0.7020 | 0.8160 | |
| `WMAP5` | 0.2732 | 0.7050 | 0.8120 | |
| `WMAP3` | 0.2342 | 0.7350 | 0.7420 | |
| `WMAP1` | 0.2700 | 0.7200 | 0.9000 | |
| `Illustris` | 0.2726 | 0.7040 | 0.8090 | |
| `Bolshoi` | 0.2700 | 0.7000 | 0.8200 | |
| `Millenium` | 0.2500 | 0.7300 | 0.9000 | `ns=1` |
| `EdS` | 1.0000 | 0.7000 | 0.8200 | Einstein-de Sitter |
| `Planck-MDARK` | 0.3070 | 0.6780 | 0.8290 | MultiDark suite |
| `Uchuu` | 0.3089 | 0.6774 | 0.8159 | Same as Planck15 |

`Planck18` is the default when no argument is supplied.

## Custom Cosmology

Pass `name = 'custom'` and a `user` struct with the required fields:

```matlab
user.Omega_m = 0.30;
user.Omega_b = 0.045;
user.h       = 0.70;
user.ns      = 0.96;
user.sigma8  = 0.82;
cosmo = cosmology('custom', user);
```

You may supply `H0` in place of `h`; the function converts internally.

## Fixed Scalars Added

After the preset or custom block, `cosmology` sets:

| Field | Value | Description |
|---|---|---|
| `cosmo.Omega_L` | `1 - Omega_m` | Dark-energy density (flat ΛCDM default) |
| `cosmo.rho_crit0` | `2.775e11` | Critical density at z=0 in M☉ h² / Mpc³ |
| `cosmo.rho_m0` | `rho_crit0 × Omega_m` | Matter density at z=0 |

## Transfer Function Selection

The field `cosmo.transfer_model` controls which transfer function is assigned to `cosmo.T`. It is set to `'eh98'` by default if not provided.

| `transfer_model` | Function handle assigned | Extra required fields |
|---|---|---|
| `'eh98'` (default) | `T_EH98(k, cosmo)` | — |
| `'eh98_full'` | `T_EH98_full(k, cosmo)` | — |
| `'sugiyama95'` | `T_Sugiyama95(k, cosmo)` | — |
| `'viel05'` | `T_total_suppressed` using `T_EH98` × `T_wdm(...,'viel')` | `cosmo.m_wdm_keV` |
| `'bode01'` | `T_total_suppressed` using `T_EH98` × `T_wdm(...,'bode')` | `cosmo.m_wdm_keV` |
| `'schive25'` | `T_total_suppressed` using `T_EH98` × `T_Schive25` | `cosmo.m22` |
| `'camb'` | Interpolated table from `camb_power` | `cosmo.python_exe`, `cosmo.camb_transfer_file` |
| `'axioncamb'` | Interpolated table from `.dat` file | `cosmo.axioncamb_file` |

See [transfer_functions.md](transfer_functions.md) for full documentation of each model.

For WDM models (`viel05`, `bode01`), a base CDM transfer function is applied first. This base can be set via `cosmo.viel05_base` or `cosmo.bode01_base` (options: `'eh98'`, `'eh98_full'`, `'sugiyama95'`; default `'eh98'`). Similarly, `cosmo.schive25_base` controls the CDM baseline for `schive25`.

## Variance Filter Selection

The field `cosmo.variance_filter` sets the real-space smoothing window used in the variance integral \(\sigma^2(R, z)\). Default: `'tophat'`.

Supported filters: `'tophat'`, `'gaussian'`, `'sharpk'`, `'smoothk'`, `'vsmk'`.

For non-tophat filters, the mass-radius relation becomes \(M = (4\pi/3)\,\rho_m\,(c R)^3\) where the calibration constant `cosmo.filter_c` encodes the effective filter volume (default `c = 1`; typical values: 2.5–2.7 for sharp-k, 3.6 for vsmk).

See [variance.md](variance.md) for details.

## Execution Sequence

`cosmology` runs the following steps in order:

1. Set input parameters (preset or custom)
2. Handle `H0`/`h` conversion
3. Set `Omega_L`, `rho_crit0`, `rho_m0`
4. Validate `transfer_model` and `camb_transfer_file` if needed
5. Call [`attach_linear_components`](cosmology.md#attach_linear_components) → assigns `cosmo.T`, `cosmo.D`, `cosmo.Pk0`, `cosmo.Pk`, `cosmo.sigmaR`, `cosmo.sigmaM`
6. Set `cosmo.rhocrit` as a function handle
7. Call [`derive_cosmo_params`](cosmology.md#derive_cosmo_params) → assigns background functions, distances, and time handles
8. Attach `cosmo.delta_c` and `cosmo.nu` using `collapse_overdensity`

## Function Handles on the Returned Struct

After construction, the `cosmo` struct carries the following callable handles. All redshift arguments accept scalars or arrays.

### Power Spectrum and Transfer

| Handle | Signature | Description |
|---|---|---|
| `cosmo.T` | `T(k)` | Linear transfer function T(k); k in h/Mpc |
| `cosmo.Pk0` | `Pk0(k)` | Linear matter power spectrum at z=0; [(Mpc/h)³] |
| `cosmo.Pk` | `Pk(k, z)` | Linear matter power spectrum at redshift z |

### Growth

| Handle | Signature | Description |
|---|---|---|
| `cosmo.D` | `D(z)` | Linear growth factor, normalized D(0)=1 |

### Variance and Halo Mass

| Handle | Signature | Description |
|---|---|---|
| `cosmo.sigmaR` | `sigmaR(R, z)` | RMS variance σ(R, z); R in Mpc/h |
| `cosmo.sigmaM` | `sigmaM(M, z)` | RMS variance σ(M, z); M in M☉/h |
| `cosmo.R_of_M` | `R_of_M(M)` | Lagrangian radius from mass |
| `cosmo.neff` | `neff(M, z, kappa)` | Effective spectral index at scale M |
| `cosmo.alphaEff` | `alphaEff(z)` | Effective spectral amplitude for Ishiyama21 |

### Background Densities and Expansion

| Handle | Signature | Description |
|---|---|---|
| `cosmo.E` | `E(z)` | Dimensionless Hubble rate H(z)/H0 |
| `cosmo.Hz` | `Hz(z)` | Hubble parameter H(z) in km/s/Mpc |
| `cosmo.rhocrit` | `rhocrit(z)` | Critical density at z |
| `cosmo.rhom` | `rhom(z)` | Matter density at z |
| `cosmo.rhob` | `rhob(z)` | Baryon density at z |
| `cosmo.rhocdm` | `rhocdm(z)` | CDM density at z |
| `cosmo.rhoL` | `rhoL(z)` | Dark-energy density at z |

### Redshift-Dependent Density Parameters

| Handle | Description |
|---|---|
| `cosmo.Omega_m_z(z)` | Matter density parameter Ω_m(z) |
| `cosmo.Omega_b_z(z)` | Baryon density parameter |
| `cosmo.Omega_c_z(z)` | CDM density parameter |
| `cosmo.Omega_r_z(z)` | Radiation density parameter |
| `cosmo.Omega_L_z(z)` | Dark-energy density parameter |

### Distances (Mpc/h)

| Handle | Description |
|---|---|
| `cosmo.comovingDistance(z)` | Line-of-sight comoving distance |
| `cosmo.transverseComovingDistance(z)` | Transverse comoving distance |
| `cosmo.angularDiameterDistance(z)` | Angular-diameter distance |
| `cosmo.luminosityDistance(z)` | Luminosity distance |

### Time

| Handle | Description |
|---|---|
| `cosmo.age(z)` | Age of the universe at z [Gyr] |
| `cosmo.lookbackTime(z)` | Lookback time to z [Gyr] |
| `cosmo.time(z)` | Struct with `.age_Gyr`, `.lookback_Gyr`, `.t0_Gyr` |

See [time_calculations.md](time_calculations.md) and [distances.md](distances.md) for full documentation.

### Collapse and Peak Height

| Handle | Signature | Description |
|---|---|---|
| `cosmo.delta_c` | `delta_c(z)` | Linear collapse overdensity with Kitayama & Suto (1996) correction |
| `cosmo.nu` | `nu(M, z)` | Peak height ν = δ_c / σ(M, z) |
| `cosmo.correlationFunction` | `correlationFunction(R, z)` | Two-point correlation function |

## Related Pages

- [transfer_functions.md](transfer_functions.md)
- [variance.md](variance.md)
- [growth_factor.md](growth_factor.md)
- [time_calculations.md](time_calculations.md)
- [distances.md](distances.md)
- [collapse_and_thresholds.md](collapse_and_thresholds.md)
