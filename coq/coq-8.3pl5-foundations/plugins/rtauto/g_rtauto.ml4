(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2011     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(* $Id: g_rtauto.ml4 14641 2011-11-06 11:59:10Z herbelin $*)

(*i camlp4deps: "parsing/grammar.cma"  i*)

TACTIC EXTEND rtauto
  [ "rtauto" ] -> [ Refl_tauto.rtauto_tac ]
END

