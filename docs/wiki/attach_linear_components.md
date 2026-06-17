# attach_linear_components

**File:** `attach_linear_components.m`

`attach_linear_components` is called automatically inside `cosmology()`. It wires up all linear perturbation theory function handles onto the `cosmo` struct: growth factor, transfer function, power spectrum, and variance. Users do not normally call this directly.

```matlab
cosmo = attach_linear_components(cosmo)
```

---

## What It Does

The function works through a fixed sequence of assignments:

### 1. Growth Factor

Selects between the standard flat-ΛCDM approximation and the extended solver based on cosmology flags:

```
cosmo.relspecies = true   →  growth_factor_D_ext
cosmo.flat       = false  →  growth_factor_D_ext
cosmo.de_model  ≠ 'lambda'→  growth_factor_D_ext
otherwise                 →  growth_factor_D        (EH98 analytic, default)
```

Assigned as: `cosmo.D = @(z) growth_factor_D(z, cosmo)`

See [growth_factor.md](growth_factor.md) for full documentation.

### 2. Transfer Function

Dispatches on `cosmo.transfer_model`:

| `transfer_model` | Assigned `cosmo.T` |
|---|---|
| `'eh98'` (default) | `T_EH98(k, cosmo)` |
| `'eh98_full'` | `T_EH98_full(k, cosmo)` |
| `'sugiyama95'` | `T_Sugiyama95(k, cosmo)` |
| `'viel05'` | `T_total_suppressed` ( `T_EH98` × `T_wdm(...,'viel')` ) |
| `'bode01'` | `T_total_suppressed` ( `T_EH98` × `T_wdm(...,'bode')` ) |
| `'schive25'` | `T_total_suppressed` ( `T_EH98` × `T_Schive25` ) |
| `'camb'` | Interpolated from `camb_power` table |
| `'axioncamb'` | Interpolated from `.dat` file |

For WDM and FDM models, the base CDM transfer can be changed via `cosmo.viel05_base`, `cosmo.bode01_base`, or `cosmo.schive25_base` (options: `'eh98'`, `'eh98_full'`, `'sugiyama95'`; default `'eh98'`).

For `camb`, CAMB optional parameters are validated here (`python_exe`, `camb_minkh`, `camb_maxkh`, `camb_npoints`).

See [transfer_functions.md](transfer_functions.md) for details.

### 3. Variance Filter

Sets `cosmo.variance_filter = 'tophat'` if not already provided.  
Sets `cosmo.filter_c = 1.0` if not provided.

### 4. Power Spectrum

For analytic transfer models:

```
cosmo.Pk0_unnorm = @(k) k.^ns .* T(k).^2
A                = normalize_A_to_sigma8(cosmo)
cosmo.Pk0        = @(k) A * Pk0_unnorm(k)
```

For `camb` and `axioncamb`, `cosmo.Pk0` is set directly from the tabulated spectrum without re-normalization.

The redshift-dependent spectrum is:

\[
P(k, z) = P_0(k) \left(\frac{D(z)}{D(0)}\right)^2
\]

Assigned as: `cosmo.Pk = @(k, z) cosmo.Pk0(k) .* (cosmo.D(z)/cosmo.D(0)).^2`

### 5. Variance and Mass Functions

```matlab
cosmo.sigmaR = @(R, z, varargin) sigma_R(R, z, cosmo, varargin{:})
cosmo.R_of_M = @(M) (1/filter_c) * (3*M / (4*pi*rho_m0)).^(1/3)
cosmo.sigmaM = @(M, z, varargin) cosmo.sigmaR(cosmo.R_of_M(M), z, varargin{:})
```

### 6. Spectral Index and Correlation

```matlab
cosmo.neff             = @(M, z, kappa) neff(M, z, kappa, cosmo)
cosmo.alphaEff         = @(z) alphaEff(z, cosmo)
cosmo.correlationFunction = @(R, z, varargin) correlation_function(R, z, cosmo, varargin{:})
```

`cosmo.corr_method` defaults to `'integral'` if not set.

---

## Related Pages

- [cosmology.md](cosmology.md)
- [transfer_functions.md](transfer_functions.md)
- [growth_factor.md](growth_factor.md)
- [variance.md](variance.md)
