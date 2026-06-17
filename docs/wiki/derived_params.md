# Derived Cosmological Parameters

`derive_cosmo_params.m` is called automatically inside `cosmology()` after `attach_linear_components`. It computes all scalar derived quantities and attaches the full set of background expansion, density, distance, and time function handles onto the `cosmo` struct.

---

## derive_cosmo_params

**File:** `derive_cosmo_params.m`

```matlab
cosmo = derive_cosmo_params(cosmo)
```

### Required Input Fields

| Field | Description |
|---|---|
| `cosmo.h` | Dimensionless Hubble parameter \(H_0/100\) |
| `cosmo.Omega_m` | Total matter density parameter at z=0 |
| `cosmo.Omega_b` | Baryon density parameter at z=0 |
| `cosmo.rho_crit0` | Critical density at z=0 [M☉ h² Mpc⁻³] |

### Optional Input Fields and Defaults

| Field | Default | Description |
|---|---|---|
| `cosmo.Tcmb` | 2.7255 K | CMB temperature |
| `cosmo.Neff` | 3.046 | Effective number of relativistic neutrino species |
| `cosmo.relspecies` | `false` | Include photons + massless neutrinos in E(z) |
| `cosmo.flat` | `true` | Flat universe flag |
| `cosmo.Omega_L` | `1 - Omega_m - Omega_r` | Dark-energy density (auto-set if flat=true) |
| `cosmo.de_model` | `'lambda'` | Dark-energy model |
| `cosmo.w0` | -1.0 | Equation-of-state parameter today |
| `cosmo.wa` | 0.0 | CPL evolution parameter |
| `cosmo.zmax` | 10⁴ | Upper redshift for age integrals |

---

## Derived Scalar Fields

The following scalars are computed and stored on `cosmo`:

| Field | Expression | Description |
|---|---|---|
| `H0` | \(100\,h\) | Hubble constant [km/s/Mpc] |
| `h2` | \(h^2\) | Square of dimensionless Hubble |
| `Omh2` | \(\Omega_m h^2\) | Physical matter density |
| `Ombh2` | \(\Omega_b h^2\) | Physical baryon density |
| `Omega_c` | \(\Omega_m - \Omega_b\) | CDM density parameter |
| `Omch2` | \(\Omega_c h^2\) | Physical CDM density |
| `Omega_gamma` | \(4.48\times10^{-7} T_\mathrm{CMB}^4 / h^2\) | Photon density (if `relspecies`) |
| `Omega_nu` | \(0.2271\,N_\mathrm{eff}\,\Omega_\gamma\) | Neutrino density (if `relspecies`) |
| `Omega_r` | \(\Omega_\gamma + \Omega_\nu\) | Total radiation density |
| `Omega_k` | \(0\) or \(1 - \Omega_m - \Omega_r - \Omega_L\) | Curvature density |
| `a_eq` | \(\Omega_r/\Omega_m\) | Scale factor at matter-radiation equality |
| `z_eq` | \(1/a_\mathrm{eq} - 1\) | Redshift of matter-radiation equality |
| `w0`, `wa` | set per `de_model` | Dark-energy equation-of-state parameters |
| `age0` | `cosmo.age(0)` | Present age of the universe [Gyr] |

---

## Dark Energy Models

The dark-energy evolution factor \(f_\mathrm{de}(z)\) appears in \(E^2(z)\) as:

\[
E^2(z) = \Omega_m(1+z)^3 + \Omega_r(1+z)^4 + \Omega_k(1+z)^2 + \Omega_L\,f_\mathrm{de}(z)
\]

Three models are implemented:

| `de_model` | \(f_\mathrm{de}(z)\) | Notes |
|---|---|---|
| `'lambda'` or `'lcdm'` | 1 | Cosmological constant |
| `'w0'` or `'wcdm'` | \((1+z)^{3(1+w_0)}\) | Constant equation of state |
| `'w0wa'` or `'cpl'` | \((1+z)^{3(1+w_0+w_a)}\,\exp\!\left(-3w_a z/(1+z)\right)\) | Chevallier-Polarski-Linder |

