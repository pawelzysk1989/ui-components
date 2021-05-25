// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Curry from "bs-platform/lib/es6/curry.js";
import * as React from "react";
import * as Caml_option from "bs-platform/lib/es6/caml_option.js";

import './Dropdown.scss';
;

function MakeDropdown(Item) {
  var setSelected = function (param) {
    console.log("");
    
  };
  var context = React.createContext([
        undefined,
        setSelected
      ]);
  var provider = context.Provider;
  var Dropdown$MakeDropdown$Context$Provider = function (Props) {
    var value = Props.value;
    var children = Props.children;
    return React.createElement(provider, {
                value: value,
                children: children
              });
  };
  var Provider = {
    provider: provider,
    make: Dropdown$MakeDropdown$Context$Provider
  };
  var Context = {
    selected: undefined,
    setSelected: setSelected,
    context: context,
    Provider: Provider
  };
  var Dropdown$MakeDropdown = function (Props) {
    var selectedValue = Props.selectedValue;
    var selectValue = Props.selectValue;
    var selectedValueTemplate = Props.selectedValueTemplate;
    var placeholder = Props.placeholder;
    var children = Props.children;
    return React.createElement(Dropdown$MakeDropdown$Context$Provider, {
                value: [
                  selectedValue,
                  selectValue
                ],
                children: null
              }, selectedValue !== undefined ? Curry._1(selectedValueTemplate, Caml_option.valFromOption(selectedValue)) : placeholder, children);
  };
  var Dropdown$MakeDropdown$Option = function (Props) {
    var value = Props.value;
    var children = Props.children;
    var match = React.useContext(context);
    var selectValue = match[1];
    return React.createElement("div", {
                className: "app-dropdown-option",
                onClick: (function (param) {
                    return Curry._1(selectValue, value);
                  })
              }, children);
  };
  var $$Option = {
    make: Dropdown$MakeDropdown$Option
  };
  return {
          Context: Context,
          make: Dropdown$MakeDropdown,
          $$Option: $$Option
        };
}

export {
  MakeDropdown ,
  
}
/*  Not a pure module */
