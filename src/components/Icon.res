%%raw(`import './Icon.scss';`)

type t = ArrowLeft

@react.component
let make = (~name) =>
  <i className="icon">
    {switch name {
    | ArrowLeft =>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        xmlnsXlink="http://www.w3.org/1999/xlink"
        ariaHidden=true
        focusable="false"
        width="1em"
        height="1em"
        preserveAspectRatio="xMidYMid meet"
        viewBox="0 0 24 24">
        <path d="M15 4l2 2l-6 6l6 6l-2 2l-8-8z" />
      </svg>
    }}
  </i>
