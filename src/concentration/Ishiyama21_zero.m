function c = Ishiyama21_zero(M, z, cosmo, mode)
% Ishiyama21_concentration  Ishiyama et al. (2021) concentration model
%
%   c = Ishiyama21_concentration(M, z, cosmo, mode)
%
%   Implements the concentration-mass relation from Ishiyama et al. 2021
%   (MNRAS 506, 4210), Equation 2 and Appendix B.
%
%   The model expresses concentration as:
%       c = C_eff * c_unnorm
%   where c_unnorm is found by inverting the function G(c) = G_target,
%   and C_eff captures the redshift-dependent growth correction.
%
%   G(c) is defined as:
%       G(c) = c / [ f(c) ]^( (5 + n_eff) / 6 )
%   where f(c) = ln(1+c) - c/(1+c)  is the standard NFW mass function.
%
%   G_target is computed analytically from the seed value x_c (Eq. 9):
%       x_c      = A_eff * (1 + nu^2 / B_eff) / nu
%       G_target = x_c / [ f(x_c) ]^( (5 + n_eff) / 6 )
%
%   The inversion G(c_unnorm) = G_target is solved element-wise using
%   fzero with an adaptive bracket search.
%
% -------------------------------------------------------------------------
%   INPUTS
%   M     : halo mass [Msun/h], scalar or vector
%   z     : redshift (scalar)
%   cosmo : cosmology struct built by cosmology() + attach_linear_components()
%             Required handles:
%               cosmo.sigmaM(M, z)   — rms linear variance at mass M
%               cosmo.neff(M, z, k)  — effective spectral index at kappa*R_L
%               cosmo.alphaEff(z)    — effective growth exponent d ln D / d ln(1+z)
%   mode  : halo definition + sample string (case-insensitive)
%             '200c_all'     — M_200c, all haloes
%             '200c_relaxed' — M_200c, dynamically relaxed haloes
%             'vir_all'      — M_vir,  all haloes
%             'vir_relaxed'  — M_vir,  relaxed haloes
%             '500_all'      — M_500c, all haloes
%             '500_relaxed'  — M_500c, relaxed haloes
%
%   OUTPUT
%   c     : halo concentration, same shape as M
%
% -------------------------------------------------------------------------
%   Reference: Ishiyama et al. 2021, MNRAS 506, 4210
%              Diemer & Joyce 2019, ApJ 871, 168  (original functional form)
% -------------------------------------------------------------------------

% =========================================================================
% Step 0: Load best-fit parameters for the requested halo definition
%         from Ishiyama et al. 2021, Table 2.
%
%   kappa   — scales the Lagrangian radius used for n_eff:
%               R_nu = kappa * R_L(M)
%   a0, a1  — control A_eff (amplitude of the x_c seed; Eq. 5)
%   b0, b1  — control B_eff (peak-height coupling in x_c;  Eq. 6)
%   cAlpha  — amplitude of the growth-rate correction (C_eff; Eq. 7)
% =========================================================================
P      = Ishiyama21_Table(mode);
kappa  = P.kappa;
a0     = P.a0;  a1 = P.a1;
b0     = P.b0;  b1 = P.b1;
cAlpha = P.cAlpha;

% =========================================================================
% Step 1: Cosmological / peak-height quantities
%
%   sigma(M,z) : rms linear density fluctuation smoothed at the Lagrangian
%                radius R_L(M), evaluated at redshift z.
%   nu         : peak height — ratio of the linear collapse threshold to
%                sigma.  High nu = rare, massive halo.
%   neff       : effective slope of the power spectrum at the Lagrangian
%                radius R_nu = kappa * R_L(M).  Captures how "steep" the
%                local power spectrum is at the halo's scale.
%   alpha      : effective growth exponent alpha_eff(z) = -d ln D / d ln(1+z).
%                Equals ~1 in matter domination, <1 with dark energy.
% =========================================================================
sigma   = cosmo.sigmaM(M, z);
delta_c = 1.686;                   % linear collapse overdensity (Einstein-de Sitter value)
nu      = delta_c ./ sigma;        % peak height  (Eq. 3)

neff  = cosmo.neff(M, z, kappa);   % effective spectral index (Appendix B, Eq. 8)
alpha = cosmo.alphaEff(z);         % effective growth exponent (Appendix B, Eq. B4)

