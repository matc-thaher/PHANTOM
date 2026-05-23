function f = multiplicity_Yung25(sigma, z)
% Yung, Somerville & Iyer (2025), MNRAS 543, 3802
% Eq. 2 + Table 1 — coefficients revised from Y24b to include z > 19 GUREFT data.
% Valid range: 6 <= z <= 30, 6 <= log(M_h/M_sun) <= 13
% Mass definition: Bryan & Norman (1998) virial, w.r.t. rho_crit
%
% NOTE: Colossus yung25 may carry Y24b coefficients — use Table 1 values below.

    % Table 1 coefficients [chi0, chi1, chi2]
    A_c = [0.21307778,  -0.01042236,   0.00013897];
    a_c = [0.94192066,   0.04453040,  -0.00202483];
    b_c = [3.27712602,  -0.01313422,   0.01027465];
    c_c = [1.15214631,   0.012866285, -0.00065572];

    % Polynomial evaluation in z
    A = A_c(1) + A_c(2)*z + A_c(3)*z^2;
    a = a_c(1) + a_c(2)*z + a_c(3)*z^2;
    b = b_c(1) + b_c(2)*z + b_c(3)*z^2;
    c = c_c(1) + c_c(2)*z + c_c(3)*z^2;

    % Eq. 2
    f = A .* ((sigma./b).^(-a) + 1) .* exp(-c ./ sigma.^2);
end