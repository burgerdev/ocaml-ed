
module type Field = sig
  type t
  val zero: t

  val ( + ): t -> t -> t
  val ( - ): t -> t -> t
  val double: t -> t
  val negate: t -> t

  val one: t

  val ( * ): t -> t -> t
  val ( / ): t -> t -> t
  val square: t -> t
  val invert: t -> t
end

module type Integral = sig
  type t
  val zero: t
  val one: t

  val ( + ): t -> t -> t

  val ( mod ): t -> t -> t
  val ( asr ): t -> int -> t
  val logxor: t -> t -> t
  val gt: t -> t -> bool
end

module type Edwards = sig
  type integral
  type element

  val bits: int
  val a24: element

  val constant_time_conditional_swap: integral -> element -> element -> element * element
end

module type S = sig
  type integral
  type element

  val scale: integral -> element -> element
end

module Make: functor (F: Field)(I: Integral)(E: Edwards with type integral = I.t and type element = F.t) ->
  S with type integral = I.t and type element = F.t