---

## Function Handles Attached

### Expansion and Hubble Rate

| Handle | Expression |
|---|---|
| `cosmo.fde(z)` | Dark-energy evolution factor |
| `cosmo.E(z)` | \(\sqrt{E^2(z)}\) |
| `cosmo.Hz(z)` | \(H_0\,E(z)\) [km/s/Mpc] |

### Component Densities

All in units of [M☉ h² Mpc⁻³] (same as `rho_crit0`):

| Handle | Expression |
|---|---|
| `cosmo.rhocrit(z)` | \(\rho_{\mathrm{crit},0}\,E^2(z)\) |
| `cosmo.rhom(z)` | \(\rho_{\mathrm{crit},0}\,\Omega_m(1+z)^3\) |
| `cosmo.rhob(z)` | \(\rho_{\mathrm{crit},0}\,\Omega_b(1+z)^3\) |
| `cosmo.rhocdm(z)` | \(\rho_{\mathrm{crit},0}\,\Omega_c(1+z)^3\) |
| `cosmo.rhor(z)` | \(\rho_{\mathrm{crit},0}\,\Omega_r(1+z)^4\) |
| `cosmo.rhoL(z)` | \(\rho_{\mathrm{crit},0}\,\Omega_L\,f_\mathrm{de}(z)\) |

### Density Parameters at Redshift z

| Handle | Expression |
|---|---|
| `cosmo.Omega_m_z(z)` | \(\Omega_m(1+z)^3 / E^2(z)\) |
| `cosmo.Omega_b_z(z)` | \(\Omega_b(1+z)^3 / E^2(z)\) |
| `cosmo.Omega_c_z(z)` | \(\Omega_c(1+z)^3 / E^2(z)\) |
| `cosmo.Omega_r_z(z)` | \(\Omega_r(1+z)^4 / E^2(z)\) |
| `cosmo.Omega_L_z(z)` | \(\Omega_L f_\mathrm{de}(z) / E^2(z)\) |
| `cosmo.Omega_gamma_z(z)` | (only if `relspecies = true`) |
| `cosmo.Omega_nu_z(z)` | (only if `relspecies = true`) |
| `cosmo.Omega_k_z(z)` | (only if \(\Omega_k \neq 0\)) |

### Time

| Handle | Description |
|---|---|
| `cosmo.time(z)` | Full struct: `.lookback_Gyr`, `.t0_Gyr`, `.age_Gyr` |
| `cosmo.lookbackTime(z)` | Lookback time [Gyr] |
| `cosmo.age(z)` | Age at z [Gyr] |

### Distances (Mpc/h)

| Handle | Description |
|---|---|
| `cosmo.comovingDistance(z)` | Line-of-sight comoving distance |
| `cosmo.transverseComovingDistance(z)` | Transverse comoving distance |
| `cosmo.angularDiameterDistance(z)` | \(d_M(z)/(1+z)\) |
| `cosmo.luminosityDistance(z)` | \(d_M(z)\,(1+z)\) |

---

## Notes

1. `Omega_L` is the only public dark-energy density parameter at z=0. Even for non-ΛCDM models, the z-evolution is encoded entirely through `cosmo.fde(z)`.
2. When `flat = true` and `Omega_L` is not supplied, it is set to \(1 - \Omega_m - \Omega_r\). When `flat = false`, `Omega_L` must be supplied by the user.
3. Time and distance integrals use direct numerical integration each call. For high-volume evaluations, pre-compute a grid and interpolate.

---

## Related Pages

- [cosmology.md](cosmology.md)
- [time_calculations.md](time_calculations.md)
- [distances.md](distances.md)
- [growth_factor.md](growth_factor.md)
