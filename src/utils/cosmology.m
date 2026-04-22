    function cosmo = cosmology( name, user)

        if nargin < 1
            name = 'Planck18';
        end

        switch lower(name)
            case 'planck18'
                cosmo.Omega_m = 0.315;
                cosmo.Omega_b = 0.049;
                cosmo.h       = 0.674;
                cosmo.ns      = 0.965;
                cosmo.sigma8  = 0.811;

            case 'uchuu'        % also, planck 2020
                cosmo.Omega_m = 0.3089;
                cosmo.Omega_b = 0.0486;
                cosmo.h       = 0.6774;
                cosmo.ns      = 0.9667;
                cosmo.sigma8  = 0.8159;

            case 'wmap9'        % wmap9+bao
                cosmo.Omega_m = 0.279;
                cosmo.Omega_b = 0.048;
                cosmo.h       = 0.683;
                cosmo.ns      = 0.972;
                cosmo.sigma8  = 0.821;

            case 'custom'
                cosmo = user;

            otherwise
                error('Unknown cosmology "%s"', name);
        end
        
        
        cosmo.Omega_L   = 1 - cosmo.Omega_m;
        cosmo.rho_crit0 = 2.8e11*(cosmo.h)^2;
        cosmo.rho_m0    = cosmo.rho_crit0 * cosmo.Omega_m;

        % Attach all linear components
        cosmo = attach_linear_components( cosmo);

    end