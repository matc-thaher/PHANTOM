function rho = DK14_profile(r, M, c, z, cosmo, Delta, selected_by, Gamma, include_outer)
% DK14_profile  Diemer & Kravtsov (2014) density profile
%
%   rho = DK14_profile(r, M, c, z, cosmo, Delta)
%   rho = DK14_profile(r, M, c, z, cosmo, Delta, selected_by)
%   rho = DK14_profile(r, M, c, z, cosmo, Delta, selected_by, Gamma)
%   rho = DK14_profile(r, M, c, z, cosmo, Delta, selected_by, Gamma, include_outer)
%
%   The DK14 profile multiplies an Einasto inner profile by a truncation
%   (splashback) function and optionally adds a power-law outer term:
%
%     rho(r) = rho_inner(r) * f_trans(r)              [default]
%     rho(r) = rho_inner(r) * f_trans(r) + rho_outer  [include_outer = true]
%
%
%   where
%     rho_inner(r) : Einasto profile via Einasto_profile.m
%                    (alpha_e from Gao+2008 inside that function)
%     f_trans(r)   = [ 1 + (r/rt)^beta ]^(-gamma_t/beta)
%     rho_outer(r) = rho_m * b_e * (r/r_ref)^(-s_e)
%
%   PARAMETER DEFAULTS  (following Colossus / DK14 deriveParameters logic)
%   -----------------------------------------------------------------------
%   selected_by = 'M'  (mass-selected sample)
%       beta    = 4
%       gamma_t = 8
%       rt      = R200m * (1.9 - 0.18*nu200m)          [DK14 eq. 6]
%
%   selected_by = 'Gamma'  (mass + accretion-rate selected sample)
%       beta    = 6
%       gamma_t = 4
%       rt      = R200m * 0.54 * (1 + 0.53*exp(-Gamma)) [DK14 Gamma form]
%       Both z and Gamma must be provided.
%
%   Outer term defaults:
%       s_e   = 1.5   (outer power-law slope)
%       rho_m = cosmo.rho_m0 * (1+z)^3  (mean matter density at z)
%
%   INPUTS
%   r             : radii [Mpc/h], scalar or vector
%   M             : halo mass [Msun/h]  (as M_200m)
%   c             : concentration c_200m
%   z             : redshift
%   cosmo         : cosmology struct with fields:
%                     .rho_m0     mean matter density at z=0 [Msun/h/(Mpc/h)^3]
%                     .rhocrit0   critical density at z=0    [Msun/h/(Mpc/h)^3]
%                     .E(z)       E(z) = H(z)/H0 function handle
%                     .nu(M,z)    peak-height function handle
%                     .Omega_m    matter density parameter
%   Delta         : overdensity w.r.t. critical (typically 200)
%   selected_by   : (optional) 'M' [default] or 'Gamma'
%   Gamma         : (optional) mass accretion rate — only used when
%                     selected_by = 'Gamma'
%   include_outer : (optional) logical, default false
%                     false -> inner * f_trans only  (matches bare Colossus DK14Profile)
%                     true  -> inner * f_trans + rho_outer
%
%   OUTPUT
%   rho         : total DK14 density at each r [Msun/h / (Mpc/h)^3]
%
%   DEPENDENCIES
%   Einasto_profile.m  (must reside in the same folder or on the MATLAB path)
%
%   REFERENCES
%   Diemer & Kravtsov 2014, ApJ 789, 1                    (DK14 profile)
%   Diemer 2022, ApJ 925, 182                             (updated form)
%   Gao et al. 2008, MNRAS 387, 536                       (alpha_e via nu)
%   Colossus deriveParameters() documentation
%   https://bdiemer.bitbucket.io/colossus/halo_profile_dk14.html

    % ---- Input defaults -------------------------------------------------
    if nargin < 7 || isempty(selected_by)
        selected_by = 'M';
    end
    if nargin < 8
        Gamma = [];
    end
    if nargin < 9 || isempty(include_outer)
        include_outer = false;
    end

    % If selected_by = 'Gamma' but no Gamma value supplied,
    % fall back silently to mass-selected defaults instead of erroring.
    if strcmp(selected_by, 'Gamma') && isempty(Gamma)
        warning('DK14_profile: selected_by = ''Gamma'' but Gamma is empty. Falling back to mass-selected defaults (beta=4, gamma_t=8).');
        selected_by = 'M';
    end

    r = r(:);

    % ---- Mean matter density at z ---------------------------------------
    rho_m_z  = cosmo.rhom(z);          % mean matter density at z

    % M200m, R200m, nu200m approximation for nu calibration (DK14 eq.6 uses nu_200m)
    [M200m, R200m, ~] = change_mass_definition(M, c, z, Delta, 'c', 200, 'm', cosmo);
    nu200m            = cosmo.nu(M200m, z);    % peak height at M_200m

    % ---- Derive beta, gamma_t, rt  (Colossus deriveParameters logic) ----
    %
    % Case 1: selected_by = 'M'
    %   (beta, gamma_t) = (4, 8)                      [DK14 Table 1]
    %   rt = R200m * (1.9 - 0.18 * nu200m)            [DK14 eq. 6]
    %
    % Case 2: selected_by = 'Gamma'
    %   (beta, gamma_t) = (6, 4)                      [DK14 Table 1]
    %   rt = R200m * 0.54 * (1 + 0.53 * exp(-Gamma))  [DK14 Gamma-based rt]
    %
    % In both cases rt is clipped to a physically reasonable lower bound
    % to avoid rt collapsing to zero for very high-nu halos.
    if strcmp(selected_by, 'M')
        beta    = 4;
        gamma_t = 8;
        rt      = R200m .* (1.9 - 0.18 .* nu200m);   % DK14 eq. 6
    else   % 'Gamma'
        beta    = 6;
        gamma_t = 4;
        rt      = R200m .* 0.54 .* (1 + 0.53 .* exp(-Gamma));
    end

    % Numerical safety: rt must be positive
    rt = max(rt, 0.01 .* R200m);

    % ---- Inner Einasto profile  (delegates to Einasto_profile.m) --------
    % alpha_e is computed inside via Gao+2008: alpha_e = 0.155+0.0095*nu^2
    [rho_inner, ~, ~] = Einasto_profile(r, M, c, z, cosmo, Delta);

    % ---- Truncation (splashback) function --------------------------------
    % f_trans(r) = [ 1 + (r/rt)^beta ]^(-gamma_t/beta)
    %   r << rt : f_trans -> 1       (inner Einasto unaffected)
    %   r ~  rt : f_trans ~ 0.5      (splashback transition)
    %   r >> rt : f_trans -> 0       (sharp suppression)
    f_trans = (1 + (r ./ rt).^beta).^(-gamma_t ./ beta);

    % ---- Total DK14 profile ---------------------------------------------
    if include_outer
        b_e       = 1.0;
        s_e       = 1.5;
        rho_outer = b_e .* rho_m_z .* (r ./ R200m).^(-s_e);
        rho       = rho_inner .* f_trans + rho_outer;
    else
        rho       = rho_inner .* f_trans;
    end

end
