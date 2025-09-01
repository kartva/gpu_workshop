{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  python = pkgs.python311;
in
pkgs.mkShell {
  buildInputs = [
    python
    python.pkgs.pip
    python.pkgs.virtualenv

    # For building native extensions
    pkgs.gcc
    pkgs.stdenv.cc.cc.lib
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"

    # Create and activate venv if not exists
    if [ ! -d .venv ]; then
      echo "Creating Python virtual environment..."
      python -m venv .venv
      source .venv/bin/activate
      pip install --upgrade pip
      pip install torch triton numpy torchvision matplotlib
    else
      source .venv/bin/activate
    fi

    echo "Triton development environment loaded"
    echo "Python: $(python --version)"
    echo "To install/update Triton: pip install triton"
  '';
}
