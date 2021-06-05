%%raw(`import './Dropdown.scss';`)
@send external focus: Dom.element => unit = "focus"

module type Dropdown = {
  type value
}

module MakeDropdown = (Item: Dropdown) => {
  type value = Item.value

  type context = {
    selectedValue: option<value>,
    setSelectedValue: value => unit,
  }

  module Context = {
    let context = React.createContext({
      selectedValue: None,
      setSelectedValue: _ => (),
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
    let setSelectedValue = value => {
      setOptionsVisibility(false)
      selectValue(value)
    }
    let onKeyDown = event =>
      switch ReactEvent.Keyboard.keyCode(event) {
      | 32 => toggleOptionsVisibility()
      | 9 => setOptionsVisibility(false)
      | _ => ()
      }
    <div className={`dropdown ${areOptionsVisible ? "dropdown--expanded" : ""}`}>
      <Context.Provider
        value={
          selectedValue: selectedValue,
          setSelectedValue: setSelectedValue,
        }>
        <div
          className="dropdown__trigger"
          role="combobox"
          ariaExpanded=areOptionsVisible
          tabIndex=0
          onKeyDown
          onClick=toggleOptionsVisibility>
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
            <div className="dropdown__options" role="listbox" tabIndex={-1}> children </div>
          </>
        | false => React.null
        }}
      </Context.Provider>
    </div>
  }

  module Option = {
    @react.component
    let make = (~value, ~children) => {
      let {selectedValue, setSelectedValue} = React.useContext(Context.context)
      let element = React.useRef(Js.Nullable.null)
      let onClick = _ => setSelectedValue(value)

      let isMaybeSelected = selectedValue->Belt.Option.map(selected => selected == value)
      let isSelected = Belt.Option.getWithDefault(isMaybeSelected, false)

      React.useEffect1(() => {
        isMaybeSelected
        ->Belt.Option.flatMap(isSelected =>
          isSelected ? Js.Nullable.toOption(element.current) : None
        )
        ->Belt.Option.forEach(focus)
        None
      }, [isMaybeSelected])

      <div
        className={`dropdown__option ${isSelected ? "dropdown__option--selected" : ""}`}
        role="option"
        tabIndex={-1}
        ariaSelected=isSelected
        ref={ReactDOM.Ref.domRef(element)}
        onClick>
        children
      </div>
    }
  }
}
