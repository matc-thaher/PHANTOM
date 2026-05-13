function [k_tab, P_tab] = camb_power(cosmo, varargin)
% Load linear matter power spectrum from CAMB through Python
%
% INPUT:
%   cosmo : cosmology struct with fields
%       Omega_m, Omega_b, h, ns
%
% OPTIONAL NAME-VALUE PAIRS:
%   'python_exe' : full path to python executable
%   'minkh'      : minimum k in h/Mpc       (default 1e-4)
%   'maxkh'      : maximum k in h/Mpc       (default 100)
%   'npoints'    : number of k samples      (default 2000)
%   'As'         : primordial amplitude     (optional)
%   'sigma8'     : optional target sigma8, only if you later want to tune As
%
% OUTPUT:
%   k_tab : k array in h/Mpc
%   P_tab : linear matter power spectrum in (Mpc/h)^3

    p = inputParser;
    addParameter(p, 'python_exe', '', @(x) ischar(x) || isstring(x));
    addParameter(p, 'minkh',   1e-4, @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'maxkh',   100,  @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'npoints', 2000, @(x) isnumeric(x) && isscalar(x) && x >= 2);
    addParameter(p, 'As', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
    parse(p, varargin{:});

    python_exe = string(p.Results.python_exe);
    minkh      = p.Results.minkh;
    maxkh      = p.Results.maxkh;
    npoints    = p.Results.npoints;
    As         = p.Results.As;

    % Set Python only if user supplied a path
    if strlength(python_exe) > 0
        pe = pyenv;
        if pe.Status == "Loaded"
            if pe.Executable ~= python_exe
                error(['Python is already loaded in MATLAB as:' newline ...
                       char(pe.Executable) newline ...
                       'Restart MATLAB, then set pyenv("Version", "...") to the desired python.']);
            end
        else
            pyenv("Version", python_exe);
        end
    end

    H0    = 100 * cosmo.h;
    ombh2 = cosmo.Omega_b * cosmo.h^2;
    omch2 = (cosmo.Omega_m - cosmo.Omega_b) * cosmo.h^2;
    ns    = cosmo.ns;

    if isempty(As)
        pycode = [
            "import camb", newline, ...
            "from camb import model", newline, ...
            "pars = camb.CAMBparams()", newline, ...
            "pars.set_cosmology(H0=H0_in, ombh2=ombh2_in, omch2=omch2_in)", newline, ...
            "pars.InitPower.set_params(ns=ns_in)", newline, ...
            "pars.set_matter_power(redshifts=[0.0], kmax=maxkh_in)", newline, ...
            "pars.NonLinear = model.NonLinear_none", newline, ...
            "results = camb.get_results(pars)", newline, ...
            "kh, z, pk = results.get_matter_power_spectrum(minkh=minkh_in, maxkh=maxkh_in, npoints=npoints_in)", newline, ...
            "kh_out = kh", newline, ...
            "pk_out = pk[0]" ...
        ];
    else
        pycode = [
            "import camb", newline, ...
            "from camb import model", newline, ...
            "pars = camb.CAMBparams()", newline, ...
            "pars.set_cosmology(H0=H0_in, ombh2=ombh2_in, omch2=omch2_in)", newline, ...
            "pars.InitPower.set_params(ns=ns_in, As=As_in)", newline, ...
            "pars.set_matter_power(redshifts=[0.0], kmax=maxkh_in)", newline, ...
            "pars.NonLinear = model.NonLinear_none", newline, ...
            "results = camb.get_results(pars)", newline, ...
            "kh, z, pk = results.get_matter_power_spectrum(minkh=minkh_in, maxkh=maxkh_in, npoints=npoints_in)", newline, ...
            "kh_out = kh", newline, ...
            "pk_out = pk[0]" ...
        ];
    end

    if isempty(As)
        [kh_py, pk_py] = pyrun(pycode, ["kh_out","pk_out"], ...
            H0_in=H0, ombh2_in=ombh2, omch2_in=omch2, ns_in=ns, ...
            minkh_in=minkh, maxkh_in=maxkh, npoints_in=int32(npoints));
    else
        [kh_py, pk_py] = pyrun(pycode, ["kh_out","pk_out"], ...
            H0_in=H0, ombh2_in=ombh2, omch2_in=omch2, ns_in=ns, As_in=As, ...
            minkh_in=minkh, maxkh_in=maxkh, npoints_in=int32(npoints));
    end

    k_tab = double(kh_py);
    P_tab = double(pk_py);

    k_tab = k_tab(:);
    P_tab = P_tab(:);

    valid = isfinite(k_tab) & isfinite(P_tab) & (k_tab > 0) & (P_tab > 0);
    k_tab = k_tab(valid);
    P_tab = P_tab(valid);

    [k_tab, idx] = sort(k_tab);
    P_tab = P_tab(idx);
end