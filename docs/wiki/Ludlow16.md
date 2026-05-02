# `Ludlow16`

**Source:** [`src/concentration/Ludlow16.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Ludlow16.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Ludlow et al. (2016) **analytic model**. Unlike fitting formulas, this model derives concentration from first principles using the Extended Press-Schechter (EPS) collapsed mass history (CMH) — no empirical calibration to a specific cosmology is needed for the functional form. A single calibration constant `C = 650` (from Ludlow+2016 eq. 12) links the model to simulations.

For a fast fitting formula from the same paper, see [`Ludlow16_fit`](Ludlow16_fit).

---

## Syntax

```matlab
[c, z_form] = Ludlow16(M, z_obs, cosmo)
[c, z_form] = Ludlow16(M, z_obs, cosmo, f)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z_obs` | scalar | — | Observation redshift |
| `cosmo` | struct | — | Cosmology struct (see required fields) |
| `f` | scalar | — | CMH progenitor fraction. Default: `0.02` (paper eq. 3) |

### Required `cosmo` fields

| Field | Description |
|---|---|
| `cosmo.sigmaM(M, z)` | RMS linear density fluctuation |
| `cosmo.growthFactor(z)` | Linear growth factor D(z), normalised so D(0)=1 |
| `cosmo.rho_crit0` | Critical density at z=0 |
| `cosmo.E(z)` | Dimensionless Hubble parameter E(z) = H(z)/H0 |

## Outputs

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |
| `z_form` | Formation redshift for each halo, same shape as `M` |

---

## How It Works

1. **CMH from EPS (Eq. 3):** Computes the collapsed mass history using the Gaussian CMH formula to find the formation redshift `z_f` at which a progenitor of mass `f*M` collapsed.
2. **Target density:** Sets the halo's characteristic density equal to `C * rho_crit(z_f)` where `C = 650`.
3. **Root-finding for c:** Solves the NFW mean enclosed density relation numerically using `fzero`:
   ```
   (200/3) * rho_crit(z_obs) * c^3 / f(c) = C * rho_crit(z_f)
   ```

---

## Parameter `f`

`f` is the progenitor mass fraction used in the CMH — it controls which progenitor defines the formation epoch. The paper default is `f = 0.02` (2% of the halo mass). Increasing `f` shifts `z_form` to lower redshifts (later formation → lower concentration).

---

## Example

```matlab
M = logspace(11, 15, 50);   % Msun/h
z = 0;

[c, z_form] = Ludlow16(M, z, cosmo);

figure;
subplot(1,2,1);
loglog(M, c, 'b-', 'LineWidth', 1.5);
xlabel('M [M_{sun}/h]'); ylabel('c'); title('Ludlow16 — Concentration');

subplot(1,2,2);
semilogx(M, z_form, 'r-', 'LineWidth', 1.5);
xlabel('M [M_{sun}/h]'); ylabel('z_{form}'); title('Formation Redshift');

% Effect of progenitor fraction f
figure; hold on;
for f_val = [0.005, 0.02, 0.05]
    [c_f, ~] = Ludlow16(M, z, cosmo, f_val);
    loglog(M, c_f, 'DisplayName', sprintf('f=%.3f', f_val), 'LineWidth', 1.5);
end
legend; xlabel('M [M_{sun}/h]'); ylabel('c'); title('Ludlow16 — Effect of f');
```

---

## Notes

- Returns `c = NaN` for halos where the root-finding bracket fails (extremely rare).
- Slower than fitting formulas due to the CMH root-finding loop over each halo — use [`Ludlow16_fit`](Ludlow16_fit) for large arrays when speed matters.
- The formation redshift `z_form` is a physically meaningful output — useful for studying assembly history.

---

## Reference

Ludlow, A. D. et al. (2016). *The mass-concentration-redshift relation of cold dark matter halos*. MNRAS, 460, 1214.
