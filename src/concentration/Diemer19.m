function c = Diemer19(M, z, cosmo, mode)
% Diemer19_concentration  Diemer & Joyce (2019) concentration model
%
%   c = Diemer19_concentration(M, z, cosmo, mode)
%
%   Identical functional form and root-finding method as Ishiyama21.
%   Only the parameter table differs (Diemer19_Table vs Ishiyama21_Table2).
%
%   INPUTS
%   M     : halo mass [Msun/h], scalar or vector
%   z     : redshift (scalar)
%   cosmo : cosmology struct from cosmology() + attach_linear_components()
%   mode  : '200c_all' | '200c_relaxed' | 'vir_all' | 'vir_relaxed'
%
%   OUTPUT
%   c     : concentration, same shape as M
%
%   Reference: Diemer & Joyce 2019, ApJ 871, 168

P      = Diemer19_Table(mode);
kappa  = P.kappa;
a0     = P.a0;  a1 = P.a1;
b0     = P.b0;  b1 = P.b1;
cAlpha = P.cAlpha;

sigma   = cosmo.sigmaM(M, z);
delta_c = 1.686;
nu      = delta_c ./ sigma;

neff  = cosmo.neff(M, z, kappa);
alpha = cosmo.alphaEff(z);

A_eff = a0 .* (1 + a1 .* (neff + 3));
B_eff = b0 .* (1 + b1 .* (neff + 3));
C_eff = 1  - cAlpha .* (1 - alpha);

% Compute G_target using x_c as seed  (Appendix B of Ishiyama+21 / DJ19)
x_c      = A_eff .* (1 + nu.^2 ./ B_eff) ./ nu;
f_xc     = log(1 + x_c) - x_c ./ (1 + x_c);
G_target = x_c ./ (f_xc .^ ((5 + neff) / 6));

% Invert G(c) = G_target element-wise via bracketed root-finding
n_halos  = numel(M);
c_unnorm = zeros(size(M));

for i = 1:n_halos
    Gi   = G_target(i);
    ni   = neff(i);
    expo = (5 + ni) / 6;

    f_c = @(cv) log(1+cv) - cv ./ (1+cv);
    obj = @(cv) cv ./ f_c(cv).^expo - Gi;

    % Adaptive bracket search
    c_lo = 1e-2;
    c_hi = 1e3;
    expanded = false;
    for k = 1:20
        if obj(c_lo) * obj(c_hi) < 0
            expanded = true;
            break;
        end
        c_lo = c_lo / 2;
        c_hi = c_hi * 2;
    end

    if ~expanded
        warning('Diemer19_concentration: no bracket for halo %d (neff=%.3f, G=%.4e). Using x_c fallback.', ...
            i, ni, Gi);
        c_unnorm(i) = x_c(i);
        continue;
    end

    c_unnorm(i) = fzero(obj, [c_lo, c_hi]);
end

c = C_eff .* c_unnorm;
end