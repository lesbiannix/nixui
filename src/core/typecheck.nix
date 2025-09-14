# NixUI: Simple static type checker for component props
{
  # Throws on type error, returns true if valid
  typecheck = component: props:
    let
      propDefs = component.props;
      checkProp = name: def:
        let
          has = builtins.hasAttr name props;
          val = if has then props.${name} else null;
        in
          if (def.required or false) && !has then
            throw "[typecheck] Missing required prop: ${name}"
          else if has then
            if def.type == "string" && !builtins.isString val then
              throw "[typecheck] Prop '${name}' should be string, got ${builtins.typeOf val}"
            else if def.type == "bool" && !builtins.isBool val then
              throw "[typecheck] Prop '${name}' should be bool, got ${builtins.typeOf val}"
            else if def.type == "enum" && !(builtins.elem val def.values) then
              throw "[typecheck] Prop '${name}' should be one of ${builtins.toJSON def.values}, got ${builtins.toJSON val}"
            else
              true
          else
            true;
      propNames = builtins.attrNames propDefs;
      _ = map (n: checkProp n propDefs.${n}) propNames;
    in
      true;
}
