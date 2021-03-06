(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2011     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(* $Id: ground.mli 14641 2011-11-06 11:59:10Z herbelin $ *)

val ground_tac:     Tacmach.tactic ->
  (Proof_type.goal Tacmach.sigma -> Sequent.t) -> Tacmach.tactic

