# NixUI

Declarative frontend framework for Nix — pure Nix components, built-in Tailwind CSS, no HTML files, type-safe, and functional.

## Quick Start

```sh
# Scaffold a new app
./nixui init my-app

# Enter dev shell
./nixui dev

# Build example app (generates HTML and Tailwind CSS)
./nixui build

# Type check components (placeholder)
./nixui check
```

## Project Structure

```
nixui/
├── flake.nix
├── src/
│   ├── core/           # Framework core (html, css, component)
│   ├── compiler/       # Compiler (Nix → HTML)
│   └── runtime/        # (future)
├── examples/
│   └── todo-app/       # Example app
├── tests/              # Test suites
└── docs/               # Documentation
```

## Example Component

```nix
let
  html = import ../../src/core/html.nix;
  css = import ../../src/core/css.nix;
  component = import ../../src/core/component.nix;
  compiler = import ../../src/compiler/compiler.nix;

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

  htmlStr = compiler.renderComponent button { text = "Click Me!"; variant = "primary"; };
in
htmlStr
```

## Example: Elm-like State Management

```nix
let
  state = import ../../src/core/state.nix;
  html = import ../../src/core/html.nix;

  counter = state.create {
    initial = 0;
    update = msg: state: if msg == "inc" then state + 1 else if msg == "dec" then state - 1 else state;
    view = state: dispatch: html.div {
      attrs = { class = "flex items-center space-x-2"; };
      children = [
        html.button { attrs = { onClick = "dispatch('dec')"; class = "btn"; }; children = [ "-" ]; }
        html.span { attrs = {}; children = [ builtins.toString state ]; }
        html.button { attrs = { onClick = "dispatch('inc')"; class = "btn"; }; children = [ "+" ]; }
      ];
    };
  };
in
# In a real runtime, the view would be rendered and dispatch would be wired to events.
counter
```


## License
MIT
