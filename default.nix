{ pkgs ? import
    (fetchTarball {
      name = "jpetrucciani-2024-01-09";
      url = "https://github.com/jpetrucciani/nix/archive/5257884e14fd174a3d55332330bc09575c3a06ed.tar.gz";
      sha256 = "05w91m5i7l767f5ihjh8bvpcdjrl59phx5rm4dg2z5778c0qgy4r";
    })
    { }
}:
let
  name = "qlsh";
  myDotnet = (with pkgs.dotnetCorePackages; combinePackages [
    sdk_7_0
    sdk_8_0
  ]);

  tools = with pkgs; {
    cli = [
      coreutils
      nixpkgs-fmt
    ];
    dotnet = [
      myDotnet
    ];

    scripts = [ ];
  };

  paths = pkgs.lib.flatten [ (builtins.attrValues tools) ];
  env = pkgs.buildEnv {
    inherit name paths;
    buildInputs = paths;
  };

in
env.overrideAttrs (_: {
  NIXUP = "0.0.5";
  DOTNET_ROOT = "${myDotnet}";
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath ([
    pkgs.stdenv.cc.cc
  ]);
  NIX_LD = "${pkgs.stdenv.cc.libc_bin}/bin/ld.so";
  nativeBuildInputs = [
  ] ++ paths;
})
