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
    let (areOptionsDisplayed, setAreOptionsDisplayed) = React.useState(_ => false)
    let toggleOptionsDisplay = _ => {
      setAreOptionsDisplayed(prev => !prev)
    }
    <div className="app-dropdown">
      <Context.Provider value=(selectedValue, selectValue)>
        <div onClick={toggleOptionsDisplay} className="app-dropdown-selected-option">
          {switch selectedValue {
          | None => placeholder
          | Some(value) => selectedValueTemplate(value)
          }}
        </div>
        {switch areOptionsDisplayed {
        | true => <>
            <div className="app-dropdown-options"> children </div>
            <div className="app-dropdown-overlay" onClick={toggleOptionsDisplay} />
          </>
        | false => React.null
        }}
      </Context.Provider>
    </div>
  }

  module Option = {
    @react.component
    let make = (~value: value, ~children) => {
      let (_, selectValue) = React.useContext(Context.context)

      <div onClick={_ => selectValue(value)} className="app-dropdown-option"> children </div>
    }
  }
}
