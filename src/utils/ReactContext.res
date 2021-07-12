module type Config = {
  type t
  let defaultValue: t
}

module Make = (Item: Config) => {
  let context = React.createContext(Item.defaultValue)

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}
