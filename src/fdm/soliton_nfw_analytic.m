function comp = soliton_nfw_analytic(rho0_sol, rc_sol, Mvir, Rvir, c_nfw, r)
% SOLITON_NFW_ANALYTIC  Analytic soliton+NFW composite for a given halo.
%
% Constructs the composite profile theoretically from:
%   - Soliton parameters: central density rho0 and core radius rc
%   - NFW parameters derived analytically from Mvir, Rvir, concentration c
%
% The intersection radius r_x is found by solving soliton(r) = NFW(r)
% numerically on the provided radial grid.
%
% INPUTS
%   rho0_sol : soliton central density [Msun/kpc^3]
%   rc_sol   : soliton core radius [kpc]
%   Mvir     : virial mass [Msun]
%   Rvir     : virial radius [kpc]
%   c_nfw    : NFW concentration (dimensionless)
%   r        : radii where the profile is desired [kpc], vector
%
% OUTPUTS (struct)
%   comp.r_x           : intersection radius [kpc]
%   comp.rho_x         : density at intersection [Msun/kpc^3]
%   comp.rho_composite : composite density profile at r
%   comp.rho_soliton   : full soliton profile at r
%   comp.rho_nfw       : full NFW profile at r (from analytic parameters)
%   comp.rs_nfw        : NFW scale radius [kpc]
%   comp.rhos_nfw      : NFW characteristic density [Msun/kpc^3]
%   comp.r             : input radius array

  r = r(:);

  % --- Soliton profile ---
  rho_sol = Soliton_profile(r, rho0_sol, rc_sol);

  % --- NFW analytic parameters from Mvir, Rvir, c ---
  % Uses NFW_analytcl_Profile.m (already in your codebase)
  nfw_struct = NFW_analytcl_Profile(Mvir, Rvir, c_nfw, r);
  rs_nfw     = nfw_struct.rs;
  rhos_nfw   = nfw_struct.rho_s;

  % Evaluate NFW on the same full r grid (NFW_analytcl_Profile may trim r)
  rho_nfw = NFW_profile(r, rhos_nfw, rs_nfw);

  % --- Find intersection on dense grid ---
  r_dense  = linspace(min(r), Rvir, 10000)';
  rho_s_d  = Soliton_profile(r_dense, rho0_sol, rc_sol);
  rho_n_d  = NFW_profile(r_dense, rhos_nfw, rs_nfw);
  diff_arr = log10(rho_s_d) - log10(rho_n_d);

  sign_changes = find(diff(sign(diff_arr)) ~= 0);

  if isempty(sign_changes)
    warning(['soliton_nfw_analytic: profiles do not cross on [rmin, Rvir]. ' ...
             'Check that rho0_sol and the NFW amplitude are consistent.']);
    r_x = rc_sol * 3;   % fallback
  else
    i_cross = sign_changes(1);
    r_a     = r_dense(i_cross);
    r_b     = r_dense(i_cross + 1);
    diff_fn = @(rv) log10(Soliton_profile(rv, rho0_sol, rc_sol)) - ...
                    log10(NFW_profile(rv, rhos_nfw, rs_nfw));
    try
      r_x = fzero(diff_fn, [r_a, r_b]);
    catch
      r_x = 0.5*(r_a + r_b);
    end
  end

  rho_x = Soliton_profile(r_x, rho0_sol, rc_sol);
  fprintf('Analytic intersection: r_x = %.4f kpc | rho_x = %.4e Msun/kpc^3\n', ...
          r_x, rho_x);

  % --- Build composite ---
  rho_composite             = zeros(size(r));
  rho_composite(r <= r_x)   = rho_sol(r <= r_x);
  rho_composite(r >  r_x)   = rho_nfw(r >  r_x);

  % --- Package output ---
  comp.r_x           = r_x;
  comp.rho_x         = rho_x;
  comp.rho_composite = rho_composite;
  comp.rho_soliton   = rho_sol;
  comp.rho_nfw       = rho_nfw;
  comp.rs_nfw        = rs_nfw;
  comp.rhos_nfw      = rhos_nfw;
  comp.r             = r;

  % --- Plot ---
  figure;
  loglog(r, rho_sol,        'b--', 'LineWidth', 1.5, 'DisplayName', 'Soliton (analytic)');
  hold on;
  loglog(r, rho_nfw,        'r--', 'LineWidth', 1.5, 'DisplayName', 'NFW (analytic)');
  loglog(r, rho_composite,  'g-',  'LineWidth', 2.5, 'DisplayName', 'Composite');
  plot(r_x, rho_x, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'y', ...
       'DisplayName', sprintf('r_x = %.3f kpc', r_x));
  xlabel('Radius [kpc]', 'FontSize', 14);
  ylabel('Density [M_{sun}/kpc^3]', 'FontSize', 14);
  legend('Location', 'southwest');
  title(sprintf('Analytic Composite: c=%.1f, r_c=%.3f kpc', c_nfw, rc_sol));
  grid on;
end