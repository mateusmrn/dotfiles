{ pkgs, ... }:
{
  home.username = "mateus";
  home.homeDirectory = "/home/mateus";
  home.stateVersion = "26.05";

  home.packages = [ ];

  programs.home-manager.enable = true;
}
