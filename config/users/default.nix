{ me, ... }:

{
  users.users.${me.username} = {
    isNormalUser = true;
    description = me.description;
    extraGroups = [
      "networkmanager"
      "wheel"
      "render"
      "input"
      "video"
    ];
  };
}
