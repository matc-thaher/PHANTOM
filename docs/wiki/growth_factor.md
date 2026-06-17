# Growth Factor

The linear growth factor \(D(z)\) describes how density perturbations grow over cosmic time in the linear regime. PHANTOM implements four growth factor routines covering flat ΛCDM, non-flat cosmologies, radiation corrections, and non-standard dark energy. The routing logic lives in `growth_factor_D_ext.m`, which selects the appropriate solver based on the cosmology configuration.

All growth factors are normalized so that \(D(0) = 1\).

---

## growth_factor_D — Flat ΛCDM (Default)

**File:** `growth_factor_D.m`

Implements the analytic approximation from Eisenstein & Hu (1998), Appendix. Valid for flat ΛCDM without radiation. This is the default used by `attach_linear_components` unless the cosmology requires an extended treatment.

\[
D(z) = \frac{a \, g(a)}{g(1)}, \quad a = \frac{1}{1+z}
\]

\[
g(a) = \frac{5\,\Omega_m(a)}{2}\left[\Omega_m(a)^{4/7} - \Omega_\Lambda(a) + \left(1 + \frac{\Omega_m(a)}{2}\right)\left(1 + \frac{\Omega_\Lambda(a)}{70}\right)\right]^{-1}
\]

where \(\Omega_m(a)\) and \(\Omega_\Lambda(a)\) are the scale-factor-dependent matter and dark-energy fractions.

```matlab
D = growth_factor_D(z, cosmo)
```

---

## growth_factor_D_ext — Dispatcher

**File:** `growth_factor_D_ext.m`

Routes to the appropriate growth solver based on the presence of radiation, curvature, and dark-energy model flags. Called by `attach_linear_components` when any non-standard flag is detected.

| Condition | Solver used |
|---|---|
| Flat ΛCDM, no radiation | `growth_factor_D` (EH98 analytic) |
| Non-flat ΛCDM, no radiation | `growth_integral` (Heath 1977 integral) |
| Flat ΛCDM + radiation | `growth_with_radiation` (hybrid integral + Gnedin) |
| Non-ΛCDM dark energy (w0, w0wa) | `growth_ODE` (Linder & Jenkins 2003 ODE) |

```matlab
D = growth_factor_D_ext(z, cosmo)
```

The conditions check for `cosmo.relspecies`, `cosmo.flat`, and `cosmo.de_model` fields.

---

## growth_integral — Heath/EH99 Integral

**File:** `growth_integral.m`

Computes the growth factor via the Heath (1977)/Peebles (1980) integral, valid for non-flat cosmologies without radiation:

\[
D(z) \propto E(z) \int_z^\infty \frac{1+z'}{E(z')^3}\,\mathrm{d}z'
\]

Normalized to \(D(0) = 1\) by dividing by the \(z=0\) value. Numerical integration is performed with MATLAB's `integral` at `RelTol = 1e-4`.

```matlab
D = growth_integral(z, cosmo)
```

---

## growth_with_radiation — Radiation-Inclusive Growth

**File:** `growth_with_radiation.m`

Handles cosmologies with relativistic species (`cosmo.relspecies = true`). Uses three regimes joined in log-scale:

- **Low-z** (\(z \leq 5\)): Heath integral with radiation term \(\Omega_r(1+z)^4\) held constant to avoid divergence at high redshift (same approach as COLOSSUS)
- **High-z** (\(z \geq 20\)): Gnedin et al. (2011), Eq. 5 analytic approximation valid in the matter-radiation regime
- **Transition** (\(5 < z < 20\)): Linear interpolation in \(\log a\)

The Gnedin approximation:

\[
D_g(a) = a + \frac{2}{3}a_\mathrm{eq} + \frac{a_\mathrm{eq}}{2\ln 2 - 3} \cdot \left[2\sqrt{1+x} + \left(\frac{2}{3}+x\right)\ln\frac{\sqrt{1+x}-1}{\sqrt{1+x}+1}\right]
\]

where \(x = a/a_\mathrm{eq}\) and \(a_\mathrm{eq} = \Omega_r/\Omega_m\).

```matlab
D = growth_with_radiation(z, cosmo)
```

---

## growth_ODE — Non-ΛCDM Dark Energy

**File:** `growth_ODE.m`

Solves the Linder & Jenkins (2003), Eq. 11 ODE for \(G = D/a\), valid for arbitrary dark energy with equation of state \(w(a) = w_0 + w_a(1-a)\) (CPL parametrization):

\[
G'' + \left(\frac{3.5 - 1.5\,w/(1+X)}{a}\right) G' + \frac{1.5(1-w)}{(1+X)\,a^2} G = 0
\]

where \(X(a) = \Omega_m a^{-3} / \rho_\mathrm{DE}(a)\) is the matter-to-dark-energy ratio.

The ODE is solved with `ode45` (`RelTol = AbsTol = 1e-6`) over the range \([a_\min, a_\max]\). Initial conditions are \(G(a_\min) = 1\), \(G'(a_\min) = 0\). Results are normalized to \(D(0) = 1\).

```matlab
D = growth_ODE(z, cosmo)
```

**Required fields:** `cosmo.de_model` (`'w0'` or `'w0wa'`), `cosmo.w0`, and optionally `cosmo.wa`.

---

## Enabling Extended Growth

To activate the extended growth solver, set any of the following flags before calling `cosmology()`:

```matlab
% Include radiation
cosmo.relspecies = true;

% Non-flat universe
cosmo.flat   = false;
cosmo.Omega_L = 0.68;

% w0CDM dark energy
cosmo.de_model = 'w0';
cosmo.w0       = -0.9;

% CPL dark energy
cosmo.de_model = 'w0wa';
cosmo.w0       = -0.9;
cosmo.wa       = 0.1;

cosmo = cosmology('Planck18', cosmo);
D_z1 = cosmo.D(1.0);
```

---

## Related Pages

- [cosmology.md](cosmology.md)
- [variance.md](variance.md)
- [time_calculations.md](time_calculations.md)
