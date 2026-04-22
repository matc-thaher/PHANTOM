function c = Bullock01(M, z, cosmo, K, F)
% Bullock01_concentration  Bullock et al. (2001) concentration model
%
%   c = Bullock01(M, z, cosmo)
%   c = Bullock01(M, z, cosmo, K, F)
%
%   Defines concentration via the collapse redshift z_coll — the redshift
%   at which a progenitor of mass F*M had sigma(F*M, z_coll) = delta_c.
%   Concentration is then:
%       c = K * (1 + z_coll) / (1 + z)
%
%   DEFAULT PARAMETERS (Colossus defaults, recalibrated from original B01):
%       K = 2.9,  F = 0.001  (= 10^-3)
%   These differ from the original Bullock+01 values (K=4, F=0.01) which
%   were calibrated to sigma8=1.0 simulations.  K=2.9, F=0.001 better
%   reproduce concentrations for lower-sigma8 WMAP-era cosmologies.
%
%   The user can override K and F to match any specific calibration:
%       Original Bullock+01 LCDM  : K = 4.0,  F = 0.01
%       Johnston et al. 2007 SDSS : K = 2.9,  F = 0.001
%
%   INPUTS
%   M     : halo mass [Msun/h], scalar or vector
%   z     : redshift (scalar)
%   cosmo : cosmology struct with cosmo.sigmaM(M,z) and cosmo.D(z)
%   K     : (optional) proportionality constant,  default = 2.9
%   F     : (optional) collapse mass fraction,     default = 0.001
%
%   OUTPUT
%   c     : concentration, same shape as M
%
%   Reference: Bullock et al. 2001, MNRAS 321, 559
%              Johnston et al. 2007, ApJ 656, 27  (K=2.9, F=0.001)

if nargin < 4 || isempty(K),  K = 2.9;    end
if nargin < 5 || isempty(F),  F = 0.001;  end

delta_c = 1.686;
M       = M(:);
c       = zeros(size(M));

for i = 1:numel(M)

    % Mass of the collapsing progenitor
    M_prog = F * M(i);

    % sigma(M_prog) at z=0  (growth factor D(z)/D(0) scales sigma)
    sigma0 = cosmo.sigmaM(M_prog, 0);

    % z_coll satisfies: D(z_coll)/D(0) * sigma0 = delta_c
    % => D(z_coll)/D(0) = delta_c / sigma0
    D_ratio_target = delta_c / sigma0;

    if D_ratio_target >= 1
        % sigma0 <= delta_c: halo has not yet collapsed — use z_coll = 0
        z_coll = 0;
    else
        % Invert D(z_coll)/D(0) = D_ratio_target
        obj    = @(zc) cosmo.D(zc) / cosmo.D(0) - D_ratio_target;
        z_coll = fzero(obj, [0, 30]);
    end

    c(i) = K * (1 + z_coll) / (1 + z);
end

end