#!/bin/bash

cat << EOF > ${spl_pkgbuild_path}/spl.install
post_install() {
    check_hostid
    run_depmod
}

post_remove() {
    run_depmod
}

post_upgrade() {
    check_hostid
    run_depmod
}

check_hostid() {
    # Check /etc/hostid to see if it set to the sentinel value, see
    # https://wiki.archlinux.org/index.php/ZFS for more information.
    HOSTID=\$(hostid)
    if [ "0x\${HOSTID}" == "0xffffffff" ]; then
        # Generate a new hostid
        : >/etc/hostid
        HOSTID=\$(hostid)
        # hostid is 4 byte little endian
        printf \$(echo -n \$HOSTID | sed 's/\(..\)\(..\)\(..\)\(..\)/\\x\4\\x\3\\x\2\\x\1/') >/etc/hostid
    fi
}

run_depmod() {
    echo ">>> Updating SPL module dependencies"
    depmod -a ${kernel_mod_path}
}
EOF
