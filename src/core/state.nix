# Elm-like state abstraction for NixUI
{
  # Create a stateful component abstraction
  # Usage: state.create { initial = 0; update = ...; view = ...; }
  create = { initial, update, view }:
    {
      inherit initial update view;
    };
}
