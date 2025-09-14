# NixUI Compiler: Nix component -> HTML string
let
  inherit (import ../core/html.nix) mkTag;
  inherit (import ../core/css.nix) compose;

  # Render a tag to HTML
  renderTag = tagObj:
    let
      attrsStr = builtins.concatStringsSep " " (
        map (k: "${k}='${tagObj.attrs.${k}}'") (builtins.attrNames tagObj.attrs)
      );
      childrenStr = builtins.concatStringsSep "" (
        map (c: if builtins.isAttrs c then renderTag c else c) tagObj.children
      );
    in
      "<${tagObj.tag} ${attrsStr}>${childrenStr}</${tagObj.tag}>";

  # Entry point: render a component
  renderComponent = comp: props:
    renderTag (comp.render props);
in
{
  inherit renderComponent;
}
