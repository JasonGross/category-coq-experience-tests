(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2011     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(*i $Id: cpretty.mli 14641 2011-11-06 11:59:10Z herbelin $ i*)

open Index

val coq_file : string -> Cdglobals.coq_module -> unit
val detect_subtitle : string -> Cdglobals.coq_module -> string option
