%%raw(`import './Dropdown.scss';`)

module type Dropdown = {
  type value
}

module MakeDropdown = (Item: Dropdown) => {
  type value = Item.value

  module Context = {
    let selected: option<value> = None
    let setSelected: value => unit = _ => {Js.log("")}
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
  let make = (~selectedValue, ~selectValue, ~selectedValueTemplate, ~placeholder, ~children) => {
    <Context.Provider value=(selectedValue, selectValue)>
      {switch selectedValue {
      | None => placeholder
      | Some(value) => selectedValueTemplate(value)
      }}
      children
    </Context.Provider>
  }

  module Option = {
    @react.component
    let make = (~value: value, ~children) => {
      let (_, selectValue) = React.useContext(Context.context)

      <div onClick={_ => selectValue(value)} className="app-dropdown-option"> children </div>
    }
  }
}
