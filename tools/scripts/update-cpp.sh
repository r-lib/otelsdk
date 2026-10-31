#! /bin/bash

# Needs an opentelemetry-cpp checkout next to otelsdk, with the
# nlohmann-json and opentelemetry-proto submodules:
# git submodule update --init third_party/nlohmann-json third_party/opentelemetry-proto

cd src/vendor
rm -rf cpp cpp-old
tar xzf opentelemetry-cpp.tgz
git rm opentelemetry-cpp.tgz
mv cpp cpp-old
mkdir cpp

CPP=../../../opentelemetry-cpp

cp ${CPP}/CMakeLists.txt cpp/
cp ${CPP}/CMakeSettings.json cpp/

cp -r ${CPP}/cmake cpp/

mkdir -p cpp/exporters
cp ${CPP}/exporters/CMakeLists.txt cpp/exporters/
cp -r ${CPP}/exporters/ostream cpp/exporters/
cp -r ${CPP}/exporters/memory cpp/exporters/
cp -r ${CPP}/exporters/otlp cpp/exporters/

cp -r ${CPP}/ext cpp/

mkdir -p cpp/third_party
cp ${CPP}/third_party/BUILD cpp/third_party/
cp -r ${CPP}/third_party/nlohmann-json cpp/third_party/
rm cpp/third_party/nlohmann-json/CITATION.cff
# keep the .git files of the submodules, otherwise cmake downloads them
rm -rf cpp/third_party/nlohmann-json/tests
rm -rf cpp/third_party/nlohmann-json/tools
rm -rf cpp/third_party/nlohmann-json/.github
cp -r ${CPP}/third_party/opentelemetry-proto cpp/third_party/
rm -rf cpp/third_party/opentelemetry-proto/.github
rm -rf cpp/third_party/opentelemetry-proto/.agents
rm -rf cpp/third_party/opentelemetry-proto/.bcr
rm -rf cpp/third_party/opentelemetry-proto/.vscode

mkdir -p cpp/sdk/include
cp -r ${CPP}/sdk/include/opentelemetry cpp/sdk/include/
cp -r ${CPP}/sdk/src cpp/sdk/
cp -r ${CPP}/sdk/CMakeLists.txt cpp/sdk/

cp -r ${CPP}/api cpp/

find cpp -name test -type d | xargs rm -rf
find cpp -name docs -type d | xargs rm -rf

# Patch at update time, so we don't need `patch` at install time
patch -p0 < ../../tools/scripts/opentelemetry-cpp.patch

echo 'Check cpp and then run'
echo 'tar czf opentelemetry-cpp.tgz --options gzip:compression-level=9 --no-xattrs cpp'
