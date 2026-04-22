function c_sup = suppression_factor(M, M_half, model)
% SUPPRESSION_FACTOR  Concentration suppression relative to CDM for FDM halos
%
% Usage:
%   c_sup = suppression_factor(M, M_half)                  % default: Laroche (2022)
%   c_sup = suppression_factor(M, M_half, 'laroche2022')   % Laroche et al. (2022)
%   c_sup = suppression_factor(M, M_half, 'dentler2022')   % Dentler et al. (2022)
%
% Inputs:
%   M       - Halo mass [M_sun], scalar or array
%   M_half  - Half-mode mass scale [M_sun]
%             M_half = 3.8e10 * m22^(-4/3) [M_sun]
%             where m22 = m_ax / (10^-22 eV)
%   model   - (optional) suppression model: 'laroche2022' (default) or 'dentler2022'
%
% Outputs:
%   c_sup   - Dimensionless suppression factor (0 < c_sup <= 1)
%
% References:
%   Laroche et al. (2022) - Eq. for concentration suppression:
%       F(x) = (1 + a*x^b)^c,  x = M/M_half
%       parameters a=5.496, b=-1.648, c=-0.417
%
%   Dentler et al. (2022) - Two-factor suppression (Kawai et al. 2024, Eqs. 29-30):
%       Delta^FDM = (1 + M0/(f_coll*M))^(-gamma0) * (1 + gamma1*M0/M)^(-gamma2)
%       where M0 = 1.6e10 * m22^(-4/3)  [NOTE: M0 != M_half]
%              M0 = (1.6/3.8) * M_half  = M_half / 2.375
%       f_coll = 0.01, gamma0 = d ln(c_vir^B)/d ln(M_h) |_{Mh=4*M0} ~ 0.06,
%       gamma1 = 15, gamma2 = 0.3

if nargin < 3 || isempty(model)
    model = 'laroche2022';
end

switch lower(model)
    case 'laroche2022'
        % Laroche et al. (2022) power-law suppression
        % c_vir(FDM)/c_vir(CDM) = F(M/M_half) = (1 + a*(M/M_half)^b)^c
        a    =  5.496;
        b    = -1.648;
        cnst = -0.417;
        x    = M ./ M_half;
        c_sup = (1 + a .* x.^b).^cnst;

    case 'dentler2022'
        % Dentler et al. (2022) two-factor FDM suppression
        % As expressed in Kawai et al. (2024), Eqs. 29-30:
        %
        %   Delta^FDM = (1 + M0/(f_coll*M))^(-gamma0)
        %             * (1 + gamma1*(M0/M))^(-gamma2)
        %
        % M0 = 1.6e10 * m22^(-4/3)  [NOT the half-mode mass]
        %    = (1.6/3.8) * M_half
        %
        % gamma0 = d ln(c_vir^B)/d ln(M_h) evaluated at M_h = 4*M0
        %        ~ 0.06  (CDM low-mass slope from Kawai Eqs. 26-27)
        % gamma1 = 15,  gamma2 = 0.3,  f_coll = 0.01

        % M0 is NOT M_half; it differs by the ratio of prefactors (1.6 vs 3.8)
        M0     = M_half .* (1.6 / 3.8);   % = 1.6e10 * m22^(-4/3)

        f_coll = 0.01;
        gamma1 = 15.0;
        gamma2 = 0.3;

        % gamma0 = local log-slope of CDM c_vir-M relation at M_h = 4*M0
        % Pivot mass: 10^11 h^-1 Msun ~ 1.43e11 Msun  (with h = 0.7)
        M_pivot = 1e11 / 0.7;   % [M_sun]
        if 4 * M0 < M_pivot
            gamma0 = 0.06;      % low-mass CDM slope  (Kawai Eq. 26)
        else
            gamma0 = 0.12;      % high-mass CDM slope (Kawai Eq. 27)
        end

        % Two-factor suppression (Dentler Eq. 33 × Eq. 35 combined)
        factor1 = (1 + M0 ./ (f_coll .* M)).^(-gamma0);
        factor2 = (1 + gamma1 .* M0 ./ M).^(-gamma2);
        c_sup   = factor1 .* factor2;

    otherwise
        error('suppression_factor: unknown model "%s". Choose ''laroche2022'' or ''dentler2022''.', model);
end
end
