function f = multiplicity_dispatcher(model, sigma, varargin)
% multiplicity_dispatcher   Unified interface to all PHANTOM multiplicity functions.
%
% USAGE:
%   f = multiplicity_dispatcher('PS',              sigma, delta_c)
%   f = multiplicity_dispatcher('ST',              sigma, delta_c)
%   f = multiplicity_dispatcher('Tinker08',        sigma, Delta)
%   f = multiplicity_dispatcher('Tinker10',        sigma, Delta)
%   f = multiplicity_dispatcher('Watson13',        sigma, z)
%   f = multiplicity_dispatcher('Crocce10',        sigma, z)
%   f = multiplicity_dispatcher('Courtin11',       sigma, delta_c)
%   f = multiplicity_dispatcher('Despali16',       sigma, Delta_c, Delta_vir_c, delta_c)
%   f = multiplicity_dispatcher('Yung25',          sigma, z)
%   f = multiplicity_dispatcher('FernandezGarcia26', sigma, M, z, mdef, cosmo)
%   f = multiplicity_dispatcher('Fiorilli26',      sigma, z, mdef, cosmo)
%   f = multiplicity_dispatcher('Fiorilli26',      sigma, z, mdef, cosmo, include_unbound)
%   % --- WDM ---
%   f = multiplicity_dispatcher('Schneider12',     sigma, M, M_hm, z, delta_c, variant)
%   f = multiplicity_dispatcher('Lovell14',        sigma, M, M_hm, z, delta_c)
%   % --- FDM ---
%   f = multiplicity_dispatcher('Schive16',        sigma, M, M_hm, z, delta_c, base_model)
%   f = multiplicity_dispatcher('Du17',            sigma, M, z, m22, cosmo)
%   f = multiplicity_dispatcher('Du17',            sigma, M, z, m22, cosmo, delta_c)
%
% INPUT:
%   model    : string name of the mass function model
%   sigma    : sigma(M, z)
%   varargin : model-specific arguments (see individual functions)

    switch lower(model)

        % ----------------------------------------------------------
        % CDM models
        % ----------------------------------------------------------
        case 'ps'
            f = multiplicity_PS(varargin{:});
        case {'st', 'sheth99', 'sheth01'}
            f = multiplicity_ST(varargin{:});
        case 'tinker08'
            f = multiplicity_Tinker08(varargin{:});
        case 'tinker10'
            f = multiplicity_Tinker10(varargin{:});
        case 'watson13'
            f = multiplicity_Watson13(sigma, varargin{:});
        case 'crocce10'
            f = multiplicity_Crocce10(sigma, varargin{:});
        case 'courtin11'
            f = multiplicity_Courtin11(sigma, varargin{:});
        case 'despali16'
            f = multiplicity_Despali16(sigma, varargin{:});
        case 'yung25'
            f = multiplicity_Yung25(sigma, varargin{:});

        case 'fernandezgarcia26'
            % Fernandez-Garcia, Betancort-Rijo, Prada et al. (2026)
            % arXiv:2512.05847 — GPS+ triaxial collapse model
            % varargin: {M, z, mdef, cosmo}
            % Valid mdef: '200m' or 'vir' only
            f = multiplicity_FernandezGarcia26(sigma, varargin{:});

        case 'fiorilli26'
            % Fiorilli, Ruiz, Sanchez & Esposito (2026)
            % arXiv:2511.16730 — Evolution Mapping framework
            % varargin: {z, mdef, cosmo} or {z, mdef, cosmo, include_unbound}
            % Valid mdef: any SO 'NNNm', Delta in [150, 1600]
            f = multiplicity_Fiorilli26(sigma, varargin{:});

        % ----------------------------------------------------------
        % WDM models
        % ----------------------------------------------------------
        case 'schneider12'
            f = multiplicity_Schneider12(sigma, varargin{:});
        case 'lovell14'
            f = multiplicity_Lovell14(sigma, varargin{:});

        % ----------------------------------------------------------
        % FDM models
        % ----------------------------------------------------------
        case 'schive16'
            f = multiplicity_Schive16(sigma, varargin{:});
        case 'du17'
            % Du, Behrens & Niemeyer (2017), MNRAS 465, 941
            % Mass-dependent FDM barrier via Sheth-Tormen with G(M)*delta_c
            % varargin: {M, z, m22, cosmo} or {M, z, m22, cosmo, delta_c}
            f = multiplicity_Du17(sigma, varargin{:});

        otherwise
            error('multiplicity_dispatcher: unknown model ''%s''.', model);
    end
end