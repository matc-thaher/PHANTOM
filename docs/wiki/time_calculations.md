# Time Calculations

PHANTOM computes cosmic time and lookback time by direct numerical integration of the FLRW time-redshift relation. The primary function is `z_to_time_gyr.m`, exposed through the `cosmo` struct handles after `cosmology()` is called.

---

## z_to_time_gyr

**File:** `z_to_time_gyr.m`

Computes the lookback time, present age of the universe, and age at redshift z, all in Gyr.

```matlab
out = z_to_time_gyr(z, cosmo)
```

**Returns a struct with fields:**

| Field | Description |
|---|---|
| `out.lookback_Gyr` | Lookback time to redshift z [Gyr] |
| `out.t0_Gyr` | Present age of the universe [Gyr] |
| `out.age_Gyr` | Age of the universe at redshift z [Gyr] |

**Integral evaluated:**

\[
t_L(z) = \frac{1}{H_0} \int_0^z \frac{\mathrm{d}z'}{(1+z')\,E(z')}
\]

\[
t_0 = \frac{1}{H_0} \int_0^{z_\mathrm{max}} \frac{\mathrm{d}z'}{(1+z')\,E(z')}
\]

\[
t_\mathrm{age}(z) = t_0 - t_L(z)
\]

where \(E(z) = H(z)/H_0\) is the dimensionless Hubble rate from `cosmo.E`.

**Unit conversions:**
- \(H_0\) is converted to SI: \(H_0\,[\mathrm{s}^{-1}] = H_0\,[\mathrm{km/s/Mpc}] / (3.086\times10^{19}\,\mathrm{km/Mpc})\)
- Result divided by `sec_per_Gyr = 365.25 × 24 × 3600 × 10⁹`

The integration runs from 0 to z for the lookback time and from 0 to `cosmo.zmax` (default: 10⁴) for the total age. MATLAB's `integral` is used with default tolerances.

> **Note:** Integration is performed in a loop over elements of z. For large arrays, this can be slow. If performance is critical, pre-compute a lookup table and interpolate.

---

## Handles on the cosmo Struct

After `cosmology()`, three convenience handles are attached by `derive_cosmo_params`:

```matlab
cosmo.time(z)          % returns the full struct from z_to_time_gyr
cosmo.lookbackTime(z)  % returns out.lookback_Gyr directly
cosmo.age(z)           % returns out.age_Gyr directly
cosmo.age0             % scalar: age of universe today [Gyr], computed at construction
```

---

## Example

```matlab
cosmo = cosmology('Planck18');

% Age of the universe today
fprintf('Age today: %.3f Gyr\n', cosmo.age0);

% Age at various redshifts
z = [0, 0.5, 1, 2, 6, 10];
for i = 1:numel(z)
    fprintf('z = %.1f  age = %.3f Gyr  lookback = %.3f Gyr\n', ...
        z(i), cosmo.age(z(i)), cosmo.lookbackTime(z(i)));
end
```

---

## Dark Energy Models

The `E(z)` function used in the integral correctly incorporates any dark energy model configured on the cosmology struct. CPL, w0CDM, and standard ΛCDM all produce the correct time integrals through the unified `cosmo.E` handle constructed in `derive_cosmo_params`.

---

## Related Pages

- [cosmology.md](cosmology.md)
- [distances.md](distances.md)
- [growth_factor.md](growth_factor.md)
