open Caliburn
open! Core

module S = struct
  open Core

  type key = int [@@deriving bin_io, hash, sexp, compare]
  type value = string [@@deriving bin_io, hash, sexp, compare]
end

module Int_DB = Db.Make (S)
