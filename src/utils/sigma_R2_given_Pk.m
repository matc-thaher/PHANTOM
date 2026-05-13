% function s2 = sigma_R2_given_Pk(R, z, cosmo, Pk_handle, filter_name)
%     % Compute sigma^2(R,z) using a user-supplied P(k)
%     % R         : radius (Mpc/h), scalar or vector
%     % z         : redshift
%     % cosmo     : cosmology struct
%     % Pk_handle : handle for P(k) at z=0
%     % filter_name (optional): 'tophat', 'gaussian', 'sharpk', 'smoothk', 'vsmk'
% 
%     if nargin < 5 || isempty(filter_name)
%         if isfield(cosmo, 'variance_filter') && ~isempty(cosmo.variance_filter)
%             filter_name = cosmo.variance_filter;
%         else
%             filter_name = 'tophat';
%         end
%     end
% 
%     lnk = linspace(log(1e-6), log(1e4), 4000).';
%     k   = exp(lnk);
% 
%     D   = cosmo.D(z) / cosmo.D(0);
%     Pk  = Pk_handle(k) .* D^2;
% 
%     R = R(:).';
%     x = k .* R;
%     W = variance_window(x, filter_name);
% 
%     % High-k taper: suppress modes with kR >> 1 that are numerical noise
%     taper = exp(-(x / 100).^2);          % negligible effect at kR < ~50
% 
%     integrand = Pk .* W.^2 .* k.^3 .* taper;
%     s2 = (1/(2*pi^2)) * trapz(lnk, integrand, 1);
% 
%     if isscalar(R)
%         s2 = s2(1);
%     end
% end

function s2 = sigma_R2_given_Pk(R, z, cosmo, Pk_handle, filter_name)

if nargin < 5 || isempty(filter_name)
    if isfield(cosmo,'variance_filter') && ~isempty(cosmo.variance_filter)
        filter_name = cosmo.variance_filter;
    else
        filter_name = 'tophat';
    end
end

D  = cosmo.D(z) / cosmo.D(0);
D2 = D^2;

% Determine integration limits from transfer model
switch lower(cosmo.transfer_model)
    case 'camb'
        if ~isfield(cosmo,'k_camb') || isempty(cosmo.k_camb)
            error(['cosmo.k_camb is missing. ' ...
                   'Call attach_linear_components(cosmo) with transfer_model=''camb'' first.']);
        end
        k_min = min(cosmo.k_camb);
        k_max = max(cosmo.k_camb);

        lnk_min = log(k_min * 1.001);   % stay just inside table
        lnk_max = log(k_max * 0.999);
    otherwise
        lnk_min = log(1e-6);
        lnk_max = log(1e4);
end

R   = R(:).';
NR  = numel(R);
s2  = zeros(1, NR);

for i = 1:NR
    Ri = R(i);
    integrand = @(lnk) local_integrand(lnk, Ri, Pk_handle, D2, filter_name);

    s2(i) = (1/(2*pi^2)) * integral(integrand, lnk_min, lnk_max, ...
        'RelTol', 1e-4, ...
        'AbsTol', 0, ...
        'ArrayValued', true);
end

if isscalar(R), s2 = s2(1); end
end

% -----------------------------------------------------------------------
function f = local_integrand(lnk, R, Pk_handle, D2, filter_name)
    k  = exp(lnk);
    Pk = Pk_handle(k) * D2;
    W  = variance_window(k .* R, filter_name);
    f  = Pk .* W.^2 .* k.^3;      % k^3 is the log-k Jacobian
end