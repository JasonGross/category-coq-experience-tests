(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2011     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(*i $Id: modintern.mli 14641 2011-11-06 11:59:10Z herbelin $ i*)

(*i*)
open Declarations
open Environ
open Entries
open Util
open Libnames
open Names
open Topconstr
(*i*)

(* Module expressions and module types are interpreted relatively to
   eventual functor or funsig arguments. *)

val interp_modtype : env -> module_ast -> module_struct_entry

val interp_modexpr : env -> module_ast -> module_struct_entry

(* The following function tries to interprete an ast as a module,
   and in case of failure, interpretes this ast as a module type.
   The boolean is true for a module, false for a module type *)

val interp_modexpr_or_modtype : env -> module_ast ->
 module_struct_entry * bool

val lookup_module : qualid located -> module_path
