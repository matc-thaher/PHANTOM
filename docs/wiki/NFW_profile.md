# `NFW_profile`

**Source:** [`src/profiles/NFW_profile.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/profiles/NFW_profile.m)  
**← Back to [Halo Profile](Halo-Profile)**

---

Computes the Navarro–Frenk–White (NFW) density profile from a characteristic density ρ_s and a scale radius r_s. This is the lowest-level NFW function in PHANTOM — it expects pre-computed physical parameters rather than deriving them internally from mass or cosmology.

---

## Syntax

```matlab
rho = NFW_profile(r, rhos, rs)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `r` | scalar or vector | `kpc` | Radii at which density is evaluated |
| `rhos` | scalar | `Msun/kpc^3` | Characteristic (scale) density ρ_s |
| `rs` | scalar | `kpc` | Scale radius r_s |

## Output

| Parameter | Unit | Description |
|---|---|---|
| `rho` | `Msun/kpc^3` | NFW density at each radius in `r` |

---

## Profile Formula

```
rho(r) = rho_s / [ (r/rs) * (1 + r/rs)^2 ]
```

- Inner regime (r ≪ r_s): ρ ∝ r⁻¹ — a shallow cusp
- Outer regime (r ≫ r_s): ρ ∝ r⁻³ — a steep fall-off
- At r = r_s: ρ = ρ_s / 4

---

## How It Works

1. Computes the dimensionless ratio `x = r ./ rs`.
2. Returns `rho = rhos ./ (x .* (1 + x).^2)` element-wise over the full radius array.

No cosmology, mass, concentration, or redshift is needed. The caller is fully responsible for supplying physically consistent `rhos` and `rs`.

---

## Example

```matlab
r    = linspace(0.01, 5, 500);    % kpc — avoid r=0 (division by zero)
rhos = 2e7;                        % Msun/kpc^3
rs   = 0.3;                        % kpc

rho  = NFW_profile(r, rhos, rs);

loglog(r, rho, 'b-', 'LineWidth', 1.5);
xlabel('r [kpc]');
ylabel('\rho [M_{sun}/kpc^3]');
title('NFW Density Profile');
grid on;
```

---

## Notes

- **Avoid `r = 0`** — the formula diverges. Always start the radius array from a small positive value (e.g. `0.01 kpc`).
- To compute `rhos` and `rs` automatically from a virial mass `Mvir`, virial radius `Rvir`, and concentration `c`, use [`NFW_analytcl_Profile`](NFW_analytcl-Profile) instead.
- This function does **not** return enclosed mass. For M(<r), use `NFW_analytcl_Profile`.

---

## Reference

Navarro, J. F., Frenk, C. S., & White, S. D. M. (1997). *A Universal Density Profile from Hierarchical Clustering*. ApJ, 490, 493.
