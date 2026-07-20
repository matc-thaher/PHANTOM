# Installation

PHANTOM is available for **MATLAB** and **GNU Octave**. Native Python bindings are planned for a future release, but PHANTOM can already be used from Python-based environments such as Jupyter via the Octave kernel — see the [Jupyter / Python](#jupyter--python-via-octave-kernel) section below.

---

## MATLAB

**Requirements:** MATLAB R2020a or later. No additional toolboxes are required.

### Option 1: Add-On Explorer *(easiest)*

The simplest way to install PHANTOM is directly through MATLAB's built-in Add-On Explorer:

1. In MATLAB, go to the **Home** tab and click **Add-Ons → Get Add-Ons**
2. Search for **PHANTOM**
3. Click **Add** — MATLAB handles the rest automatically

No path configuration is needed. PHANTOM will be available in every future MATLAB session.

### Option 2: Install via `.mltbx` file

1. Download [`PHANTOM.mltbx`](https://github.com/matc-thaher/PHANTOM/releases/download/V1.0/PHANTOM.mltbx) from the [Releases page](https://github.com/matc-thaher/PHANTOM/releases/latest)
2. Double-click the file — MATLAB installs it automatically
3. Verify the installation:

```matlab
addons = matlab.addons.toolbox.installedToolboxes();
disp({addons.Name})   % PHANTOM should appear in the list
```

### Option 3: Clone and add path *(recommended for development)*

```bash
git clone https://github.com/matc-thaher/PHANTOM.git
```

Then in MATLAB:

```matlab
addpath(genpath('PHANTOM'))
```

> **Tip:** To make this permanent across sessions, add the line above to your
> [`startup.m`](https://www.mathworks.com/help/matlab/ref/startup.html) file.
> Run `edit startup.m` in MATLAB to open or create it.

### Verify Your Installation

Whichever option you used, confirm everything is working:

```matlab
cosmo = cosmology();
c     = Diemer15(1e12, 0, cosmo);
fprintf('Concentration: %.4f\n', c)
```

If this prints a number without errors, PHANTOM is installed correctly.

---

## GNU Octave

**Requirements:** Octave >= 4.5.0

PHANTOM for Octave is maintained as a separate package: [`PHANTOM_oct`](https://github.com/matc-thaher/PHANTOM_oct).

### Install from GitHub

```octave
pkg install "https://github.com/matc-thaher/PHANTOM_oct/archive/refs/heads/main.zip"
pkg load phantom-octave
```

> **Note (Windows):** if `pkg install` fails with `couldn't copy files to the
> installation directory`, this is almost always a local write-permission
> issue with the default package prefix (`AppData\Roaming\octave\...`), not
> a problem with the archive itself. You can point the installation at a
> different, unrestricted folder instead:
>
> ```octave
> mkdir C:\octave_packages
> pkg prefix C:\octave_packages C:\octave_packages
> pkg install "https://github.com/matc-thaher/PHANTOM_oct/archive/refs/heads/main.zip"
> ```
>
> Add the `pkg prefix` line to your `~/.octaverc` startup file to make it
> persist across sessions.

### Fitting Functions

The fitting functions depend on the `optim` package. Install it from Octave Forge:

```octave
pkg install -forge optim
pkg load optim
```

### `colossus_query`

> **Note:** `colossus_query` requires Octave >= 7.0, as it depends on `jsonencode`, which was introduced in that version. Earlier Octave releases will not support this function.

### Verify Your Installation

```octave
pkg load phantom-octave
cosmo = cosmology();
c     = Diemer15(1e12, 0, cosmo);
fprintf('Concentration: %.4f\n', c)
```

---

## Jupyter / Python (via Octave kernel)

PHANTOM does not yet have native Python bindings, but it can be run directly
inside a **Jupyter notebook** using the Octave kernel, so PHANTOM fits
naturally into Python-based, notebook-driven research workflows without any
code changes to the toolbox itself.

**Requirements:**

- A working **GNU Octave** installation (see the [GNU Octave](#gnu-octave)
  section above) — the Jupyter kernel launches this installation under the
  hood, it does not bundle its own Octave engine.
- The `octave_kernel` package, or the native `xeus-octave` kernel.

### 1. Install the Octave kernel for Jupyter

Using `octave_kernel` (pip):

```bash
pip install octave_kernel
python -m octave_kernel install --user
```

Or, for a native C++ Jupyter-protocol kernel via conda-forge:

```bash
mamba install -c conda-forge xeus-octave
```

Restart Jupyter after installing so the new kernel is picked up.

### 2. Select the Octave kernel

In Jupyter: **Kernel → Change Kernel → Octave**

All cells from this point on run natively in Octave/PHANTOM syntax, identical
to a standalone Octave session.

### 3. Load PHANTOM and run a quick check

```octave
pkg load phantom-octave

cosmo = cosmology('Planck18');
c     = Diemer15(1e12, 0, cosmo);
printf('Concentration: %.4f\n', c)
```

If this prints a number without errors, PHANTOM is correctly available
inside your notebook session.

### 4. Full worked example

A complete, ready-to-run example notebook demonstrating cosmology
initialization, the linear power spectrum, and an NFW density-profile plot
entirely from Jupyter is provided in the repository:

📓 [`examples/phantom_octave_jupyter_demo.ipynb`](https://github.com/matc-thaher/PHANTOM_oct/blob/main/examples/phantom_octave_jupyter_demo.ipynb)

Open it directly in Jupyter (or JupyterLab) with the Octave kernel selected
to see PHANTOM running end-to-end in a notebook environment, including a
saved figure output.

> **Tip:** If `pkg install` fails inside a Jupyter-launched Octave kernel
> specifically (but works from the Octave GUI), this is usually a
> local file-permission difference between how the two processes are
> started on Windows. See the Windows note under
> [GNU Octave → Install from GitHub](#install-from-github) above for the
> `pkg prefix` workaround.

---

*Back to [Home](Home)*
