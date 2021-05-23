// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as ReactDom from "react-dom";
import * as Caml_option from "bs-platform/lib/es6/caml_option.js";
import * as App$Dropdown from "./App.bs.js";
import ReportWebVitals from "./reportWebVitals";

import './styles/index.scss';
;

function reportWebVitals(prim) {
  ReportWebVitals();
  
}

var rootQuery = document.querySelector("#root");

if (!(rootQuery == null)) {
  ReactDom.render(React.createElement(App$Dropdown.make, {}), rootQuery);
}

ReportWebVitals();

var rootQuery$1 = (rootQuery == null) ? undefined : Caml_option.some(rootQuery);

export {
  reportWebVitals ,
  rootQuery$1 as rootQuery,
  
}
/*  Not a pure module */
