{
  description = "Main Flake";

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs

  # For more information about well-known outputs checked by `nix flake check`:
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake-check.html#evaluation-checks

  inputs = {
    # NixOS official package source, using the nixos-26.05 branch here
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable"; # Rolling Release (Unstable Branch)
    };

    # Disk Partitioning
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs"; # don't pull a second nixpkgs
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs"; # don't pull a second nixpkgs
    };

  };

  outputs =
    { 
      self,
      nixpkgs, # Nix Packages
      disko, # Disk Partitioning
      impermanence, # Impermanence
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
    in
    {

      nixosConfigurations = {
        # This is a function
        nixos = lib.nixosSystem {
          # Keep this the same as your hostname t oavoid having to do (...) --flake /etc/nixos#nixos

          # When fresh installing, it needs this since it doesn't have a hardwareConfigurations file yet
          # system = "x86_64-linux";
          
          # Passing dependencies to submodules - only those that are defined in outputs are visible
          specialArgs = {
            # TODO: integrate Vm specific logic to disko config too, rn it has to be done by hand
            # Switch this when on VM/BareMetal
            vmMode = true;            



            inherit disko impermanence;
          };
          # Alternatively:
          # _module.args = { inherit inputs; };

          # submodules - not strictly hierarchical, but is passed to the same system.
          modules = [
            ./configuration.nix

            # Disko
            ./flakes/disko.nix
          
            # impermanence
            ./flakes/impermanence.nix

          ];
        };
      };
    };
}
