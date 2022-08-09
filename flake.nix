{
  description = "Dana";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      src = pkgs.fetchzip {
        url = "http://www.projectdana.com/download/ubu64/255#dana.zip";
        stripRoot = false;
        sha256 = "sha256-YwNXq7n6Q7KBPP3zbyADobbkK+IX9DqVQHBsMz4m+WY=";
      };
      drv = doWrap: pkgs.stdenv.mkDerivation {
        name = "dana";
        pname = "dana";
        version = "255";
        inherit src;

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.makeWrapper
        ];

        buildInputs = [
          pkgs.zlib
          pkgs.stdenv.cc.cc.lib
          pkgs.xorg.libX11
        ];

        sourceRoot = ".";

        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          echo $src
          install -m755 -D $src/dana $out/bin/dana
          install -m755 -D $src/dnc $out/bin/dnc

          find -L "$src/components" -type f -print0 | while read -d $'\0' f
          do
            dest="$(realpath --relative-to="$src/components" "$f")"
            install -m755 -D "$f" "$out/lib/dana/components/$dest"
          done

          find -L "$src/resources-ext" -type f -print0 | while read -d $'\0' f
          do
            dest="$(realpath --relative-to="$src/resources-ext" "$f")"
            install -m755 -D "$f" "$out/lib/dana/resources-ext/$dest"
          done

          ${if doWrap then "wrapProgram $out/bin/dana --set-default DANA_HOME $out/lib/dana;" else ""}
          ${if doWrap then "wrapProgram $out/bin/dnc --set-default DANA_HOME $out/lib/dana;" else ""}

          ln -s $out/bin/dana $out/lib/dana/dana
          ln -s $out/bin/dnc $out/lib/dana/dnc
        '';

        meta = with pkgs.lib; {
          description = "The Dana programming language";
          longDescription = ''
            Dana is the most advanced adaptive programming
            language in the world, able to seamlessly hot-swap components in
            microseconds with inherent soundness. Update programs without
            restarting them; edit code live and see your system change in
            real-time; and write programs which constantly adapt to their context.
          '';
          homepage = "https://www.projectdana.com/";
          changelog = "https://www.projectdana.com/timeline";
        };
      };
    in
    {
      packages.x86_64-linux.default = drv true;
      packages.x86_64-linux.unwrapped = drv false;
    };
}
