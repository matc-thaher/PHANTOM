# `Ishiyama21`

**Source:** [`src/concentration/Ishiyama21.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Ishiyama21.m)  
**← Back to [Concentration](Concentration)**

---

Computes halo concentration from the Ishiyama et al. (2021) model — the most comprehensive and physically motivated concentration model in PHANTOM. It supports six halo definitions and sample types, and is valid across any cosmology due to its dependence on peak height, the local power-spectrum slope, and the growth rate. This is the **recommended default model** in `c_CDM`.

---

## Syntax

```matlab
c = Ishiyama21(M, z, cosmo, mode)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct (see required fields below) |
| `mode` | string | — | Halo definition + sample (see table below) |

### Required `cosmo` fields

| Field | Description |
|---|---|
| `cosmo.sigmaM(M, z)` | RMS linear density fluctuation at mass M |
| `cosmo.neff(M, z, kappa)` | Effective power-spectrum slope at kappa × R_Lagrangian |
| `cosmo.alphaEff(z)` | Effective growth exponent d ln D / d ln(1+z) |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Mode Options (Table 2 of paper)

| `mode` | Mass definition | Sample |
|---|---|---|
| `'200c_all'` | M_200c | All halos (default) |
| `'200c_relaxed'` | M_200c | Dynamically relaxed halos |
| `'vir_all'` | M_vir | All halos |
| `'vir_relaxed'` | M_vir | Relaxed halos |
| `'500_all'` | M_500c | All halos |
| `'500_relaxed'` | M_500c | Relaxed halos |

---

## Model Formula

The model proceeds in five steps:

**Step 1 — Peak height and spectral quantities:**
```
nu    = delta_c / sigma(M, z)         % peak height
n_eff = cosmo.neff(M, z, kappa)       % local power-spectrum slope
alpha = cosmo.alphaEff(z)             % effective growth exponent
```

**Step 2 — Auxiliary parameters (Eqs. 5–7):**
```
A_eff = a0 * (1 + a1 * (n_eff + 3))
B_eff = b0 * (1 + b1 * (n_eff + 3))
C_eff = 1  - cAlpha * (1 - alpha)    % growth-rate correction
```

**Step 3 — Analytic seed and target (Eq. 9):**
```
x_c      = A_eff * (1 + nu^2 / B_eff) / nu
G_target = x_c / [ f(x_c) ]^((5 + n_eff)/6)
```
where `f(c) = ln(1+c) - c/(1+c)` is the NFW shape function.

**Step 4 — Root-finding:**  
Solves `G(c_unnorm) = G_target` using `fzero` with adaptive bracketing.

**Step 5 — Final concentration:**
```
c = C_eff * c_unnorm
```

---

## Example

```matlab
M = logspace(10, 15, 100);   % Msun/h
z = 0;

% All halos, M_200c (default)
c_all  = Ishiyama21(M, z, cosmo, '200c_all');

% Relaxed halos, M_200c
c_relx = Ishiyama21(M, z, cosmo, '200c_relaxed');

% M_500c all halos
c_500  = Ishiyama21(M, z, cosmo, '500_all');

loglog(M, c_all, M, c_relx, M, c_500, 'LineWidth', 1.5);
legend('200c all','200c relaxed','500c all');
xlabel('M [M_{sun}/h]'); ylabel('c');
title('Ishiyama+2021 Concentration');

% Redshift evolution
figure; hold on;
for z_val = [0, 0.5, 1, 2]
    c = Ishiyama21(M, z_val, cosmo, '200c_all');
    loglog(M, c, 'DisplayName', sprintf('z=%.1f', z_val), 'LineWidth', 1.5);
end
legend; xlabel('M [M_{sun}/h]'); ylabel('c'); title('Ishiyama21 — Redshift Evolution');
```

---

## Notes

- Internally loops over each halo for root-finding — performance scales linearly with the number of halos.
- If the adaptive bracket search fails (very rare, at extreme masses/redshifts), the function falls back to the analytic seed `x_c` and issues a warning.
- `C_eff` captures the effect of dark energy on structure growth — halos in a slower-growing universe are less concentrated at fixed ν.

---

## References

- Ishiyama, T. et al. (2021). *The Uchuu Simulations*. MNRAS, 506, 4210.
- Diemer, B., & Joyce, M. (2019). ApJ, 871, 168. *(Original functional form)*
