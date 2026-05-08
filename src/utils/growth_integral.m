% =========================================================================
function D = growth_integral(z, cosmo)
    % Heath 1977/ Peebles1980 / EH99 Eq.8 integral — works for non-flat, no radiation
    % D(z) = 5/2 * Om * E(z) * integral_{z}^{inf} (1+z')/E(z')^3 dz'
    Om = cosmo.Omega_m;

    % (1+z_eq) prefactor — cancels in D/D0 normalization but kept for correctness
    if cosmo.relspecies
        one_plus_zeq = 1.0 + cosmo.z_eq;
    else
        one_plus_zeq = 1.0;
    end

    % Integrand uses cosmo.E directly — no need to rebuild Ez
    integrand = @(zp) (1 + zp) ./ cosmo.E(zp).^3;


    z   = z(:);
    D   = zeros(size(z));
    for i = 1:numel(z)
        D(i) = integral(integrand, z(i), Inf, 'RelTol', 1e-6, 'AbsTol', 1e-10);
    end

    D   = (5/2) .* Om .* one_plus_zeq .* Ez(z) .* D;
    D0  = (5/2) .* Om .* one_plus_zeq .* Ez(0) .* integral(integrand, 0, Inf, 'RelTol', 1e-6, 'AbsTol', 1e-10);
    D   = D ./ D0;
end
