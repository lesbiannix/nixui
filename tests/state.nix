# Test for NixUI state abstraction
let
  state = import ../src/core/state.nix;

  counter = state.create {
    initial = 0;
    update = msg: s: if msg == "inc" then s + 1 else if msg == "dec" then s - 1 else s;
    view = s: _: s;
  };

  afterInc = counter.update "inc" counter.initial;
  afterDec = counter.update "dec" afterInc;
  afterUnknown = counter.update "noop" afterDec;
in
assert afterInc == 1;
assert afterDec == 0;
assert afterUnknown == 0;
true
