# `Diemer19`

**Source:** [`src/concentration/Diemer19.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Diemer19.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Diemer & Joyce (2019) model. This model shares the same functional form as [`Ishiyama21`](Ishiyama21) but uses a different parameter table. It is the predecessor to Ishiyama21 and is based on an analytic framework linking concentration to peak height, the local power spectrum slope, and the growth rate of structure.

Optionally, a `profile_name` argument selects the halo density profile used in the \(G(c)\) relation and its inversion (default `'nfw'`); see `profile_mu.m` for the list of supported profiles.

---

## Syntax

```matlab
c = Diemer19(M, z, cosmo, mode, profile_name, method)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct with `cosmo.sigmaM`, `cosmo.neff`, `cosmo.alphaEff` |
| `mode` | string | — | Halo definition + sample (see table below) |
| `profile_name` | string | — | (Optional) Profile used in the \(G(c)\) relation; default `'nfw'`. See `profile_mu.m` for supported values. |
| `method` | string | — | (Optional) Solver method: `'fzero'` (direct root finding, default) or `'table'` (interpolation via `build_lhs_table`). |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Mode Options

| `mode` | Definition | Sample |
|---|---|---|
| `'200c_all'` | M_200c | All halos |
| `'200c_relaxed'` | M_200c | Relaxed halos |
| `'vir_all'` | M_vir | All halos |
| `'vir_relaxed'` | M_vir | Relaxed halos |

---

## Model Formula

```
c = C_eff * c_unnorm
```

Where `c_unnorm` is found by inverting:

```
G(c) = c / [ f(c) ]^((5 + n_eff)/6)  =  G_target
```

with seed:
```
x_c      = A_eff * (1 + nu^2 / B_eff) / nu
G_target = x_c / [ f(x_c) ]^((5 + n_eff)/6)
```

and growth correction:
```
C_eff = 1 - cAlpha * (1 - alpha_eff)
```

The root-finding uses an adaptive bracket + `fzero`.

---

## Example

```matlab
M = logspace(11, 15, 100);   % Msun/h
z = 0;

c_all  = Diemer19(M, z, cosmo, '200c_all', 'hernquist', 'fzero');
c_relx = Diemer19(M, z, cosmo, '200c_relaxed', 'nfw', 'table');

loglog(M, c_all, M, c_relx, 'LineWidth', 1.5);
legend('All halos','Relaxed halos');
xlabel('M [M_{sun}/h]'); ylabel('c');
title('Diemer & Joyce 2019 Concentration');
```

---

## Reference

Diemer, B., & Joyce, M. (2019). *An Accurate Physical Model for Halo Concentrations*. ApJ, 871, 168.
