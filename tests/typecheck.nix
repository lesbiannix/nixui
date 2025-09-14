# Test for NixUI type checker
let
  component = import ../src/core/component.nix;
  typecheck = (import ../src/core/typecheck.nix).typecheck;

  button = component.define "Button" {
    text = { type = "string"; required = true; };
    variant = { type = "enum"; values = ["primary" "secondary"]; };
  } (_: null);

  # Valid props
  valid = typecheck button { text = "Click"; variant = "primary"; };

  # Missing required prop
  missing = builtins.tryEval (typecheck button { variant = "primary"; });

  # Wrong type
  wrongType = builtins.tryEval (typecheck button { text = 123; variant = "primary"; });

  # Invalid enum
  wrongEnum = builtins.tryEval (typecheck button { text = "Click"; variant = "danger"; });

in
assert valid == true;
assert missing.success == false;
assert builtins.match ".*Missing required prop: text.*" missing.value != null;
assert wrongType.success == false;
assert builtins.match ".*should be string.*" wrongType.value != null;
assert wrongEnum.success == false;
assert builtins.match ".*should be one of.*" wrongEnum.value != null;
true
