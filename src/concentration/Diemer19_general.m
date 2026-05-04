function [c, mask] = Diemer19_general(M, z, cosmo, params)
% MATLAB clone of Colossus _diemer19_general for NFW profile
% params: struct with fields kappa, a0, a1, b0, b1, c_alpha

    profile = 'nfw';

    % Load interpolators
    [Gc_interp, Gmin_interp, Gmax_interp] = get_Gc_table(profile);

    % Compute nu, n_eff, alpha_eff
    sigma = cosmo.sigmaM(M, z);
    delta_c = 1.686;
    nu = delta_c ./ sigma;

    % n_eff from your neff(M,z,kappa)
    n_eff = cosmo.neff(M, z, params.kappa);

    % alpha_eff: same function you already use for Ishiyama
    alpha_eff = cosmo.alphaEff(z);

    % Ensure arrays
    nu      = nu(:);
    n_eff   = n_eff(:);
    alpha_eff = alpha_eff .* ones(size(nu));

    % Diemer19/Ishiyama parameter combinations
    A_n = params.a0 .* (1 + params.a1 .* (n_eff + 3));
    B_n = params.b0 .* (1 + params.b1 .* (n_eff + 3));
    C_alpha = 1 - params.c_alpha .* (1 - alpha_eff);

    rhs = log10(A_n ./ nu .* (1 + nu.^2 ./ B_n));  % "G" in DJ19 sense

    % Mask where G-range is valid at given n
    Gmin = Gmin_interp(n_eff);
    Gmax = Gmax_interp(n_eff);
    mask = (rhs >= Gmin) & (rhs <= Gmax);

    c = nan(size(nu));

    % Interpolate log10 c from (G, n)
    log10c = Gc_interp(rhs, n_eff);   % this returns log10 c
    c(mask) = 10.^log10c(mask) .* C_alpha(mask);
    c(~mask) = NaN;  % or some INVALID_CONCENTRATION

    % reshape to original M shape
    c = reshape(c, size(M));
    mask = reshape(mask, size(M));
end