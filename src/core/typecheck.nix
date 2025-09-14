# NixUI: Enhanced static type checker for component props
{
  # Throws on type error, returns props with defaults applied if valid
  typecheck = component: props:
    let
      propDefs = component.props;
      
      # Helper to validate list items
      validateList = items: itemType:
        if itemType == "string" then
          builtins.all builtins.isString items
        else if itemType == "int" then
          builtins.all builtins.isInt items
        else if itemType == "float" then
          builtins.all (x: builtins.isFloat x || builtins.isInt x) items
        else if itemType == "bool" then
          builtins.all builtins.isBool items
        else
          true;
      
      # Helper to validate attribute sets
      validateAttrs = attrs: attrTypes:
        let
          requiredKeys = builtins.filter (k: attrTypes.${k}.required or false) (builtins.attrNames attrTypes);
          missingKeys = builtins.filter (k: !builtins.hasAttr k attrs) requiredKeys;
        in
          if missingKeys != [] then
            throw "[typecheck] Missing required attributes: ${builtins.toJSON missingKeys}"
          else
            builtins.all (k: 
              let attrDef = attrTypes.${k}; 
                  val = attrs.${k};
              in validateType val attrDef.type
            ) (builtins.attrNames attrs);
      
      # Type validation function
      validateType = val: type:
        if type == "string" then builtins.isString val
        else if type == "bool" then builtins.isBool val
        else if type == "int" then builtins.isInt val
        else if type == "float" then (builtins.isFloat val || builtins.isInt val)
        else if builtins.isAttrs type && type.type or null == "list" then
          builtins.isList val && validateList val (type.itemType or "string")
        else if builtins.isAttrs type && type.type or null == "attrs" then
          builtins.isAttrs val && validateAttrs val (type.attrTypes or {})
        else if builtins.isAttrs type && type.type or null == "enum" then
          builtins.elem val (type.values or [])
        else if builtins.isAttrs type && type.type or null == "union" then
          builtins.any (t: validateType val t) (type.types or [])
        else
          true;
      
      checkProp = name: def:
        let
          has = builtins.hasAttr name props;
          val = if has then props.${name} else (def.default or null);
          hasDefault = builtins.hasAttr "default" def;
          isRequired = def.required or false;
        in
          if isRequired && !has && !hasDefault then
            throw "[typecheck] Missing required prop: ${name}"
          else if has || hasDefault then
            let actualVal = if has then props.${name} else def.default;
            in
              if def.type == "string" && !builtins.isString actualVal then
                throw "[typecheck] Prop '${name}' should be string, got ${builtins.typeOf actualVal}"
              else if def.type == "bool" && !builtins.isBool actualVal then
                throw "[typecheck] Prop '${name}' should be bool, got ${builtins.typeOf actualVal}"
              else if def.type == "int" && !builtins.isInt actualVal then
                throw "[typecheck] Prop '${name}' should be int, got ${builtins.typeOf actualVal}"
              else if def.type == "float" && !(builtins.isFloat actualVal || builtins.isInt actualVal) then
                throw "[typecheck] Prop '${name}' should be float, got ${builtins.typeOf actualVal}"
              else if !validateType actualVal def.type then
                throw "[typecheck] Prop '${name}' failed type validation for ${builtins.toJSON def.type}"
              else
                { ${name} = actualVal; }
          else
            {};
            
      propNames = builtins.attrNames propDefs;
      validatedProps = map (n: checkProp n propDefs.${n}) propNames;
      mergedProps = builtins.foldl' (acc: p: acc // p) {} validatedProps;
    in
      props // mergedProps;
}
