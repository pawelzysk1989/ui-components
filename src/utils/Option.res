let filter = (maybeValue, fn) => {
  Belt.Option.flatMap(maybeValue, value => fn(value) ? maybeValue : None)
}
