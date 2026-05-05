function [Gc_interp, Gmin_interp, Gmax_interp] = get_Gc_table(profile)
    % profile: 'nfw' only for now

    persistent cache
    if ~isempty(cache) && isfield(cache, profile)
        s = cache.(profile);
        Gc_interp   = s.Gc_interp;
        Gmin_interp = s.Gmin_interp;
        Gmax_interp = s.Gmax_interp;
        return;
    end

    % --- grid sizes (match Colossus) ---
    n_G = 80;  n_n = 40;  n_c = 80;
    n   = linspace(-4.0, 0.0, n_n);           % shape (1 x n_n)
    c_log = linspace(-1.0, 3.0, n_c);         % log10 c, shape (1 x n_c)
    c     = 10.^c_log;                        % shape (1 x n_c)

    % --- mu(c) for NFW (1 x n_c) ---
    mu = NFW_mu(c);                           % same size as c

    % --- lhs(G,c,n): n_c x n_n ---
    lhs = zeros(n_c, n_n);
    for j = 1:n_n
        % vectorized over c: both c and mu are 1 x n_c
        exponent = (5 + n(j)) / 6;            % scalar
        lhs(:, j) = log10( (c ./ (mu.^exponent)) );  % result 1 x n_c → column
    end

    % --- enforce monotonic ascending region in c for each n ---
    mask_ascending = true(size(lhs));
    mask_ascending(1:end-1, :) = diff(lhs, 1, 1) > 0;

    % --- global G range ---
    G_min = min(lhs(:));
    G_max = max(lhs(:));
    G     = linspace(G_min, G_max, n_G);      % 1 x n_G

    gc_table = -10*ones(n_G, n_n);           % table of log10(c)
    mins = zeros(1, n_n);
    maxs = zeros(1, n_n);

    for j = 1:n_n
        m = mask_ascending(:, j);            % n_c x 1 logical
        lhs_j = lhs(m, j);                   % column (n_valid x 1)
        c_j   = c_log(m)';                   % log10(c), column

        mins(j) = min(lhs_j);
        maxs(j) = max(lhs_j);

        % valid G in this n-bin
        maskG   = (G >= mins(j) & G <= maxs(j));
        G_valid = G(maskG);                  % row vector

        % interpolate log10 c as function of G
        c_valid = interp1(lhs_j, c_j, G_valid, 'linear', 'extrap');  % row

        % fill gc_table for this n
        gc_table(maskG, j) = c_valid(:);     % column assignment

        mask_low  = (G < mins(j));
        mask_high = (G > maxs(j));
        gc_table(mask_low, j)  = min(c_valid);
        gc_table(mask_high, j) = max(c_valid);
    end

    % 2D interpolator: (G, n) → log10(c)
    [G_grid, n_grid] = ndgrid(G, n);         % both n_G x n_n
    Gc_interp = griddedInterpolant(G_grid, n_grid, gc_table, 'linear');

    % 1D interpolants for Gmin(n), Gmax(n)
    Gmin_interp = griddedInterpolant(n, mins, 'linear');
    Gmax_interp = griddedInterpolant(n, maxs, 'linear');

    % cache
    s.Gc_interp   = Gc_interp;
    s.Gmin_interp = Gmin_interp;
    s.Gmax_interp = Gmax_interp;
    if isempty(cache), cache = struct; end
    cache.(profile) = s;
end

function mu = NFW_mu(c)
    % NFWProfile.mu(c) = f(c) / f(1). For Diemer19, the key is to use the
    % same f(c) as in Diemer's code:
    % f(c) = ln(1+c) - c/(1+c).
    % mu(c) is then normalized enclosed mass; for the DJ19 G(c) definition,
    % you can directly set:
    f = log(1 + c) - c ./ (1 + c);
    mu = f;   % normalization absorbed into fit
end