#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 https://github.com/kdrag0n/proton-clang clang
git clone --depth=1 https://github.com/dndxtz/AnyKernel3 AnyKernel
echo "Done"
tanggal=$(TZ=Asia/Jakarta date "+%Y%m%d-%H%M")
ZIP_NAME="SeraphineKernel-Rolex-${tanggal}.zip"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
chat_id=-1001944300223
export PATH="${PWD}/clang/bin:$PATH"
export ARCH=arm64
export KBUILD_BUILD_HOST=DESKTOP-ET3IKPU
export KBUILD_BUILD_USER=idkser
# sticker plox
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot6498090143:AAHLOptNjpQDQsdy1kRdGdCTRRKr-zaGa94/sendSticker" \
        -d sticker="CAACAgEAAxkBAAEnKnJfZOFzBnwC3cPwiirjZdgTMBMLRAACugEAAkVfBy-aN927wS5blhsE" \
        -d chat_id=$chat_id
}
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot6498090143:AAHLOptNjpQDQsdy1kRdGdCTRRKr-zaGa94/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• IdkSer Kernel •</b>%0ABuild started on <code>Circle CI</code>%0AFor device <b>Xiaomi Redmi 4A</b> (Rolex)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>${KBUILD_COMPILER_STRING}</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b>#Stable"
}
# Push kernel to channel
function push() {
    cd AnyKernel
    curl -F document=@$ZIP_NAME "https://api.telegram.org/bot6498090143:AAHLOptNjpQDQsdy1kRdGdCTRRKr-zaGa94/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
	-F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot6498090143:AAHLOptNjpQDQsdy1kRdGdCTRRKr-zaGa94/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}
# Compile plox
function compile() {
    make O=out ARCH=arm64 rolex_defconfig
    make -j$(nproc --all) O=out \
                    ARCH=arm64 \
                    CC=clang \
                    CROSS_COMPILE=aarch64-linux-gnu- \
		    CROSS_COMPILE_ARM32=arm-linux-gnueabi-

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 $ZIP_NAME *
    cd ..
}
sticker
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
