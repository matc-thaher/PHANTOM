function b = halo_bias_ST(sigma, delta_c)
% Sheth, Mo & Tormen (2001) halo bias
% Mo & White (1996) extended to ellipsoidal collapse
    if nargin < 2 || isempty(delta_c)
        delta_c = collapse_overdensity();   % EdS value 1.6865
    end
    a = 0.707;  p = 0.3;
    nu = delta_c ./ sigma;
    nu2 = nu.^2;
    b  = 1 + ((a*nu2 - 1)/delta_c) + ((2*p/delta_c) ./ (1 + (a*nu2).^p));
end