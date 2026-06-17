# Transfer Functions

PHANTOM supports multiple linear matter transfer function models, all resolved through `attach_linear_components.m`. The active model is selected by setting `cosmo.transfer_model` before calling `cosmology()`. The selected function is assigned to `cosmo.T` as a function handle `T(k)`, where `k` is the wavenumber in h/Mpc.

The linear matter power spectrum at z=0 is then constructed as:

\[
P_0(k) = A \, k^{n_s} \, T(k)^2
\]

where A is fixed by normalizing to `cosmo.sigma8` via `normalize_A_to_sigma8.m`. For `camb` and `axioncamb` models, `Pk0` is set directly from the tabulated spectrum without this renormalization step.

---

## T_EH98 — Eisenstein & Hu (1998), No-Wiggle

**File:** `T_EH98.m`  
**Key:** `'eh98'` (default)

Implements the zero-baryon (no-wiggle) fitting formula from Eisenstein & Hu (1998), Eqs. 26–31. This is the default transfer function in PHANTOM.

**Physics:** The effective shape parameter \(\Gamma_\mathrm{eff}\) absorbs the baryon suppression into a smooth correction:

\[
\Gamma_\mathrm{eff} = \Omega_m h \left[ \alpha_\Gamma + \frac{1 - \alpha_\Gamma}{1 + (0.43\, k\, h\, s)^4} \right]
\]

\[
T_0(k) = \frac{L_0}{L_0 + C_0 \, q^2}, \quad q = \frac{k \,\theta^2}{\Gamma_\mathrm{eff}}
\]

where \(\theta = T_\mathrm{CMB}/2.7\), \(s\) is the sound horizon, and \(\alpha_\Gamma\) is a baryon correction factor.

**Required cosmology fields:** `Omega_m`, `Omega_b`, `h`

**Usage:**
```matlab
cosmo = cosmology('Planck18');   % uses eh98 by default
T = cosmo.T(k);
```

---

## T_EH98_full — Eisenstein & Hu (1998), Full Baryon

**File:** `T_EH98_full.m`  
**Key:** `'eh98_full'`

Implements the full baryon transfer function from Eisenstein & Hu (1998), including baryon acoustic oscillations (BAO) and Silk damping. It separates CDM and baryon contributions:

\[
T(k) = f_b \, T_b(k) + f_c \, T_c(k)
\]

where \(f_b = \Omega_b / \Omega_m\) and \(f_c = 1 - f_b\).

Key scales computed internally:
- \(z_\mathrm{eq}\): matter-radiation equality redshift (Eq. 2)
- \(z_d\): baryon drag epoch (Eq. 4)
- \(s\): sound horizon at drag epoch (Eq. 5–6)
- \(k_\mathrm{Silk}\): Silk damping scale (Eq. 7)

The CDM component \(T_c\) uses the double-beta fitting form (Eqs. 11, 17–18) and the baryon component \(T_b\) includes acoustic oscillations damped by Silk diffusion (Eqs. 14–15, 21–24).

**Required cosmology fields:** `Omega_m`, `Omega_b`, `h`

**Usage:**
```matlab
cosmo.transfer_model = 'eh98_full';
cosmo = cosmology('Planck18', cosmo);
```

---

## T_Sugiyama95 — Sugiyama (1995)

**File:** `T_Sugiyama95.m`  
**Key:** `'sugiyama95'`

Implements the BBKS transfer function with the Sugiyama (1995) baryon correction to the shape parameter:

\[
\Gamma = \Omega_m \, h \, \exp\!\left[-\Omega_b \left(1 + \frac{\sqrt{2h}}{\Omega_m}\right)\right]
\]

\[
T(k) = \frac{\ln(1 + 2.34\,q)}{2.34\,q} \left[1 + 3.89\,q + (16.1\,q)^2 + (5.46\,q)^3 + (6.71\,q)^4\right]^{-1/4}
\]

where \(q = (T_\mathrm{CMB}/2.7)^2 \, k / \Gamma\).

**Optional field:** `cosmo.Tcmb0` (default: 2.7255 K)

---

## T_wdm — Warm Dark Matter Suppression

**File:** `T_wdm.m`  
**Key:** used internally by `'viel05'` and `'bode01'`

Returns the WDM suppression transfer function \(T_\mathrm{WDM}(k)\) such that \(P_\mathrm{WDM}(k) = T_\mathrm{WDM}(k)^2 \cdot P_\mathrm{CDM}(k)\).

### Viel+2005 (`'viel'`)

From Viel et al. (2005), Phys. Rev. D 71, 063534, Eqs. 6–7:

\[
T_\mathrm{WDM}(k) = \left[1 + (\alpha k)^{2\mu}\right]^{-5/\mu}, \quad \mu = 1.12
\]

\[
\alpha = 0.049 \left(\frac{m_\mathrm{WDM}}{\mathrm{keV}}\right)^{-1.11} \left(\frac{\Omega_m}{0.25}\right)^{0.11} \left(\frac{h}{0.7}\right)^{1.22} \; [h^{-1}\,\mathrm{Mpc}]
\]

### Bode+2001 (`'bode'`)

From Bode, Ostriker & Turok (2001), ApJ 556, 93, Eq. 16:

