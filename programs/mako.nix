{ ... }:

{
  home.file.".config/mako/config".text = ''
    max-history=5
    sort=-time

    on-button-left=invoke-default-action
    on-button-right=dismiss

    # General
    icons=1
    markup=1
    actions=1
    width=300
    height=200
    invisible=0
    group-by=none
    format=%s\n%b
    layer=overlay
    border-size=4
    max-visible=10
    margin=2,2,2,2
    outer-margin=15
    max-icon-size=42
    anchor=top-right
    border-radius=7
    ignore-timeout=0
    text-alignment=right
    default-timeout=0
    font=CaskaydiaCove Nerd Font 11
    icon-path=/usr/share/icons/hicolor

    # Colors

    background-color=#35141DDD
    text-color=#FEEAE2
    border-color=#FCA035
    progress-color=over #313244

    # Per-mode settings

    [mode=do-not-disturb]
    invisible=1
    on-notify=none

    [mode=silent]
    on-notify=none

    [urgency=high]
    border-color=#EA5B23

    [category=notification-sync]
    anchor=bottom-right
  '';
}
