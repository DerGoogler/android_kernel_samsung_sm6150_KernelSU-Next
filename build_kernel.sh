#!/bin/bash

DIR=`readlink -f .`
PARENT_DIR=`readlink -f ${DIR}/..`

ARGS="$*"
DEVICE_MODEL="$1"

JOBS=$(nproc --all)
MAKE_PARAMS="-j$JOBS ARCH=arm64 O=out LLVM=1 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=llvm- CROSS_COMPILE_ARM32=arm-linux-gnueabi-"

devicecheck() {
    if [ "$DEVICE_MODEL" == "a70q" ]; then
        DEVICE_NAME="a70q"
        ZIP_NAME=""$DEVICE_NAME"_KSU-Next_"$(date +%d%m%y)""
        DEFCONFIG=a70q_defconfig
    elif [ "$DEVICE_MODEL" == "a70s" ]; then
        DEVICE_NAME="a70s"
        ZIP_NAME=""$DEVICE_NAME"_KSU-Next_"$(date +%d%m%y)""
        DEFCONFIG=a70q_defconfig
    else
        echo "- Config not found"
        exit
    fi
}

toolchain() {
	CL_DIR="$PARENT_DIR/Prebuilts/los-clang"
	GCC32_DIR="P$ARENT_DIR/Prebuilts/gcc32"
	GCC64_DIR="$PARENT_DIR/Prebuils/gcc64"
	BT_DIR="$PARENT_DIR/Prebuilts/build-tools"
	GAS_DIR="$PARENT_DIR/Prebuilts/gas"

	export PATH=$CL_DIR/bin:$PATH
	export PATH=$GCC32_DIR/bin:$PATH
	export PATH=$GCC64_DIR/bin:$PATH
	export PATH=$BT_DIR/path/linux-x86:$PATH
	export PATH=$GAS_DIR/linux-x86:$PATH
}

anykernel3() {
	if [ -d $PARENT_DIR/AnyKernel3 ]; then
		cd ../AnyKernel3 
		git reset HEAD --hard
		cd $DIR
	else 
	    git clone --branch a70 https://github.com/DerGoogler/AnyKernel3-A70-KSU_Next.git $PARENT_DIR/AnyKernel3
	    cd $DIR
	fi
}

makezipfile() {
    cp out/arch/arm64/boot/Image.gz-dtb $PARENT_DIR/AnyKernel3/
    cd $PARENT_DIR/AnyKernel3
    rm -rf a70*
    zip -r9 $ZIP_NAME . -x '*.git*' '*patch*' '*ramdisk*' 'README.md' '*modules*'
    cd $DIR
}

echo "Starting Building ..."
devicecheck
toolchain
make $MAKE_PARAMS $DEFCONFIG
make $MAKE_PARAMS
anykernel3
makezipfile
