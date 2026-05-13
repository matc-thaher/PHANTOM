function neff = neff( M,z,kappa, cosmo)
        % small step in ln R

        R_L = radius_from_mass( M,cosmo);
        R = kappa.*R_L;

        d = 5e-3;

        Rp = R .* (1+d);
        Rm = R ./ (1+d);

        sig_p = cosmo.sigmaR(Rp, z);
        sig_m = cosmo.sigmaR(Rm, z);

        dlnsigma = log(sig_p ./ sig_m) ./ (2*log(1+d)); %-log(1-d));
        neff = -3 - 2 * dlnsigma;

    end

