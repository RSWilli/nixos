let
  # this key is used so we do not need root access when rekeying
  willi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTU+w/41oNnBH7Zf9qa5PIREYSzlAwRkdvYpym5BF4j";

  willi-work = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVKaSX/C4MWoEkOr9PeFD9ogc5UZUiwjefl8zF7xdGYUlRcBt/esSsBw5iP+J+dg1OYeENZ00OJaqCiaMjmJKaypslS/S5qAkUBeQHOp6FG6s/3EMG3g+z4h5cjBOSPhYbVNuA4dEs+s6IDhuV0IUwHOS+WPAKHqEy6AeZ9hJh1Q4JGcgwXWRRmxCHJYrzjGD7hEAnNECR8znLJlBo2iZFiaESMen7ADadvO+RJ8jfC/v2teAIFfdLKOj+6pD7Sjhn2peF572LJXis+gozG5+YJse1WHXuP11MC+5zG9oTacTijUSjD710NZojHgIwIhlDbGsEzjaT32nVV9LJxuThA6vy0WW+1403ZR/wMOg4z3FpcnoCI2i9X9GvqRAD7SLz4ONNz4N/V2kRmzuFHxa+wvqyoNjHAAOiaYtSCh0W8NYX7LBoLqwJ4wv+PNHz6w0phpEfRGuayrYr/p+i1v7WlGLrSF0SMdyASQJ2k4fax6Pcrz59ey3RFbQ8+SI59eM=";

  think = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDseXq0mgC/CN9CtgZeduV7MG1h0wzohUS+Cy+hzRMBz";
  main = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDdftcbfr7MVnbjMPzRL1KHfOoYkwnDScyZCJWcSBmN";

  cloud = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtWXfbInoez4N3XF8ec7ZMAl8PUzojSvJxB9tBi+rW7";

  # dell = "TODO";

  private = [willi main cloud think];
  work = [willi-work];

  all = private ++ work;
in {
  "root-password.age".publicKeys = all;

  "password.age".publicKeys = all;

  "mumble-cert.age".publicKeys = all;
  "initrd-ssh-host-key.age".publicKeys = all;

  "willi-id_ed25519.age".publicKeys = all;
  "willi-id_rsa.age".publicKeys = all;
}
