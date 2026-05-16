{ pkgs, lib, ... }:
{
  imports = [ ./packages.nix ];

  home.stateVersion = "26.05";

  home.sessionVariables = {
    EDITOR = "neovim";
  };

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  xdg.configFile."opencode/agents".source = ../programs/opencode/agents;
  xdg.configFile."opencode/skills".source = ../programs/opencode/skills;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.tmux = import ../programs/tmux.nix {
    inherit pkgs;
  };

  programs.alacritty = import ../programs/alacritty.nix {
    inherit pkgs;
  };

  programs.zsh = import ../programs/zsh.nix {
    inherit pkgs;
  };

  programs.neovim = import ../programs/neovim.nix {
    inherit pkgs;
  };

  programs.starship = {
    enable = true;

    settings = {
      aws = {
        disabled = true;
      };
      battery = {
        disabled = true;
      };
      gcloud = {
        disabled = true;
      };
    };
  };
}
