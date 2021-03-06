(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2011     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(*i $Id: RelationalChoice.v 14641 2011-11-06 11:59:10Z herbelin $ i*)

(** This file axiomatizes the relational form of the axiom of choice *)

Axiom relational_choice :
  forall (A B : Type) (R : A->B->Prop),
   (forall x : A, exists y : B, R x y) ->
     exists R' : A->B->Prop,
       subrelation R' R /\ forall x : A, exists! y : B, R' x y.
