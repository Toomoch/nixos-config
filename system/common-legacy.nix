{pkgs, ...}:
{
  fonts.fonts = with pkgs; [
    rubik
    fira-code
    fira-code-symbols
    font-awesome
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk
    noto-fonts-emoji
  ];
}