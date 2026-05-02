# `Ludlow16_fit`

**Source:** [`src/concentration/Ludlow16_fit.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Ludlow16_fit.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration using the **Appendix C fitting formula** from Ludlow et al. (2016) — a fast broken power-law in peak height. This is the algebraic counterpart to the physically motivated [`Ludlow16`](Ludlow16) analytic model. Use this when speed matters and the full CMH calculation is unnecessary.

---

## Syntax

```matlab
c = Ludlow16_fit(M, z, cosmo)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct with `cosmo.sigmaM(M, z)` and `cosmo.D(z)` |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Model Formula (Eqs. C1–C6)

```
c = c0 * x^(-gamma1) / [1 + x^(1/mu)]^(mu*(gamma1 - gamma2))
```

where `x = nu / nu0` and all parameters depend on redshift:

```
c0     = 3.395 * (1+z)^(-0.215)               % Eq. C2
nu0    = 0.307 * (1+z)^( 0.540)               % Eq. C3
gamma1 = 0.628 * (1+z)^(-0.047)               % Eq. C4
gamma2 = 0.317 * (1+z)^(-0.893)               % Eq. C5
mu     = f(a, D(z))                            % Eq. C6 — growth-dependent
```

`nu = delta_c / sigma(M, z)` is the standard peak height.

---

## Valid Range

- Mass: `−8 ≤ log10(M / [h⁻¹ Msun]) ≤ 16.5`
- Redshift: `0 ≤ z ≤ 1` (1+z ≤ 2)
- Cosmology: Planck (Table 2 of paper)

---

## Example

```matlab
M = logspace(10, 15, 100);   % Msun/h

% Compare analytic model vs. fitting formula at z=0
[c_analytic, ~] = Ludlow16(M, 0, cosmo);
c_fit           = Ludlow16_fit(M, 0, cosmo);

loglog(M, c_analytic, 'b-', M, c_fit, 'r--', 'LineWidth', 1.5);
legend('Ludlow16 (analytic)','Ludlow16\_fit (formula)');
xlabel('M [M_{sun}/h]'); ylabel('c');
title('Ludlow+2016: Analytic vs. Fitting Formula');

% Redshift evolution with the fitting formula
figure; hold on;
for z = [0, 0.5, 1]
    c = Ludlow16_fit(M, z, cosmo);
    loglog(M, c, 'DisplayName', sprintf('z=%.1f', z), 'LineWidth', 1.5);
end
legend; xlabel('M [M_{sun}/h]'); ylabel('c');
title('Ludlow16\_fit — Redshift Evolution');
```

---

## Notes

- Much faster than [`Ludlow16`](Ludlow16) since it is purely algebraic — no root-finding or CMH integration.
- Accuracy degrades slightly at `z > 1` relative to the analytic model.
- Requires `cosmo.D(z)` (linear growth factor) in addition to `cosmo.sigmaM`.

---

## Reference

Ludlow, A. D. et al. (2016). *The mass-concentration-redshift relation of cold dark matter halos*. MNRAS, 460, 1214, Appendix C, Eqs. C1–C6.
