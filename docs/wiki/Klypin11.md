# `Klypin11`

**Source:** [`src/concentration/Klypin11.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Klypin11.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Klypin, Trujillo-Gomez & Primack (2011) model. Supports both distinct halos (Eq. 12 with an upturn at high mass) and subhalos (simple power law). No cosmology struct is needed.

---

## Syntax

```matlab
c = Klypin11(M, z, sample)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo virial mass |
| `z` | scalar | — | Redshift |
| `sample` | string | — | `'distinct'` (default) or `'subhalo'` |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Model Formulas

**Distinct halos (Eq. 12):**
```
c = c0(z) * (M/1e12)^alpha * [1 + (M/M0(z))^beta]^-1
```

`c0(z)` is back-solved from the tabulated `c(1e12, z)` so the formula exactly reproduces Table 3 at the pivot mass. Parameters are log-linearly interpolated between tabulated redshift nodes.

**Subhalos (Eq. 11):**
```
c = c0_sub * (M / M_pivot)^alpha_sub
```

---

## Sample Options

| `sample` | Description | Formula |
|---|---|---|
| `'distinct'` | Field/distinct halos (default) | Eq. 12 — upturn at high mass |
| `'subhalo'` | Satellite/subhalos | Eq. 11 — simple power law |

---

## Example

```matlab
M = logspace(10, 15, 100);   % Msun/h

c_dist = Klypin11(M, 0, 'distinct');
c_sub  = Klypin11(M, 0, 'subhalo');

loglog(M, c_dist, M, c_sub, 'LineWidth', 1.5);
legend('Distinct halos','Subhalos');
xlabel('M [M_{sun}/h]'); ylabel('c_{vir}');
title('Klypin+2011 Concentration');
```

---

## Notes

- Redshift is clamped to the maximum tabulated value if `z` exceeds it — a warning is issued.
- No `cosmo` struct needed.
- The characteristic upturn at high mass (large `M/M0`) is a feature of the Bolshoi simulation cosmology and may not hold in other cosmologies.

---

## Reference

Klypin, A., Trujillo-Gomez, S., & Primack, J. (2011). *Dark Matter Halos in the Standard Cosmological Model*. ApJ, 740, 102.
