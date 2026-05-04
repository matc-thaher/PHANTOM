function s = sigma_R( R, z, cosmo)
    % % sigma_R  Top-hat smoothed variance σ(R,z)
    % % R can be scalar or vector (in Mpc/h)
    % % z is scalar
    % % cosmo.Pk is P(k,z)
    
    lnk = linspace(log(1e-6), log(1e4), 4000).';
    k   = exp(lnk);
    x   = k .* R;
    W   = 3*(sin(x) - x.*cos(x)) ./ (x.^3 + (x==0));
    D   = cosmo.D(z) / cosmo.D(0);
    Pk  = cosmo.Pk0(k) .* D^2;
    integrand = Pk .* W.^2 .* k.^3;   % k^3 for d(lnk) integration
    s2  = (1/(2*pi^2)) * trapz(lnk, integrand);
    s   = sqrt(s2);

    end