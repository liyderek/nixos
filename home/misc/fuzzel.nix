{ ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:weight=bold:size=14";
        line-height = 25;
        fields = "name,generic,comment,categories,filename,keywords";
        terminal = "kitty";
        prompt = "' ➜  '";
        icon-theme = "Papirus-Dark";
        layer = "top";
        lines = 10;
        width = 35;
        horizontal-pad = 25;
        inner-pad = 5;
      };
      colors = {
        background = "282828ff";
        text = "ebdbb2ff";
        match = "b16286ff";
        selection = "d79921ff";
        selection-match = "b16286ff";
        selection-text = "fabd2fff";
        border = "d79921ff";
      };
      border = {
        radius = 0;
        width = 1;
      };
    };
  };
}
