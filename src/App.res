%%raw(`import './App.scss';`)

@react.component
let make = () => {
  let (selectedValue, setSelectedValue) = React.useState(_ => None)
  let selectValue = value => setSelectedValue(_ => Some(value))
  <div className="app-container">
    <Dropdown selectedValue selectValue>
      <Dropdown.Option value=0> {React.string("Value 1")} </Dropdown.Option>
      <Dropdown.Option value=1> {React.string("Value 2")} </Dropdown.Option>
      <Dropdown.Option value=2> {React.string("Value 3")} </Dropdown.Option>
    </Dropdown>
  </div>
}
