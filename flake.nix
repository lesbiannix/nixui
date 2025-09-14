{
  description = "NixUI Development Environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs_20 typescript playwright chromium
        ];
      };
      packages.${system}.nixui = pkgs.stdenv.mkDerivation {
        name = "nixui";
        src = ./.;
        buildPhase = ''
          cd examples/todo-app
          ${pkgs.tailwindcss}/bin/tailwindcss -c tailwind.config.js -i input.css -o tailwind.css --minify
        '';
        installPhase = ''
          mkdir -p $out
          cp -r ../../* $out/
          cp tailwind.css $out/examples/todo-app/
        '';

      };
    };
}
