# `Child18`

**Source:** [`src/concentration/Child18.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Child18.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Child et al. (2018) model, which uses a smooth broken power-law in mass relative to the nonlinear mass scale M*(z). The model supports four fitting types covering different halo samples and profile fitting methods, calibrated against the Q Continuum and Outer Rim simulations (WMAP-7 cosmology).

---

## Syntax

```matlab
[c, Mstar] = Child18(M, z, cosmo)
[c, Mstar] = Child18(M, z, cosmo, fit_type)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass M_200c |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct with `cosmo.sigmaM(M, z)` |
| `fit_type` | string | — | Fitting sample (see table below). Default: `'individual_all'` |

## Outputs

| Parameter | Description |
|---|---|
| `c` | Concentration c_200c, same shape as `M` |
| `Mstar` | Nonlinear mass scale M*(z) in `Msun/h` |

---

## Fit Types (Table 1 of paper)

| `fit_type` | Description |
|---|---|
| `'individual_all'` | All halos, individual NFW fits (default) |
| `'individual_relaxed'` | Dynamically relaxed halos only |
| `'stack_nfw'` | Stacked NFW profile fits |
| `'stack_einasto'` | Stacked Einasto profile fits |

---

## Model Formula

```
c = A * (M/M*)^b / [1 + (M/M_T)^(-b)] + c0
```

where `M_T = m * M*` is the transition mass and M*(z) is the nonlinear mass scale where `sigma(M*, z) = delta_c = 1.686`.

**Behaviour:**
- `M << M_T`: power-law regime, `c` rises with decreasing mass
- `M >> M_T`: plateau regime, `c → c0`

---

## Valid Range

- Redshift: `0 ≤ z ≤ 4`
- Mass: fitted over ~8 decades in M/M*
- Cosmology: WMAP-7

---

## Example

```matlab
M = logspace(10, 15, 100);   % Msun/h
z = 0;

[c_all,  Mstar] = Child18(M, z, cosmo, 'individual_all');
[c_relx, ~]     = Child18(M, z, cosmo, 'individual_relaxed');
[c_nfw,  ~]     = Child18(M, z, cosmo, 'stack_nfw');

loglog(M, c_all, M, c_relx, M, c_nfw, 'LineWidth', 1.5);
xline(Mstar, 'k--', 'M*');
legend('All','Relaxed','Stack NFW');
xlabel('M [M_{sun}/h]'); ylabel('c_{200c}');
title('Child+2018 Concentration');
```

---

## Reference

Child, H. L. et al. (2018). *Halo Concentration and the Dark Matter Power Spectrum*. ApJ, 859, 55. https://doi.org/10.3847/1538-4357/aabf95
