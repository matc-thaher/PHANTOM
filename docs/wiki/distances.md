# Distances

PHANTOM computes comoving, transverse, angular-diameter, and luminosity distances through direct numerical integration of the FLRW metric. All distances are returned in comoving **Mpc/h** unless otherwise stated.

---

## comoving_distance

**File:** `comoving_distance.m`

Computes the line-of-sight comoving distance:

\[
d_C(z) = \frac{c}{H_0} \int_0^z \frac{\mathrm{d}z'}{E(z')}
\]

Returned in Mpc/h (multiplied by `cosmo.h` after integration in Mpc).

```matlab
d = comoving_distance(z, cosmo)
```

- `z` : scalar or column vector of redshifts
- Returns `d` in Mpc/h

Integration is performed with MATLAB's `integral` in a loop over z. The speed of light used is \(c = 299\,792.458\) km/s.

---

## transverse_comoving_distance

**File:** `transverse_comoving_distance.m`

Computes the transverse comoving distance \(d_M(z)\), which equals the comoving distance for a flat universe (\(\Omega_k = 0\)):

\[
d_M(z) = \begin{cases}
d_C(z) & \Omega_k = 0 \\
\dfrac{c}{H_0\sqrt{\Omega_k}} \sinh\!\left[\sqrt{\Omega_k}\,\dfrac{H_0}{c}\,d_C(z)\right] & \Omega_k > 0 \\
\dfrac{c}{H_0\sqrt{|\Omega_k|}} \sin\!\left[\sqrt{|\Omega_k|}\,\dfrac{H_0}{c}\,d_C(z)\right] & \Omega_k < 0
\end{cases}
\]

```matlab
d = transverse_comoving_distance(z, cosmo)
```

---

## Derived Distances

The following are computed directly from `transverse_comoving_distance` and are attached as function handles on the `cosmo` struct by `derive_cosmo_params`:

| Handle | Expression | Description |
|---|---|---|
| `cosmo.comovingDistance(z)` | \(d_C(z)\) | Line-of-sight comoving distance [Mpc/h] |
| `cosmo.transverseComovingDistance(z)` | \(d_M(z)\) | Transverse comoving distance [Mpc/h] |
| `cosmo.angularDiameterDistance(z)` | \(d_M(z)/(1+z)\) | Angular-diameter distance [Mpc/h] |
| `cosmo.luminosityDistance(z)` | \(d_M(z)\,(1+z)\) | Luminosity distance [Mpc/h] |

---

## Example

```matlab
cosmo = cosmology('Planck18');

z = [0.1, 0.5, 1.0, 2.0, 5.0];
dc = cosmo.comovingDistance(z);
da = cosmo.angularDiameterDistance(z);
dl = cosmo.luminosityDistance(z);

fprintf('z=1: dc=%.1f, da=%.1f, dl=%.1f Mpc/h\n', dc(3), da(3), dl(3));
```

---

## Notes

1. All distances are in **comoving Mpc/h**, consistent with the conventions used for large-scale structure and halo statistics throughout PHANTOM.
2. For flat cosmologies (`cosmo.flat = true`), `transverseComovingDistance` returns the same value as `comovingDistance`.
3. The curvature term `Omega_k` is computed automatically in `derive_cosmo_params` when `cosmo.flat = false`.

---

## Related Pages

- [cosmology.md](cosmology.md)
- [time_calculations.md](time_calculations.md)
