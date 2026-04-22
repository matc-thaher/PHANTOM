 function s2 = sigma_R2_given_Pk( R, z, cosmo, Pk_handle)
    % Compute sigma^2(R,z) using a user-supplied P(k)
    % -------------------------------------------------
    % R          : radius (Mpc/h)
    % z          : redshift
    % cosmo      : cosmology struct (needed for growth factor)
    % Pk_handle  : function handle for P(k) at z=0 (unnormalized or unit)

        % k-grid for integration
        k = logspace(-4, 2, 2000);  % h/Mpc

        % x = k*R
        x = k .* R;

        % Fourier-space top-hat window function
        W = 3 * ( sin(x) - x.*cos(x) ) ./ (x.^3 + (x==0));

        % Apply growth factor if needed
        D = cosmo.D(z) / cosmo.D(0);
        Pk = Pk_handle(k) * D^2;

        % Compute sigma^2
        integrand = k.^2 .* Pk .* (W.^2);
        s2 = (1/(2*pi^2)) * trapz(k, integrand);
    end