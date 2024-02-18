{ pkgs, lib, ... }:

{
    ultrawide_name = "LG Electronics LG ULTRAWIDE 0x0000BFCD";
    monitor_workspace = begin: end: monitor:
    let
      size = end - begin + 1;
    in
      lib.lists.imap1 (i: v: "${pkgs.sway}/bin/swaymsg workspace ${toString (i + begin - 1)}, move workspace to output \'\"${monitor}\"\'") (lib.lists.replicate size "");
}
