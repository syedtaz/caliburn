type ('k, 'v) t =
  | Head of
      { sibling : ('k, 'v) t
      ; child : ('k, 'v) t
      }
  | Node of
      { key : 'k
      ; value : 'v
      ; sibling : ('k, 'v) t
      ; child : ('k, 'v) t
      }
  | Nil

