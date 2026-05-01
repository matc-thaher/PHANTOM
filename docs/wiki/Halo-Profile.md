# Halo Profile

This page documents all halo density profile functions available in PHANTOM under [`src/profiles/`](https://github.com/matc-thaher/PHANTOM/tree/main/src/profiles). Each function returns the 3D density ρ(r) of a dark matter halo as a function of radius, given physical parameters such as mass, concentration, and redshift.

---

## Available Profile Functions

| Function | Profile Model | Typical Use Case |
|---|---|---|
| [`NFW_profile`](NFW_profile) | Navarro–Frenk–White (1997) | Minimal NFW — raw ρ_s and r_s inputs |
| [`NFW_analytcl_Profile`](NFW_analytcl-Profile) | NFW with enclosed mass output | Full NFW from virial parameters |
| [`Einasto_profile`](Einasto_profile) | Einasto (1965) + Gao+2008 α_e | Smooth, cusp-free inner profile |
| [`Hernquist_profile`](Hernquist_profile) | Hernquist (1990) | Analytically convenient steep cusp |
| [`DK14_profile`](DK14_profile) | Diemer & Kravtsov (2014) | Splashback + infalling outer region |
| [`Soliton_profile`](Soliton_profile) | Schive et al. (2014) | Ultra-light / fuzzy dark matter core |

---

## Common Conventions

All profiles share consistent units and structural conventions:

- **Radii** `r` — `Mpc/h` for cosmological profiles; `kpc` for `NFW_analytcl_Profile` and `Soliton_profile`
- **Masses** `M` — `Msun/h` for cosmological profiles; `Msun` for `NFW_analytcl_Profile` and `Soliton_profile`
- **Density output** `rho` — `Msun/h / (Mpc/h)^3` or `Msun/kpc^3` depending on function
- **`cosmo` struct** (where required) — must include `.rhocrit0`, `.E(z)`, `.nu(M,z)`, `.Omega_m`, `.rho_m0`
- **`Delta`** — overdensity threshold relative to critical density (typically `200`)

---

## Quick-Reference Examples

### NFW profile — raw inputs
```matlab
r    = linspace(0.01, 5, 500);   % kpc
rhos = 2e7;                       % Msun/kpc^3
rs   = 0.3;                       % kpc
rho  = NFW_profile(r, rhos, rs);
loglog(r, rho);
xlabel('r [kpc]'); ylabel('\rho [M_{sun}/kpc^3]');
```

### NFW profile — from virial parameters
```matlab
Mvir = 1e12;                         % Msun
Rvir = 250;                          % kpc
c    = 10;
r    = linspace(0.1, Rvir, 300);     % kpc
NFW  = NFW_analytcl_Profile(Mvir, Rvir, c, r);
loglog(NFW.r, NFW.rho);
```

### Einasto profile
```matlab
r     = linspace(0.01, 2, 300);   % Mpc/h
M     = 1e13;  c = 8;  z = 0;  Delta = 200;
[rho, rhos, rs] = Einasto_profile(r, M, c, z, cosmo, Delta);
loglog(r, rho);
```

### Hernquist profile
```matlab
r   = linspace(0.01, 2, 300);    % Mpc/h
M   = 1e13;  c = 8;  z = 0;  Delta = 200;
[rho, rhos, rs] = Hernquist_profile(r, M, c, z, cosmo, Delta);
loglog(r, rho);
```

### DK14 profile — mass-selected
```matlab
r   = logspace(-1, 1, 300);      % Mpc/h
M   = 1e14;  c = 5;  z = 0.5;  Delta = 200;
rho = DK14_profile(r, M, c, z, cosmo, Delta);
loglog(r, rho);
```

### DK14 profile — accretion-rate selected
```matlab
Gamma = 1.5;
rho   = DK14_profile(r, M, c, z, cosmo, Delta, 'Gamma', Gamma);
```

### Soliton profile
```matlab
r    = linspace(0, 5, 300);   % kpc
rho0 = 1e8;                    % Msun/kpc^3
rc   = 0.5;                    % kpc
rho  = Soliton_profile(r, rho0, rc);
plot(r, rho);
```

---

## See Also

- [NFW_profile](NFW_profile)
- [NFW_analytcl_Profile](NFW_analytcl-Profile)
- [Einasto_profile](Einasto_profile)
- [Hernquist_profile](Hernquist_profile)
- [DK14_profile](DK14_profile)
- [Soliton_profile](Soliton_profile)
