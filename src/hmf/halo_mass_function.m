function [dndlnM, n_cum] = halo_mass_function(M, z, cosmo, model, varargin)
% halo_mass_function   Compute dn/dlnM and cumulative n(>M) via Eq. 28 of
%                      Diemer (2018), Colossus paper.
%
%   dn/dlnM = f(sigma) * (rho_m0 / M) * |d ln(sigma^-1) / d ln M|
%
% USAGE:
%   [dndlnM, n_cum] = halo_mass_function(M, z, cosmo, 'ST',    delta_c)
%   [dndlnM, n_cum] = halo_mass_function(M, z, cosmo, 'Du17',  M, z, m22, cosmo)
%   [dndlnM, n_cum] = halo_mass_function(M, z, cosmo, 'Yung25', z)
%   ... (any model accepted by multiplicity_dispatcher)
%
% INPUT:
%   M        : halo mass array [h^-1 M_sun], must be monotonically increasing
%   z        : redshift (scalar)
%   cosmo    : PHANTOM cosmo struct — must contain:
%                cosmo.Om0      : matter density parameter
%                cosmo.rho_crit0: critical density [h^2 M_sun/(Mpc/h)^3]
%                cosmo.sigmaM   : function handle sigmaM(M, z)
%   model    : string passed to multiplicity_dispatcher
%   varargin : extra arguments forwarded to multiplicity_dispatcher
%
% OUTPUT:
%   dndlnM   : dn/dlnM  [h^3 Mpc^-3]  (same size as M)
%   n_cum    : n(>M)    [h^3 Mpc^-3]  cumulative number density (same size as M)

    % --- Mean matter density today [h^2 M_sun / (Mpc/h)^3] --------------
    rho_m0 = cosmo.Om0 * cosmo.rho_crit0;   % [h^2 M_sun (Mpc/h)^-3]

    % --- sigma(M, z) and its logarithmic derivative ----------------------
    sigma = cosmo.sigmaM(M, z);              % sigma(M, z)

    % d ln(sigma^-1) / d ln M = -d ln sigma / d ln M
    % Computed via central finite differences on ln M.
    lnM   = log(M);
    lnSig = log(sigma);
    dlnSig_dlnM = gradient(lnSig, lnM);     % d ln sigma / d ln M

    % Eq. 28 needs |d ln sigma^-1 / d ln M| = |d ln sigma / d ln M|
    abs_deriv = abs(dlnSig_dlnM);

    % --- Multiplicity function f(sigma) ----------------------------------
    % Pass sigma as second argument; varargin carries model-specific extras
    f = multiplicity_dispatcher(model, sigma, varargin{:});

    % --- dn/dlnM [h^3 Mpc^-3] -------------------------------------------
    % Eq. 28: dn/dlnM = f(sigma) * (rho_m0/M) * |d ln sigma^-1 / d ln M|
    dndlnM = f .* (rho_m0 ./ M) .* abs_deriv;

    % --- Cumulative n(>M) by integrating from high M down ----------------
    if nargout > 1
        % Integrate dn/dlnM over ln M from each M to M_max
        % Flip so integration runs from low to high lnM, then cumsum from top
        dndlnM_flip = fliplr(dndlnM(:)');
        lnM_flip    = fliplr(lnM(:)');
        n_cum_flip  = cumtrapz(lnM_flip, dndlnM_flip);
        n_cum       = fliplr(n_cum_flip);          % restore original ordering
        n_cum       = reshape(n_cum, size(M));
    end

    dndlnM = reshape(dndlnM, size(M));
end