{ pkgs, lib, ... }:
pkgs.stdenv.mkDerivation {
  name = "blog";
  src = ../private/blog;
  buildPhase = ''
    ${pkgs.hugo}/bin/hugo --minify
  '';
  installPhase = ''
    cp -r public $out
  '';
  meta = with pkgs.lib; {
    description = "Toomoch help blog";
    platforms = platforms.all;
  };
}

