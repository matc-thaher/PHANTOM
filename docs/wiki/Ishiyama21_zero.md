# `Ishiyama21_zero`

**Source:** [`src/concentration/Ishiyama21_zero.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/Ishiyama21_zero.m)  
**← Back to [Concentration](Concentration)**

---

Direct `fzero` implementation of the Ishiyama et al. (2021) concentration–mass relation. Conceptually it implements the same physical model as [`Ishiyama21`](Ishiyama21), but instead of using the generic Diemer19 engine and a precomputed left-hand-side table, it inverts the defining equation with `fzero` for each halo. [file:5]

This variant is useful if you prefer a fully self-contained implementation of the Ishiyama21 model or want to experiment with the root-finding details.

---

## Syntax

```matlab
c = Ishiyama21_zero(M, z, cosmo, mode)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Redshift |
| `cosmo` | struct | — | Cosmology struct (see required fields below) |
| `mode` | string | — | Halo definition + sample (see table below) |

### Required `cosmo` fields

Same as for [`Ishiyama21`](Ishiyama21):

| Field | Description |
|---|---|
| `cosmo.sigmaM(M, z)` | RMS linear density fluctuation at mass \(M\) |
| `cosmo.neff(M, z, kappa)` | Effective power-spectrum slope at \(kappa \times R_{\mathrm{L}}\) |
| `cosmo.alphaEff(z)` | Effective growth exponent \(d \ln D / d \ln(1+z)\) |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Mode options

`mode` selects the mass definition and halo sample, following Table 2 of Ishiyama et al. (2021): [file:5]

| `mode` | Mass definition | Sample |
|---|---|---|
| `'200c_all'` | \(M_{200\mathrm{c}}\) | All halos (typical default) |
| `'200c_relaxed'` | \(M_{200\mathrm{c}}\) | Dynamically relaxed halos |
| `'vir_all'` | \(M_{\mathrm{vir}}\) | All halos |
| `'vir_relaxed'` | \(M_{\mathrm{vir}}\) | Relaxed halos |
| `'500_all'` | \(M_{500\mathrm{c}}\) | All halos |
| `'500_relaxed'` | \(M_{500\mathrm{c}}\) | Relaxed halos |

---

## Model outline

`Ishiyama21_zero` follows the same five conceptual steps as the published model: [file:5]

1. **Peak-height and spectral quantities**  
   Compute peak height \(\nu\), effective slope \(n_{\mathrm{eff}}\), and growth exponent \(\alpha_{\mathrm{eff}}\) from `cosmo.sigmaM`, `cosmo.neff`, and `cosmo.alphaEff`.

2. **Auxiliary parameters**  
   Using mode-dependent parameters \((\kappa, a_0, a_1, b_0, b_1, c_\alpha)\) from `Ishiyama21_Table`, build
   \[
     A_{\mathrm{eff}},\; B_{\mathrm{eff}},\; C_{\mathrm{eff}}
   \]
   as in equations (5)–(7) of Ishiyama et al. (2021).

3. **Analytic seed and target**  
   Form an analytic seed \(x_c\) and a target
   \[
     G_{\mathrm{target}} = G(x_c)
   \]
   where
   \[
     G(c) = \frac{c}{[f(c)]^{(5+n_{\mathrm{eff}})/6}},\quad
     f(c) = \ln(1+c) - \frac{c}{1+c}.
   \]

4. **Direct root-finding with `fzero`**  
   For each halo, solve \(G(c_{\mathrm{unnorm}}) = G_{\mathrm{target}}\) using MATLAB’s `fzero`, with an adaptive bracketing strategy to ensure robustness at extreme masses and redshifts.

5. **Final concentration**  
   Apply the growth correction,
   \[
     c = C_{\mathrm{eff}} \, c_{\mathrm{unnorm}}.
   \]

The main difference relative to [`Ishiyama21`](Ishiyama21) is that the inversion \(G(c)=G_{\mathrm{target}}\) is performed directly via `fzero` rather than through the `build_lhs_table` / `Diemer19_general` machinery.

---

## Example

```matlab
M = logspace(10, 15, 100);   % Msun/h
z = 0;

% All halos, M_200c (typical default)
c_all  = Ishiyama21_zero(M, z, cosmo, '200c_all');

% Relaxed halos, M_200c
c_relx = Ishiyama21_zero(M, z, cosmo, '200c_relaxed');

loglog(M, c_all, M, c_relx, 'LineWidth', 1.5);
legend('200c all','200c relaxed');
xlabel('M [M_{sun}/h]'); ylabel('c');
title('Ishiyama21\_zero Concentration (direct fzero)');
grid on;
```

---

## Notes

- `Ishiyama21_zero` is numerically more self-contained because it does not rely on a precomputed \(G(c)\) table, at the cost of a per-halo `fzero` call. [file:5]
- For large halo samples, `Ishiyama21` (table-based) may be faster, while `Ishiyama21_zero` can be useful for validation, debugging, or experimenting with the inversion procedure.

---

## References

- Ishiyama, T. et al. (2021), *The Uchuu Simulations*, MNRAS, 506, 4210. [file:5]  
- Diemer, B., & Joyce, M. (2019), ApJ, 871, 168. [file:2]