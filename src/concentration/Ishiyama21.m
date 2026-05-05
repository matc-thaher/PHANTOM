function c = Ishiyama21(M, z, cosmo, mode, varargin)
% Ishiyama21 concentration using the Diemer19 engine,
% Ishiyama21_concentration  Ishiyama et al. (2021) concentration model
%
%   c = Ishiyama21(M, z, cosmo, mode)
%
%
% -------------------------------------------------------------------------
%   INPUTS
%   M     : halo mass [Msun/h], scalar or vector
%   z     : redshift (scalar)
%   cosmo : cosmology struct built by cosmology() + attach_linear_components()
%             Required handles:
%               cosmo.sigmaM(M, z)   — rms linear variance at mass M
%               cosmo.neff(M, z, k)  — effective spectral index at kappa*R_L
%               cosmo.alphaEff(z)    — effective growth exponent d ln D / d ln(1+z)
%   mode  : halo definition + sample string (case-insensitive)
%             '200c_all'     — M_200c, all haloes
%             '200c_relaxed' — M_200c, dynamically relaxed haloes
%             'vir_all'      — M_vir,  all haloes
%             'vir_relaxed'  — M_vir,  relaxed haloes
%             '500_all'      — M_500c, all haloes
%             '500_relaxed'  — M_500c, relaxed haloes
%  profile_name : (optional) string, profile for G-table. Default: 'nfw'
%                  See profile_mu.m for supported profiles.
%
%   OUTPUT
%   c     : halo concentration, same shape as M
%

% -------------------------------------------------------------------------
%   Reference: Ishiyama et al. 2021, MNRAS 506, 4210
%              Diemer & Joyce 2019, ApJ 871, 168  (original functional form)
% -------------------------------------------------------------------------

    P = Ishiyama21_Table(mode);  % same as you already have
    params.kappa   = P.kappa;
    params.a0      = P.a0;
    params.a1      = P.a1;
    params.b0      = P.b0;
    params.b1      = P.b1;
    params.c_alpha = P.cAlpha;

    c = Diemer19_general(M, z, cosmo, params, varargin{:});
end