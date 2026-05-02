# `Diemer15`

**Source:** [`src/concentration/Diemer15.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Diemer15.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Diemer & Kravtsov (2015) universal model. Unlike simple power-law fits, this model depends on both the peak height ν and the local slope of the linear matter power spectrum n_eff, making it valid across a wide range of cosmologies, masses, and redshifts without recalibration.

---

## Syntax

```matlab
c = Diemer15(M200c, z, cosmo)
c = Diemer15(M200c, z, cosmo, statistic)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M200c` | scalar or vector | `Msun/h` | Halo mass M_200c |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct with `cosmo.sigmaM`, `cosmo.neff` |
| `statistic` | string | — | `'median'` (default) or `'mean'` |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration c_200c, same shape as `M200c` |

---

## Model Formula (Eq. 9 of paper)

```
c = 0.5 * c_min * [ (nu/nu_min)^(-alpha) + (nu/nu_min)^beta ]
```

where the minimum concentration `c_min` and its location `nu_min` depend on the local power spectrum slope:

```
c_min  = phi0  + phi1  * n_eff
nu_min = eta0  + eta1  * n_eff
```

`n_eff` is evaluated at the Lagrangian radius scaled by `kappa`: `R = kappa * R_L(M)`.

---

## Statistics Options

| `statistic` | Description |
|---|---|
| `'median'` | Median concentration (default) |
| `'mean'` | Mean concentration (slightly higher) |

---

## Example

```matlab
M = logspace(11, 15, 100);   % Msun/h
z = 0;

c_med  = Diemer15(M, z, cosmo, 'median');
c_mean = Diemer15(M, z, cosmo, 'mean');

loglog(M, c_med, 'b-', M, c_mean, 'r--', 'LineWidth', 1.5);
legend('Median','Mean');
xlabel('M [M_{sun}/h]'); ylabel('c_{200c}');
title('Diemer & Kravtsov 2015 Concentration');
```

---

## Notes

- `cosmo.neff(M, z, kappa)` must be a valid function handle that returns the effective power-spectrum slope at the Lagrangian scale scaled by `kappa`.
- `nu` is floored at `0.1` internally to prevent divergence at very low peak heights.

---

## Reference

Diemer, B., & Kravtsov, A. V. (2015). *A Universal Model for Halo Concentrations*. ApJ, 799, 108.
