function s2 = sigma_R2_given_Pk(R, z, cosmo, Pk_handle, filter_name)
    % Compute sigma^2(R,z) using a user-supplied P(k)
    % R         : radius (Mpc/h), scalar or vector
    % z         : redshift
    % cosmo     : cosmology struct
    % Pk_handle : handle for P(k) at z=0
    % filter_name (optional): 'tophat', 'gaussian', 'sharpk', 'smoothk', 'vsmk'

    if nargin < 5 || isempty(filter_name)
        if isfield(cosmo, 'variance_filter') && ~isempty(cosmo.variance_filter)
            filter_name = cosmo.variance_filter;
        else
            filter_name = 'tophat';
        end
    end

    lnk = linspace(log(1e-6), log(1e4), 4000).';
    k   = exp(lnk);

    D   = cosmo.D(z) / cosmo.D(0);
    Pk  = Pk_handle(k) .* D^2;

    R = R(:).';
    x = k .* R;
    W = variance_window(x, filter_name);

    integrand = Pk .* W.^2 .* k.^3;
    s2 = (1/(2*pi^2)) * trapz(lnk, integrand, 1);

    if isscalar(R)
        s2 = s2(1);
    end
end