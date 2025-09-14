# Pure Nix HTML DSL with enhanced children support
rec {
  # Example: html.button { attrs = { class = "foo"; }; children = [ "Click" ]; }
  mkTag = tag: { attrs ? {}, children ? [] }: {
    inherit tag attrs;
    children = if builtins.isList children then children else [children];
  };

  # Render a tag to HTML string
  render = tag:
    let
      htmlLib = {
        inherit div span button input form h1 h2 h3 ul li p a img br hr script;
        mkTag = mkTag;
        render = render;
      };
      
      renderAttrs = attrs:
        builtins.concatStringsSep " " (
          map (name: "${name}=\"${builtins.toString attrs.${name}}\"") (builtins.attrNames attrs)
        );
      
      renderChildren = children:
        builtins.concatStringsSep "" (map (child:
          if builtins.isString child then child
          else if builtins.isAttrs child && child ? tag then
            render child
          else if builtins.isAttrs child && child ? render then
            child.render (child.props or {}) htmlLib
          else builtins.toString child
        ) children);
      
      attrsStr = if tag.attrs == {} then "" else " ${renderAttrs tag.attrs}";
      childrenStr = renderChildren tag.children;
    in
      if tag.children == [] && (builtins.elem tag.tag ["input" "br" "hr" "img" "meta" "link"])
      then "<${tag.tag}${attrsStr} />"
      else "<${tag.tag}${attrsStr}>${childrenStr}</${tag.tag}>";

  # Helper for creating components with children
  withChildren = tag: attrs: children: mkTag tag { inherit attrs children; };

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
  p = mkTag "p";
  a = mkTag "a";
  img = mkTag "img";
  br = mkTag "br";
  hr = mkTag "hr";
  script = mkTag "script";
}
