# Component definition/type system
{
  # Define a component with name, props, and render function
  define = name: props: render: {
    inherit name props render;
  };

  # Example type signatures (for documentation)
  # props = {
  #   text = { type = "string"; required = true; };
  #   variant = { type = "enum"; values = ["primary" "secondary"]; };
  # };
}