\[
T_\mathrm{WDM}(k) = \left[1 + (\alpha k)^{2\nu}\right]^{-5/\nu}
\]

\[
\alpha = 0.048 \left(\frac{\Omega_m}{0.4}\right)^{0.15} \left(\frac{h}{0.65}\right)^{1.3} \left(\frac{\mathrm{keV}}{m_\mathrm{WDM}}\right)^{1.15} \left(\frac{1.5}{g_\mathrm{eff}}\right)^{0.29}
\]

The shape parameter \(\nu\) and effective degrees of freedom \(g_\mathrm{eff}\) can be set via name-value pairs. Defaults: `nu = 1.2`, `g_eff = 1.5`.

**Required field:** `cosmo.m_wdm_keV` (thermal relic mass in keV)

**Usage:**
```matlab
cosmo.transfer_model = 'viel05';
cosmo.m_wdm_keV      = 3.0;
cosmo = cosmology('Planck18', cosmo);
```

---

## T_Schive25 — Fuzzy Dark Matter (FDM)

**File:** `T_Schive25.m`  
**Key:** used internally by `'schive25'`

Implements the FDM transfer function from Schive (2025, Living Reviews in Comp. Astrophysics), Eqs. 19–20, based on the original fitting formula by Hu et al. (2000):

\[
T_\mathrm{FDM}(k) = \frac{\cos(x^3)}{1 + x^8}, \quad x = \frac{1.61\, m_{22}^{1/18}\, k}{k_{J,\mathrm{eq}}}
\]

\[
k_{J,\mathrm{eq}} = 9\, m_{22}^{1/2} \quad [\mathrm{Mpc}^{-1}]
\]

where \(m_{22} = m_a / (10^{-22}\,\mathrm{eV})\). Note that `k` here is in Mpc\(^{-1}\) (not h/Mpc).

The suppression is redshift-independent; it is fixed by quantum pressure during the radiation-dominated era.

**Required field:** `cosmo.m22`

**Usage:**
```matlab
cosmo.transfer_model = 'schive25';
cosmo.m22            = 1.0;   % m_a = 1e-22 eV
cosmo = cosmology('Planck18', cosmo);
```

---

## T_total_suppressed — Composite Transfer Function

**File:** `T_total_suppressed.m`  
**Key:** used internally

Combines a base CDM transfer function and a suppression factor:

\[
T_\mathrm{tot}(k) = T_\mathrm{supp}(k) \cdot T_\mathrm{base}(k)
\]

Used internally by `attach_linear_components` for all beyond-CDM models (`viel05`, `bode01`, `schive25`). Not called directly by the user.

---

## CAMB Interface

**File:** `camb_power.m`  
**Key:** `'camb'`

Calls CAMB through the MATLAB Python interface (`pyrun`) to compute the linear matter power spectrum. Requires a working Python installation with the `camb` package.

**Required fields:**
- `cosmo.python_exe` — full path to the Python executable
- `cosmo.camb_transfer_file` — file path for the exported transfer function

**Optional fields:**

| Field | Default | Description |
|---|---|---|
| `cosmo.camb_minkh` | `1e-4` | Minimum k [h/Mpc] |
| `cosmo.camb_maxkh` | `100` | Maximum k [h/Mpc] |
| `cosmo.camb_npoints` | `2000` | Number of k samples |
| `cosmo.As` | — | Primordial amplitude (optional; uses sigma8 otherwise) |

`Pk0` is set by interpolating the tabulated spectrum using pchip. Sigma8 normalization is **not** re-applied for this model.

**Usage:**
```matlab
cosmo.transfer_model    = 'camb';
cosmo.python_exe        = '/usr/bin/python3';
cosmo.camb_transfer_file = 'camb_transfer.mat';
cosmo = cosmology('Planck18', cosmo);
```

---

## AxionCAMB Interface

**Key:** `'axioncamb'`

Loads a precomputed matter power spectrum from an AxionCAMB `.dat` output file (two-column: k, P(k)). Used for FDM models computed with AxionCAMB.

**Required field:** `cosmo.axioncamb_file` — path to the `.dat` file.

`Pk0` is set by pchip interpolation. Sigma8 normalization is **not** re-applied.

---

## Summary Table

| Key | File | DM Model | Analytic | Extra Params |
|---|---|---|---|---|
| `eh98` | `T_EH98.m` | CDM | Yes | — |
| `eh98_full` | `T_EH98_full.m` | CDM | Yes | — |
| `sugiyama95` | `T_Sugiyama95.m` | CDM | Yes | — |
| `viel05` | `T_wdm.m` | WDM | Yes | `m_wdm_keV` |
| `bode01` | `T_wdm.m` | WDM | Yes | `m_wdm_keV`, `g_eff`, `nu` |
| `schive25` | `T_Schive25.m` | FDM | Yes | `m22` |
| `camb` | `camb_power.m` | CDM/any | No (numerical) | `python_exe` |
| `axioncamb` | — | FDM | No (table) | `axioncamb_file` |

---

## Related Pages

- [cosmology.md](cosmology.md)
- [variance.md](variance.md)
- [growth_factor.md](growth_factor.md)
