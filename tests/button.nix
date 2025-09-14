# Test for NixUI Button component
let
  html = import ../src/core/html.nix;
  css = import ../src/core/css.nix;
  component = import ../src/core/component.nix;
  compiler = import ../src/compiler/compiler.nix;

  button = component.define "Button" {
    text = { type = "string"; required = true; };
    variant = { type = "enum"; values = ["primary" "secondary"]; };
  } (props: html.button {
    attrs = {
      class = css.compose [
        "px-4 py-2 rounded font-medium"
        (if props.variant == "primary" then "bg-blue-600 text-white" else "bg-gray-200")
      ];
    };
    children = [ props.text ];
  });

  htmlStr = compiler.renderComponent button { text = "Test"; variant = "primary"; };
  expected = "<button class='px-4 py-2 rounded font-medium bg-blue-600 text-white'>Test</button>";
in
assert htmlStr == expected; true
