{ lib
, acl
, autoreconfHook
, dbus
, fetchFromGitHub
, fetchpatch
, flatpak
, fuse3
, systemdMinimal
, geoclue2
, glib
, gsettings-desktop-schemas
, json-glib
, libportal
, libxml2
, nixosTests
, pipewire
, gdk-pixbuf
, librsvg
, python3
, pkg-config
, stdenv
, substituteAll
, wrapGAppsHook
, enableGeoLocation ? true
}:

stdenv.mkDerivation rec {
  pname = "xdg-desktop-portal";
  version = "1.14.4";

  outputs = [ "out" "installedTests" ];

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = pname;
    rev = version;
    sha256 = "///X0inMi9Znuhjn9n0HlVLa5/kFWpKorKS8RY9WeYM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    libxml2
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    acl
    dbus
    flatpak
    fuse3
    systemdMinimal # libsystemd
    glib
    gsettings-desktop-schemas
    json-glib
    libportal
    pipewire

    # For icon validator
    gdk-pixbuf
    librsvg

    # For document-fuse installed test.
    (python3.withPackages (pp: with pp; [
      pygobject3
    ]))
  ] ++ lib.optionals enableGeoLocation [
    geoclue2
  ];

  configureFlags = [
    "--enable-installed-tests"
  ] ++ lib.optionals (!enableGeoLocation) [
    "--disable-geoclue"
  ];

  makeFlags = [
    "installed_testdir=${placeholder "installedTests"}/libexec/installed-tests/xdg-desktop-portal"
    "installed_test_metadir=${placeholder "installedTests"}/share/installed-tests/xdg-desktop-portal"
  ];

  passthru = {
    tests = {
      installedTests = nixosTests.installed-tests.xdg-desktop-portal;
    };
  };

  meta = with lib; {
    description = "Desktop integration portals for sandboxed apps";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
