% ==========================================================================
%  PHANTOM Profile Plots  —  using colossus_bridge + colossus_query
%  Figure 1 : CDM profiles (NFW, Einasto, Hernquist, DK14) vs Colossus
%  Figure 2 : FDM composite — soliton_nfw_analytic, three halo masses
% ==========================================================================
clear; clc; close all;

% --------------------------------------------------------------------------
% 0.  PATHS & USER SETTINGS
% --------------------------------------------------------------------------
addpath('F:\PHANTOM\src\utils',         '-begin');
addpath('F:\PHANTOM\src\concentration', '-begin');
addpath('F:\PHANTOM\src\suppression',   '-begin');
addpath('F:\PHANTOM\src\profiles',      '-begin');
addpath('F:\PHANTOM\src\fdm',           '-begin');

python_exe  = 'F:\anaconda3\python.exe';
bridge_path = 'F:\PHANTOM\src\utils\colossus_bridge.py';
cosmo_id    = 'planck18';
z           = 0.0;

% Halo parameters
M200c   = 1e14;   % [Msun/h]
c_halo  = 5.0;   % concentration c_200c
Delta   = 200;   % overdensity w.r.t. critical

% --------------------------------------------------------------------------
% 1.  PHANTOM COSMOLOGY STRUCT
% --------------------------------------------------------------------------
cosmo                = cosmology(cosmo_id);
cosmo.transfer_model = 'eh98';
cosmo                = attach_linear_components(cosmo);
cosmo                = attach_linear_components(cosmo);
cosmo.nu = @(M, z) max( ...
    collapse_overdensity('corrections', true, 'z', z, 'cosmo', cosmo) ...
    ./ cosmo.sigmaM(M, z), ...
    0.5 );
cosmo.peakheight     = cosmo.nu;   % alias used by DK14_profile internally

% --------------------------------------------------------------------------
% 2.  RADIAL GRID  [Mpc/h]
% --------------------------------------------------------------------------
rho_c  = cosmo.rho_crit0 * cosmo.E(z)^2;
R200c  = ( 3*M200c / (4*pi*Delta*rho_c) )^(1/3);
rs_est = R200c / c_halo;
r_Mph  = logspace( log10(0.01*rs_est), log10(5*R200c), 300 );   % [Mpc/h]
x_axis = r_Mph / rs_est;                                         % r / r_s
N_prof = 4;   % NFW, Einasto, Hernquist, DK14

% --------------------------------------------------------------------------
% 3.  PHANTOM CDM PROFILES
% --------------------------------------------------------------------------
f_c      = log(1 + c_halo) - c_halo/(1 + c_halo);
rhos_nfw = M200c / (4*pi * rs_est^3 * f_c);

fprintf('Computing PHANTOM profiles ...\n');
rho_phantom    = cell(4, 1);
rho_phantom{1} = NFW_profile(r_Mph, rhos_nfw, rs_est);
[rho_phantom{2}, ~, ~, ~] = Einasto_profile(r_Mph,   M200c, c_halo, z, cosmo, Delta);
[rho_phantom{3}, ~, ~, ~] = Hernquist_profile(r_Mph, M200c, c_halo, z, cosmo, Delta);
rho_phantom{4} = DK14_profile(r_Mph, M200c, c_halo, z, cosmo, Delta, 'M', []);
fprintf('PHANTOM profiles done.\n');

% --------------------------------------------------------------------------
% 4.  COLOSSUS PROFILES  via colossus_query + bridge
% --------------------------------------------------------------------------
fprintf('Querying Colossus profiles ...\n');

extra.M    = M200c;
extra.c    = c_halo;
extra.mdef = '200c';

T_col = colossus_query('profile_batch', r_Mph * 1e3, cosmo_id, '', z, ...
                        python_exe, bridge_path, extra);

