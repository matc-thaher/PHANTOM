function [c_fdm, M_half] = c_FDM(M, z, m_ax, varargin)
% C_FDM  FDM halo concentration = CDM reference concentration × suppression factor
%
% Computes M_half internally from the boson mass m_ax, then calls
% suppression_factor() and c_CDM().
%
% -------------------------------------------------------------------------
% Usage:
%   [c, M_half] = c_FDM(M, z, m_ax)
%       Default CDM model: 'ishiyama21', default suppression: 'laroche2022'.
%
%   [c, M_half] = c_FDM(M, z, m_ax, 'dentler2022')
%       Custom suppression model, default CDM model.
%
%   [c, M_half] = c_FDM(M, z, m_ax, 'laroche2022', 'bullock01')
%       Custom suppression + CDM model (no cosmo needed for bullock01).
%
%   [c, M_half] = c_FDM(M, z, m_ax, 'laroche2022', 'ishiyama21', cosmo)
%       Physics-based CDM model requiring cosmo struct.
%
%   [c, M_half] = c_FDM(M, z, m_ax, 'laroche2022', 'ishiyama21', cosmo, mode)
%       Physics-based CDM model with explicit mode string.
%
% -------------------------------------------------------------------------
% Inputs:
%   M         - Halo mass [M_sun], scalar or array
%   z         - Redshift, scalar (broadcast-compatible with M)
%   m_ax      - Boson (axion) mass [eV],  e.g. 1e-22
%   varargin  - Optional positional arguments (all optional, in order):
%                 1. sup_model  - Suppression model string
%                                 'laroche2022' (default) | 'dentler2022'
%                 2. cdm_model  - CDM concentration model string
%                                 Default: 'ishiyama21'
%                                 See c_CDM for full list
%                 3. cosmo      - Cosmology struct from cosmology.m
%                                 Required for physics-based CDM models:
%                                 prada12, diemer15, ludlow16, klypin16,
%                                 child18, diemer19, ishiyama21
%                                 Not needed for: bullock01, duffy08,
%                                 klypin11, dutton14
%                 4. mode       - Model-specific mode string (optional)
%                                 Passed directly to c_CDM
%
% Outputs:
%   c_fdm     - FDM halo concentration parameter (same size as M)
%   M_half    - Half-mode mass [M_sun] computed from m_ax
%               M_half = 3.8e10 * (m_ax / 1e-22)^(-4/3)
%
% -------------------------------------------------------------------------
% CDM models and required arguments:
%
%   Simple fits — cosmo NOT required:
%     'duffy08'    Duffy    et al. 2008  (mode optional)
%     'klypin11'   Klypin   et al. 2011  (mode optional)
%     'dutton14'   Dutton & Maccio 2014  (mode optional)
%
%   Physics-based — cosmo REQUIRED:
%     'bullock01'  Bullock  et al. 2001
%     'prada12'    Prada    et al. 2012
%     'diemer15'   Diemer & Kravtsov 2015
%     'ludlow16'   Ludlow   et al. 2016
%     'klypin16'   Klypin   et al. 2016  (mode optional)
%     'child18'    Child    et al. 2018  (mode optional)
%     'diemer19'   Diemer & Joyce  2019  (mode optional)
%     'ishiyama21' Ishiyama et al. 2021  (mode optional) [DEFAULT]
%
% -------------------------------------------------------------------------
% Examples:
%   cosmo = cosmology();
%   M     = logspace(8, 15, 100);    % [M_sun]
%   z     = 0;
%   m_ax  = 1e-22;                   % [eV]
%
%   % Minimal call — Ishiyama21 CDM + Laroche2022 suppression
%   [c, Mh] = c_FDM(M, z, m_ax)
%
%   % Dentler suppression, default CDM
%   [c, Mh] = c_FDM(M, z, m_ax, 'dentler2022')
%
%   % Laroche suppression, Bullock01 CDM with cosmo
%   [c, Mh] = c_FDM(M, z, m_ax, 'laroche2022', 'bullock01')
%
%   % Laroche suppression, Dutton14 CDM with mode
%   [c, Mh] = c_FDM(M, z, m_ax, 'laroche2022', 'dutton14', 'vir')
%
%   % Dentler suppression, Ishiyama21 CDM with cosmo
%   [c, Mh] = c_FDM(M, z, m_ax, 'dentler2022', 'ishiyama21', cosmo)
%
%   % Dentler suppression, Ishiyama21 CDM with cosmo + mode
%   [c, Mh] = c_FDM(M, z, m_ax, 'dentler2022', 'ishiyama21', cosmo, '200c_relaxed')
%
%   % Laroche suppression, Diemer19 CDM with cosmo + mode
%   [c, Mh] = c_FDM(M, z, m_ax, 'laroche2022', 'diemer19', cosmo, 'mean')
%
% -------------------------------------------------------------------------
% References:
%   Laroche et al. (2022)  https://doi.org/10.1093/mnras/stac2677
%   Dentler et al. (2022)  https://doi.org/10.1093/mnras/stac1946
%   Kawai   et al. (2024)  https://doi.org/10.1103/PhysRevD.110.023519

