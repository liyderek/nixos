{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Enable sound with pipewire.
    pulseaudio.enable = false;

    bluetooth.settings = {
      Policy = {
        ReconnectAttempts = 0;
      };
    };
  };
}
