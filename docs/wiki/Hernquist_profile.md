# `Hernquist_profile`

**Source:** [`src/profiles/Hernquist_profile.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/profiles/Hernquist_profile.m)  
**← Back to [Halo Profile](Halo-Profile)**

---

Computes the Hernquist (1990) density profile. The Hernquist profile is algebraically similar to NFW at small radii (ρ ∝ r⁻¹ inner cusp) but falls off more steeply as ρ ∝ r⁻⁴ at large radii, giving it a finite total mass — a useful property for analytic work.

---

## Syntax

```matlab
[rho, rhos, rs, fc] = Hernquist_profile(r, M, c, z, cosmo, Delta)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `r` | scalar or vector | `Mpc/h` | Radii at which density is evaluated |
| `M` | scalar | `Msun/h` | Halo mass within R_Delta |
| `c` | scalar | — | Concentration  c = R_Delta / r_s |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct (needs `.rhocrit0`, `.E`) |
| `Delta` | scalar | — | Overdensity w.r.t. critical density (e.g. `200`) |

### `cosmo` struct fields

| Field | Description |
|---|---|
| `cosmo.rhocrit0` | Critical density at z=0 [Msun/h / (Mpc/h)^3] |
| `cosmo.E(z)` | Function handle: E(z) = H(z)/H0 |

---

## Outputs

| Parameter | Unit | Description |
|---|---|---|
| `rho` | `Msun/h / (Mpc/h)^3` | Hernquist density at each radius in `r` |
| `rhos` | `Msun/h / (Mpc/h)^3` | Characteristic density normalisation |
| `rs` | `Mpc/h` | Scale radius |
| `fc`   | — | Concentration‑dependent mass factor \(M/M_{\mathrm{tot}}\) |

---

## Profile Formula

```
rho(r) = rho_s / [ (r/rs) * (1 + r/rs)^3 ]
```

- Inner regime (r ≪ r_s): ρ ∝ r⁻¹ — same cusp as NFW
- Outer regime (r ≫ r_s): ρ ∝ r⁻⁴ — steeper than NFW (r⁻³), giving finite total mass

---

## How It Works

1. Computes `rho_c` and `R_Delta` from mass and cosmology.
2. Sets `rs = R_Delta / c`.
3. Derives the total (infinite-sphere) mass `Mtot = M / f(c)` where `f(c) = c^2 / (1+c)^2`.
4. Sets the normalisation `rho_s = Mtot / (2*pi*rs^3)` following Hernquist (1990).
5. Evaluates `rho` at all radii.

---

## Example

```matlab
r     = logspace(-2, 0.5, 300);     % Mpc/h
M     = 1e13;                        % Msun/h
c     = 8;
z     = 0;
Delta = 200;

cosmo.rhocrit0 = 2.775e11;
cosmo.E = @(z) sqrt(0.3*(1+z)^3 + 0.7);

[rho, rhos, rs, fc] = Hernquist_profile(r, M, c, z, cosmo, Delta);

loglog(r, rho, 'g-', 'LineWidth', 1.5);
xlabel('r [Mpc/h]');
ylabel('\rho [M_{sun}/h / (Mpc/h)^3]');
title(sprintf('Hernquist Profile  (r_s = %.3f Mpc/h)', rs));
grid on;
```

---

## Notes

- The Hernquist profile has a **finite total mass**, unlike NFW which formally diverges. This makes it cleaner for semi-analytic models requiring mass integrals.
- The outer slope (r⁻⁴) falls off faster than NFW (r⁻³), so the Hernquist profile underestimates density at large radii relative to NFW for the same inner normalisation.
- `rho_s` here is a normalisation constant, not the density evaluated at r_s.

---

## Reference

Hernquist, L. (1990). *An Analytical Model for Spherical Galaxies and Bulges*. ApJ, 356, 359.
