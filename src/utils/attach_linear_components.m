    function cosmo = attach_linear_components( cosmo)

        % Expansion rate
        cosmo.E  = @(z) sqrt(cosmo.Omega_m*(1+z).^3 + cosmo.Omega_L);

        % Growth factor
        cosmo.D = @(z) growth_factor_D( z,cosmo);

        % Transfer function
        cosmo.T = @(k) T_EH98( k,cosmo);

        % Unnormalized power spectrum
        cosmo.Pk0_unnorm = @(k) k.^cosmo.ns .* cosmo.T(k).^2;

        % Normalize P(k) to sigma8
        A = normalize_A_to_sigma8(cosmo);
        cosmo.Pk0 = @(k) A * cosmo.Pk0_unnorm(k);
        cosmo.Pk  = @(k,z) cosmo.Pk0(k) .* (cosmo.D(z)/cosmo.D(0)).^2;

        % σ(R,z) and σ(M,z)
        cosmo.sigmaR = @(R,z) sigma_R(R,z,cosmo);
        cosmo.R_of_M = @(M) (3*M./(4*pi*cosmo.rho_m0)).^(1/3);
        cosmo.sigmaM = @(M,z) cosmo.sigmaR(cosmo.R_of_M(M),z);

        % n_eff and α_eff for Ishiyama21
        % Rneff = radius_from_mass(M,cosmo);
        cosmo.neff     = @(M,z,kappa) neff(M,z,kappa,cosmo);
        % cosmo.neff     = @(M,z) neff_Ishiyama(cosmo.R_of_M(M),z,cosmo);
        cosmo.alphaEff = @(z) alphaEff(z,cosmo);

    end