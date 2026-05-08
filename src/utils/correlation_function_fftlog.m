function xi = correlation_function_fftlog(R, z, cosmo, Pk_handle)
% CORRELATION_FUNCTION_FFTLOG  FFTLog-based xi(R,z).
%
%   Uses a Hamilton-style discrete logarithmic Hankel transform.
%
%   For the spherical Bessel j0 transform, the corresponding Hankel order is
%   mu = 1/2 because j0(x) = sqrt(pi/(2x)) J_{1/2}(x).
%
%   The transform is applied to
%       A(k) = k^(3/2) P(k,z)
%   and the result is converted back to
%       xi(r,z) = B(r) / (2*pi^2 * r^(3/2)).
%
%   Notes
%   -----
%   - This routine uses a low-ringing choice of kr = k0*r0.
%   - Accuracy depends on grid size, k-range, and how well aliasing is
%     controlled.
%   - Always validate against the direct integral method.
%
%   Reference
%   ---------
%   Hamilton 2000.

    Rreq = R(:);

    D2 = (cosmo.D(z) / cosmo.D(0)).^2;

    % FFTLog settings
    N    = 2048;
    kmin = 1e-6;
    kmax = 1e4;
    q    = 0.0;
    mu   = 0.5;

    % Logarithmic spacing
    L   = log(kmax / kmin);
    dln = L / N;

    % Logarithmic k-grid centered at k0
    jc  = (N + 1) / 2;
    j   = (1:N).';
    k0  = sqrt(kmin * kmax);
    k   = k0 .* exp((j - jc) * dln);

    % Choose central kr close to unity, then adjust to nearest low-ringing kr
    kr_guess = 1.0;
    kr       = fftlog_krgood(mu, q, dln, kr_guess);
    r0       = kr / k0;

    % Corresponding logarithmic r-grid
    r = r0 .* exp((j - jc) * dln);

    % Input sequence for Hankel transform
    Pk = Pk_handle(k) .* D2;
    A  = k.^(1.5) .* Pk;

    % FFTLog transform
    B = fftlog_fht(A, mu, q, dln, kr);

    % Convert to xi(r)
    xi_grid = real(B) ./ (2*pi^2 .* r.^(1.5));

    % Interpolate to requested radii
    xi = interp1(log(r), xi_grid, log(Rreq), 'pchip', 'extrap');

    if isscalar(R)
        xi = xi(1);
    end
end