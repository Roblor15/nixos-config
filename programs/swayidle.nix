{ lib, config, pkgs, ... }:

/* lib.mkIf (config.specialisation) */ {
	services.swayidle = {
		enable = true;
    # systemdTarget = "hyprland-session.target";
		events = [
			{
				event = "before-sleep";
				command = "swaylock -f -C ~/.config/swaylock/swaylock";
			}
		];
		timeouts = [
			{
				timeout = 10;
				command = "systemctl suspend";
			}
		];
	};
}
