# Concentration

This page documents all halo concentration-mass relation functions in PHANTOM under [`src/concentration/`](https://github.com/matc-thaher/PHANTOM/tree/main/src/concentration). Each function returns the concentration parameter `c = R_Delta / r_s` for a dark matter halo given its mass, redshift, and cosmology.

The **recommended entry point** for all models is [`c_CDM`](c_CDM), which acts as a unified dispatcher to all individual models through a single consistent interface.

---

## Available Functions

| Function | Model | Mass Def | Cosmology Needed |
|---|---|---|---|
| [`c_CDM`](c_CDM) | Unified dispatcher — calls any model below | any | optional |
| [`Bhattacharya13`](Bhattacharya13) | Bhattacharya et al. 2013 | 200c, vir, 200m | Yes (σ(M,z)) |
| [`Bullock01`](Bullock01) | Bullock et al. 2001 | vir | Yes (σ, D(z)) |
| [`Child18`](Child18) | Child et al. 2018 | 200c | Yes (σ(M,z)) |
| [`Diemer15`](Diemer15) | Diemer & Kravtsov 2015 | 200c | Yes (σ, n_eff) |
| [`Diemer19`](Diemer19) | Diemer & Joyce 2019 | 200c, vir | Yes (σ, n_eff, α) |
| [`Duffy08`](Duffy08) | Duffy et al. 2008 | 200c, vir, 200m | No |
| [`Dutton14`](Dutton14) | Dutton & Macciò 2014 | 200c, vir | No |
| [`Ishiyama21`](Ishiyama21) | Ishiyama et al. 2021 | 200c, vir, 500c | Yes (σ, n_eff, α) |
| [`Klypin11`](Klypin11) | Klypin et al. 2011 | vir | No |
| [`Klypin16`](Klypin16) | Klypin et al. 2016 | 200c, vir | Optional (σ for cnu) |
| [`Ludlow16`](Ludlow16) | Ludlow et al. 2016 (analytic) | 200c | Yes (σ, D(z), ρ_crit) |
| [`Ludlow16_fit`](Ludlow16_fit) | Ludlow et al. 2016 (fitting formula) | 200c | Yes (σ(M,z)) |
| [`Prada12`](Prada12) | Prada et al. 2012 | 200c | Yes (σ(M,z), Ω) |

---

## Common Conventions

- **Mass** `M`: in `Msun/h`
- **Redshift** `z`: scalar
- **Output** `c`: dimensionless concentration `c = R_Delta / r_s`
- **`cosmo` struct** (where required): must include `.sigmaM(M,z)`, `.E(z)`, `.D(z)`, `.neff(M,z,kappa)`, `.alphaEff(z)` depending on model
- **`delta_c = 1.686`**: linear collapse threshold used internally by all models

---

## Quick-Reference: Simple Applications

### Recommended — use the unified dispatcher
```matlab
M = logspace(11, 15, 50);   % Msun/h
z = 0;

% Default model (Ishiyama21, 200c_all)
c = c_CDM(M, z, 'ishiyama21', cosmo);

% Duffy08 — no cosmo needed
c = c_CDM(M, z, 'duffy08');

% Dutton14 virial
c = c_CDM(M, z, 'dutton14', 'vir');

% Diemer15 mean
c = c_CDM(M, z, 'diemer15', cosmo, 'mean');
```

### Simple power-law fits (no cosmo)
```matlab
M = logspace(11, 15, 50);   z = 0;

c_duf  = Duffy08(M, z, '200c', 'NFW', 'full', 'z0_2');
c_dut  = Dutton14(M, z, '200c');
c_kl11 = Klypin11(M, z, 'distinct');

loglog(M, c_duf, M, c_dut, M, c_kl11);
legend('Duffy08','Dutton14','Klypin11');
xlabel('M [M_{sun}/h]'); ylabel('c');
```

### Physics-based models (cosmo required)
```matlab
c_d15  = Diemer15(M, z, cosmo);
c_i21  = Ishiyama21(M, z, cosmo, '200c_all');
c_d19  = Diemer19(M, z, cosmo, '200c_all');
```

### Comparing all models
```matlab
models = {'duffy08','dutton14','diemer15','ishiyama21'};
figure; hold on;
for i = 1:numel(models)
    c = c_CDM(M, z, models{i}, cosmo);
    loglog(M, c, 'DisplayName', models{i});
end
legend; xlabel('M [M_{sun}/h]'); ylabel('c');
title('Concentration-Mass Relations at z=0');
```

---

## Choosing a Model

| Scenario | Recommended Model |
|---|---|
| General purpose, any cosmology | [`Ishiyama21`](Ishiyama21) or [`Diemer19`](Diemer19) |
| No cosmology struct available | [`Duffy08`](Duffy08) or [`Dutton14`](Dutton14) |
| WMAP5 calibrated work | [`Duffy08`](Duffy08) |
| Planck cosmology, relaxed halos | [`Dutton14`](Dutton14) or [`Klypin16`](Klypin16) |
| Physical model (no fitting) | [`Ludlow16`](Ludlow16) |
| Mass + accretion rate dependence | [`Diemer15`](Diemer15) |
| Multiple halo definitions | [`Ishiyama21`](Ishiyama21) |

---

## See Also

- [c_CDM](c_CDM)
- [Bhattacharya13](Bhattacharya13)
- [Bullock01](Bullock01)
- [Child18](Child18)
- [Diemer15](Diemer15)
- [Diemer19](Diemer19)
- [Duffy08](Duffy08)
- [Dutton14](Dutton14)
- [Ishiyama21](Ishiyama21)
- [Ishiyama21_zero](Ishiyama21_zero)
- [Klypin11](Klypin11)
- [Klypin16](Klypin16)
- [Ludlow16](Ludlow16)
- [Ludlow16_fit](Ludlow16_fit)
- [Prada12](Prada12)
