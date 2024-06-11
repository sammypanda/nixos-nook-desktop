# Nook Desktop | Nix Flake
This is a flake to install [Nook Desktop](https://github.com/mn6/nook-desktop) on systems using the Nix package manager.

###### (Only tested on x86_64)

## Usage

Add the following in your flake inputs:

```nix
{
    inputs = {
        # the rest of your inputs here

        nook-desktop = {
            url = "github:sammypanda/nixos-nook-desktop";
            inputs.nixpkgs.follows = "nixpkgs";
        }
    };

    # ...
```

...and in outputs you can overlay and add to system or user packages as ``pkgs.nook-desktop``. Or instead just add to system or user packages without overlaying.

```nix
    # ...

    outputs = { nook-desktop, ... } @ inputs:
    let
        pkgs = import nixpkgs {
            overlays = [self.overlays.default];
        }
    in {
        overlays.default = final: prev: {
            nook-desktop = inputs.nook-desktop.packages.YOURPLATFORM.default;
            # OR 
            # nook-desktop = inputs.nook-desktop.packages."${system}".default;
        }
    }

    # ...
}
```
