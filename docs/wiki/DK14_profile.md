# `DK14_profile`

**Source:** [`src/profiles/DK14_profile.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/profiles/DK14_profile.m)  
**← Back to [Halo Profile](Halo-Profile)**

---

Computes the Diemer & Kravtsov (2014) density profile, which extends the Einasto inner profile with a physically motivated splashback truncation and a power-law outer (infalling matter) term. This is the most feature-rich profile in PHANTOM and supports two distinct selection modes depending on whether the halo sample is selected by mass alone or by mass plus accretion rate.

---

## Syntax

```matlab
rho = DK14_profile(r, M, c, z, cosmo, Delta)
rho = DK14_profile(r, M, c, z, cosmo, Delta, selected_by)
rho = DK14_profile(r, M, c, z, cosmo, Delta, selected_by, Gamma)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `r` | scalar or vector | `Mpc/h` | Radii at which density is evaluated |
| `M` | scalar | `Msun/h` | Halo mass (as M_200m) |
| `c` | scalar | — | Concentration c_200m = R_200m / r_s |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct (see below) |
| `Delta` | scalar | — | Overdensity w.r.t. critical density (typically `200`) |
| `selected_by` | string | — | `'M'` (default) or `'Gamma'` — selection mode |
| `Gamma` | scalar | — | Mass accretion rate (required only when `selected_by = 'Gamma'`) |

### `cosmo` struct fields

| Field | Description |
|---|---|
| `cosmo.rhocrit0` | Critical density at z=0 [Msun/h / (Mpc/h)^3] |
| `cosmo.E(z)` | Function handle: E(z) = H(z)/H0 |
| `cosmo.nu(M,z)` | Function handle: peak height ν(M,z) |
| `cosmo.Omega_m` | Matter density parameter Ω_m |
| `cosmo.rho_m0` | Mean matter density at z=0 [Msun/h / (Mpc/h)^3] |

---

## Output

| Parameter | Unit | Description |
|---|---|---|
| `rho` | `Msun/h / (Mpc/h)^3` | Total DK14 density at each radius in `r` |

---

## Profile Formula

The DK14 profile has three components:

```
rho(r) = rho_inner(r) * f_trans(r) + rho_outer(r)
```

**Inner profile** — Einasto (via `Einasto_profile.m`):
```
rho_inner(r) = Einasto_profile(r, M, c, z, cosmo, Delta)
```

**Transition (splashback) function:**
```
f_trans(r) = [ 1 + (r/rt)^beta ]^(-gamma_t / beta)
```
- r ≪ r_t: f_trans → 1 (inner profile unchanged)
- r ~ r_t: f_trans ~ 0.5 (splashback transition region)
- r ≫ r_t: f_trans → 0 (sharp suppression)

**Outer power-law (infalling matter):**
```
rho_outer(r) = rho_m(z) * r^(-s_e)
```
where `rho_m(z) = cosmo.rho_m0 * (1+z)^3` and `s_e = 1.5` (fixed default).

---

## Selection Modes

The `selected_by` option controls how the splashback radius `r_t` and the transition steepness parameters are calibrated.

### `selected_by = 'M'` (default — mass-selected)

Follows DK14 Table 1 and eq. 6:

| Parameter | Value |
|---|---|
| `beta` | 4 |
| `gamma_t` | 8 |
| `rt` | `R_200m * (1.9 - 0.18 * nu_200m)` |

Use this when your halo sample is selected purely by mass (e.g. mass-limited catalogs).

### `selected_by = 'Gamma'` (mass + accretion-rate selected)

Follows DK14 Table 1 and the Gamma-based r_t formula:

| Parameter | Value |
|---|---|
| `beta` | 6 |
| `gamma_t` | 4 |
| `rt` | `R_200m * 0.54 * (1 + 0.53 * exp(-Gamma))` |

Use this when halos are binned by both mass and accretion rate Γ. **`Gamma` must be supplied.**  
If `selected_by = 'Gamma'` but `Gamma` is empty, the function issues a warning and falls back to mass-selected defaults.

---

## How It Works

1. Computes the mean matter density at redshift z: `rho_m = cosmo.rho_m0 * (1+z)^3`.
2. Derives `R_200m` and `nu_200m` from mass and cosmology.
3. Sets `beta`, `gamma_t`, and `rt` according to the `selected_by` mode.
4. Clips `rt` to a minimum of `0.01 * R_200m` to prevent numerical collapse.
5. Calls [`Einasto_profile`](Einasto_profile) for the inner profile.
6. Evaluates the splashback transition function `f_trans`.
7. Adds the outer power-law term.
8. Returns `rho = rho_inner .* f_trans + rho_outer`.

---

## Examples

### Mass-selected (default)

```matlab
r     = logspace(-1, 1, 300);   % Mpc/h
M     = 1e14;                    % Msun/h
c     = 5;
z     = 0.5;
Delta = 200;

rho = DK14_profile(r, M, c, z, cosmo, Delta);

loglog(r, rho, 'k-', 'LineWidth', 1.5);
xlabel('r [Mpc/h]');
ylabel('\rho [M_{sun}/h / (Mpc/h)^3]');
title('DK14 Profile — Mass Selected');
grid on;
```

### Accretion-rate selected

```matlab
Gamma = 1.5;   % mass accretion rate
rho   = DK14_profile(r, M, c, z, cosmo, Delta, 'Gamma', Gamma);

loglog(r, rho, 'r--', 'LineWidth', 1.5);
title('DK14 Profile — Gamma Selected');
```

### Comparing both modes

```matlab
rho_M   = DK14_profile(r, M, c, z, cosmo, Delta, 'M');
rho_G   = DK14_profile(r, M, c, z, cosmo, Delta, 'Gamma', 1.5);

loglog(r, rho_M, 'b-', r, rho_G, 'r--', 'LineWidth', 1.5);
legend('Mass-selected', 'Gamma-selected');
```

---

## Notes

- DK14 requires `Einasto_profile.m` to be on the MATLAB path — it is called internally.
- The splashback radius `r_t` can become unphysically small for very high-ν halos; the function clips it to `0.01 * R_200m` automatically.
- The outer slope `s_e = 1.5` and the normalisation `b_e * r_ref^s_e = rho_m` (with `b_e ≈ 1`, `r_ref = 1 Mpc/h`) are hard-coded DK14 defaults. They are not currently user-configurable.

---

## References

- Diemer, B., & Kravtsov, A. V. (2014). *Dependence of the Outer Density Profiles of Halos on Their Mass Accretion Rate*. ApJ, 789, 1. *(DK14 profile)*
- Diemer, B. (2022). ApJ, 925, 182. *(Updated outer form)*
- Gao, L. et al. (2008). MNRAS, 387, 536. *(α_e via ν)*
- Colossus documentation: https://bdiemer.bitbucket.io/colossus/halo_profile_dk14.html
