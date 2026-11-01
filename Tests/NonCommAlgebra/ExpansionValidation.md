# Native expansion optimization validation

The changes preserve the public `DotExpand` and `DotSimplify` interfaces.
`DotExpand` retains its ordered rewrite rules and skips matching only for
terminal chains. `DotSimplify` retains its outer processing pipeline, uses
ordered coefficient construction for ordinary Dirac words, and a staged
peeling implementation for other inputs.

## Reproduce the repository regressions

Use a fresh Wolfram kernel with this checkout's `FeynCalc` directory on
`$Path`, then run the complete `NonCommAlgebra` group using the repository's
test runner. Do not supply a subtest filter; verify the test count rather
than relying only on the shell exit status.

The new `DotExpandRegression.test` and `DotSimplifyExpansion.test` files
contain 32 named test rows. Several rows exercise generated matrices of
inputs. The tests include factoring, numerical multiplication order,
dynamic evaluation, empty products, declared noncommutative composite
expressions, and finite iteration limits.

`DotExpandBenchmarks.wl` provides optional generic microbenchmarks with an
embedded pre-change reference. Timings are not unit-test assertions.

## Verification on November 1, 2026

Runtime: Wolfram Language 15.0.1, Linux x86-64, FeynCalc 10.2.1. Both modified
modules were installed into a clean source extraction before package load.

- 231 existing NonCommAlgebra test rows and all 32 new rows passed.
- 209 downstream DiracSimplify, PauliSimplify and SUNSimplify test rows passed.
- DotExpand passed 5,838 generated/adversarial reference comparisons.
- DotSimplify passed 5,507 generated structural/numerical comparisons,
  280 dynamic-generation cases, 60 finite-iteration cases, 33 custom/mixed
  cases, and 94 additional strict regressions. Numerical suites also checked
  message lists and precision/accuracy metadata where applicable.
- Independent source review found and prompted fixes for composite
  noncommutativity declarations and incomplete expansion-cache handling.
- `git diff --check` passed.

These are executed Wolfram evaluator checks, not a claim that GitHub Actions
or the entire FeynCalc test suite ran. The original shell/MUnit launcher,
parallel kernels, and older supported Mathematica versions were not tested
in this environment. Runtime compatibility with Mathematica 10 remains
unverified; the implementation avoids newer-only APIs.

Illustrative generic timings: an eight-factor weighted sum took median
0.266184 s with original DotExpand and 0.057246 s with the optimized version
(three measurements). A 4,096-term DotSimplify benchmark took 1.253488 s
originally and 0.180197 s after optimization (single measurements).
Results were compared before interpreting timings; speedups depend on input
and runtime and are not guarantees for arbitrary amplitudes.