% % In Section 4, after getting rho_colossus{1..3} with mdef='200c',
% % query DK14 separately with mdef='200m'
% extra_dk14.M    = M200c;
% extra_dk14.c    = c_halo;
% extra_dk14.mdef = '200m';
% 
% T_dk14 = colossus_query('profile_batch', r_Mph * 1e3, cosmo_id, 'dk14_only', z, ...
%                           python_exe, bridge_path, extra_dk14);
% T_col(:,4) = T_dk14(:,1);

unit_fac     = 1e9;   % (kpc/h)^-3  ->  (Mpc/h)^-3
rho_colossus = cell(N_prof, 1);
for i = 1:N_prof
    rho_colossus{i} = T_col(:, i) * unit_fac;
end

fprintf('Colossus profiles done.\n');

% --------------------------------------------------------------------------
% 5.  RESIDUALS
% --------------------------------------------------------------------------
profile_labels = {'NFW'; 'Einasto'; 'Hernquist'; 'DK14'};
profile_tags   = {'nfw'; 'einasto'; 'hernquist'; 'dk14'};
residuals      = cell(N_prof, 1);
for i = 1:N_prof
    residuals{i} = rho_phantom{i}(:) ./ rho_colossus{i}(:);
end

%%
% --------------------------------------------------------------------------
% 6.  FIGURE 1 :  CDM profiles + Colossus  (turbo colormap)
% --------------------------------------------------------------------------
fprintf('Plotting Figure 1 ...\n');

cmap1 = turbo(N_prof);
lw    = 2;
lwc   = 2;

fig1 = figure;

ax1 = subplot(3, 1, [1 2]);
hold(ax1, 'on');  box(ax1, 'on');
for i = 1:N_prof
    loglog(ax1, x_axis, rho_phantom{i},  '-',  ...
           'Color', cmap1(i,:), 'LineWidth', lw,  ...
           'DisplayName', profile_labels{i});
    loglog(ax1, x_axis, rho_colossus{i}, '--', ...
           'Color', cmap1(i,:), 'LineWidth', lwc, ...
           'DisplayName', [profile_tags{i}, ' (Colossus)']);
end
ylabel(ax1, '$\rho\ [\mathrm{M}_\odot\,h\,(\mathrm{Mpc}/h)^{-3}]$', ...
       'Interpreter', 'latex', 'FontSize', 32);
xlim(ax1, [min(x_axis), max(x_axis)]);
set(ax1, 'XTickLabel', [], 'XScale', 'log', 'YScale', 'log', ...
         'FontSize', 22, 'TickDir', 'in');
legend(ax1, 'Location', 'best', 'NumColumns', 2, ...
       'FontSize', 20, 'Interpreter', 'none');

ax2 = subplot(3, 1, 3);
hold(ax2, 'on');  box(ax2, 'on');
for i = 1:N_prof
    semilogx(ax2, x_axis, residuals{i}, '-', ...
             'Color', cmap1(i,:), 'LineWidth', lw, ...
             'DisplayName', profile_labels{i});
end
% % yline(ax2,  1,     'k--', 'LineWidth', 1.0);
% % yline(ax2,  1.01,  ':',   'Color', [0.5 0.5 0.5], 'LineWidth', 0.8);
% % yline(ax2,  0.99,  ':',   'Color', [0.5 0.5 0.5], 'LineWidth', 0.8);
xlabel(ax2, '$r/r_s$',                      'Interpreter', 'latex', 'FontSize', 32);
ylabel(ax2, '$\rho_{\rm PHANTOM} / \rho_{\rm Col}$', 'Interpreter', 'latex', 'FontSize', 32);
xlim(ax2, [min(x_axis), max(x_axis)]);
ylim(ax2, [0.8,1.2])
set(ax2, 'XScale', 'log', 'YScale', 'linear', 'FontSize', 22, 'TickDir', 'in');

% tight panel layout (mirrors concentration script)
left = 0.10;  right = 0.88;
bot2 = 0.15;  h2    = 0.20;
gap  = 0.00;  h1    = 0.60;
bot1 = bot2 + h2 + gap;
set(ax1, 'Position', [left, bot1, right, h1], 'LineWidth',2, 'FontSize', 20);
set(ax2, 'Position', [left, bot2, right, h2], 'LineWidth',2, 'FontSize', 20);
set(ax1, 'XTickLabel', [], 'TickDir', 'in');
set(ax2, 'TickDir', 'in');
linkaxes([ax1, ax2], 'x');

