{
  xdg.configFile."hypr/hyprland.lua".source = ../hypr/hyprland.lua;
  xdg.configFile."hypr/scripts".source = ../hypr/scripts;

  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ../hypr/hyprlock.conf;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = {
        monitor = "";
        path = "/home/mateus/Pictures/wallpapers/a_ship_in_the_water.jpg";
        fit_mode = "cover";
      };
    };
  };
}