% =========================================================================
% Step 2: Appendix B auxiliary functions
%
%   A_eff (Eq. 5): sets the overall amplitude of the x_c seed.
%                  Shifts with the local power-spectrum slope neff.
%   B_eff (Eq. 6): controls how strongly the peak height nu couples into
%                  x_c.  Also shifts with neff.
%   C_eff (Eq. 7): redshift- and growth-dependent rescaling factor.
%                  Accounts for the fact that at fixed nu, haloes forming
%                  in a slower-growing universe are less concentrated.
%                  Capped at a maximum of 1 (cAlpha in [0,1]).
% =========================================================================
A_eff = a0 .* (1 + a1 .* (neff + 3));       % Eq. 5
B_eff = b0 .* (1 + b1 .* (neff + 3));       % Eq. 6
C_eff = 1  - cAlpha .* (1 - alpha);         % Eq. 7  (growth-rate correction)

% =========================================================================
% Step 3: Compute G_target using the analytic seed x_c
%
%   x_c (Eq. 9): analytic estimate for the un-normalized concentration.
%                This is a closed-form approximation; the exact value is
%                found by root-finding below.
%   f(x_c)     : NFW enclosed-mass shape function evaluated at x_c.
%                f(c) = ln(1+c) - c/(1+c)
%   G_target   : the target value of G(c) that the true c_unnorm must hit.
%                G is a monotonically increasing function of c (for c>0),
%                so the inversion is well-defined.
% =========================================================================
x_c      = A_eff .* (1 + nu.^2 ./ B_eff) ./ nu;          % Eq. 9 — seed
f_xc     = log(1 + x_c) - x_c ./ (1 + x_c);              % f(x_c)
G_target = x_c ./ (f_xc .^ ((5 + neff) / 6));            % G(x_c) = G_target

% =========================================================================
% Step 4: Invert G(c_unnorm) = G_target element-wise
%
%   We solve  obj(c) = G(c) - G_target = 0  for each halo independently
%   using MATLAB's fzero (Illinois / Brent's method) within a bracket.
%
%   The bracket [c_lo, c_hi] is expanded adaptively if the initial guess
%   [1e-2, 1e3] does not straddle the root (can happen at extreme masses
%   or redshifts where x_c is very large or very small).
%
%   Fallback: if no bracket is found after 20 halvings/doublings, we fall
%   back to the analytic seed x_c for that halo and emit a warning.
% =========================================================================
n_halos  = numel(M);
c_unnorm = zeros(size(M));

for i = 1:n_halos

    Gi   = G_target(i);           % target G value for this halo
    ni   = neff(i);               % local spectral index for this halo
    expo = (5 + ni) / 6;          % exponent in G(c)

    % Anonymous functions for the NFW shape and the root objective
    f_c = @(cv) log(1 + cv) - cv ./ (1 + cv);
    obj = @(cv) cv ./ f_c(cv).^expo - Gi;

    % --- Adaptive bracket search ----------------------------------------
    c_lo = 1e-2;
    c_hi = 1e3;
    expanded = false;
    for k = 1:20
        if obj(c_lo) * obj(c_hi) < 0
            % Signs differ => a root exists in [c_lo, c_hi]
            expanded = true;
            break;
        end
        c_lo = c_lo / 2;    % push lower bound down
        c_hi = c_hi * 2;    % push upper bound up
    end

    if ~expanded
        % No bracket found — G_target may be outside the monotone range
        % (very rare; can occur for extremely low-sigma halos)
        warning('Ishiyama21_concentration: no bracket for halo %d (neff=%.3f, G_target=%.4e). Using analytic seed x_c as fallback.', ...
            i, ni, Gi);
        c_unnorm(i) = x_c(i);   % analytic seed is a reasonable approximation
        continue;
    end

    % --- Root finding ---------------------------------------------------
    c_unnorm(i) = fzero(obj, [c_lo, c_hi]);
end

% =========================================================================
% Step 5: Apply growth-rate correction and return
%
%   The final concentration is  c = C_eff * c_unnorm  (Eq. 2).
%   C_eff < 1 when alpha < 1 (dark-energy epoch), reducing concentration
%   relative to a matter-dominated universe at the same peak height.
% =========================================================================
c = C_eff .* c_unnorm;

end