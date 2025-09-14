# Minimal NixUI app example
let
  html = import ../../src/core/html.nix;
  css = import ../../src/core/css.nix;
  component = import ../../src/core/component.nix;
  compiler = import ../../src/compiler/compiler.nix;

  # Define a button component
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

  # Define a todo item component
  todoItem = component.define "TodoItem" {
    text = { type = "string"; required = true; };
    done = { type = "bool"; required = true; };
  } (props: html.li {
    attrs = {
      class = css.compose [
        "flex items-center space-x-2"
        (if props.done then "line-through text-gray-400" else "")
      ];
    };
    children = [ props.text ];
  });

  # Define a todo list
  todos = [
    { text = "Learn Nix"; done = true; }
    { text = "Build a frontend"; done = false; }
    { text = "Profit!"; done = false; }
  ];

  todoList = html.ul {
    attrs = { class = "space-y-2 mt-4"; };
    children = map (t: todoItem.render t) todos;
  };

  # Render the app
  app = html.div {
    attrs = { class = "max-w-md mx-auto mt-10 p-6 bg-white rounded shadow"; };
    children = [
      html.h1 { attrs = { class = "text-2xl font-bold mb-4"; }; children = [ "NixUI Todo List" ]; }
      todoList
      button.render { text = "Add Todo"; variant = "primary"; }
    ];
  };

  htmlStr = compiler.renderComponent { render = _: app; } {};
in
htmlStr
