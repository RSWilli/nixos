{...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    prompt.enable = true;

    config = {
      user.name = "RSWilli";
      user.email = "bartel.wilhelm@gmail.com";
      pull.rebase = "true";
      push.followTags = "true";

      alias = {
        pfush = "push origin --force-with-lease";
      };
    };
  };
}
