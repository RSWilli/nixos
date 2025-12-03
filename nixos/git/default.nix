{
  config,
  lib,
  ...
}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    prompt.enable = true;

    config = [
      {
        user.name = "RSWilli";
        user.email = "bartel.wilhelm@gmail.com";
        pull.rebase = "true";
        push.followTags = "true";

        alias = {
          pfush = "push origin --force-with-lease";
        };
      }
      {
        # needs to be after the user config, so in a new section
        "includeIf \"gitdir:work/\"".path = "/etc/${config.environment.etc.gitconfig-work.target}";
      }
    ];
  };

  environment.etc.gitconfig-work = let
    workConfig = {
      user.name = "Wilhelm Bartel";
      user.email = "wilhelm.bartel@streamonkey.de";
    };
  in {
    text = lib.generators.toGitINI workConfig;
  };
}
