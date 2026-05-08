function xi = correlation_function_integral(R, z, cosmo, Pk_handle)
% CORRELATION_FUNCTION_INTEGRAL  Direct quadrature for xi(R,z).
%
%   xi = CORRELATION_FUNCTION_INTEGRAL(R, z, cosmo, Pk_handle)
%
%   Evaluates
%
%       xi(R,z) = (1 / 2*pi^2) * \int dlnk k^3 P(k,z) sin(kR)/(kR)
%
%   by direct numerical integration over ln(k).
%
%   This method is slower than FFTLog for large R-grids, but it is more
%   transparent and should be used as the default and validation reference.
%
%   Reference
%   ---------
%   Diemer 2018, COLOSSUS, Section 2.7.

    R = R(:);
    xi = zeros(size(R));

    D2 = (cosmo.D(z) / cosmo.D(0)).^2;
    kmin = 1e-6;
    kmax = 1e4;

    for i = 1:numel(R)
        Ri = R(i);
        integrand = @(lnk) local_xi_integrand(lnk, Ri, D2, Pk_handle);

        xi(i) = (1 / (2*pi^2)) * integral(integrand, log(kmin), log(kmax), ...
            'ArrayValued', true, 'AbsTol', 1e-8, 'RelTol', 1e-6);
    end

    if isscalar(R)
        xi = xi(1);
    end
end

function y = local_xi_integrand(lnk, R, D2, Pk_handle)
    k = exp(lnk);
    x = k .* R;

    j0 = ones(size(x));
    m = (x ~= 0);
    j0(m) = sin(x(m)) ./ x(m);

    y = k.^3 .* Pk_handle(k) .* D2 .* j0;
end