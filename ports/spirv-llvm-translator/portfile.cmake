vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-LLVM-Translator
    REF "v${VERSION}"
    SHA512 fff2224f63926819e29d5f2daa54015b486497f131ecf4b563cfde75a594812a5c395b67971022be13de42d7429db1fc747c725c15978894baa3a62013d98777
    HEAD_REF main
    PATCHES
        cmake-config.patch
        spirv-tools-dis.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        spirv-tools LLVM_SPIRV_ENABLE_LIBSPIRV_DIS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLLVM_SPIRV_BUILD_EXTERNAL=ON
        -DLLVM_SPIRV_INCLUDE_TESTS=OFF
        "-DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=${CURRENT_INSTALLED_DIR}"
        -DCCACHE_ALLOWED=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME LLVMSPIRVLib CONFIG_PATH lib/cmake/LLVMSPIRVLib)

vcpkg_copy_tools(TOOL_NAMES llvm-spirv AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Some sources are licensed under Apache-2.0 (WITH LLVM-exception); include their license headers.
set(license_files "${SOURCE_PATH}/LICENSE.TXT")
foreach(source IN ITEMS
    lib/SPIRV/LLVMBitreverse.h
    lib/SPIRV/SPIRVLowerLLVMIntrinsic.cpp
    lib/SPIRV/libSPIRV/SPIRVFnVar.cpp
    lib/SPIRV/libSPIRV/SPIRVLLVMUtil.h
)
    file(READ "${SOURCE_PATH}/${source}" content)
    string(REGEX MATCH "^(//[^\n]*\n)+" header "${content}")
    get_filename_component(name "${source}" NAME)
    file(WRITE "${CURRENT_BUILDTREES_DIR}/${name}" "${header}")
    list(APPEND license_files "${CURRENT_BUILDTREES_DIR}/${name}")
endforeach()
vcpkg_install_copyright(FILE_LIST ${license_files})
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
