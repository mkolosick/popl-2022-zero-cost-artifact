sudo apt-get update
sudo apt-get install -y curl ca-certificates cmake clang llvm nasm unzip m4 python3 git
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh && sh -- rustup.sh -y
source $HOME/.cargo/env

mkdir -p /opt
curl -L https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-10/wasi-sdk-10.0-linux.tar.gz | \
sudo tar x -zv -C /opt -f - wasi-sdk-10.0/share && \
  sudo ln -s /opt/wasi-sdk-*/share/wasi-sysroot /opt/wasi-sysroot

cargo install cargo-wasi

rustup target add wasm32-wasi

git clone https://github.com/PLSysSec/veriwasm.git
pushd veriwasm
git checkout docker
make bootstrap
cargo build --release
make build_fuzzers
make build_public_data
popd

echo 'alias lucetc4G="./lucet_sandbox_compiler/target/release/lucetc --bindings ./lucet_sandbox_compiler/lucet-wasi/bindings.json --guard-size \"4GiB\" --min-reserved-size \"4GiB\" --max-reserved-size \"4GiB\" "' >> .bashrc

echo 'alias wasiclang="./veriwasm_fuzzing/wasi-sdk-10.0/bin/clang --sysroot ./veriwasm_fuzzing/wasi-sdk-10.0/share/wasi-sysroot -Wl,--export-all --std=c99 -Ofast -Wall -W"' >> .bashrc
