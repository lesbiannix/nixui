# Component definition/type system with children support
{
  # Define a component with name, props, and render function
  define = name: props: render: {
    inherit name props render;
  };

  # Helper to create components with children prop
  withChildren = name: props: render: {
    inherit name render;
    props = props // {
      children = { 
        type = { type = "list"; itemType = "component"; }; 
        default = []; 
      };
    };
  };

  # Helper to render a list of child components
  renderChildren = children: htmlLib:
    builtins.concatStringsSep "" (map (child:
      if builtins.isString child then child
      else if builtins.isAttrs child && child ? render then
        child.render (child.props or {}) htmlLib
      else builtins.toString child
    ) children);

  # Compose multiple components together
  compose = components: props: htmlLib:
    let
      componentMap = builtins.listToAttrs (map (c: { name = c.name; value = c; }) components);
      renderComponent = comp: compProps:
        if builtins.hasAttr comp componentMap then
          let component = componentMap.${comp};
          in component.render compProps htmlLib
        else throw "Unknown component: ${comp}";
    in
      renderComponent;

  # Example type signatures (for documentation)
  # props = {
  #   text = { type = "string"; required = true; };
  #   variant = { type = "enum"; values = ["primary" "secondary"]; };
  #   count = { type = "int"; default = 0; };
  #   config = { 
  #     type = "attrs"; 
  #     attrTypes = {
  #       enabled = { type = "bool"; default = true; };
  #       items = { type = { type = "list"; itemType = "string"; }; };
  #     };
  #   };
  #   children = { type = { type = "list"; itemType = "component"; }; default = []; };
  # };
}
