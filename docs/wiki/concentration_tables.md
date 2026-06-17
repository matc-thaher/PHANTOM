# Concentration-Mass Relation Tables

PHANTOM provides lookup table implementations for several published halo concentration-mass relations. These functions live in `src/utils` alongside the cosmology utilities and are used by the concentration module.

---

## Overview

All table functions follow the same calling pattern: they accept halo mass M, redshift z, and a cosmology struct, and return the median concentration \(c(M, z)\). Some also accept a mass definition string.

---

## Duffy08_Table

**File:** `Duffy08_Table.m`  
**Reference:** Duffy et al. (2008), MNRAS 390, L64

Power-law fit \(c = A (M/M_\mathrm{pivot})^B (1+z)^C\) for several mass definitions. Coefficients tabulated for NFW profiles in full, relaxed, and all-halo samples.

---

## Dutton14_Table

**File:** `Dutton14_Table.m`  
**Reference:** Dutton & Macciò (2014), MNRAS 441, 3359

Power-law fit calibrated on Planck cosmology N-body simulations. Provides median \(c_{200c}(M, z)\) using a log-linear fitting form.

---

## Klypin11_Table

**File:** `Klypin11_Table.m`  
**Reference:** Klypin et al. (2011), ApJ 740, 102

Concentration table from the Bolshoi simulation. Calibrated for \(M_{200c}\) and \(M_\mathrm{vir}\) at \(z = 0\).

---

## Klypin16_Table

**File:** `Klypin16_Table.m`  
**Reference:** Klypin et al. (2016), MNRAS 457, 4340

MultiDark simulation concentration fits covering a wide mass range at multiple redshifts. Provides separate fits for `200c` and `vir` mass definitions.

---

## Diemer15_Table

**File:** `Diemer15_Table.m`  
**Reference:** Diemer & Kravtsov (2015), ApJ 799, 108

Concentration model based on the peak curvature of the linear power spectrum. Returns \(c(M, z)\) using the local power spectrum slope.

---

## Diemer19_Table

**File:** `Diemer19_Table.m`  
**Reference:** Diemer & Joyce (2019), ApJ 871, 168

Updated universal concentration model with improved fitting at high masses and high redshifts.

---

## Ishiyama21_Table

**File:** `Ishiyama21_Table.m`  
**Reference:** Ishiyama et al. (2021), MNRAS 506, 4210

Concentration-mass relation from the Uchuu simulation. The largest cosmological N-body simulation to date at time of publication. Uses `neff` and `alphaEff` spectral index quantities computed from `cosmo.neff` and `cosmo.alphaEff`.

---

## Ludlow16 Suite

**Files:** `Ludlow16_concentration.m`, `Ludlow16_CMH.m`, `Ludlow16_formation_z.m`, `Ludlow16_rho_char.m`  
**Reference:** Ludlow et al. (2016), MNRAS 460, 1214

The Ludlow model derives concentration from the characteristic density of the NFW profile, linking it to the mass accretion history (MAH). The suite comprises:

| File | Role |
|---|---|
| `Ludlow16_concentration.m` | Top-level: returns \(c(M, z)\) |
| `Ludlow16_CMH.m` | Computes the cumulative mass history |
| `Ludlow16_formation_z.m` | Finds the formation redshift \(z_f\) |
| `Ludlow16_rho_char.m` | Computes characteristic density \(\rho_s\) |

This is a physics-based model requiring the full power spectrum and growth factor, not just a parameter fit. It calls `cosmo.sigmaM` and `cosmo.D` internally.

---

## Child18 Suite

**Files:** `Child18_Mstar.m`, `Child18_table.m`  
**Reference:** Child et al. (2018), ApJ 859, 55

Provides concentration fits from hydrodynamical simulations including baryonic effects. `Child18_Mstar.m` computes the characteristic stellar mass for normalization, and `Child18_table.m` returns the concentration table.

---

## COLOSSUS Bridge

**Files:** `colossus_bridge.py`, `colossus_query.m`

Provides a MATLAB interface to the Python [COLOSSUS](https://bdiemer.bitbucket.io/colossus/) package (Diemer 2018) for concentration models not natively implemented in PHANTOM.

- `colossus_bridge.py` — Python-side script called via `pyrun`
- `colossus_query.m` — MATLAB wrapper that passes cosmology parameters and returns concentration values

Requires a working Python installation with `colossus` installed.

---

## change_mass_definition

**File:** `change_mass_definition.m`

Converts halo mass and radius between different overdensity definitions (e.g., \(M_{200c}\) to \(M_{500c}\)) assuming an NFW profile. Uses `parse_mass_definition` to interpret the mass definition string and iterates on the NFW concentration to find the consistent solution.

```matlab
[M_new, R_new, c_new] = change_mass_definition(M, c, z, mdef_in, mdef_out, cosmo)
```

---

## Supporting Utilities

| File | Description |
|---|---|
| `parse_mass_definition.m` | Splits `'200c'` → type `'c'`, delta `200` |
| `overdensity_to_mean.m` | Converts overdensity relative to critical to mean |
| `radius_from_mass.m` | Computes halo radius from mass and overdensity threshold |
| `einasto_mass_ratio.m` | Mass ratio for Einasto vs NFW profiles |
| `profile_mu.m` | Einasto profile shape function \(\mu\) |
| `U_mu.m` | Fourier transform of Einasto profile |
| `lhs_profile.m` | LHS profile for sampling |
| `build_lhs_table.m` | Builds Latin Hypercube Sampling table |

---

## Related Pages

- [cosmology.md](cosmology.md)
- [variance.md](variance.md)
- [collapse_and_thresholds.md](collapse_and_thresholds.md)
