# `Bullock01`

**Source:** [`src/concentration/Bullock01.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Bullock01.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Bullock et al. (2001) collapse-redshift model. The model links concentration to the redshift at which a progenitor of mass `F*M` first collapsed, making it physically motivated rather than a pure fitting formula.

---

## Syntax

```matlab
c = Bullock01(M, z, cosmo)
c = Bullock01(M, z, cosmo, K, F)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Observation redshift |
| `cosmo` | struct | — | Cosmology struct with `cosmo.sigmaM(M,z)` and `cosmo.D(z)` |
| `K` | scalar | — | Proportionality constant. Default: `2.9` |
| `F` | scalar | — | Collapse mass fraction. Default: `0.001` |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Model Formula

```
c = K * (1 + z_coll) / (1 + z)
```

where `z_coll` is the redshift at which `sigma(F*M, z_coll) = delta_c` — i.e., the collapse redshift of a progenitor of mass `F*M`.

---

## Parameter Options

| Calibration | K | F |
|---|---|---|
| Default (WMAP-era, Colossus) | 2.9 | 0.001 |
| Original Bullock+01 (σ8=1.0) | 4.0 | 0.01 |
| Johnston et al. 2007 (SDSS) | 2.9 | 0.001 |

The original `K=4, F=0.01` values were calibrated to high-σ8 simulations. The default `K=2.9, F=0.001` better reproduces concentrations for lower-σ8 WMAP-era cosmologies.

---

## How It Works

1. For each halo mass `M(i)`, computes the progenitor mass `M_prog = F * M(i)`.
2. Finds `sigma(M_prog, z=0)` from `cosmo.sigmaM`.
3. Solves for `z_coll` where `D(z_coll)/D(0) * sigma0 = delta_c` using `fzero`.
4. If `sigma0 <= delta_c` (halo not yet collapsed), sets `z_coll = 0`.
5. Returns `c = K * (1 + z_coll) / (1 + z)`.

---

## Example

```matlab
M = logspace(11, 15, 100);   % Msun/h
z = 0;

% Default parameters
c_default = Bullock01(M, z, cosmo);

% Original B01 parameters
c_orig = Bullock01(M, z, cosmo, 4.0, 0.01);

loglog(M, c_default, M, c_orig, 'LineWidth', 1.5);
legend('K=2.9, F=0.001 (default)', 'K=4.0, F=0.01 (original)');
xlabel('M [M_{sun}/h]'); ylabel('c');
title('Bullock+2001 Concentration');
```

---

## Notes

- Uses `fzero` internally — can be slow for large mass arrays since it loops over each halo.
- For very massive halos where `sigma0 <= delta_c`, `z_coll = 0` is returned, giving `c = K / (1+z)`.

---

## Reference

Bullock, J. S. et al. (2001). *Profiles of dark haloes: evolution, scatter and environment*. MNRAS, 321, 559.
