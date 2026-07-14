{

  # Swap file set in disko flake

  # ZSwap

  boot.zswap = {
    enable = true;
    acceptThresholdPercent = 90;
    shrinkerEnabled = true;
    maxPoolPercent = 25; # kernel default is 20 but extra 5 should work fror better build performance with nix
    # compressor = zstd; # Default - Let nix choose
    # zpool = zsmalloc; # Let nix choose

  };

}