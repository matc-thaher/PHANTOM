    function cosmo = attach_linear_components( cosmo)

        % % Expansion rate
        % cosmo.E  = @(z) sqrt(cosmo.Omega_m*(1+z).^3 + cosmo.Omega_L);

        % % Growth factor
        % cosmo.D = @(z) growth_factor_D( z,cosmo);
        % Growth factor — use extended version only when needed
        if isfield(cosmo,'relspecies') && cosmo.relspecies || ...
            isfield(cosmo,'flat') && ~cosmo.flat || ...
            isfield(cosmo,'de_model') && ~strcmpi(cosmo.de_model,'lambda')
            cosmo.D = @(z) growth_factor_D_ext(z, cosmo);
        else
            cosmo.D = @(z) growth_factor_D(z, cosmo);   % your original, untouched
        end

        % Transfer function
        % cosmo.T = @(k) T_EH98( k,cosmo);
        switch lower(cosmo.transfer_model)
            case 'eh98_full'
                cosmo.T = @(k) T_EH98_full(k, cosmo);

            case 'camb'
                % Load CAMB transfer function once and build interpolant
                d = load(cosmo.camb_transfer_file, 'k_h', 'T_camb');
                k_tab = d.k_h(:);
                T_tab = d.T_camb(:);
                % Log-linear interpolation, clamp extrapolation to boundary values
                cosmo.T = @(k) interp1(log(k_tab), T_tab, log(k(:)), ...
                                   'pchip', 'extrap');

            otherwise  % default: EH98 zero-baryon
                cosmo.T = @(k) T_EH98(k, cosmo);
        end

         % Default variance filter
        if ~isfield(cosmo,'variance_filter') || isempty(cosmo.variance_filter)
            cosmo.variance_filter = 'tophat';
        end

        % For sharpk/smoothk/vsmk, M = (4*pi/3) * rho_m * (c*R)^3
        % so R = (1/c) * (3M / 4*pi*rho_m)^(1/3)
        %
        % c defaults to 1 (top-hat / Gaussian — no calibration needed)
        % c = 2.5-2.7 for sharpk (Leo_2018, Ruderman_2026)
        % c = 3.0-3.7 for smoothk (Leo_2018)
        % c = 3.6     for vsmk    (Ruderman_2026)

        if ~isfield(cosmo, 'filter_c') || isempty(cosmo.filter_c)
            cosmo.filter_c = 1.0;
        end

        % Unnormalized power spectrum
        cosmo.Pk0_unnorm = @(k) k.^cosmo.ns .* cosmo.T(k).^2;

        % Normalize P(k) to sigma8
        A = normalize_A_to_sigma8(cosmo);
        cosmo.Pk0 = @(k) A * cosmo.Pk0_unnorm(k);
        cosmo.Pk  = @(k,z) cosmo.Pk0(k) .* (cosmo.D(z)/cosmo.D(0)).^2;

        % σ(R,z) and σ(M,z)
        cosmo.sigmaR = @(R,z,varargin) sigma_R(R, z, cosmo, varargin{:});
        cosmo.R_of_M = @(M) (1/cosmo.filter_c) * (3*M./(4*pi*cosmo.rho_m0)).^(1/3);
        cosmo.sigmaM = @(M,z,varargin) cosmo.sigmaR(cosmo.R_of_M(M), z, varargin{:});

        % n_eff and α_eff for Ishiyama21
        cosmo.neff     = @(M,z,kappa) neff(M,z,kappa,cosmo);
        cosmo.alphaEff = @(z) alphaEff(z,cosmo);

        if ~isfield(cosmo,'corr_method') || isempty(cosmo.corr_method)
            cosmo.corr_method = 'integral';
        end

        cosmo.correlationFunction = @(R,z,varargin) correlation_function(R, z, cosmo, varargin{:});

    end