# `c_CDM`

**Source:** [`src/concentration/c_CDM.m`](https://github.com/matc-thaher/PHANTOM/blob/main/src/concentration/c_CDM.m)  
**← Back to [Concentration](Concentration)**

---

Unified dispatcher for all CDM concentration-mass relations in PHANTOM. Instead of calling individual model functions directly, `c_CDM` provides a single consistent interface that routes to any of the 11 supported models by name. The default model is `ishiyama21`.

---

## Syntax

```matlab
c = c_CDM(M, z)
c = c_CDM(M, z, model)
c = c_CDM(M, z, model, cosmo)
c = c_CDM(M, z, model, cosmo, mode)
```

---

## Inputs

| Parameter | Type | Unit | Description |
|---|---|---|---|
| `M` | scalar or vector | `Msun/h` | Halo mass |
| `z` | scalar | — | Redshift |
| `model` | string | — | Model name (see table below). Default: `'ishiyama21'` |
| `cosmo` | struct | — | Cosmology struct (required by physics-based models) |
| `mode` | string | — | Model-specific option string (optional; uses model default if omitted) |

## Output

| Parameter | Description |
|---|---|
| `c` | Concentration, same shape as `M` |

---

## Supported Models

| Model String | Aliases | Cosmo? | Default Mode |
|---|---|---|---|
| `'bullock01'` | `'b01'` | Yes | — |
| `'duffy08'` | `'d08'` | No | `'200c_NFW_full_z0_2'` |
| `'klypin11'` | `'k11'` | No | `'distinct'` |
| `'prada12'` | `'p12'` | Yes | — |
| `'dutton14'` | `'dm14'` | No | `'200c'` |
| `'diemer15'` | `'dk15'` | Yes | `'median'` |
| `'ludlow16'` | `'l16'` | Yes | — |
| `'klypin16'` | `'k16'` | Yes | `'planck13_200c_cM'` |
| `'child18'` | `'c18'` | Yes | `'individual_all'` |
| `'diemer19'` | `'dj19'` | Yes | `'200c_all'` |
| `'ishiyama21'` | `'i21'` | Yes | `'200c_all'` |

---

## Examples

```matlab
M = logspace(11, 15, 100);   % Msun/h
z = 0;

% Default model — Ishiyama21, 200c_all
c = c_CDM(M, z, 'ishiyama21', cosmo);

% Duffy08 — no cosmo needed, uses default mode
c = c_CDM(M, z, 'duffy08');

% Duffy08 with explicit mode
c = c_CDM(M, z, 'duffy08', '200c_NFW_relaxed_z0_2');

% Dutton14 virial mass definition
c = c_CDM(M, z, 'dutton14', 'vir');

% Diemer15 mean statistic
c = c_CDM(M, z, 'diemer15', cosmo, 'mean');

% Ishiyama21 relaxed halos
c = c_CDM(M, z, 'ishiyama21', cosmo, '200c_relaxed');

% Klypin16 with sigma-based formula
c = c_CDM(M, z, 'klypin16', cosmo, 'planck13_200c_cnu');

% Compare all models on one plot
models = {'duffy08','dutton14','diemer15','ishiyama21','ludlow16'};
figure; hold on;
for i = 1:numel(models)
    c = c_CDM(M, z, models{i}, cosmo);
    loglog(M, c, 'DisplayName', models{i}, 'LineWidth', 1.5);
end
legend; grid on;
xlabel('M [M_{sun}/h]'); ylabel('c');
title('Concentration-Mass Relations at z=0');
```

---

## Notes

- Models that do not require `cosmo` (`duffy08`, `klypin11`, `dutton14`) can be called with just `M`, `z`, and `model`. Passing a `cosmo` struct to these is harmless — it is simply ignored.
- The `mode` string format varies by model. When omitted, the function uses the default listed in the table above. See each individual model page for the full list of valid mode strings.
- `bhattacharya13` and `ludlow16_fit` are available as standalone functions but are **not** currently routed through `c_CDM`. Call them directly if needed.

---

## References

See individual model pages for full references. The dispatcher covers:
Bullock+01, Duffy+08, Klypin+11, Prada+12, Dutton+14, Diemer+15, Ludlow+16, Klypin+16, Child+18, Diemer+19, Ishiyama+21.
