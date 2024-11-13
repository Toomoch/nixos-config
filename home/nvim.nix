{ lib, pkgs, config, inputs, ... }:
let
  shellaliases = {
    vim = "nvim";
    vimdiff = "nvim -d";
  };
  vim-minizinc = pkgs.vimUtils.buildVimPlugin {
    name = "vim-minizinc";
    src = pkgs.fetchFromGitHub {
      owner = "vale1410";
      repo = "vim-minizinc";
      rev = "83ac0d6b8ceab3417b43925a99894c0423e3c492";
      hash = "sha256-PLMeTZVn/17yC77qH7EiXguYUtENclrV+gWB95Kbsz0=";
    };
  };
in {
  home.packages = with pkgs; [
    ripgrep
    bitbake-language-server
    inputs.self.outputs.packages.${system}.nvim
  ];

  programs.bash.shellAliases = shellaliases;
  programs.zsh.shellAliases = shellaliases;
  home.sessionVariables = { EDITOR = "nvim"; };

}
