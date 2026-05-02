# `Dutton14`

**Source:** [`src/concentration/Dutton14.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Dutton14.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Dutton & Macciò (2014) power-law fit with redshift-dependent coefficients. Calibrated against relaxed halos in Planck 2013 cosmology simulations. No cosmology struct is needed — all parameters are built into the function.

---

## Syntax

```matlab
c = Dutton14(M, z, mdef)
c = Dutton14(M, z, mdef, M_pivot)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Redshift |
| `mdef` | string | — | Mass definition: `'200c'` (default) or `'vir'` |
| `M_pivot` | scalar | `Msun/h` | Pivot mass. Default: `1e12` (paper value). Override only if needed. |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Model Formulas (Eqs. 7, 10–13)

```
log10(c) = a(z) + b(z) * log10(M / M_pivot)
```

with redshift-dependent coefficients:

```
b(z) = b0 + b1 * z
a(z) = a0 + (a1 - a0) * exp(-eta * z^phi)
```

---

## Valid Range

- Mass: `M > 1e10 Msun/h`
- Redshift: `0 ≤ z ≤ 5`
- Cosmology: Planck 2013, **relaxed halos only**

---

## Example

```matlab
M = logspace(10, 15, 100);   % Msun/h

% Redshift evolution
for z = [0, 0.5, 1, 2]
    c = Dutton14(M, z, '200c');
    loglog(M, c, 'DisplayName', sprintf('z=%.1f', z), 'LineWidth', 1.5);
    hold on;
end
legend; xlabel('M [M_{sun}/h]'); ylabel('c_{200c}');
title('Dutton & Maccio 2014 — Redshift Evolution');

% Compare mass definitions at z=0
c_200c = Dutton14(M, 0, '200c');
c_vir  = Dutton14(M, 0, 'vir');
figure;
loglog(M, c_200c, M, c_vir, 'LineWidth', 1.5);
legend('200c','vir'); xlabel('M [M_{sun}/h]'); ylabel('c');
```

---

## Notes

- No `cosmo` struct needed — purely algebraic.
- Calibrated for **relaxed halos**. For all-halo samples, prefer [`Duffy08`](Duffy08) (`'full'` sample) or [`Ishiyama21`](Ishiyama21) (`'200c_all'` mode).
- The `M_pivot` default is fixed at `1e12 Msun/h` as in the paper. Override only when comparing to a custom calibration.

---

## Reference

Dutton, A. A., & Macciò, A. V. (2014). *Cold dark matter haloes in the Planck era*. MNRAS, 441, 3359, Eqs. (7)–(13).
