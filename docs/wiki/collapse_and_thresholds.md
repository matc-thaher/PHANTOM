# Collapse Overdensity and Density Thresholds

These utilities compute the linear collapse overdensity \(\delta_c\), the virial overdensity \(\Delta_\mathrm{vir}\), halo density thresholds, and beyond-CDM collapse corrections relevant for FDM cosmologies.

---

## collapse_overdensity

**File:** `collapse_overdensity.m`

Returns the linear collapse overdensity \(\delta_c\) for spherical collapse.

In an Einstein-de Sitter universe the exact value is:

\[
\delta_c^\mathrm{EdS} = \frac{3}{5}\left(\frac{3\pi}{2}\right)^{2/3} \approx 1.6865
\]

For realistic flat ΛCDM cosmologies the correction is less than 3%. When `corrections = true`, the Kitayama & Suto (1996), Eq. A6 fitting formula is applied:

\[
\delta_c(z) = \delta_c^\mathrm{EdS} \times \begin{cases} \Omega_m(z)^{0.0055} & \text{flat} \\ \Omega_m(z)^{0.0185} & \text{non-flat} \end{cases}
\]

```matlab
delta_c = collapse_overdensity()
delta_c = collapse_overdensity('corrections', true, 'z', z, 'cosmo', cosmo)
```

**Name-value pairs:**

| Argument | Type | Description |
|---|---|---|
| `'corrections'` | logical | Apply Ω_m(z) correction (default: `false`) |
| `'z'` | scalar | Redshift (required if corrections = true) |
| `'cosmo'` | struct | PHANTOM cosmo struct (required if corrections = true) |

After `cosmology()` is called, `cosmo.delta_c(z)` wraps this with corrections enabled by default.

---

## collapse_overdensity_fdm

**File:** `collapse_overdensity_fdm.m`

Returns the mass-dependent FDM collapse threshold \(\delta_c(M, z)\), which is enhanced relative to CDM below the Jeans mass due to quantum pressure support.

Based on Du et al. (2016) and Marsh (2016a), Eqs. 11–14:

\[
\delta_c^\mathrm{FDM}(M) = G(M) \cdot \delta_c^\mathrm{CDM}
\]

where \(G(M)\) is a smooth enhancement factor:

\[
G(M) = h_F(x)\,e^{a_3 x^{-a_4}} + [1 - h_F(x)]\,e^{a_5 x^{-a_6}}
\]

\[
h_F(x) = \frac{1}{2}\left[1 - \tanh\!\left(M_J\,(x - a_2)\right)\right], \quad x = M/M_J
\]

with best-fit parameters \(\{a_1, a_2, a_3, a_4, a_5, a_6\} = \{3.4, 1.0, 1.8, 0.5, 1.7, 0.9\}\).

The FDM Jeans mass \(M_J\) (Du et al. 2016, Eq. 14):

\[
M_J = \frac{10^8\,a_1\,m_{22}^{-3/2}}{h} \left(\frac{\Omega_m h^2}{0.14}\right)^{0.25} \; [h^{-1}\,M_\odot]
\]

By construction, \(G(M) \geq 1\) — values below the CDM baseline are unphysical and are clipped.

```matlab
delta_c = collapse_overdensity_fdm(M, cosmo)
delta_c = collapse_overdensity_fdm(M, cosmo, 'z', z, 'corrections', true)
```

**Required field:** `cosmo.m22` (FDM boson mass in units of \(10^{-22}\) eV)

---

## delta_vir_bn98 — Virial Overdensity

**File:** `delta_vir_bn98.m`

Computes the virial overdensity \(\Delta_\mathrm{vir}(z)\) relative to the critical density, using the Bryan & Norman (1998) fitting formula:

\[
\Delta_\mathrm{vir}(z) = 18\pi^2 + 82\,x - 39\,x^2, \quad x = \Omega_m(z) - 1
\]

Valid for flat ΛCDM. Approaches 178 in EdS (\(x = 0\)) and varies with matter domination fraction at higher z.

```matlab
Delta_vir = delta_vir_bn98(z, cosmo)
```

---

## density_threshold

**File:** `density_threshold.m`

Returns the physical density threshold \(\rho_\mathrm{th}(z)\) for a given mass definition string.

```matlab
rho_th = density_threshold(z, mdef, cosmo)
```

**Mass definition strings:**

| `mdef` | Threshold |
|---|---|
| `'200c'` | \(200 \times \rho_\mathrm{crit}(z)\) |
| `'500c'` | \(500 \times \rho_\mathrm{crit}(z)\) |
| `'200m'` | \(200 \times \rho_m(z)\) |
| `'vir'` | \(\Delta_\mathrm{vir}(z) \times \rho_\mathrm{crit}(z)\) via Bryan & Norman (1998) |

Mass definition parsing is handled by `parse_mass_definition.m`, which splits the string into a type (`'c'`, `'m'`, `'vir'`) and a numeric overdensity delta.

---

## halfmode_mass

**File:** `halfmode_mass.m`

Computes the half-mode mass scale \(M_\mathrm{hm}\) below which the power spectrum is suppressed by half.

### WDM (Schneider et al. 2012)

Based on Schneider et al. (2012), MNRAS 424, 684, Eqs. 5, 8, 9, using the Viel+2005 transfer function with \(\mu = 1.12\):

\[
\alpha_\mathrm{fs} = 0.049 \left(\frac{m_\mathrm{WDM}}{\mathrm{keV}}\right)^{-1.11} \left(\frac{\Omega_m}{0.25}\right)^{0.11} \left(\frac{h}{0.7}\right)^{1.22}
\]

\[
\lambda_\mathrm{hm} = 2\pi\,\alpha_\mathrm{fs}\left(2^{\mu/5} - 1\right)^{-1/(2\mu)}
\]

\[
M_\mathrm{hm} = \frac{4\pi}{3}\,\rho_{m,0}\left(\frac{\lambda_\mathrm{hm}}{2}\right)^3 \quad [h^{-1}\,M_\odot]
\]

### FDM (Schive et al. 2016)

\[
M_\mathrm{hm} = 3.8 \times 10^{10}\,m_{22}^{-4/3} \quad [M_\odot]
\]

```matlab
M_hm = halfmode_mass('WDM', m_WDM_keV, cosmo)
M_hm = halfmode_mass('FDM', m22)
```

---

## Peak Height

`cosmo.nu(M, z)` is a convenience handle attached by `cosmology()`:

\[
\nu(M, z) = \frac{\delta_c(z)}{\sigma(M, z)}
\]

Used directly in Press-Schechter and Sheth-Tormen mass function calculations.

---

## Related Pages

- [cosmology.md](cosmology.md)
- [variance.md](variance.md)
- [transfer_functions.md](transfer_functions.md)
