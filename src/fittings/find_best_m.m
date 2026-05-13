function [best_m, best_chi2, rss_list, chi2_list, rmse_list] = find_best_m(profile_name, rc, ...
                                                                              r, rho, m_range)
% FIND_BEST_M  Scan cutoff multiplier m to find optimal r_cut = m * rc.
%
% Selects the best cutoff by minimizing reduced chi-squared (chi2_red),
% which is a normalized goodness-of-fit that accounts for the number of
% data points available at each cutoff. This is more reliable than raw
% log-RSS, which shrinks artificially as fewer points are included.
%
% INPUTS
%   profile_name : 'nfw' | 'soliton' | 'einasto_fit' | 'hernquist_fit' | 'dk14_fit'
%   rc           : reference radius (e.g., soliton core radius) [kpc]
%   r            : full radius array [kpc], column vector
%   rho          : full density array [Msun/kpc^3], column vector
%   m_range      : 1x2 vector [m_min, m_max], e.g. [2, 10]
%
% OUTPUTS
%   best_m       : optimal cutoff multiplier (minimises chi2_red)
%   best_chi2    : reduced chi-squared at best_m
%   rss_list     : log-RSS values across all m tested (100 steps)
%   chi2_list    : chi2_red values across all m tested
%   rmse_list    : RMSE [dex] values across all m tested
%
% WHY chi2_red INSTEAD OF raw log-RSS?
%   Raw log-RSS decreases whenever data points are removed, so a fitter
%   with a very high r_cut (few points) always appears to win. chi2_red
%   = log_RSS / dof penalises models that fit only a handful of points,
%   giving a fair comparison across different cutoffs.
%
% NOTE ON DEGREES OF FREEDOM
%   dof = N_pts - N_params. If dof < 1 the fit is underdetermined and
%   that m value is skipped (set to Inf in chi2_list).

  m_values  = linspace(m_range(1), m_range(2), 100);
  rss_list  = zeros(size(m_values));
  chi2_list = zeros(size(m_values));
  rmse_list = zeros(size(m_values));
  r_max     = max(r);

  for i = 1:length(m_values)
    r_cut = m_values(i) * rc;
    try
      res = fit_profile_generic(r, rho, profile_name, r_cut, r_max);

      % skip underdetermined fits
      if res.dof < 1 || isinf(res.log_rss) || isnan(res.log_rss)
        rss_list(i)  = Inf;
        chi2_list(i) = Inf;
        rmse_list(i) = Inf;
      else
        rss_list(i)  = res.log_rss;
        chi2_list(i) = res.chi2_red;
        rmse_list(i) = res.rmse;
      end

    catch
      rss_list(i)  = Inf;
      chi2_list(i) = Inf;
      rmse_list(i) = Inf;
    end
  end

  % --- select best m by chi2_red ---
  [best_chi2, idx] = min(chi2_list);
  best_m           = m_values(idx);

  fprintf('\n--- find_best_m: %s ---\n',               profile_name);
  fprintf('  Best m      = %.2f\n',                    best_m);
  fprintf('  r_cut       = %.4f kpc\n',                best_m * rc);
  fprintf('  chi2_red    = %.4f\n',                    best_chi2);
  fprintf('  log-RSS     = %.4e\n',                    rss_list(idx));
  fprintf('  RMSE        = %.4f dex\n',                rmse_list(idx));
end