exportgraphics(fig1, 'profile_CDM_comparison.png', 'ContentType', 'vector');
fprintf('Figure 1 saved.\n');

%%
% --------------------------------------------------------------------------
% 7.  FIGURE 2 :  FDM composite — soliton_nfw_analytic
% --------------------------------------------------------------------------
fprintf('Plotting Figure 2 ...\n');

% { Mvir [Msun], Rvir [kpc], c_nfw, rho0_sol [Msun/kpc^3], rc_sol [kpc], label }
fdm_cases = {
    1e10,  50,   8.0,  3.0e8,  0.3, '$M_{\rm vir}=10^{10}\,\mathrm{M}_\odot$';
    1e12,  100,  6.0,  5.0e10, 0.2, '$M_{\rm vir}=10^{12}\,\mathrm{M}_\odot$';
    1e14,  200,  4.5,  2.0e12, 0.1, '$M_{\rm vir}=10^{14}\,\mathrm{M}_\odot$';
};
N_fdm = size(fdm_cases, 1);
r_kpc = logspace(-2, 4, 500)';   % 0.01 -> 10000 kpc

cmap2 = turbo(N_fdm);
lw2   = 2.0;

fig2 = figure;
hold on;  box on;

for i = 1:N_fdm
    comp = soliton_nfw_analytic( ...
               fdm_cases{i,4}, fdm_cases{i,5}, ...
               fdm_cases{i,1}, fdm_cases{i,2}, fdm_cases{i,3}, r_kpc);

    plot(r_kpc, comp.rho_composite, '-',  ...
           'Color', cmap2(i,:), 'LineWidth', lw2, ...
           'DisplayName', fdm_cases{i,6});
    plot(r_kpc, comp.rho_soliton,   '--', ...
           'Color', cmap2(i,:), 'LineWidth', 1.0, ...
           'HandleVisibility', 'off');
    plot(r_kpc, comp.rho_nfw,       ':', ...
           'Color', cmap2(i,:), 'LineWidth', 1.0, ...
           'HandleVisibility', 'off');
    plot(comp.r_x, comp.rho_x, 'o', ...
         'MarkerSize', 7, 'MarkerFaceColor', cmap2(i,:), ...
         'MarkerEdgeColor', 'k', 'LineWidth', 0.8, ...
         'HandleVisibility', 'off');
end

% line-style legend entries
plot(NaN, NaN, 'k-',  'LineWidth', lw2, 'DisplayName', 'Composite');
plot(NaN, NaN, 'k--', 'LineWidth', 1.0, 'DisplayName', 'Soliton');
plot(NaN, NaN, 'k:',  'LineWidth', 1.0, 'DisplayName', 'NFW');
plot(  NaN, NaN, 'ko',  'MarkerSize', 7,  'MarkerFaceColor', 'w', ...
       'DisplayName', '$r_\times$');

xlabel('$r\ [\mathrm{kpc}]$', ...
       'Interpreter', 'latex', 'FontSize', 32);
ylabel('$\rho\ [\mathrm{M}_\odot\,\mathrm{kpc}^{-3}]$', ...
       'Interpreter', 'latex', 'FontSize', 32);
xlim([min(r_kpc), fdm_cases{1,2}]);
ylim([1e3,1e14])
set(gca, 'XScale', 'log', 'YScale', 'log', 'FontSize', 22, ...
         'LineWidth', 1.5, 'TickDir', 'in');
legend('Location', 'southwest', 'NumColumns', 1, ...
       'FontSize', 13, 'Interpreter', 'latex');

exportgraphics(fig2, 'profile_FDM_composite.png', 'ContentType', 'vector');
fprintf('Figure 2 saved.\n');

fprintf('\nAll done.\n');
