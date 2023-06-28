#!/usr/bin/env bash

#
# TODO: what bothers me with this script is the subdomain part. This is not as
# good as it should be
#

info() { echo "(~) $@" 1>&2; }

cmd_in_parallel() {
    local pids=()
    for cmd in "$@"; do
        $cmd &
        pids+=($!)
    done
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

banner() {
    info "Treasuremap - V0"
}

waybackurls_cmd() {
    info "Running waybackurls..."
    cat tmp_url_file.txt | waybackurls > waybackurls.txt
    info "waybackurls done"
}

gau_cmd() {
    info "Running gau..."
    cat tmp_url_file.txt | gau --threads 8 > gau.txt
    info "gau done"
}

cariddi_cmd() {
    info "Running cariddi..."
    cat tmp_url_file.txt  | cariddi -e -s -ext 2 -plain -cache -intensive -err -info -ot cariddi
    info "cariddi done"
}

xurlfind_cmd() {
    info "Running xurlfind3r..."
    xurlfind3r --include-subdomains -d $1 -v silent -o xurlfind3r.txt
    info "xurlfind3r done"
}

kurl_cmd() {
    info "Running kurl..."
    kurl some.txt -p 16 -o kurl.txt
    info "kurl done"
}

main() {
    URL="$1"
    banner

    mkdir "out_$1"
    cd "out_$1"

    echo "$1" > tmp_url_file.txt



    #xurlfind_cmd "$URL"
    gau_cmd "$URL"
    waybackurls_cmd "$URL"
    #cariddi_cmd "$URL"
    #cmd_in_parallel gau_cmd waybackurls_cmd xurlfind_cmd cariddi_cmd

    cat waybackurls.txt gau.txt | sort | uniq > all.txt
    #cat waybackurls.txt gau.txt ./output-cariddi/cariddi.results.txt | sort | uniq > all.txt
    #cat xurlfind3r.txt waybackurls.txt gau.txt ./output-cariddi/cariddi.results.txt | sort | uniq > all.txt
    cat all.txt | uro > some.txt

    kurl_cmd
}

install() {
    go install github.com/tomnomnom/waybackurls@latest
    pip3 install uro
    go install github.com/edoardottt/cariddi/cmd/cariddi@latest
    go install github.com/jaeles-project/gospider@latest
    go install github.com/lc/gau/v2/cmd/gau@latest
#    go install github.com/hueristiq/xurlfind3r/cmd/xurlfind3r@latest

}

if [ -z "$1" ]; then
    echo "Usage: $0 install,file [URL]"
    exit 1
elif [ "$1" == "install" ]; then
    install
else
    main $1
fi

