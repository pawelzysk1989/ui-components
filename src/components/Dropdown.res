%%raw(`import './Dropdown.scss';`)
@send external focus: Dom.element => unit = "focus"

module type Dropdown = {
  type value
}

module MakeDropdown = (Item: Dropdown) => {
  type value = Item.value
  type direction = Up | Down

  type context = {
    selectedValue: option<value>,
    setSelectedValue: value => unit,
    focusedIndex: int,
    setFocusedIndex: int => unit,
    index: int,
  }

  module Context = {
    let context = React.createContext({
      selectedValue: None,
      setSelectedValue: _ => (),
      focusedIndex: 0,
      setFocusedIndex: _ => (),
      index: 0,
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
    let (focusIndex, setFocusIndex) = React.useState(_ => 0)
    let toggleOptionsVisibility = _ => {
      setAreOptionsVisible(prev => !prev)
    }
    let setOptionsVisibility = isVisible => setAreOptionsVisible(_ => isVisible)
    let setSelectedValue = value => {
      setOptionsVisibility(false)
      selectValue(value)
    }
    let numberOfOptions = React.Children.count(children)
    let setFocusedIndex = index => setFocusIndex(_ => index)

    let onKeyDown = event =>
      switch ReactEvent.Keyboard.keyCode(event) {
      | 13
      | 32 =>
        toggleOptionsVisibility()
      | 37
      | 38 =>
        switch focusIndex == 0 {
        | true => setFocusedIndex(numberOfOptions - 1)
        | _ => setFocusedIndex(focusIndex - 1)
        }
      | 39
      | 40 =>
        switch focusIndex == numberOfOptions - 1 {
        | true => setFocusedIndex(0)
        | _ => setFocusedIndex(focusIndex + 1)
        }
      | 9 => setOptionsVisibility(false)
      | _ => ()
      }

    <div
      onKeyDown tabIndex=0 className={`dropdown ${areOptionsVisible ? "dropdown--expanded" : ""}`}>
      <div
        className="dropdown__trigger"
        role="combobox"
        ariaExpanded=areOptionsVisible
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
          <div className="dropdown__options" role="listbox" tabIndex={-1}>
            {React.Children.mapWithIndex(children, (child, index) =>
              <Context.Provider
                value={
                  selectedValue: selectedValue,
                  setSelectedValue: setSelectedValue,
                  focusedIndex: focusIndex,
                  setFocusedIndex: setFocusedIndex,
                  index: index,
                }>
                child
              </Context.Provider>
            )}
          </div>
        </>
      | false => React.null
      }}
    </div>
  }

  module Option = {
    @react.component
    let make = (~value, ~children, ~disabled: option<bool>=?) => {
      let {
        selectedValue,
        setSelectedValue,
        focusedIndex,
        setFocusedIndex,
        index,
      } = React.useContext(Context.context)
      let element = React.useRef(Js.Nullable.null)
      let onClick = _ => setSelectedValue(value)

      let isSelected =
        selectedValue
        ->Belt.Option.map(selected => selected == value)
        ->Belt.Option.getWithDefault(false)

      let isDisabled = Belt.Option.getWithDefault(disabled, false)
      let isFocused = index == focusedIndex

      React.useEffect1(() => {
        switch isSelected {
        | true => setFocusedIndex(index)
        | _ => ()
        }
        None
      }, [isSelected])

      React.useEffect1(() => {
        Js.Nullable.toOption(element.current)
        ->Option.filter(_ => isFocused)
        ->Belt.Option.forEach(focus)
        None
      }, [isFocused])

      let onKeyDown = event => {
        switch ReactEvent.Keyboard.keyCode(event) {
        | 13
        | 32 =>
          setSelectedValue(value)
        | _ => ()
        }
      }

      <div
        className={`dropdown__option ${isSelected ? "dropdown__option--selected" : ""} ${isDisabled
            ? "dropdown__option--disabled"
            : ""}`}
        role="option"
        tabIndex={0}
        onKeyDown
        ariaSelected=isSelected
        ref={ReactDOM.Ref.domRef(element)}
        onClick>
        children
      </div>
    }
  }
}
