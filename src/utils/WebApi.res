module Element = {
  @send external querySelectorAll: (Dom.element, string) => Js.Array.array_like<Dom.element> = ""
  @send external querySelector: (Dom.element, string) => Js.nullable<Dom.element> = ""
  @send external focus: Dom.element => unit = "focus"
  @get external scrollHeight: Dom.element => int = "scrollHeight"
  @get external clientHeight: Dom.element => int = "clientHeight"
  @get external offsetHeight: Dom.element => int = "offsetHeight"

  let queryAll = (element, query) => {
    element->querySelectorAll(query)->Js.Array.from
  }
}

module Document = {
  type document
  @val @scope("document")
  external activeElement: Js.nullable<Dom.element> = ""
}
