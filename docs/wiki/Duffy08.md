# `Duffy08`

**Source:** [`src/concentration/Duffy08.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Duffy08.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Duffy et al. (2008) power-law fit. This is one of the most widely used concentration models — simple, fast, requires no cosmology struct, and covers NFW and Einasto profiles for both full and relaxed halo samples. Calibrated against WMAP5 simulations.

---

## Syntax

```matlab
c = Duffy08(M, z, mdef)
c = Duffy08(M, z, mdef, profile)
c = Duffy08(M, z, mdef, profile, sample)
c = Duffy08(M, z, mdef, profile, sample, redshift_range)
c = Duffy08(M, z, mdef, profile, sample, redshift_range, M_pivot)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Redshift |
| `mdef` | string | — | Mass definition: `'200c'`, `'vir'`, or `'200m'` |
| `profile` | string | — | Profile type: `'NFW'` (default) or `'Einasto'` |
| `sample` | string | — | Halo sample: `'full'` (default) or `'relaxed'` |
| `redshift_range` | string | — | `'z0_2'` (default, 0≤z≤2) or `'z0'` (z=0 only) |
| `M_pivot` | scalar | `Msun/h` | Pivot mass. Default: `2e12` |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Model Formula (Eq. 4 of paper)

```
c = A * (M / M_pivot)^B * (1 + z)^C
```

Parameters A, B, C are loaded from Table 1 of Duffy+08 based on the combination of `mdef`, `profile`, `sample`, and `redshift_range`.

---

## All Mode Options

The mode string in `c_CDM` is formatted as `'mdef_profile_sample_zrange'`:

| mdef | profile | sample | redshift_range | Example mode string |
|---|---|---|---|---|
| `200c` | `NFW` | `full` | `z0_2` | `'200c_NFW_full_z0_2'` (default) |
| `200c` | `NFW` | `relaxed` | `z0_2` | `'200c_NFW_relaxed_z0_2'` |
| `200c` | `NFW` | `full` | `z0` | `'200c_NFW_full_z0'` |
| `vir` | `NFW` | `full` | `z0_2` | `'vir_NFW_full_z0_2'` |
| `200m` | `Einasto` | `relaxed` | `z0_2` | `'200m_Einasto_relaxed_z0_2'` |

---

## Valid Range

- Mass: `1e11 < M < 1e15 Msun/h`
- Redshift: `0 < z < 2`
- Cosmology: WMAP5 `(Ωm, Ωb, ΩΛ, h, σ8, ns) = (0.258, 0.0441, 0.742, 0.719, 0.796, 0.963)`

---

## Example

```matlab
M = logspace(11, 15, 100);   % Msun/h
z = 0.5;

% Defaults: 200c, NFW, full sample, z0_2 range
c_def  = Duffy08(M, z, '200c');

% Relaxed halos
c_relx = Duffy08(M, z, '200c', 'NFW', 'relaxed', 'z0_2');

% Virial mass definition
c_vir  = Duffy08(M, z, 'vir');

loglog(M, c_def, M, c_relx, M, c_vir, 'LineWidth', 1.5);
legend('200c full','200c relaxed','vir full');
xlabel('M [M_{sun}/h]'); ylabel('c');
title('Duffy+2008 Concentration at z=0.5');
```

---

## Notes

- No `cosmo` struct is needed — all parameters are hardcoded from Table 1 of the paper.
- The function is the fastest model in PHANTOM since it is purely algebraic.
- For cosmologies significantly different from WMAP5, consider using [`Ishiyama21`](Ishiyama21) or [`Diemer19`](Diemer19) instead.

---

## Reference

Duffy, A. R. et al. (2008). *Dark matter halo concentrations in the Wilkinson Microwave Anisotropy Probe year 5 cosmology*. MNRAS, 390, L64.
