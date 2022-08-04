# A nix flake for Dana

## Usage

### As a flake input

``` nix
{
    description = "Your flake";

    inputs.dana.url = "github:simmsb/dana-nix";

    outputs = { self, nixpkgs, dana }: ...
}
```

### Install into your profile

`nix profile install github:simmsb/dana-nix`
