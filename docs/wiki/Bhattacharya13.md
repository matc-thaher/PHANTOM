# `Bhattacharya13`

**Source:** [`src/concentration/Bhattacharya13.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Bhattacharya13.m)  
**← Back to [Concentration](Concentration)**

---

Computes the halo concentration from the Bhattacharya et al. (2013) power-law model in peak-height space. Calibrated against WMAP7 N-body simulations for three overdensity definitions.

---

## Syntax

```matlab
c = Bhattacharya13(M, z, mdef, cosmo)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Redshift |
| `mdef` | string | — | Mass definition: `'200c'`, `'vir'`, or `'200m'` |
| `cosmo` | struct | — | Cosmology struct with `cosmo.sigmaM(M, z)` |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Model Formula

```
c = A * (1 + z)^B * nu^D
```

where `nu = delta_c / sigma(M, z)` is the peak height and `delta_c = 1.686`.

### Parameters by mass definition (Table 2 of paper)

| `mdef` | A | B | D |
|---|---|---|---|
| `'200c'` | 5.9 | −0.35 | −0.44 |
| `'vir'` | 6.6 | −0.26 | −0.45 |
| `'200m'` | 9.0 | −0.47 | −0.54 |

---

## Valid Range

- Mass: `2e12 < M < 2e15 Msun/h`
- Redshift: `0 < z < 2`
- Cosmology: WMAP7

---

## Example

```matlab
M     = logspace(12, 15, 100);   % Msun/h
z     = 0;

c_200c = Bhattacharya13(M, z, '200c', cosmo);
c_vir  = Bhattacharya13(M, z, 'vir',  cosmo);
c_200m = Bhattacharya13(M, z, '200m', cosmo);

loglog(M, c_200c, M, c_vir, M, c_200m, 'LineWidth', 1.5);
legend('200c','vir','200m');
xlabel('M [M_{sun}/h]'); ylabel('c');
title('Bhattacharya+2013 Concentration');
```

---

## Reference

Bhattacharya, S. et al. (2013). *Mass Function Predictions Beyond the Press-Schechter Formalism*. ApJ, 766, 32, Table 2.
