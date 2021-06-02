%%raw(`import './Dropdown.scss';`)

module type Dropdown = {
  type value
}

module MakeDropdown = (Item: Dropdown) => {
  type value = Item.value

  type context = {
    selectedValue: option<value>,
    setSelectedValue: value => unit,
    setOptionsVisibility: bool => unit,
  }

  module Context = {
    let context = React.createContext({
      selectedValue: None,
      setSelectedValue: _ => (),
      setOptionsVisibility: _ => (),
    })

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
    let (areOptionsVisible, setAreOptionsVisible) = React.useState(_ => false)
    let toggleOptionsVisibility = _ => {
      setAreOptionsVisible(prev => !prev)
    }
    let setOptionsVisibility = isVisible => setAreOptionsVisible(_ => isVisible)
    <div className={`dropdown ${areOptionsVisible ? "dropdown--expanded" : ""}`}>
      <Context.Provider
        value={
          selectedValue: selectedValue,
          setSelectedValue: selectValue,
          setOptionsVisibility: setOptionsVisibility,
        }>
        <div className="dropdown__trigger" onClick={toggleOptionsVisibility}>
          <div className="dropdown__value">
            {switch selectedValue {
            | None => placeholder
            | Some(value) => selectedValueTemplate(value)
            }}
          </div>
          <div className="dropdown__arrow"> <Icon name=Icon.ArrowLeft /> </div>
        </div>
        {switch areOptionsVisible {
        | true => <>
            <div className="dropdown__overlay" onClick={toggleOptionsVisibility} />
            <div className="dropdown__options"> children </div>
          </>
        | false => React.null
        }}
      </Context.Provider>
    </div>
  }

  module Option = {
    @react.component
    let make = (~value, ~children) => {
      let {setSelectedValue, setOptionsVisibility} = React.useContext(Context.context)

      let onClick = _ => {
        setSelectedValue(value)
        setOptionsVisibility(false)
      }

      <div onClick className="dropdown__option"> children </div>
    }
  }
}
