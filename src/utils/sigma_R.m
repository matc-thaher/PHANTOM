function s = sigma_R( R, z, cosmo)
    % sigma_R  Top-hat smoothed variance σ(R,z)
    % R can be scalar or vector (in Mpc/h)
    % z is scalar
    % cosmo.Pk is P(k,z)

        % k grid (column vector)
        k = logspace(-4, 2, 2000).';   % 2000×1

        % Make R a row vector for broadcasting
        R = R(:).';                    % 1×NR

        % Compute k*R with broadcasting
        x = k .* R;                    % (NK × NR)

        % Window function W(kR)
        W = 3*(sin(x) - x.*cos(x)) ./ (x.^3 + (x==0));

        % P(k,z) (Nk × 1)
        Pk = cosmo.Pk(k, z);

        % Integrand: k^2 * P(k) * W^2
        integrand = (k.^2 .* Pk) .* (W.^2);  % (Nk × NR)

        % Integrate over k
        s2 = (1/(2*pi^2)) * trapz(k, integrand, 1);  % 1 × NR

        s = sqrt(s2);  % 1 × NR

        % Return column vector if input R was column
        if size(R,1) > 1
            s = s.';
        end
    end