(* ::Package:: *)

(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: DotExpand														*)

(*
	This software is covered by the GNU General Public License 3.
	Copyright (C) 1990-2026 Rolf Mertig
	Copyright (C) 1997-2026 Frederik Orellana
	Copyright (C) 2014-2026 Vladyslav Shtabovenko
*)

(* :Summary:  Expand DOT products   										*)

(* ------------------------------------------------------------------------ *)

DotExpand::usage =
"DotExpand[exp] expands dot products in exp.";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`DotExpand`Private`"]

(* A terminal chain cannot match any of the expansion rules, nor can any of
   its subexpressions. Recognizing it before the Flat DOT patterns avoids
   searching all possible argument groups in already expanded chains.

   Do not use this shortcut for chains containing nested DOTs: rewriting a
   child can evaluate its enclosing head, change its commutativity, or create
   another DOT. Such expressions must retain the ordered rewrite passes. *)
dotExpandTerminalQ[dot_] :=
	Head[dot] === Dot && With[{args = List @@ dot},
		FreeQ[Head /@ args, Plus | Times] && FreeQ[args, DOT] &&
		AllTrue[args, NonCommQ]
	];

DotExpand[expr_] :=
	expr //. {dot_DOT :> dot /; dotExpandTerminalQ[dot],
	DOT[a___, b_ + c_, d___] :> Distribute[DOT[a, b + c, d]],
	DOT[a___, b_*c_, d___] :> b*DOT[a, c, d] /; NonCommFreeQ[b],
	DOT[a___, b_, d___] :> b*DOT[a, d] /; NonCommFreeQ[b],
	DOT[a___, b_*c__, d___] :> DOT[a, b, c, d] /; NonCommQ[b]} /.
	DOT[] :> Sequence[];

FCPrint[1,"DotExpand.m loaded"];
End[]
