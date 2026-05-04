function c = Ishiyama21(M, z, cosmo, mode)
% Ishiyama21 concentration using the Diemer19 engine,
% matching Colossus model='ishiyama21' (NFW, CDM).
%
% mode examples:
%   'vir_all', 'vir_relaxed', '200c_all', '200c_relaxed', '500c_all', '500c_relaxed'

    P = Ishiyama21_Table(mode);  % same as you already have
    params.kappa   = P.kappa;
    params.a0      = P.a0;
    params.a1      = P.a1;
    params.b0      = P.b0;
    params.b1      = P.b1;
    params.c_alpha = P.cAlpha;

    c = Diemer19_general(M, z, cosmo, params);
end