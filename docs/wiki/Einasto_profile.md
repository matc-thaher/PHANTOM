# `Einasto_profile`

**Source:** [`src/profiles/Einasto_profile.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/profiles/Einasto_profile.m)  
**← Back to [Halo Profile](Halo-Profile)**

---

Computes the Einasto (1965) density profile with the shape parameter α_e derived internally from the halo peak height ν(M, z) using the empirical formula of Gao et al. (2008). This makes it self-consistent with the halo's mass and redshift — no manual tuning of α_e is needed.

---

## Syntax

```matlab
[rho, rhos, rs, fc] = Einasto_profile(r, M, c, z, cosmo, Delta)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `r` | scalar or vector | `Mpc/h` | Radii at which density is evaluated |
| `M` | scalar | `Msun/h` | Halo mass |
| `c` | scalar | — | Concentration  c = R_Delta / r_s |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct (see below) |
| `Delta` | scalar | — | Overdensity w.r.t. critical density (e.g. `200`) |

### `cosmo` struct fields

| Field | Description |
|---|---|
| `cosmo.rhocrit0` | Critical density at z=0 [Msun/h / (Mpc/h)^3] |
| `cosmo.E(z)` | Function handle: dimensionless Hubble parameter E(z) = H(z)/H0 |
| `cosmo.nu(M,z)` | Function handle: peak height ν(M,z) = δ_crit(z) / σ(M,z) |

---

## Outputs

| Parameter | Unit | Description |
|---|---|---|
| `rho` | `Msun/h / (Mpc/h)^3` | Einasto density at each radius in `r` |
| `rhos` | `Msun/h / (Mpc/h)^3` | Characteristic density at the scale radius |
| `rs` | `Mpc/h` | Scale radius |
| `fc`   | — | Concentration‑dependent mass factor \(M/M_{\mathrm{tot}}\) |

---

## Profile Formula

```
rho(r) = rho_s * exp( -(2/alpha_e) * [ (r/rs)^alpha_e - 1 ] )
```

Unlike NFW, the Einasto profile has **no central cusp** — density flattens smoothly toward r = 0.

---

## Shape Parameter α_e (Gao+2008, eq. 5)

The shape parameter is computed automatically:

```
alpha_e = 0.155 + 0.0095 * nu^2
```

where `nu = cosmo.nu(M, z)` is the peak height.

| Peak height ν | Halo type | α_e |
|---|---|---|
| ν < 1 | Low-mass, common halos | ~0.16 |
| ν ~ 3 | Rare, massive clusters | ~0.24–0.30 |

α_e is **capped at 0.3** following Benson (2012), since Gao+2008 did not probe ν > ~3.5.

---

## How It Works

1. Computes `nu = cosmo.nu(M, z)`.
2. Derives `alpha_e = min(0.155 + 0.0095 * nu^2, 0.3)`.
3. Computes `rho_c` and `R_Delta` from mass and cosmology.
4. Sets `rs = R_Delta / c`.
5. Normalises `rho_s` so that M(<R_Delta) = M exactly, using the lower incomplete gamma function.
6. Evaluates the Einasto profile at all radii in `r`.

---

## Example

```matlab
r     = logspace(-2, 0.5, 300);     % Mpc/h
M     = 1e13;                        % Msun/h
c     = 8;
z     = 0;
Delta = 200;

% cosmo struct (user must build this externally)
cosmo.rhocrit0 = 2.775e11;           % Msun/h / (Mpc/h)^3
cosmo.E        = @(z) sqrt(0.3*(1+z)^3 + 0.7);
cosmo.nu       = @(M,z) my_peak_height(M, z);  % user-defined

[rho, rhos, rs, fc] = Einasto_profile(r, M, c, z, cosmo, Delta);

loglog(r, rho, 'r-', 'LineWidth', 1.5);
xlabel('r [Mpc/h]');
ylabel('\rho [M_{sun}/h / (Mpc/h)^3]');
title(sprintf('Einasto Profile  (r_s = %.3f Mpc/h)', rs));
grid on;
```

---

## Notes

- The Einasto profile is also used internally by [`DK14_profile`](DK14_profile) as its inner component.
- `rho_s` here is the density **at the scale radius** r_s, not a free parameter — it is fixed by mass normalisation.
- The mass normalisation integral uses MATLAB's `gammainc` and `gamma` functions; these are native and no external toolbox is required.

---

## References

- Einasto, J. (1965). *On the Construction of a Composite Model for the Galaxy and on the Determination of the System of Galactic Parameters*. Trudy Inst. Astroz. Alma-Ata, 5, 87.
- Merritt, D. et al. (2006). AJ, 132, 2685.
- Gao, L. et al. (2008). *The redshift dependence of the structure of massive ΛCDM haloes*. MNRAS, 387, 536. *(α_e formula, eq. 5)*
