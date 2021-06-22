%%raw(`import './Dropdown.scss';`)
@send external focus: Dom.element => unit = "focus"

module type Dropdown = {
  type value
}

module MakeDropdown = (Item: Dropdown) => {
  type value = Item.value
  type direction = Up | Down
  type action = Toggle | Open | Hide
  type state = {isOpen: bool}

  type context = {
    selectedValue: option<value>,
    setSelectedValue: value => unit,
  }

  let initialState = {
    isOpen: false,
  }

  let reducer = (state, action) =>
    switch action {
    | Toggle => {isOpen: !state.isOpen}
    | Open => {isOpen: true}
    | Hide => {isOpen: false}
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
    let (state, dispatch) = React.useReducer(reducer, initialState)

    let dropdownRef = React.useRef(Js.Nullable.null)
    let optionsRef = React.useRef(Js.Nullable.null)

    let setSelectedValue = value => {
      dropdownRef.current->Js.Nullable.toOption->Belt.Option.forEach(focus)
      dispatch(Hide)
      selectValue(value)
    }

    let manageOptionsFocus = direction => {
      let optionElements = optionsRef.current->Js.Nullable.toOption
      let selectableQuery = "[role=option][tabindex='0']"
      let selectables =
        optionElements
        ->Belt.Option.map(options => WebApi.Element.queryAll(options, selectableQuery))
        ->Belt.Option.getWithDefault([])

      let focused =
        WebApi.Document.activeElement
        ->Js.Nullable.toOption
        ->Belt.Option.flatMap(focusedElement =>
          Belt.Array.getBy(selectables, elem => elem == focusedElement)
        )

      let selected =
        optionElements->Belt.Option.flatMap(options =>
          WebApi.Element.querySelector(
            options,
            `${selectableQuery}[aria-selected=true]`,
          )->Js.Nullable.toOption
        )

      switch (focused, selected) {
      | (None, Some(selectedElement)) => focus(selectedElement)
      | (None, None) =>
        switch direction {
        | Up =>
          selectables->Belt.Array.get(Belt.Array.length(selectables))->Belt.Option.forEach(focus)
        | Down => selectables->Belt.Array.get(0)->Belt.Option.forEach(focus)
        }
      | (Some(focusedElement), _) => {
          let (optionsBeforeFocused, optionsAfterFocused) =
            selectables->ArrayUtil.splitWithout(elem => elem == focusedElement)
          switch direction {
          | Up =>
            Belt.Array.concat(optionsAfterFocused, optionsBeforeFocused)
            ->Belt.Array.reverse
            ->Belt.Array.get(0)
            ->Belt.Option.forEach(focus)
          | Down =>
            Belt.Array.concat(optionsAfterFocused, optionsBeforeFocused)
            ->Belt.Array.get(0)
            ->Belt.Option.forEach(focus)
          }
        }
      }
    }

    React.useEffect1(() => {
      switch state.isOpen {
      | true => manageOptionsFocus(Up)
      | false => ()
      }
      None
    }, [state.isOpen])

    let onKeyDown = event => {
      switch ReactEvent.Keyboard.keyCode(event) {
      | 9 => dispatch(Hide)
      | 13
      | 32 =>
        dispatch(Toggle)
      | 37
      | 38 =>
        dispatch(Open)
        manageOptionsFocus(Up)
      | 39
      | 40 =>
        dispatch(Open)
        manageOptionsFocus(Down)
      | _ => ()
      }
    }
    <Context.Provider
      value={
        selectedValue: selectedValue,
        setSelectedValue: setSelectedValue,
      }>
      <div
        role="combobox"
        tabIndex=0
        ref={ReactDOM.Ref.domRef(dropdownRef)}
        onKeyDown
        className={`dropdown ${state.isOpen ? "dropdown--expanded" : ""}`}>
        <div
          className="dropdown__trigger" ariaExpanded=state.isOpen onClick={_ => dispatch(Toggle)}>
          <div className="dropdown__value">
            {switch selectedValue {
            | None => placeholder
            | Some(value) => selectedValueTemplate(value)
            }}
          </div>
          <div className="dropdown__arrow"> <Icon name=Icon.ArrowLeft /> </div>
        </div>
        {switch state.isOpen {
        | true => <>
            <div className="dropdown__overlay" onClick={_ => dispatch(Hide)} />
            <div className="dropdown__options" role="listbox" ref={ReactDOM.Ref.domRef(optionsRef)}>
              children
            </div>
          </>
        | false => React.null
        }}
      </div>
    </Context.Provider>
  }

  module Option = {
    @react.component
    let make = (~value, ~children, ~disabled: option<bool>=?) => {
      let {selectedValue, setSelectedValue} = React.useContext(Context.context)
      let onClick = _ => setSelectedValue(value)

      let isSelected =
        selectedValue
        ->Belt.Option.map(selected => selected == value)
        ->Belt.Option.getWithDefault(false)

      let isDisabled = Belt.Option.getWithDefault(disabled, false)

      let onKeyDown = event => {
        switch ReactEvent.Keyboard.keyCode(event) {
        | 13
        | 32 =>
          ReactEvent.Keyboard.stopPropagation(event)
          setSelectedValue(value)
        | _ => ()
        }
      }

      <div
        className={`dropdown__option ${isSelected ? "dropdown__option--selected" : ""} ${isDisabled
            ? "dropdown__option--disabled"
            : ""}`}
        role="option"
        tabIndex={isDisabled ? -1 : 0}
        ariaSelected=isSelected
        onKeyDown
        onClick>
        children
      </div>
    }
  }
}
