# PHANTOM

**P**rofile and **H**alo **A**nalysis for **N**umerous **T**heoretical dark **M**atter **O**bservables

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-blue.svg)](https://www.mathworks.com)
[![DOI](https://zenodo.org/badge/1214330711.svg)](https://doi.org/10.5281/zenodo.19700919)
[![GitHub Release](https://img.shields.io/github/v/release/matc-thaher/PHANTOM?label=Release&color=brightgreen)](https://github.com/matc-thaher/PHANTOM/releases/latest)



A MATLAB toolbox for computing dark matter halo properties across multiple dark matter models. PHANTOM provides a unified interface for NFW and Einasto halo profiles, concentration–mass relations, suppression transfer functions for non-CDM models, and fuzzy dark matter (FDM) soliton core physics — including the core-halo mass relations of Schive et al., Mocz et al., and Thaher et al. (in prep.).
 
## Features
- **Halo density profiles:** NFW and Einasto profiles, enclosed mass, and gravitational potential
- **Concentration–mass relations:** Bullock et al. (2001), Diemer & Kravtsov (2015), Klypin et al. (2016), and more
- **Suppression factors:** Transfer functions for WDM and FDM relative to CDM
- **FDM soliton core physics:** Soliton density profile and three core-halo mass relations:
  - Schive et al. (2014)
  - Mocz et al. (2017)
  - Thaher et al. (in prep.)
- **Cosmological utilities:** Critical density, overdensity radii (R200, Rvir), mean density

## Requirements
- MATLAB R2020a or later (no additional toolboxes required)
 
Requirements
•	MATLAB R2020a or later (no additional toolboxes required)
 
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

 
## Module Overview

| Folder | Functions | Description |
|---|---|---|
| `src/profiles/` | `NFW_profile`, `Einasto_profile`, `Soliton_profile`, `Hernquist_profile` | Halo density profiles, enclosed mass, gravitational potential |
| `src/concentration/` | `Diemer15`, `Diemer19`, `Bullock01`, `Duffy08`, `Dutton14`, `Klypin11`, `Klypin16`, `Prada12`, `Child18`, `Ishiyama21`, `Ludlow16`, `c_CDM` | Concentration–mass relations for CDM and FDM |
| `src/suppression/` | `suppression_factor`, `c_FDM` | WDM and FDM transfer function suppression factors |
| `src/utils/` | `cosmology`, `radius_from_mass`, `sigma_R`, `growth_factor_D`, `neff` | Cosmological parameters, critical density, overdensity radii |
| `tests/` | `run_all_tests`, `test_*.m` | Unit tests for all modules |

 
Running Tests
cd PHANTOM/tests
run_all_tests

All tests use the MATLAB unit testing framework. Output shows pass/fail for each module.
 
## Citation

If you use PHANTOM in your research, please cite the software paper:

Chowdhury, Mohammad Abu Thaher. (2026). *PHANTOM: Profile and Halo Analysis for
Numerous Theoretical dark Matter Observables*. Zenodo.
[https://doi.org/10.5281/zenodo.19700919](https://doi.org/10.5281/zenodo.19700919)

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

> Chowdhury, Mohammad Abu Thaher et al. (in prep.). [Core-halo mass relation paper title].
 
Related Papers Implemented
•	Schive, H.-Y., Chiueh, T., & Broadhurst, T. (2014). Cosmic structure as the quantum interference of a coherent dark wave. Nature Physics, 10, 496–499.
•	Mocz, P. et al. (2017). Galaxy formation with BECDM. MNRAS, 471, 4559–4570.
•	Navarro, J. F., Frenk, C. S., & White, S. D. M. (1997). A universal density profile from hierarchical clustering. ApJ, 490, 493.
•	Diemer, B. & Kravtsov, A. V. (2015). A universal model for halo concentrations. ApJ, 799, 108.
 
Contributing
See CONTRIBUTING.md for how to report bugs, request features, or contribute code.
 
License
MIT License. See LICENSE for details.

