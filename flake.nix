{
  description = "A Ruby dev environment for Casa Development";

  nixConfig = {
    extra-substituters = "https://nixpkgs-ruby.cachix.org";
    extra-trusted-public-keys =
      "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM=";
  };

  inputs = {
    nixpkgs.url = "nixpkgs";
    ruby-nix = {
      url = "github:inscapist/ruby-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bundix = {
      url = "github:inscapist/bundix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fu.url = "github:numtide/flake-utils";
    bob-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fu, ruby-nix, bundix, bob-ruby }:
    with fu.lib;
    eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ bob-ruby.overlays.default ];
        };
        rubyNix = ruby-nix.lib pkgs;

        gemset =
          if builtins.pathExists ./gemset.nix then import ./gemset.nix else { };

        gemConfig = { };
        # See available versions here: https://github.com/bobvanderlinden/nixpkgs-ruby/blob/master/ruby/versions.json
        ruby = pkgs."ruby-3.2.4";

        bundixcli = bundix.packages.${system}.default;
      in rec {
        inherit (rubyNix {
          inherit gemset ruby;
          name = "ruby-env-casa";
          gemConfig = pkgs.defaultGemConfig // gemConfig;
        })
          env;

        devShells = rec {
          default = dev;
          dev = pkgs.mkShell {
            BUNDLE_FORCE_RUBY_PLATFORM = "true";
            shellHook = ''
              export PS1='\n\[\033[1;34m\][💎:\w]\$\[\033[0m\] '

              # Setup postgres database
              export PGHOST=$HOME/postgres
              export PGDATA=$PGHOST/data
              export PGDATABASE=postgres
              export PGLOG=$PGHOST/postgres.log

              mkdir -p $PGHOST

              if [ ! -d $PGDATA ]; then
                initdb --auth=trust --no-locale --encoding=UTF8
              fi

              if ! pg_ctl status
              then
                pg_ctl start -l $PGLOG -o "--unix_socket_directories='$PGHOST'"
              fi

              trap 'pg_ctl stop -D "$PGDATA" -s -m fast' EXIT
            '';

            buildInputs = [
              env
              bundixcli
              pkgs.bundix
              pkgs.bundler-audit
              pkgs.direnv
              pkgs.git
              pkgs.gnumake
              pkgs.libpcap
              pkgs.libpqxx
              pkgs.libxml2
              pkgs.libxslt
              pkgs.nodejs-18_x
              pkgs.pkg-config
              pkgs.postgresql
              pkgs.sqlite
              pkgs.yarn
            ];
          };
        };
      });
}
