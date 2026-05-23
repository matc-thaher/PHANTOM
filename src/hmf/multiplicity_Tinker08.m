function f = multiplicity_Tinker08(sigma, Delta)
% Tinker et al. (2008) mass function fitting parameters.
% Table 2 of Tinker+2008 (ApJ 688, 709) for Delta = 200 (mean).
% Interpolation across Delta is supported here for Delta=200 only.
%
% f(sigma) = A * [ (sigma/b)^(-a) + 1 ] * exp(-c/sigma^2)

    % Parameters for Delta=200m (Table 2, Tinker+2008)
    Delta_ref = [200   300   400   600   800  1200  1600  2400  3200];
    A_ref     = [0.186 0.200 0.212 0.218 0.248 0.255 0.260 0.260 0.260];
    a_ref     = [1.47  1.52  1.56  1.61  1.87  2.13  2.30  2.53  2.66];
    b_ref     = [2.57  2.25  2.05  1.87  1.59  1.51  1.46  1.44  1.41];
    c_ref     = [1.19  1.27  1.34  1.45  1.58  1.80  1.97  2.24  2.44];

    A_p = interp1(log(Delta_ref), A_ref, log(Delta), 'linear', 'extrap');
    a_p = interp1(log(Delta_ref), a_ref, log(Delta), 'linear', 'extrap');
    b_p = interp1(log(Delta_ref), b_ref, log(Delta), 'linear', 'extrap');
    c_p = interp1(log(Delta_ref), c_ref, log(Delta), 'linear', 'extrap');

    f = A_p .* ((sigma/b_p).^(-a_p) + 1) .* exp(-c_p ./ sigma.^2);
end