function comp = soliton_nfw_composite(r, rho, r_c_guess, virRad)
% SOLITON_NFW_COMPOSITE  Composite soliton+NFW profile from simulation data.
%
% Procedure:
%   1. Fit soliton profile to the inner region (r < ~3.5 * r_c_guess).
%   2. Fit NFW profile to the outer region (r > ~3.5 * r_c_guess).
%   3. Find the intersection radius r_x where soliton(r_x) = NFW(r_x).
%   4. Build composite: soliton for r <= r_x, NFW for r > r_x.
%
% INPUTS
%   r          : radii [kpc], column vector
%   rho        : simulation density [Msun/kpc^3], column vector
%   r_c_guess  : initial estimate of soliton core radius [kpc]
%   virRad     : virial radius [kpc] (upper bound for NFW fit)
%
% OUTPUTS (struct)
%   comp.r_x          : intersection radius [kpc]
%   comp.rho_x        : density at intersection [Msun/kpc^3]
%   comp.rho_composite: stitched density profile at all r [Msun/kpc^3]
%   comp.rho_soliton  : soliton model evaluated at all r
%   comp.rho_nfw      : NFW model evaluated at all r
%   comp.pfit_sol     : soliton fit parameters [rho0, rc]
%   comp.pfit_nfw     : NFW fit parameters [rhos, rs]
%   comp.r            : input radius array

  r   = r(:);
  rho = rho(:);

  % --- Step 1: find best cutoff for soliton ---
  [m_sol, ~, ~] = find_best_m('soliton', r_c_guess, r, rho, [2.0, 3.5]);
  r_cut_sol     = m_sol * r_c_guess;
  res_sol       = fit_profile_generic(r, rho, 'soliton', 0, r_cut_sol);
  p_sol         = res_sol.pfit;   % [rho0, rc]

  % --- Step 2: find best cutoff for NFW ---
  [m_nfw, ~, ~] = find_best_m('nfw', r_c_guess, r, rho, [3.5, 10.0]);
  r_cut_nfw     = m_nfw * r_c_guess;
  res_nfw       = fit_profile_generic(r, rho, 'nfw', r_cut_nfw, virRad);
  p_nfw         = res_nfw.pfit;   % [rhos, rs]

  % --- Step 3: find intersection radius ---
  % Search on a dense grid, then refine with fzero
  r_dense  = linspace(r_cut_sol, virRad, 5000)';
  rho_s    = Soliton_profile(r_dense, p_sol(1), p_sol(2));
  rho_n    = NFW_profile(r_dense, p_nfw(1), p_nfw(2));
  diff_arr = log10(rho_s) - log10(rho_n);

  sign_changes = find(diff(sign(diff_arr)) ~= 0);

  if isempty(sign_changes)
    warning(['soliton_nfw_composite: no intersection found between ' ...
             'soliton and NFW. Using r_cut_nfw as fallback r_x.']);
    r_x = r_cut_nfw;
  else
    % Take the first sign change (innermost crossing)
    i_cross = sign_changes(1);
    r_a     = r_dense(i_cross);
    r_b     = r_dense(i_cross + 1);
    diff_fn = @(rv) log10(Soliton_profile(rv, p_sol(1), p_sol(2))) - ...
                    log10(NFW_profile(rv, p_nfw(1), p_nfw(2)));
    try
      r_x = fzero(diff_fn, [r_a, r_b]);
    catch
      r_x = 0.5 * (r_a + r_b);
    end
  end

  rho_x = Soliton_profile(r_x, p_sol(1), p_sol(2));
  fprintf('Intersection: r_x = %.4f kpc | rho_x = %.4e Msun/kpc^3\n', r_x, rho_x);

  % --- Step 4: stitch composite profile ---
  rho_sol_full = Soliton_profile(r, p_sol(1), p_sol(2));
  rho_nfw_full = NFW_profile(r, p_nfw(1), p_nfw(2));

  rho_composite              = zeros(size(r));
  rho_composite(r <= r_x)    = rho_sol_full(r <= r_x);
  rho_composite(r >  r_x)    = rho_nfw_full(r >  r_x);

  % --- Package output ---
  comp.r_x           = r_x;
  comp.rho_x         = rho_x;
  comp.rho_composite = rho_composite;
  comp.rho_soliton   = rho_sol_full;
  comp.rho_nfw       = rho_nfw_full;
  comp.pfit_sol      = p_sol;
  comp.pfit_nfw      = p_nfw;
  comp.r             = r;

  % --- Plot ---
  figure;
  loglog(r, rho, 'k.', 'MarkerSize', 8, 'DisplayName', 'Simulation data');
  hold on;
  loglog(r, rho_sol_full, 'b--', 'LineWidth', 1.5, 'DisplayName', 'Soliton fit');
  loglog(r, rho_nfw_full, 'r--', 'LineWidth', 1.5, 'DisplayName', 'NFW fit');
  loglog(r, rho_composite,'g-',  'LineWidth', 2.5, 'DisplayName', 'Composite');
  plot(r_x, rho_x, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'y', ...
       'DisplayName', sprintf('r_x = %.3f kpc', r_x));
  xlabel('Radius [kpc]', 'FontSize', 14);
  ylabel('Density [M_{sun}/kpc^3]', 'FontSize', 14);
  legend('Location', 'southwest');
  title('Soliton + NFW Composite Profile');
  grid on;
end