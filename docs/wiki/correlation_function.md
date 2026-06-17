# Correlation Function

The two-point matter correlation function \(\xi(R, z)\) is the Fourier transform of the matter power spectrum. PHANTOM provides two implementations: a direct numerical integration and an FFTLog-based fast transform.

---

## correlation_function

**File:** `correlation_function.m`

Dispatcher that routes to the integration or FFTLog method based on `cosmo.corr_method`.

```matlab
xi = correlation_function(R, z, cosmo)
xi = correlation_function(R, z, cosmo, 'method', 'fftlog')
```

`cosmo.corr_method` defaults to `'integral'` unless changed before calling `cosmology()`.

After `cosmology()`, the handle `cosmo.correlationFunction(R, z)` wraps this function.

---

## correlation_function_integral

**File:** `correlation_function_integral.m`

Computes \(\xi(R, z)\) by direct integration:

\[
\xi(R, z) = \frac{1}{2\pi^2} \int_0^\infty P(k, z)\, j_0(kR)\, k^2\,\mathrm{d}k
\]

where \(j_0(x) = \sin(x)/x\) is the zeroth-order spherical Bessel function. Numerical integration is performed with MATLAB's `integral`.

---

## correlation_function_fftlog

**File:** `correlation_function_fftlog.m`

Computes \(\xi(R, z)\) using the FFTLog algorithm (Hamilton 2000). FFTLog exploits the fact that the integral is a Hankel transform and evaluates it in \(\mathcal{O}(N \log N)\) via:

\[
\xi(R) = \int_0^\infty P(k)\, j_0(kR)\, k^2\, \mathrm{d}k
\]

The FFTLog machinery is implemented in three supporting files:

| File | Role |
|---|---|
| `fftlog_fht.m` | Core fast Hankel transform |
| `fftlog_krgood.m` | Selects optimal kr pivot to minimize aliasing |
| `fftlog_modes.m` | Computes the FFTLog mode coefficients |

Use FFTLog when evaluating \(\xi(R)\) on a dense grid of R values, as it is substantially faster than the direct integral for large arrays.

---

## Example

```matlab
cosmo = cosmology('Planck18');

R  = logspace(-1, 2, 200);   % Mpc/h
xi = cosmo.correlationFunction(R, 0);

% Switch to FFTLog
cosmo.corr_method = 'fftlog';
cosmo = cosmology('Planck18', cosmo);
xi_fast = cosmo.correlationFunction(R, 0);
```

---

## Related Pages

- [cosmology.md](cosmology.md)
- [variance.md](variance.md)
