# Enhanced Compiler with Runtime Integration
{
  compiler = import ./compiler.nix;
  
  # Compile Nix component to HTML with runtime integration
  compileWithRuntime = component: props: 
    let
      html = import ../core/html.nix;
      typecheck = import ../core/typecheck.nix;
      
      # Validate props and apply defaults
      validatedProps = typecheck.typecheck component props;
      
      # Generate HTML with runtime attributes
      addRuntimeAttrs = tag: runtimeProps:
        if runtimeProps ? nixuiId then
          tag // {
            attrs = (tag.attrs or {}) // {
              "data-nixui-id" = runtimeProps.nixuiId;
              "data-nixui-events" = runtimeProps.nixuiEvents or "";
            };
          }
        else if runtimeProps ? nixuiState then
          tag // {
            attrs = (tag.attrs or {}) // {
              "data-nixui-state" = runtimeProps.nixuiState;
            };
          }
        else tag;
      
      # Enhanced HTML renderer with runtime support
      renderWithRuntime = tag:
        let
          renderAttrs = attrs:
            builtins.concatStringsSep " " (
              map (name: 
                let value = attrs.${name};
                in "${name}=\"${if builtins.isString value then value else builtins.toString value}\""
              ) (builtins.attrNames attrs)
            );
          
          renderChildren = children:
            builtins.concatStringsSep "" (map (child:
              if builtins.isString child then child
              else if builtins.isAttrs child && child ? tag then
                renderWithRuntime child
              else if builtins.isAttrs child && child ? render then
                child.render (child.props or {}) html
              else builtins.toString child
            ) children);
          
          attrsStr = if tag.attrs == {} then "" else " ${renderAttrs tag.attrs}";
          childrenStr = renderChildren (tag.children or []);
        in
          if (tag.children or []) == [] && (builtins.elem tag.tag ["input" "br" "hr" "img" "meta" "link"])
          then "<${tag.tag}${attrsStr} />"
          else "<${tag.tag}${attrsStr}>${childrenStr}</${tag.tag}>";
      
      # Render component with runtime integration
      renderedTag = component.render validatedProps html;
      
    in {
      html = renderWithRuntime renderedTag;
      props = validatedProps;
      runtime = {
        componentId = component.name or "component";
        initialState = validatedProps;
        events = extractEvents renderedTag;
      };
    };
  
  # Extract event handlers from rendered component
  extractEvents = tag:
    let
      tagEvents = if tag ? attrs && tag.attrs ? "data-nixui-events" 
                  then builtins.filter (x: x != "") (builtins.split "," (tag.attrs."data-nixui-events"))
                  else [];
      childEvents = builtins.concatLists (map extractEvents (tag.children or []));
    in tagEvents ++ childEvents;
  
  # Generate complete HTML page with runtime
  generatePage = { title ? "NixUI App", components, initialState ? {}, updateFunction ? null }:
    let
      runtimeScript = if updateFunction != null then ''
        <script>
          const runtime = new NixUIRuntime(
            ${builtins.toJSON initialState},
            ${updateFunction}
          );
          
          document.addEventListener('DOMContentLoaded', () => {
            runtime.hydrate('body');
          });
        </script>
      '' else "";
      
      componentHtml = builtins.concatStringsSep "\n" (map (comp: 
        (compileWithRuntime comp.component comp.props).html
      ) components);
      
    in ''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${title}</title>
        <link href="tailwind.css" rel="stylesheet">
        <script src="src/core/runtime.js"></script>
      </head>
      <body>
        ${componentHtml}
        ${runtimeScript}
      </body>
      </html>
    '';
}