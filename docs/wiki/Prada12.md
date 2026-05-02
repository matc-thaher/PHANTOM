# `Prada12`

**Source:** [`src/concentration/Prada12.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Prada12.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Prada et al. (2012) model. This model introduces cosmology dependence through the parameter `x = (Omega_L/Omega_m)^(1/3) * a`, which captures the transition from matter to dark energy domination and produces a characteristic upturn in the c-M relation at high masses and low redshifts.

---

## Syntax

```matlab
c = Prada12(M200c, z, cosmo)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M200c` | scalar or vector | `Msun/h` | Halo mass M_200c |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct with `cosmo.Omega_m`, `cosmo.Omega_L`, `cosmo.sigmaM(M, z)` |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration c_200c, same shape as `M200c` |

---

## Model Formula (Eqs. 12–22)

The model follows seven steps:

**1. Cosmological parameter x (Eq. 13):**
```
x = (Omega_L / Omega_m)^(1/3) * a         % a = 1/(1+z)
```

**2. c_min(x) and sigma_min_inv(x) (Eqs. 19–20):**
```
c_min(x)       = c0  + (c1 - c0)  * [arctan(alpha*(x - x0_c))/pi + 0.5]
sigma_min_inv(x) = s0 + (s1 - s0) * [arctan(beta*(x  - x1))/pi   + 0.5]
```

**3. Normalisation factors B0, B1 (Eq. 18):**  
Ratio of `c_min` and `sigma_min_inv` at redshift z to their values at z=0 for the input cosmology.

**4. Rescaled sigma (Eq. 15):**
```
sigma' = B1 * sigma(M, z)
```

**5. C(sigma') (Eqs. 16–17):**
```
C(sigma') = A * [(sigma'/b)^c_p + 1] * exp(d / sigma'^2)
```

**6. Final concentration (Eq. 14):**
```
c = B0 * C(sigma')
```

The characteristic upturn at high mass / low z arises from `c_min(x)` peaking near `x ~ 0.5` (the matter-to-DE transition).

---

## Example

```matlab
M = logspace(11, 15, 100);   % Msun/h

c_z0  = Prada12(M, 0,   cosmo);
c_z05 = Prada12(M, 0.5, cosmo);
c_z1  = Prada12(M, 1.0, cosmo);

loglog(M, c_z0, M, c_z05, M, c_z1, 'LineWidth', 1.5);
legend('z=0','z=0.5','z=1');
xlabel('M_{200c} [M_{sun}/h]'); ylabel('c_{200c}');
title('Prada+2012 Concentration');
```

---

## Notes

- The upturn at high mass (c increasing with M at large M) is a distinctive feature of this model — it is physical in origin (dark energy upturn) but may be stronger than seen in some simulations.
- Calibrated against the Bolshoi and MultiDark simulations.
- Normalised at z=0 of the **input** cosmology, not Bolshoi's specific parameters, so `B0 = B1 = 1` at z=0 by construction for any cosmology.

---

## Reference

Prada, F. et al. (2012). *Halo concentrations in the standard ΛCDM cosmology*. MNRAS, 423, 3018, Eqs. (12)–(22).
