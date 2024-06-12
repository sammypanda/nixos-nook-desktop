{
  stdenv,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  electron,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  ...
}:

let
  electronDist = electron + "/libexec/electron";
in

buildNpmPackage rec {
  pname = "nook-desktop";
  version = "1.0.10";

  src = fetchFromGitHub {
    owner = "mn6";
    repo = "nook-desktop";
    rev = "v${version}"; # github release tag
    hash = "sha256-FQQxxPr1yAxxCxHE1Nedr2cZ036FekWwGpyOBGFKSdQ="; # hash for the source code
  };

  npmDepsHash = "sha256-69PMvhJVEaB+clGXlkRpggNemt6Ocy1EWNGwM6xs2FE="; # hash for the deps

  dontNpmBuild = true; # no build script

  makeCacheWritable = true; # makes logs able to write

  ELECTRON_SKIP_BINARY_DOWNLOAD = 1; # deps able to download

  nativeBuildInputs = [
    makeWrapper
  ] ++ lib.optionals stdenv.isLinux [
    copyDesktopItems
  ];

  preBuild = ''
    # remove some prebuilt binaries
    find node_modules -type d -name prebuilds -exec rm -r {} +
  '';

  postBuild = ''
    cp -r ${electronDist} electron-dist
    chmod -R u+w electron-dist

    npm exec electron-builder -- \
      --dir \
      -c.asarUnpack="**/*.node" \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version} \
      -c.npmRebuild=false
  '';

  installPhase = ''
    runHook preInstall

    ${lib.optionalString stdenv.isLinux ''
      mkdir -p $out/share/nook-desktop
      cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/nook-desktop

      makeWrapper ${lib.getExe electron} $out/bin/nook-desktop \
          --add-flags $out/share/nook-desktop/resources/app.asar \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
          --set-default ELECTRON_IS_DEV 0 \
          --inherit-argv0

      install -Dm644 build/icons/nook.png $out/share/icons/hicolor/512x512/apps/nook-desktop.png
    ''}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "nook-desktop";
      exec = "nook-desktop %U";
      icon = "nook-desktop";
      desktopName = "Nook Desktop";
      comment = meta.description;
      categories = [ "Music" "Audio" ];
      terminal = false;
    })
  ];

  meta = with lib; {
    mainProgram = "nook-desktop";
    description = "A flake of Nook Desktop, the desktop edition of the extension created for people who love to listen to Animal Crossing's hourly music all day, every day.";
    inherit (electron.meta) platforms;
  };
}
