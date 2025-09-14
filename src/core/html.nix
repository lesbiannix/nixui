# Pure Nix HTML DSL
rec {
  # Example: html.button { attrs = { class = "foo"; }; children = [ "Click" ]; }
  mkTag = tag: { attrs, children }: {
    inherit tag attrs children;
  };

  # Common tags
  div = mkTag "div";
  span = mkTag "span";
  button = mkTag "button";
  input = mkTag "input";
  form = mkTag "form";
  h1 = mkTag "h1";
  h2 = mkTag "h2";
  h3 = mkTag "h3";
  ul = mkTag "ul";
  li = mkTag "li";
  # ...add more as needed
}
