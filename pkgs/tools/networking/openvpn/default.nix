{ stdenv, fetchurl, iproute, lzo, openssl, pam, systemd, pkgconfig
, pkcs11Support ? false, pkcs11helper ? null,
}:

assert pkcs11Support -> (pkcs11helper != null);

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "openvpn-${version}";
  version = "2.4.2";

  src = fetchurl {
    url = "http://swupdate.openvpn.net/community/releases/${name}.tar.xz";
    sha256 = "1ydzy5i7yaifz0v1ivrckksvm0nkkx5sia3g5y5b1xkx9cw4yp6z";
  };

  buildInputs = [ lzo openssl pkgconfig ]
                  ++ optionals stdenv.isLinux [ pam systemd iproute ]
                  ++ optional pkcs11Support pkcs11helper;

  configureFlags = optionals stdenv.isLinux [
    "--enable-systemd"
    "--enable-iproute2"
    "IPROUTE=${iproute}/sbin/ip" ]
    ++ optional pkcs11Support "--enable-pkcs11"
    ++ optional stdenv.isDarwin "--disable-plugin-auth-pam";

  postInstall = ''
    mkdir -p $out/share/doc/openvpn/examples
    cp -r sample/sample-config-files/ $out/share/doc/openvpn/examples
    cp -r sample/sample-keys/ $out/share/doc/openvpn/examples
    cp -r sample/sample-scripts/ $out/share/doc/openvpn/examples
  '';

  enableParallelBuilding = true;

  meta = {
    description = "A robust and highly flexible tunneling application";
    homepage = http://openvpn.net/;
    downloadPage = "https://openvpn.net/index.php/open-source/downloads.html";
    license = stdenv.lib.licenses.gpl2;
    maintainers = [ stdenv.lib.maintainers.viric ];
    platforms = stdenv.lib.platforms.unix;
    updateWalker = true;
  };
}
