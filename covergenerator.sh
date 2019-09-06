#!/bin/bash

checkdeps() {
    local deps

    deps="awk crc32 sed optipng"
    unameOut="$(uname -s)"
    url="your system package manager"
    imagemagick="/c/library/ImageMagick"
    [ ! -d "$imagemagick" ] && deps="awk crc32 sed optipng imagemagick"
    case "${unameOut}" in
    CYGWIN* | MINGW*)
        OS=Windows
        ;;
    esac

    for dep in $deps; do

        if [ -z "$(command -v "$dep")" ]; then
            echo "############################################################################################"
            echo "#"
            echo "#  Dependency     : $dep"
            echo "#  Description    : Fatal: the required dependency \"$dep\" is missing."
            echo "#"
            echo "#  !!! Please install \"$dep\" on your system. !!!"
            echo "#"
            if [ $OS = "Windows" ]; then
                path="C:\Program Files\Git\usr\bin"

                case "$dep" in
                crc32)
                    # if [ "$OS" = "Windows" ]; then
                    url="http://esrg.sourceforge.net/utils_win_up/md5sum/crc32.exe"

                    # fi
                    ;;
                optipng)
                    # if [ "$OS" = "Windows" ]; then
                    url="http://prdownloads.sourceforge.net/optipng/optipng-0.7.7-win32.zip?download"
                    # fi
                    ;;
                imagemagick)
                    url="https://imagemagick.org/download/binaries/ImageMagick-7.0.8-63-portable-Q16-x86.zip"
                    path="C:\library\ImageMagick"
                    ;;
                esac

            fi
            echo "#  Get it at \"$url\""
            if [ "$OS" = "Windows" ]; then
                echo "#  And copy it to \"$path\""
            fi
            echo "#"
            echo "############################################################################################"
            exit 1
        fi

    done

}

rename() {
    if [ -f "$1" ]; then
        echo "Renaming '$1' to '$2' "
        mv "$1" "$2"
    fi

}

remove() {
    [ -f "$1" ] && rm -rf "$1"
}

help() {
    echo ""
    echo "Usage:
   sh $(basename "$0") files | [options]..."
    echo ""
    echo "Files:
   Rom files of type: \"*.nes\", \"*.snes\", \"*.gb\", \"*.gbc\", \"*.sms\", \"*.gen\", \"*.gg\""
    echo ""
    echo "Options:
   -?, -h, -help			This information screen
   *.md                Convert Mega Drive roms \"*.md\" to nds compatible roms \"*.gen\"
   -png               Optimize png files"
    echo ""
    echo "Examples:
   sh $(basename "$0") nes        Rename matching title \"png\" files to the rom CRC
   sh $(basename "$0") -?         Display help info
   sh $(basename "$0") -png       Compress \"png\" files"
    echo ""
    exit 1
}

checkdeps

if [ $# -lt 1 ]; then
    help
fi

for rom in "$@"; do
    fullromtitle=$(basename -- "$rom")
    title="${fullromtitle%.*}"
    tid=$(crc32 "$rom")

    if [ $OS = "Windows" ]; then
        tid=$(crc32 "$rom" | sed -e 's/^0x\(.\{8\}\).*/\1/')
    fi

    case $rom in
    *.snes | *.gbc | *.nes | *.gb | *.sms | *.gen | *.gg)

        if [ -f "$title.png" ]; then
            rename "$title.png" "$tid.png"
            remove "$fullromtitle"
        fi
        # exit 1

        ;;
    *.md)

        rename "$rom" "$title.gen"
        exit 1

        ;;
    replace)

        find . -type f -name "*_*.png" -print0 | while IFS= read -r -d '' file; do
            if [ -f "$file" ]; then
                echo "#  Renaming '$file'"
                mv "$file" "$(echo $file | sed "s/\_/\&/g")"
            fi
        done
        exit 1
        ;;
    png)
        [ ! -d "optimized" ] && mkdir -p optimized
        for cover in *.png; do
            optipng -o7 -quiet -keep -preserve -dir optimized "$cover"
        done
        exit 1
        ;;
    resize | -r)
        echo "############################################################################################"
        echo "#"
        for boxart in *.png; do

            if [ $OS = "Windows" ]; then
                ndssize=$($imagemagick/identify -format "%wx%h" "$boxart")
                resizer=$($imagemagick/convert "$boxart" -resize 128x115! "$boxart")
            else
                ndssize=$(identify -format "%wx%h" "$boxart")
                resizer=$(convert "$boxart" -resize 128x115! "$boxart")
            fi
            if [ "$ndssize" != "128x115" ]; then
                echo "#  Resizing $boxart"
                $resizer
            fi

        done
        echo "#"
        echo "############################################################################################"
        exit 1
        ;;
    '-?' | -h | -help)
        help
        ;;
    esac
done
