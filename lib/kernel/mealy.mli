(** State machines inspired by Crem (Perone & Karachalias, 2023).

    The core of this module is the type of the state machine :
    [('i, 'o, 's) t]. This corresponds to a machine that can
    respond to ['i] messages with ['o] outputs while transitioning between
    states of type ['s].

    The module provides combinators for combining these state machines
    in various ways. *)

(** A mealy machine. *)
type ('input, 'output, 'state) t =
  { initial : 'state
  ; action : 'state -> 'input -> 'output * 'state
  }

(** A mealy machine with implicit state. *)
type ('i, 'o) s = { action : 'i -> 'o * ('i, 'o) s }

(** [unfold] hides the state in an explicit Mealy machine. *)
val unfold : ('i, 'o, 's) t -> ('i, 'o) s

(** Sequential composition. [ a >>> b] returns a new machine that runs the
    machine [a], takes its output and feeds it into machine [b] *)
val ( >>> ) : ('i, 'o, 's1) t -> ('o, 'c, 's2) t -> ('i, 'c, 's1 * 's2) t

(** Parallel composition. [ a *** b] returns a new machine that takes a message
    of the same type, runs [a] and [b] in parallel and returns the output from
    both. *)
val ( *** ) : ('c, 'o, 's1) t -> ('c, 'd, 's2) t -> ('c, 'o * 'd, 's1 * 's2) t

module type Machine0 = sig
  type input
  type output
  type state

  val machine : (input, output) s
end

module type Machine1 = sig
  type input
  type output
  type state
  type driver

  val machine : driver -> (input, output, state) t
end