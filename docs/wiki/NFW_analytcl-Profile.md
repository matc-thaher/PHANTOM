# `NFW_analytcl_Profile`

**Source:** [`src/profiles/NFW_analytcl_Profile.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/profiles/NFW_analytcl_Profile.m)  
**← Back to [Halo Profile](Halo-Profile)**

---

Constructs a complete NFW halo profile from virial parameters. Unlike [`NFW_profile`](NFW_profile), this function derives all internal quantities (scale radius, scale density, enclosed mass) automatically from `Mvir`, `Rvir`, and `c`. Results are returned as a convenient MATLAB struct.

---

## Syntax

```matlab
NFW = NFW_analytcl_Profile(Mvir, Rvir, c, r)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `Mvir` | scalar | `Msun` | Virial mass of the halo |
| `Rvir` | scalar | `kpc` | Virial radius of the halo |
| `c` | scalar | — | Concentration parameter ( c = Rvir / rs ) |
| `r` | vector | `kpc` | Radii at which the profile is evaluated |

> **Note:** If any element of `r` exceeds `Rvir`, those radii are silently trimmed — the profile is only evaluated within the virial sphere.

---

## Output: NFW struct

| Field | Unit | Description |
|---|---|---|
| `NFW.rho` | `Msun/kpc^3` | NFW density at each radius in `r` |
| `NFW.Menc` | `Msun` | Enclosed mass M(<r) at each radius |
| `NFW.rs` | `kpc` | Scale radius r_s = Rvir / c |
| `NFW.rho_s` | `Msun/kpc^3` | Scale density ρ_s |
| `NFW.f_c` | — | Concentration factor f(c) = ln(1+c) − c/(1+c) |
| `NFW.r` | `kpc` | Trimmed radius array (≤ Rvir) |
| `NFW.Mvir` | `Msun` | Input virial mass (stored for reference) |
| `NFW.Rvir` | `kpc` | Input virial radius (stored for reference) |
| `NFW.c` | — | Input concentration (stored for reference) |

---

## Profile Formulas

**Scale radius and density:**
```
rs    = Rvir / c
f(c)  = ln(1 + c) - c/(1 + c)
rho_s = Mvir / (4*pi * rs^3 * f(c))
```

**Density profile:**
```
rho(r) = rho_s / [ (r/rs) * (1 + r/rs)^2 ]
```

**Enclosed mass:**
```
M(<r) = 4*pi * rho_s * rs^3 * [ ln(1 + x) - x/(1 + x) ]
```
where `x = r / rs`.

---

## How It Works

1. Computes `rs = Rvir / c`.
2. Evaluates the NFW concentration factor `f(c) = log(1+c) - c/(1+c)`.
3. Derives `rho_s = Mvir / (4*pi*rs^3 * f(c))` so that `M(<Rvir) = Mvir` exactly.
4. Trims `r` to values ≤ `Rvir` to stay within the virial boundary.
5. Evaluates density and enclosed mass at all trimmed radii.
6. Packages everything into the output struct.

---

## Example

```matlab
Mvir = 1e12;                          % Msun  (Milky Way-like halo)
Rvir = 250;                           % kpc
c    = 10;
r    = linspace(0.1, Rvir, 300);      % kpc

NFW = NFW_analytcl_Profile(Mvir, Rvir, c, r);

figure;
subplot(1,2,1);
loglog(NFW.r, NFW.rho, 'b-', 'LineWidth', 1.5);
xlabel('r [kpc]'); ylabel('\rho [M_{sun}/kpc^3]');
title('NFW Density'); grid on;

subplot(1,2,2);
loglog(NFW.r, NFW.Menc, 'r-', 'LineWidth', 1.5);
xlabel('r [kpc]'); ylabel('M_{enc} [M_{sun}]');
title('NFW Enclosed Mass'); grid on;
```

---

## Notes

- Radii beyond `Rvir` are **silently dropped** from the output `NFW.r` array. Pre-trim `r` yourself if you want explicit control.
- For a raw NFW evaluation without the struct overhead, use [`NFW_profile`](NFW_profile) with manually supplied `rhos` and `rs`.
- Units here are `kpc` and `Msun` (not `Mpc/h`). Be careful mixing with cosmological profile functions.

---

## References

- Navarro, J. F., Frenk, C. S., & White, S. D. M. (1996). *The Structure of Cold Dark Matter Halos*. ApJ, 462, 563.
- Navarro, J. F., Frenk, C. S., & White, S. D. M. (1997). *A Universal Density Profile from Hierarchical Clustering*. ApJ, 490, 493.
