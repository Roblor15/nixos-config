{ lib, config, pkgs, ... }:

/* lib.mkIf (config.specialisation) */ {
	services.swayidle = {
		enable = true;
		events = [
			{
				event = "before-sleep";
				command = "swaylock -f -C ~/.config/swaylock/swaylock";
			}
		];
		timeouts = [
			{
				timeout = 3 * 60;
				command = "systemctl suspend";
			}
		];
	};
}
