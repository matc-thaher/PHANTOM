# PHANTOM
PHANTOM
Profile and Halo Analysis for Numerous Theoretical dark Matter Observables



A MATLAB toolbox for computing dark matter halo properties across multiple dark matter models. PHANTOM provides a unified interface for NFW and Einasto halo profiles, concentration–mass relations, suppression transfer functions for non-CDM models, and fuzzy dark matter (FDM) soliton core physics — including the core-halo mass relations of Schive et al., Mocz et al., and Thaher et al. (in prep.).
 
Features
•	Halo density profiles: NFW and Einasto profiles, enclosed mass, and gravitational potential
•	Concentration–mass relations: Bullock et al. (2001), Diemer & Kravtsov (2015), Klypin et al. (2016), and more
•	Suppression factors: Transfer functions for warm dark matter (WDM) and fuzzy dark matter (FDM) relative to CDM
•	FDM soliton core physics: Soliton density profile and three core-halo mass relations:
o	Schive et al. (2014)
o	Mocz et al. (2017)
o	Thaher et al. (in prep.)
•	Cosmological utilities: Critical density, overdensity radii (R200, Rvir), mean density
 
Requirements
•	MATLAB R2020a or later (no additional toolboxes required)
 
Installation
Option 1: Clone and add path (recommended for development)
git clone https://github.com/matc-thaher/PHANTOM.git
addpath(genpath('PHANTOM'))

Add the above addpath line to your startup.m to make it permanent.
Option 2: Download and install .mltbx
Download PHANTOM.mltbx from the Releases page and double-click to install directly into MATLAB Add-Ons.
 
Quick Start
% --- NFW profile ---
r  = logspace(-2, 1, 200);   % radii in Mpc/h
rho0 = 1e7;                  % characteristic density [M_sun / (Mpc/h)^3]
rs   = 0.5;                  % scale radius [Mpc/h]
rho  = phantom.profiles.nfw(r, rho0, rs);

% --- Concentration-mass relation ---
Mvir = 1e12;   % halo mass [M_sun/h]
z    = 0.0;    % redshift
c    = phantom.concentration.diemer(Mvir, z);

% --- FDM core-halo mass relation (Schive et al. 2014) ---
m22   = 1.0;   % FDM particle mass in units of 1e-22 eV
Mhalo = 1e10;  % halo mass [M_sun]
Mc    = phantom.fdm.corehalo_schive(Mhalo, z, m22);

% --- WDM suppression factor ---
k    = logspace(-1, 2, 300);  % wavenumber [h/Mpc]
mWDM = 3.0;                   % WDM particle mass [keV]
T    = phantom.suppression.wdm(k, mWDM);

 
Module Overview
Module	Description
+phantom/+profiles/	NFW and Einasto density profiles, enclosed mass, potential
+phantom/+concentration/	Concentration–mass relations for CDM and FDM
+phantom/+fdm/	FDM soliton profile and core-halo mass relations
+phantom/+suppression/	WDM and FDM transfer function suppression factors
+phantom/+utils/	Cosmological parameters, critical density, overdensity radii

 
Running Tests
cd PHANTOM/tests
run_all_tests

All tests use the MATLAB unit testing framework. Output shows pass/fail for each module.
 
Citation
If you use PHANTOM in your research, please cite the software paper:
Chowdhury, Mohammad Abu Thaher. (2026). PHANTOM: Profile and Halo Analysis for Numerous Theoretical dark Matter Observables. [in preperation]
For the core-halo mass relation introduced in this package, also cite:
Thaher, Mohammad Abu Thaher et al. (in prep.). [Core-halo mass relation paper title].
BibTeX entries are provided in CITATION.cff.
 
Related Papers Implemented
•	Schive, H.-Y., Chiueh, T., & Broadhurst, T. (2014). Cosmic structure as the quantum interference of a coherent dark wave. Nature Physics, 10, 496–499.
•	Mocz, P. et al. (2017). Galaxy formation with BECDM. MNRAS, 471, 4559–4570.
•	Navarro, J. F., Frenk, C. S., & White, S. D. M. (1997). A universal density profile from hierarchical clustering. ApJ, 490, 493.
•	Diemer, B. & Kravtsov, A. V. (2015). A universal model for halo concentrations. ApJ, 799, 108.
 
Contributing
See CONTRIBUTING.md for how to report bugs, request features, or contribute code.
 
License
MIT License. See LICENSE for details.

