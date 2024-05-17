{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.writeShellScriptBin
    "chatblade"
    ''
      #!/usr/bin/env bash
      export OPENAI_API_KEY=$(cat ${config.age.secrets."OPENAI_API_KEY".path})
      ${pkgs.chatblade}/bin/chatblade $@
    ''
  ];

  age.secrets."OPENAI_API_KEY" = {
    file = ../secrets/OPENAI_API_KEY.age;
  };
}
