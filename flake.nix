{
  description = "NixUI Development Environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      
      # Build function for any NixUI app
      buildApp = appPath: pkgs.stdenv.mkDerivation {
        name = "nixui-app";
        src = ./.;
        buildInputs = with pkgs; [ tailwindcss ];
        buildPhase = ''
          cd ${appPath}
          if [ -f tailwind.config.js ] && [ -f input.css ]; then
            ${pkgs.tailwindcss}/bin/tailwindcss -c tailwind.config.js -i input.css -o tailwind.css --minify
          fi
        '';
        installPhase = ''
          mkdir -p $out
          cp -r ${appPath}/* $out/
          cp -r src $out/
        '';
      };
      
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs_20 typescript playwright chromium
        ];
      };
      
      packages.${system} = {
        # Default package builds todo-app for backward compatibility
        default = buildApp "examples/todo-app";
        nixui = buildApp "examples/todo-app";
        
        # Apps for different examples
        todo-app = buildApp "examples/todo-app";
        lucy-about = buildApp "examples/lucy-about";
      };
      
      # Function to build custom apps
      lib.buildApp = buildApp;
    };
}
