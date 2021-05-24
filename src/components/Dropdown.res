%%raw(`import './Dropdown.scss';`)

type t = int

module Context = {
  let selected: option<t> = None
  let setSelected: t => unit = _ => {Js.log("")}
  let context = React.createContext((selected, setSelected))

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}

@react.component
let make = (~selectedValue, ~selectValue, ~children) => {
  <Context.Provider value=(selectedValue, selectValue)>
    {selectedValue
    ->Belt.Option.map(Belt.Int.toString)
    ->Belt.Option.getWithDefault("select value")
    ->React.string}
    children
  </Context.Provider>
}

module Option = {
  @react.component
  let make = (~value: t, ~children) => {
    let (_, selectValue) = React.useContext(Context.context)

    <div onClick={_ => selectValue(value)} className="app-dropdown-option"> children </div>
  }
}
