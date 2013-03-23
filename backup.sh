#!/bin/sh

project_name="misery"

current_path=$(pwd)

# example: ${project_name}_2013_03_22__08_30
archive_name=$(date +${project_name}_%Y_%m_%d__%H_%M)

cp -r . ../${archive_name}
cd ..
tar -cf ${archive_name}.tar ${archive_name}
# rm -rf ${archive_name}
cd ${current_path}
