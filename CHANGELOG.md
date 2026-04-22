Changelog
All notable changes to PHANTOM will be documented in this file.
The format follows Keep a Changelog.
PHANTOM uses Semantic Versioning: MAJOR.MINOR.PATCH.
 
Unreleased
Changes staged for the next release will appear here.
 
1.0.0 — 2026-04-22
Added
Halo Profiles (+phantom/+profiles/)
•	nfw.m — Navarro-Frenk-White (NFW) density profile
•	nfw_mass.m — NFW enclosed mass within radius r
•	nfw_potential.m — NFW gravitational potential
•	einasto.m — Einasto density profile
Concentration–Mass Relations (+phantom/+concentration/)
•	bullock.m — Bullock et al. (2001) concentration model
•	diemer.m — Diemer & Kravtsov (2015) concentration model
•	klypin.m — Klypin et al. (2016) concentration model
Fuzzy Dark Matter (+phantom/+fdm/)
•	soliton_profile.m — FDM soliton (ground-state) density profile
•	corehalo_schive.m — Core-halo mass relation from Schive et al. (2014)
•	corehalo_mocz.m — Core-halo mass relation from Mocz et al. (2017)
•	corehalo_mine.m — Core-halo mass relation from Thaher et al. (in prep.)
Suppression Factors (+phantom/+suppression/)
•	wdm.m — WDM transfer function suppression factor (Bode et al. 2001 fitting form)
•	fdm.m — FDM suppression factor relative to CDM power spectrum
Utilities (+phantom/+utils/)
•	cosmology_params.m — Default Planck 2018 cosmological parameters
•	critical_density.m — Critical density as a function of redshift
•	overdensity_radius.m — R200c, R200m, and Rvir computation
Tests (tests/)
•	Unit tests for all modules using the MATLAB testing framework
•	run_all_tests.m — Master test runner script
Examples (examples/)
•	example_nfw_concentration.m — NFW profile and concentration demo
•	example_fdm_soliton.m — FDM soliton and core-halo mass demo
•	example_suppression_factor.m — WDM and FDM suppression factor demo
•	example_corehalo_comparison.m — Comparison of all three core-halo mass relations
 
Version History Summary
Version	Date	Notes
1.0.0	2026-04-22	Initial public release

 
