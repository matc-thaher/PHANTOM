# `Soliton_profile`

**Source:** [`src/profiles/Soliton_profile.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/profiles/Soliton_profile.m)  
**← Back to [Halo Profile](Halo-Profile)**

---

Computes the soliton (core) density profile for ultra-light dark matter (ULDM) — also known as fuzzy dark matter (FDM) — halos. The profile follows the fitting formula of Schive et al. (2014), calibrated against numerical simulations of the Schrödinger–Poisson equations. Unlike CDM profiles, the soliton has a flat, wave-supported core rather than a central cusp.

---

## Syntax

```matlab
rho = Soliton_profile(r, rho0, rc)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `r` | scalar or vector | `kpc` | Radial distance from halo center |
| `rho0` | scalar | `Msun/kpc^3` | Central (peak) soliton density |
| `rc` | scalar | `kpc` | Soliton core radius — defined as the **half-density radius** where ρ(rc) = ρ0 / 2 |

---

## Output

| Parameter | Unit | Description |
|---|---|---|
| `rho` | `Msun/kpc^3` | Soliton density at each radius in `r` |

---

## Profile Formula

```
rho(r) = rho0 * [ 1 + 0.091 * (r/rc)^2 ]^(-8)
```

The exponent `−8` and coefficient `0.091` are empirical fitting parameters from Schive et al. (2014), determined by fitting the ground-state solution of the Schrödinger–Poisson system.

**Key behaviours:**
- At `r = 0`: ρ = ρ0 (flat central core, no cusp)
- At `r = rc`: ρ = ρ0 / 2 (by definition of the half-density radius)
- At `r ≫ rc`: ρ falls steeply as r⁻¹⁶

---

## How It Works

The function is a single direct evaluation — no iterative solving or cosmology is required:

1. Computes `(r / rc)^2` element-wise.
2. Returns `rho0 * (1 + 0.091 * x^2)^(-8)` for each radius.

The simplicity makes it extremely fast and suitable for use inside larger fitting or MCMC loops.

---

## Example

```matlab
r    = linspace(0, 5, 500);    % kpc
rho0 = 1e8;                     % Msun/kpc^3 (central density)
rc   = 0.5;                     % kpc (core radius)

rho  = Soliton_profile(r, rho0, rc);

figure;
plot(r, rho / rho0, 'b-', 'LineWidth', 2);
xline(rc, 'r--', 'r_c');
yline(0.5, 'r--', '\rho_0/2');
xlabel('r [kpc]');
ylabel('\rho / \rho_0');
title('Soliton (FDM) Core Profile');
grid on;
```

### Varying core radius

```matlab
rc_vals = [0.2, 0.5, 1.0, 2.0];    % kpc
r       = linspace(0, 6, 500);
colors  = lines(numel(rc_vals));

figure; hold on;
for i = 1:numel(rc_vals)
    rho = Soliton_profile(r, 1e8, rc_vals(i));
    plot(r, rho, 'Color', colors(i,:), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('r_c = %.1f kpc', rc_vals(i)));
end
legend; xlabel('r [kpc]'); ylabel('\rho [M_{sun}/kpc^3]');
title('Soliton Profile — Varying Core Radius');
grid on;
```

---

## Physical Context

In ULDM/FDM models, the boson mass m_ψ determines the de Broglie wavelength and hence the soliton core size. Smaller m_ψ → larger, lower-density soliton core. The core radius and central density are related to the boson mass and halo mass through scaling relations derived in Schive et al. (2014) and subsequent work. The soliton typically occupies only the innermost region of the halo; beyond a few r_c, the profile transitions to an NFW-like envelope.

---

## Notes

- `r = 0` is safe — the formula is well-defined and returns `rho0`.
- `rho0` and `rc` must be derived externally (e.g. from ULDM scaling relations or fitting to simulation data). This function does not constrain them.
- For a ULDM halo model combining a soliton core with an NFW envelope, call `Soliton_profile` for `r < r_transition` and [`NFW_analytcl_Profile`](NFW_analytcl-Profile) for the outer region.

---

## Reference

Schive, H.-Y., Chiueh, T., & Broadhurst, T. (2014). *Cosmic Structure as the Quantum Interference of a Coherent Dark Wave*. Nature Physics, 10, 496–499. https://doi.org/10.1038/nphys2996
