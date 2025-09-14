# Enhanced Elm-like state abstraction for NixUI with runtime integration
{
  # Create a stateful component abstraction
  # Usage: state.create { initial = 0; update = ...; view = ...; }
  create = { initial, update, view }:
    {
      inherit initial update view;
      # Generate runtime-compatible state binding
      runtimeId = builtins.hashString "sha256" (builtins.toJSON { inherit initial; });
    };

  # Create event handlers that integrate with the JavaScript runtime
  onClick = action: {
    event = "click";
    action = action;
    handler = "dispatch";
  };

  onInput = action: {
    event = "input";
    action = action;
    handler = "dispatch";
  };

  onChange = action: {
    event = "change";
    action = action;
    handler = "dispatch";
  };

  # Helper to create actions
  action = type: payload: {
    inherit type;
    payload = payload or {};
  };

  # State binding for HTML elements
  bind = statePath: {
    nixuiState = statePath;
    nixuiBinding = true;
  };

  # Create interactive element with event handlers
  interactive = elementId: events: {
    nixuiId = elementId;
    nixuiEvents = builtins.concatStringsSep "," (map (e: e.event) events);
    nixuiHandlers = builtins.listToAttrs (map (e: {
      name = e.event;
      value = e.action;
    }) events);
  };

  # Connect Nix state definition to runtime
  connectRuntime = stateApp: {
    initial = stateApp.initial;
    update = ''
      function(state, action) {
        // This would be generated from the Nix update function
        switch(action.type) {
          ${builtins.concatStringsSep "\n" (generateUpdateCases stateApp.update)}
          default:
            return state;
        }
      }
    '';
    view = stateApp.view;
  };

  # Generate JavaScript update cases from Nix update function
  generateUpdateCases = updateFn: [
    "// Generated from Nix update function"
    "// This needs integration with the Nix compiler"
  ];
}