% -------------------------------------------------------------------------
% Parse varargin: (sup_model, cdm_model, [cosmo], [mode])
% -------------------------------------------------------------------------

% CDM models that do NOT need a cosmo struct
simple_models = { 'duffy08', 'd08', ...
                 'klypin11',  'k11', 'dutton14', 'dm14'};

% % --- suppression model (arg 1) ---
% if numel(varargin) >= 1 && ischar(varargin{1}) && ...
%         any(strcmpi(varargin{1}, {'laroche2022','dentler2022'}))
%     sup_model = varargin{1};
%     varargin  = varargin(2:end);          % consume
% else
%     sup_model = 'laroche2022';            % default
% end
% 
% % --- CDM model (arg 2, now arg 1 of remaining) ---
% if numel(varargin) >= 1 && ischar(varargin{1}) && ...
%         ~isstruct(varargin{1})
%     cdm_model = varargin{1};
%     varargin  = varargin(2:end);          % consume
% else
%     cdm_model = 'ishiyama21';             % default
% end

% --- suppression model (arg 1) ---
if numel(varargin) >= 1 && (ischar(varargin{1}) || isstring(varargin{1})) && ...
        any(strcmpi(varargin{1}, {'laroche2022','dentler2022'}))
    sup_model = varargin{1};
    varargin  = varargin(2:end);          % consume
else
    sup_model = 'laroche2022';            % default
end
% --- CDM model (arg 2, now arg 1 of remaining) ---
if numel(varargin) >= 1 && (ischar(varargin{1}) || isstring(varargin{1})) && ...
        ~isstruct(varargin{1})
    cdm_model = varargin{1};
    varargin  = varargin(2:end);          % consume
else
    cdm_model = 'ishiyama21';             % default
end

% Remaining varargin is forwarded to c_CDM as-is:
%   cosmo (struct) and/or mode (char), exactly matching c_CDM's signature.
% For simple models (no cosmo), varargin may be empty or contain only mode.
% Validate that physics-based models received a cosmo struct.
% needs_cosmo = ~any(strcmpi(cdm_model, simple_models));
% if needs_cosmo && (isempty(varargin) || ~isstruct(varargin{1}))
%     error(['c_FDM: CDM model "%s" requires a cosmo struct as input.\n' ...
%            'Call: c_FDM(M, z, m_ax, sup_model, ''%s'', cosmo) ' ...
%            'or c_FDM(M, z, m_ax, sup_model, ''%s'', cosmo, mode).'], ...
%            cdm_model, cdm_model, cdm_model);
% end

% -------------------------------------------------------------------------
% Compute M_half from boson mass
%   M_half = 3.8e10 * m22^(-4/3)  [M_sun]
%   where m22 = m_ax / 1e-22 eV
% -------------------------------------------------------------------------
m22    = m_ax ; %/ 1e-22;
M_half = 3.8e10 * m22^(-4/3);           % [M_sun]

% -------------------------------------------------------------------------
% CDM reference concentration
% -------------------------------------------------------------------------
c_ref = c_CDM(M, z, cdm_model, varargin{:});

% -------------------------------------------------------------------------
% FDM suppression factor
% -------------------------------------------------------------------------
sup = suppression_factor(M, M_half, sup_model);

% -------------------------------------------------------------------------
% FDM concentration
% -------------------------------------------------------------------------
c_fdm = c_ref .* sup;

end