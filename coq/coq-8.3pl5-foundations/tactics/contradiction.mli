(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2011     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(*i $Id: contradiction.mli 14641 2011-11-06 11:59:10Z herbelin $ i*)

(*i*)
open Names
open Term
open Proof_type
open Rawterm
open Genarg
(*i*)

val absurd                      : constr -> tactic
val contradiction               : constr with_bindings option -> tactic
