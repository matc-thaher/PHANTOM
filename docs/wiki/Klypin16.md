# `Klypin16`

**Source:** [`src/concentration/Klypin16.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Klypin16.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Klypin et al. (2016) model, which provides two distinct fitting formulas from Appendix A: a mass-based formula (`cM`) and a peak-height / sigma-based formula (`cnu`). Supports two cosmologies (Planck13 and Bolshoi) and two mass definitions (200c and vir).

---

## Syntax

```matlab
[c, valid] = Klypin16(M, z, cosmo, cosmo_name, mdef, formula)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct (only needed for `formula='cnu'`; needs `cosmo.sigmaM`) |
| `cosmo_name` | string | — | `'planck13'` or `'bolshoi'` |
| `mdef` | string | — | `'200c'` or `'vir'` |
| `formula` | string | — | `'cM'` (mass-based) or `'cnu'` (sigma-based) |

## Outputs

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |
| `valid` | Logical mask — `true` where `M > 1e10 Msun/h` AND `z ≤ z_max` |

---

## Formulas

### `formula = 'cM'` — Eq. (A1), mass-based
```
c(M, z) = C0(z) * (M/1e12)^(-gamma(z)) * [1 + (M/M0(z))^0.4]
```
Parameters `C0`, `gamma`, `M0` are linearly interpolated from Tables A1–A4.

### `formula = 'cnu'` — Eq. (A5), sigma-based
```
c(sigma) = b0(z) * [1 + 7.37*(sigma/a0(z))^0.75] * [1 + 0.14*(sigma/a0(z))^(-2)]
```
Parameters `a0`, `b0` are interpolated from Tables A5–A8. Requires `cosmo.sigmaM`.

---

## Mode Options (via `c_CDM`)

When called through [`c_CDM`](c_CDM), the mode string encodes all options:

| Mode string | cosmo_name | mdef | formula |
|---|---|---|---|
| `'planck13_200c_cM'` | planck13 | 200c | cM |
| `'planck13_200c_cnu'` | planck13 | 200c | cnu |
| `'planck13_vir_cM'` | planck13 | vir | cM |
| `'planck13_vir_cnu'` | planck13 | vir | cnu |
| `'bolshoi_200c_cM'` | bolshoi | 200c | cM |
| `'bolshoi_vir_cnu'` | bolshoi | vir | cnu |

---

## Example

```matlab
M = logspace(10, 15, 100);   % Msun/h
z = 0;

% Mass-based formula, Planck13
[c_cM, valid]  = Klypin16(M, z, cosmo, 'planck13', '200c', 'cM');

% Sigma-based formula, Planck13
[c_cnu, ~] = Klypin16(M, z, cosmo, 'planck13', '200c', 'cnu');

loglog(M(valid), c_cM(valid), M(valid), c_cnu(valid), 'LineWidth', 1.5);
legend('cM formula','c-nu formula');
xlabel('M [M_{sun}/h]'); ylabel('c_{200c}');
title('Klypin+2016 Concentration');
```

---

## Notes

- Always check the `valid` output mask — results outside the calibrated range (`M < 1e10` or `z > z_max`) are extrapolated and should be used with caution.
- `formula = 'cM'` does not require `cosmo` — the `cosmo` argument is accepted but ignored.
- `formula = 'cnu'` requires `cosmo.sigmaM(M, z)`.

---

## Reference

Klypin, A. et al. (2016). *MultiDark simulations: the story of dark matter halo concentrations and abundance*. MNRAS, 457, 4340.
