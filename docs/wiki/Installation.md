# Installation

PHANTOM is available for **MATLAB** and **GNU Octave**. Python support is planned for a future release.

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

## Python

> 🚧 **Coming soon.** Python support is under development and will be documented here in a future release.

---

*Back to [Home](Home)*
