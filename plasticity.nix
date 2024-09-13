{
  stdenv,
  lib,
  mkWindowsApp,
  wine,
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon, # This comes with erosanix. It's a handy way to generate desktop icons.
  copyDesktopItems,
  copyDesktopIcons, # This comes with erosanix. It's a handy way to generate desktop icons.
  unzip,
  system,
  self,
  pkgs,
  setDPI ? null,
}: let
  # This registry file sets winebrowser (xdg-open) as the default handler for
  # text files, instead of Wine's notepad.
  pname = "plasticity";
  txtReg = ./txt.reg;
  # Contains GPU cache, code cache, window state,
  # and the machine's unique license sig
  stateDir = "$HOME/.local/share/${pname}/roaming";

  setDPIReg = pkgs.writeText "set-dpi-${toString setDPI}.reg" ''
    Windows Registry Editor Version 5.00
    [HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
    "LogPixels"=dword:${toString setDPI}
  '';
in
  mkWindowsApp rec {
    inherit wine pname;

    version = "24.2.2";

    src = builtins.fetchurl {
      url = "https://github.com/nkallen/plasticity/releases/download/v${version}/Plasticity.msi";
      sha256 = "sha256:1llqb3w8dwd0kdf96d5vkz7zgz05hdyjhp7i84s4pzm8zfnvhssq";
    };

    dontUnpack = true;
    wineArch = "win64";

    enableInstallNotification = true;
    fileMap = {
      "${stateDir}" = "drive_c/users/$USER/AppData/Roaming/Plasticity";
    };

    fileMapDuringAppInstall = false;
    persistRegistry = false;
    persistRuntimeLayer = false;
    inputHashMethod = "store-path";

    nativeBuildInputs = [unzip copyDesktopItems copyDesktopIcons];

    winAppInstall =
      ''
        # https://askubuntu.com/questions/29552/how-do-i-enable-font-anti-aliasing-in-wine
        winetricks -q settings fontsmooth=rgb
        # https://www.advancedinstaller.com/silent-install-exe-msi-applications.html
        $WINE msiexec /i ${src} /qb!
        regedit ${txtReg}
        regedit ${./use-theme-none.reg}
        regedit ${./wine-breeze-dark.reg}
      ''
      + lib.optionalString (setDPI != null) ''
        regedit ${setDPIReg}
      '';
    winAppPreRun = ''
    '';

    winAppRun = ''
      wine "$WINEPREFIX/drive_c/Program Files/Plasticity/Plasticity.exe" "$ARGS"
    '';

    winAppPostRun = "";

    installPhase = ''
      runHook preInstall
      ln -s $out/bin/.launcher $out/bin/${pname}
      runHook postInstall
    '';

    desktopItems = let
      mimeTypes = [
        "application/x-Plasticity"
        "application/x-plasticity"
      ];
    in [
      (makeDesktopItem {
        inherit mimeTypes;

        name = pname;
        exec = pname;
        icon = pname;
        desktopName = "Plasticity for Windows";
        genericName = "3D CAD software for Windows-using artists, I guess.";
        categories = ["Graphics" "Viewer"];
      })
    ];

    desktopIcon = makeDesktopIcon {
      name = "plasticity";

      src = fetchurl {
        url = "https://www.plasticity.xyz/_next/image?w=256&q=75&url=%2F_next%2Fstatic%2Fmedia%2Ficon_256x256.09a58ec3.png";
        sha256 = "sha256-OAmFMeIsrMogwTYiney7rNcKkjbSj/64kGb+6zdbRtA=";
      };
    };

    meta = with lib; {
      description = "Plasticity (Proton version)";
      homepage = "https://www.plasticity.xyz/";
      license = licenses.unfree;
      maintainers = with maintainers; [];
      platforms = ["x86_64-linux"];
    };
  }
