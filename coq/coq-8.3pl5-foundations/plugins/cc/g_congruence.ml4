(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2011     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(*i camlp4deps: "parsing/grammar.cma" i*)

(* $Id: g_congruence.ml4 14641 2011-11-06 11:59:10Z herbelin $ *)

open Cctac
open Tactics
open Tacticals

(* Tactic registration *)

TACTIC EXTEND cc
 [ "congruence" ] -> [ congruence_tac 1000 [] ]
 |[ "congruence" integer(n) ] -> [ congruence_tac n [] ]
 |[ "congruence" "with" ne_constr_list(l) ] -> [ congruence_tac 1000 l ]
 |[ "congruence" integer(n) "with" ne_constr_list(l) ] ->
   [ congruence_tac n l ]
END

TACTIC EXTEND f_equal
 [ "f_equal" ] -> [ f_equal ]
END
