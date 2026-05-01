Welcome to the PHANTOM wiki!


# PHANTOM
### Profile and Halo Analysis for Numerous Theoretical Dark Matter Observables

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-blue.svg)](https://www.mathworks.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/1214330711.svg)](https://doi.org/10.5281/zenodo.19700919)
[![GitHub Release](https://img.shields.io/github/v/release/matc-thaher/PHANTOM?label=Release&color=brightgreen)](https://github.com/matc-thaher/PHANTOM/releases/latest)

---

PHANTOM is an open-source MATLAB toolbox for computing dark matter halo properties across multiple dark matter models. It provides a unified, modular interface for:

- **Halo density profiles:** NFW and Einasto profiles, enclosed mass, and gravitational potential
- **Concentration–mass relations:** Bullock et al. (2001), Diemer & Kravtsov (2015), Klypin et al. (2016), and more
- **Suppression factors:** Transfer functions for WDM and FDM relative to CDM
- **FDM soliton core physics:** Soliton density profile and three core-halo mass relations:
  - Schive et al. (2014)
  - Mocz et al. (2017)
  - Thaher et al. (in prep.)
- **Cosmological utilities:** Critical density, overdensity radii (R200, Rvir), mean density

PHANTOM is developed and maintained by **Mohammad Abu Thaher Chowdhury**.

---

## Requirements

| Requirement | Details |
|---|---|
| MATLAB | R2020a or later |
| Toolboxes | None required |
| GNU Octave | Core functions compatible (see [Octave Compatibility](Octave-Compatibility)) |

---

## Quick Start

```matlab
% Set up cosmology (Planck18 by default)
cosmo = cosmology();            % uses Planck 2018 parameters
% cosmo = cosmology('WMAP9');   % or choose: 'Planck18', 'Uchuu', 'WMAP9'
% cosmo = cosmology('custom', myparams); % or supply your own

% --- NFW density profile ---
r    = logspace(-2, 1, 200);   % radii [Mpc/h]
rhos = 1e7;                    % characteristic density [Msun/kpc^3]
rs   = 0.5;                    % scale radius [Mpc/h]
rho  = NFW_profile(r, rhos, rs);

% --- Concentration-mass relation (Diemer & Kravtsov 2015) ---
M200c = 1e12;                  % halo mass M_200c [Msun/h]
z     = 0.0;                   % redshift
c     = Diemer15(M200c, z, cosmo);

% --- Concentration-mass relation (Bullock et al. 2001) ---
c_B01 = Bullock01(M200c, z, cosmo);

% --- WDM/FDM suppression factor ---
T = suppression_factor(cosmo);
```

→ See **[Installation](Installation)** for full setup instructions.

***

## Installation

### Option 1: Clone and add path *(recommended for development)*

```bash
git clone https://github.com/matc-thaher/PHANTOM.git
```

Then in MATLAB:

```matlab
addpath(genpath('PHANTOM'))
```

> **Tip:** To make this permanent across sessions, add the line above to your
> [`startup.m`](https://www.mathworks.com/help/matlab/ref/startup.html) file.
> Run `edit startup.m` in MATLAB to open or create it.

### Option 2: Install via `.mltbx` *(recommended for users)*

1. Download [`PHANTOM.mltbx`](https://github.com/matc-thaher/PHANTOM/releases/download/V1.0/PHANTOM.mltbx)
   from the [Releases page](https://github.com/matc-thaher/PHANTOM/releases/latest)
2. Double-click the file — MATLAB will install it automatically
3. Verify installation in MATLAB:

```matlab
addons = matlab.addons.toolbox.installedToolboxes();
disp({addons.Name})   % PHANTOM should appear in the list
```

### Verify Your Installation

Whichever option you used, confirm everything works:

```matlab
cosmo = cosmology();          % should run without errors
c     = Diemer15(1e12, 0, cosmo);
fprintf('Concentration: %.4f\n', c)
```

If this prints a number without errors, PHANTOM is installed correctly.

***

## Modules

| Folder | Functions | Description |
|---|---|---|
| `src/profiles/` | `NFW_profile`, `Einasto_profile`, `Soliton_profile`, `Hernquist_profile` | Halo density profiles, enclosed mass, gravitational potential |
| `src/concentration/` | `Diemer15`, `Diemer19`, `Bullock01`, `Duffy08`, `Dutton14`, `Klypin11`, `Klypin16`, `Prada12`, `Child18`, `Ishiyama21`, `Ludlow16`, `c_CDM` | Concentration–mass relations for CDM and FDM |
| `src/suppression/` | `suppression_factor`, `c_FDM` | WDM and FDM transfer function suppression factors |
| `src/utils/` | `cosmology`, `radius_from_mass`, `sigma_R`, `growth_factor_D`, `neff` | Cosmological parameters, critical density, overdensity radii |
| `tests/` | `run_all_tests`, `test_*.m` | Unit tests for all modules |

***

## Running Tests

```matlab
cd PHANTOM/tests
run_all_tests
```

All tests use the MATLAB unit testing framework. Output shows pass/fail for each module.

---

## Documentation Pages

| Page | Description |
|---|---|
| [Installation](Installation) | Clone, path setup, and `.mltbx` install option |
| [Halo Profiles](Halo-Profile) | NFW, Einasto, Soliton, Hernquist — function list and usage |
| [Concentration Relations](Concentration-Relations) | All supported concentration–mass models |
| [FDM Soliton Physics](FDM-Soliton) | Soliton profile and core-halo mass relations |
| [Suppression Functions](Suppression-Functions) | WDM and FDM transfer functions |
| [Cosmological Utilities](Cosmological-Utilities) | Critical density, R200, Rvir |
| [Octave Compatibility](Octave-Compatibility) | Notes on running PHANTOM in GNU Octave |

> 📌 This wiki is actively being built. Pages are added incrementally — check back for updates.

---

## Citation

If you use PHANTOM in your research, please cite the software paper:

Chowdhury, Mohammad Abu Thaher. (2026). *PHANTOM: Profile and Halo Analysis for
Numerous Theoretical dark Matter Observables*. Zenodo.
https://doi.org/10.5281/zenodo.19700919

```bibtex
@software{chowdhury_2026_phantom,
  author    = {Chowdhury, Mohammad Abu Thaher},
  title     = {PHANTOM: Profile and Halo Analysis for Numerous
               Theoretical dark Matter Observables},
  year      = {2026},
  publisher = {Zenodo},
  doi       = {10.5281/zenodo.19700919},
  url       = {https://doi.org/10.5281/zenodo.19700919}
}
```

For the core-halo mass relation introduced in this package, also cite:

> Chowdhury, Mohammad Abu Thaher et al. (in prep.). *[Core-halo mass relation paper title]*.

***

## Related Papers Implemented

- Schive, H.-Y., Chiueh, T., & Broadhurst, T. (2014). Cosmic structure as the quantum interference of a coherent dark wave. *Nature Physics*, 10, 496–499.
- Mocz, P. et al. (2017). Galaxy formation with BECDM. *MNRAS*, 471, 4559–4570.
- Navarro, J. F., Frenk, C. S., & White, S. D. M. (1997). A universal density profile from hierarchical clustering. *ApJ*, 490, 493.
- Diemer, B. & Kravtsov, A. V. (2015). A universal model for halo concentrations. *ApJ*, 799, 108.
- Bullock, J. S. et al. (2001). Profiles of dark haloes. *MNRAS*, 321, 559–575.
- Klypin, A. et al. (2016). MultiDark simulations. *MNRAS*, 457, 4340–4359.

***

## Contributing & Issues

Found a bug or want to request a feature?
→ Open an [Issue](https://github.com/matc-thaher/PHANTOM/issues) or see
[CONTRIBUTING.md](https://github.com/matc-thaher/PHANTOM/blob/main/CONTRIBUTING.md).

***

*MIT License — see [LICENSE](https://github.com/matc-thaher/PHANTOM/blob/main/LICENSE)*
```

---

**How to use this:**
1. In your GitHub repo, go to the **Wiki** tab
2. Click **Edit** on the Home page (or create it if new)
3. Paste the entire block above and save

> ⚠️ Note: The closing triple-backticks in the code blocks above have a stray space (` `` `) to avoid breaking the outer markdown fence here — remove that space so they render as ` ``` ` in your actual wiki file.