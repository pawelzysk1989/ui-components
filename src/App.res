%%raw(`import './App.scss';`)

module DropdownOfInts = Dropdown.MakeDropdown({
  type value = int
})

type country = PL | GB | USA

let countryToString = country => {
  switch country {
  | PL => "Poland"
  | GB => "Great Britain"
  | USA => "United States"
  }
}

module DropdownOfCountries = Dropdown.MakeDropdown({
  type value = country
})

@react.component
let make = () => {
  let (selectedValue, setSelectedValue) = React.useState(_ => None)
  let selectValue = value => setSelectedValue(_ => Some(value))
  let intLabelTemplate = value => value->Belt.Int.toString->Js.String.concat("Value ")->React.string
  let intPlaceholder = React.string("Select value")

  let (selectedCountry, setSelectedCountry) = React.useState(_ => None)
  let selectCountry = value => setSelectedCountry(_ => Some(value))
  let countryLabelTemplate = country => country->countryToString->React.string
  let countryPlaceholder = React.string("Select country")

  <div className="app-container">
    <DropdownOfInts
      selectedValue selectValue selectedValueTemplate=intLabelTemplate placeholder=intPlaceholder>
      <DropdownOfInts.Option value=0> {intLabelTemplate(0)} </DropdownOfInts.Option>
      <DropdownOfInts.Option value=1> {intLabelTemplate(1)} </DropdownOfInts.Option>
      <DropdownOfInts.Option value=2> {intLabelTemplate(2)} </DropdownOfInts.Option>
    </DropdownOfInts>
    <DropdownOfCountries
      selectedValue=selectedCountry
      selectValue=selectCountry
      selectedValueTemplate=countryLabelTemplate
      placeholder=countryPlaceholder>
      <DropdownOfCountries.Option value=PL> {countryLabelTemplate(PL)} </DropdownOfCountries.Option>
      <DropdownOfCountries.Option value=GB> {countryLabelTemplate(GB)} </DropdownOfCountries.Option>
      <DropdownOfCountries.Option value=USA>
        {countryLabelTemplate(USA)}
      </DropdownOfCountries.Option>
    </DropdownOfCountries>
  </div>
}
