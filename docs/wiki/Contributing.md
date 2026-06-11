# Contributing to PHANTOM

Thank you for your interest in contributing. PHANTOM is a research software package for dark matter halo analysis, and accuracy matters. All contributions go through a review process before anything is merged into the codebase.

---

## How Contributions Work

PHANTOM uses the standard **fork → branch → pull request** workflow. No one can push directly to the main repository. Every change — whether a bug fix, a new function, or a documentation update — must be submitted as a pull request and approved by a maintainer before it is merged.

This keeps the codebase verified and scientifically correct.

---

## What You Can Contribute

| Type | Examples |
|---|---|
| **Bug fixes** | Incorrect formula, wrong unit, broken function |
| **New concentration models** | A published CMR not yet implemented |
| **New halo profiles** | A density profile from the literature |
| **Documentation** | Clarifications, typo fixes, usage examples |
| **Tests** | Unit tests for existing or new functions |
| **Performance** | Speed improvements that do not change outputs |

If you are unsure whether your contribution fits, open an [Issue](https://github.com/matc-thaher/PHANTOM/issues) first and describe what you have in mind. This saves everyone time.

---

## Step-by-Step Workflow

### 1. Fork the repository

Click **Fork** at the top right of the [PHANTOM repository](https://github.com/matc-thaher/PHANTOM). This creates your own copy under your GitHub account.

### 2. Clone your fork locally

```bash
git clone https://github.com/<your-username>/PHANTOM.git
cd PHANTOM
```

### 3. Add the upstream remote

This keeps your fork in sync with the main repository:

```bash
git remote add upstream https://github.com/matc-thaher/PHANTOM.git
```

### 4. Create a feature branch

Never work on `main` directly. Create a branch with a descriptive name:

```bash
git checkout -b feature/add-diemer23
# or
git checkout -b fix/nfw-enclosed-mass
```

### 5. Make your changes

Follow the coding conventions below. If you are adding a new function, include a unit test in `tests/`.

### 6. Sync with upstream before submitting

```bash
git fetch upstream
git rebase upstream/main
```

### 7. Push to your fork

```bash
git push origin feature/add-diemer23
```

### 8. Open a pull request

Go to the original PHANTOM repository on GitHub. You will see a banner prompting you to open a pull request from your branch. Click **Compare & pull request**.

In the pull request description:
- Briefly explain what the change does and why
- Link to the relevant paper if you are implementing a published model (e.g., `Diemer & Kravtsov (2015), ApJ 799, 108`)
- Note any edge cases or known limitations

---

## Review Process

Once your pull request is open:

1. A maintainer will review the code, check the math, and run the tests
2. If changes are needed, they will leave comments on the pull request — you can push additional commits to address them
3. Once the maintainer is satisfied, they will **approve and merge** the pull request
4. If a contribution does not meet the standards after revision, it will be closed with an explanation

There is no automated merge. Every pull request requires explicit approval from a project maintainer.

---

## Coding Conventions

- **Function names** follow the existing pattern: `AuthorYY` for concentration models (e.g., `Diemer15`), descriptive names for profiles (e.g., `NFW_profile`)
- **Inputs and outputs** must match the units and conventions used elsewhere in the package (see existing functions for reference)
- **Every new function** needs at least one unit test in `tests/`
- **MATLAB syntax only** in the core `src/` directory — no toolbox dependencies
- **Comments** should explain the physics, not just the code. Cite the equation number and paper where the formula comes from

---

## Reporting Bugs

Open an [Issue](https://github.com/matc-thaher/PHANTOM/issues) and include:
- MATLAB or Octave version
- A minimal reproducible example
- The output you got vs. what you expected

---

## Code of Conduct

Be direct and constructive. Disagreements about implementation or physics are expected and welcome — that is how scientific software improves. Personal criticism is not.

---

*Questions? Open an [Issue](https://github.com/matc-thaher/PHANTOM/issues) or reach out via the repository.*
