function zf = Ludlow16_formation_z(M0, f, cosmo)
% Find z where Mcoll(z)/M0 = f using bisection

z_lo = 0.0;
z_hi = 30.0;

% Evaluate bracket directly — no anonymous function, no closure
r_lo = Ludlow16_CMH(z_lo, M0, f, cosmo) / M0 - f;
r_hi = Ludlow16_CMH(z_hi, M0, f, cosmo) / M0 - f;

if sign(r_lo) == sign(r_hi)
    error('Ludlow16_formation_z: no sign change in [%.1f, %.1f]', z_lo, z_hi);
end

% Bisection loop — no anonymous function needed
tol = 1e-4;
for iter = 1:200
    z_mid = 0.5 * (z_lo + z_hi);
    r_mid = Ludlow16_CMH(z_mid, M0, f, cosmo) / M0 - f;

    if abs(r_mid) < tol || (z_hi - z_lo) < tol
        break;
    end

    if sign(r_mid) == sign(r_lo)
        z_lo = z_mid;
        r_lo = r_mid;
    else
        z_hi = z_mid;
    end
end

zf = 0.5 * (z_lo + z_hi);
end