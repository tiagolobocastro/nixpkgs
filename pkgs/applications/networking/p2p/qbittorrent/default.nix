{ stdenv, fetchurl, pkgconfig, which
, boost, libtorrentRasterbar, qtbase, qttools, qtsvg
, debugSupport ? false # Debugging
, guiSupport ? true, dbus_libs ? null # GUI (disable to run headless)
, webuiSupport ? true # WebUI
}:

assert guiSupport -> (dbus_libs != null);
with stdenv.lib;

stdenv.mkDerivation rec {
  name = "qbittorrent-${version}";
  version = "4.1.0";

  src = fetchurl {
    url = "mirror://sourceforge/qbittorrent/${name}.tar.xz";
    sha256 = "0fdr74sc31x421sb69vlgal1hxpccjxxk8hrrzz9f5bg4jv895pw";
  };

  nativeBuildInputs = [ pkgconfig which ];

  buildInputs = [ boost libtorrentRasterbar qtbase qttools qtsvg ]
    ++ optional guiSupport dbus_libs;

  # Otherwise qm_gen.pri assumes lrelease-qt5, which does not exist.
  QMAKE_LRELEASE = "lrelease";

  configureFlags = [
    "--with-boost-libdir=${boost.out}/lib"
    "--with-boost=${boost.dev}"
    (if guiSupport then "" else "--disable-gui")
    (if webuiSupport then "" else "--disable-webui")
  ] ++ optional debugSupport "--enable-debug";

  enableParallelBuilding = true;

  meta = {
    description = "Free Software alternative to µtorrent";
    homepage    = https://www.qbittorrent.org/;
    license     = licenses.gpl2;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ viric ];
  };
}
