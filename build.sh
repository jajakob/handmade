# Author: Jakob Jakob

# To make build.sh runable:
#   chmod +x build.sh
# src_dir="${dir_path}/src"
# ext_dir="${dir_path}/ext"
# clang++ -g ${src_dir}/*.cpp -I ${ext_dir}/eigen/ -o ${build_dir}/main

# echo Building Handmade

# TODO: build w\ dbg flags and build w\o

full_path=$(realpath $0) 
dir_path=$(dirname $full_path)

build_dir="${dir_path}/build"
if [ ! -d $build_dir ]; then
    mkdir $build_dir
fi

DB_FLAGS="-g -O0 -Wall -DINTERNAL=1 -DSLOW=1"
RL_FLAGS="-O2 -DNDEBUG"
# FLAGS="-std=c99 -framework AppKit -framework OpenGL"
FLAGS="-std=c99 -framework AppKit -framework Metal -framework Quartzcore"

pushd $build_dir
clang $DB_FLAGS $FLAGS -o handmade ../src/handmade_macos.m
popd