(* Generic DotExpand microbenchmarks, not timing-sensitive unit tests.
   Run with a Wolfram kernel after adding this checkout to $Path:
     Get["Tests/NonCommAlgebra/DotExpandBenchmarks.wl"]
   No private amplitude or external data is required. *)

$FeynCalcStartupMessages = False;
Needs["FeynCalc`"];

Module[{reference, measure, cases, results, x, y, mu, i},
	(* The implementation before the terminal-chain optimization. *)
	reference[expr_] := expr //. {
		DOT[a___, b_ + c_, d___] :> Distribute[DOT[a, b + c, d]],
		DOT[a___, b_*c_, d___] :> b*DOT[a, c, d] /; NonCommFreeQ[b],
		DOT[a___, b_, d___] :> b*DOT[a, d] /; NonCommFreeQ[b],
		DOT[a___, b_*c__, d___] :> DOT[a, b, c, d] /; NonCommQ[b]
	} /. DOT[] :> Sequence[];

	measure[function_, expr_] :=
		Median[Table[First[AbsoluteTiming[function[expr];]], {3}]];

	cases = Join[
		Table[{"terminal-" <> ToString[n],
			DOT @@ Table[GA[mu[i]], {i, n}]}, {n, {5, 15, 30}}],
		Table[{"weighted-sums-" <> ToString[n],
			DOT @@ Table[x[i] GA[mu[2 i]] + y[i] GA[mu[2 i + 1]], {i, n}]},
			{n, {4, 6, 8}}]
	];

	results = Map[Function[c,
		If[!SameQ[reference[c[[2]]], DotExpand[c[[2]]]],
			{c[[1]], "MISMATCH"},
			{c[[1]], measure[reference, c[[2]]], measure[DotExpand, c[[2]]]}
		]], cases];
	Print[{$Version, $FeynCalcVersion}];
	Print[{"case", "reference seconds (median of 3)",
		"DotExpand seconds (median of 3)"}];
	Print /@ results;
	results
]
