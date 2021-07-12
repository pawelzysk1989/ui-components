%%raw(`import './Dropdown.scss';`)

module type Dropdown = {
  type value
}

module Make = (Item: Dropdown) => {
  type value = Item.value
  type direction = Up | Down
  type action = Open | Hide | MoveUp | MoveDown | Select(value)
  type state = {isOpen: bool}

  type context = {
    selectedValue: option<value>,
    dispatch: action => unit,
  }

  let initialState = {
    isOpen: false,
  }

  module Context = ReactContext.Make({
    type t = context
    let defaultValue = {
      selectedValue: None,
      dispatch: _ => (),
    }
  })

  @react.component
  let make = (~selectedValue, ~selectValue, ~selectedValueTemplate, ~placeholder, ~children) => {
    let dropdownRef = React.useRef(Js.Nullable.null)
    let optionsRef = React.useRef(Js.Nullable.null)

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
      | (None, Some(selectedElement)) => WebApi.Element.focus(selectedElement)

      | (None, None) =>
        switch direction {
        | Up =>
          selectables
          ->Belt.Array.get(Belt.Array.length(selectables) - 1)
          ->Belt.Option.forEach(WebApi.Element.focus)
        | Down => selectables->Belt.Array.get(0)->Belt.Option.forEach(WebApi.Element.focus)
        }

      | (Some(focusedElement), _) => {
          let (optionsBeforeFocused, optionsAfterFocused) =
            selectables->ArrayUtil.splitWithout(elem => elem == focusedElement)
          switch direction {
          | Up =>
            Belt.Array.concat(optionsAfterFocused, optionsBeforeFocused)
            ->Belt.Array.reverse
            ->Belt.Array.get(0)
            ->Belt.Option.forEach(WebApi.Element.focus)
          | Down =>
            Belt.Array.concat(optionsAfterFocused, optionsBeforeFocused)
            ->Belt.Array.get(0)
            ->Belt.Option.forEach(WebApi.Element.focus)
          }
        }
      }
    }

    let (state, dispatch) = ReactUpdate.useReducerWithMapState(
      (_, action) =>
        switch action {
        | Hide => ReactUpdate.Update({isOpen: false})
        | Open
        | MoveDown =>
          ReactUpdate.UpdateWithSideEffects(
            {isOpen: true},
            _ => {
              manageOptionsFocus(Down)
              None
            },
          )
        | MoveUp =>
          ReactUpdate.UpdateWithSideEffects(
            {isOpen: true},
            _ => {
              manageOptionsFocus(Up)
              None
            },
          )
        | Select(value) =>
          ReactUpdate.UpdateWithSideEffects(
            {isOpen: false},
            _ => {
              dropdownRef.current->Js.Nullable.toOption->Belt.Option.forEach(WebApi.Element.focus)
              selectValue(value)
              None
            },
          )
        },
      () => initialState,
    )

    let toggle = () => {
      switch state.isOpen {
      | true => dispatch(Hide)
      | false => dispatch(Open)
      }
    }

    let onKeyDown = event => {
      switch ReactEvent.Keyboard.keyCode(event) {
      | 9
      | 27 =>
        dispatch(Hide)
      | 13
      | 32 =>
        toggle()
      | 37
      | 38 =>
        dispatch(MoveUp)
        ReactEvent.Keyboard.preventDefault(event)
      | 39
      | 40 =>
        dispatch(MoveDown)
        ReactEvent.Keyboard.preventDefault(event)
      | _ => ()
      }
    }

    <Context.Provider
      value={
        selectedValue: selectedValue,
        dispatch: dispatch,
      }>
      <div
        role="combobox"
        tabIndex=0
        ref={ReactDOM.Ref.domRef(dropdownRef)}
        onKeyDown
        className={`dropdown ${state.isOpen ? "dropdown--expanded" : ""}`}>
        <div className="dropdown__trigger" ariaExpanded=state.isOpen onClick={_ => toggle()}>
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
      let {selectedValue, dispatch} = React.useContext(Context.context)
      let selectValue = value => value->Select->dispatch
      let onClick = _ => selectValue(value)

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
          selectValue(value)
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
