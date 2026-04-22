Contributing to PHANTOM
Thank you for your interest in PHANTOM! Contributions, bug reports, and suggestions are welcome from anyone in the astrophysics and dark matter community.
 
Reporting Bugs
If you find a bug, please open an issue on GitHub and include:
1.	Your MATLAB version (run version in MATLAB)
2.	Operating system (Windows / macOS / Linux)
3.	A minimal working example that reproduces the problem
4.	The full error message or unexpected output
 
Suggesting Features
Feature requests are welcome. Please open an issue and describe:
•	What you want the new feature to do
•	Why it would be useful to the community
•	Any relevant paper or formula you have in mind
 
Contributing Code
Getting Started
1.	Fork the repository on GitHub
2.	Clone your fork:
git clone https://github.com/YOUR-USERNAME/PHANTOM.git

3.	Create a new branch for your feature or fix:
git checkout -b feature/your-feature-name

Code Style
•	Follow the existing folder and namespace structure (+phantom/+module/function.m)
•	Use descriptive variable names; avoid single-letter variables except for standard physics notation (e.g., r, z, k)
•	Include a header comment block in every .m file:
function rho = nfw(r, rho0, rs)
% NFW  Navarro-Frenk-White density profile.
%
%   RHO = NFW(R, RHO0, RS) returns the NFW density at radii R given
%   characteristic density RHO0 and scale radius RS.
%
%   Inputs:
%     r     - Radii [Mpc/h], scalar or array
%     rho0  - Characteristic density [M_sun (Mpc/h)^-3]
%     rs    - Scale radius [Mpc/h]
%
%   Output:
%     rho   - Density at r [M_sun (Mpc/h)^-3]
%
%   Reference: Navarro, Frenk & White (1997), ApJ 490, 493.

•	Add a corresponding test in tests/ for any new function
Writing Tests
Tests use the MATLAB unit testing framework. Follow the pattern in existing test files:
function tests = test_nfw_profile
tests = functiontests(localfunctions);

function test_output_shape(testCase)
r = logspace(-1, 1, 50);
rho = phantom.profiles.nfw(r, 1e7, 0.5);
verifySize(testCase, rho, size(r));

function test_known_value(testCase)
rho = phantom.profiles.nfw(1.0, 1.0, 1.0);
verifyEqual(testCase, rho, 0.25, 'AbsTol', 1e-10);

Submitting a Pull Request
1.	Make sure all tests pass: run run_all_tests in the tests/ folder
2.	Push your branch to your fork
3.	Open a Pull Request on GitHub against the main branch
4.	Describe your changes clearly in the PR description
 
Contact
For questions not suited to a GitHub issue, you can reach the maintainer at:
[your university email]
 
Code of Conduct
Be respectful. This project follows standard open-source community norms.
