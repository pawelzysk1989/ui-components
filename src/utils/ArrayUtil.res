let splitWith = (array: array<'t>, predicate: 't => bool) => {
  array->Belt.Array.reduce(([], []), (acc, item) =>
    switch (predicate(item), acc) {
    | (false, (left, [])) => (Belt.Array.concat(left, [item]), [])
    | (_, (left, right)) => (left, Belt.Array.concat(right, [item]))
    }
  )
}

let splitWithout = (array: array<'t>, predicate: 't => bool) => {
  switch splitWith(array, predicate) {
  | (left, []) => (left, [])
  | (left, right) => (left, right->Belt.Array.sliceToEnd(1))
  }
}
