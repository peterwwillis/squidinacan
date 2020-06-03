#!/bin/sh
set -e

# Default 'sudo' command/path
[ "${SUDO:-}" ] || SUDO=sudo

_usage () {
    cat <<EOUSAGE
$0: Error: $1: invalid command '$2'
$0: Usage: $0 $1 COMMAND

$0: Commands:
$0:    enable
$0:    disable
EOUSAGE
    return 1
}

_cmd_ip_forward () {

    case "$1" in
        enable)
            cat <<EOF | $SUDO sysctl -p -
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.accept_source_route = 0
EOF
            ;;
        disable)
            cat <<EOF | $SUDO sysctl -p -
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
EOF
            ;;
        *)
            _usage "ip-forward" "$1"
            ;;
    esac

}

_cmd_iptables_redirect () {

    case "$1" in
        enable)
            $SUDO iptables -t nat -I OUTPUT 1 -p tcp --dport 80 -j DNAT --to-destination 127.0.0.1:3129
            ;;
        disable)
            $SUDO iptables -t nat -D OUTPUT -p tcp --dport 80 -j DNAT --to-destination 127.0.0.1:3129
            ;;
        *)
            _usage "iptables-redirect" "$1"
            ;;
    esac

}

case "$1" in
    ip-forward)
        _cmd_ip_forward "$2"
        ;;
    iptables-redirect)
        _cmd_iptables_redirect "$2"
        ;;
    *)
        cat << EOERR
$0: Error: invalid command '$1'. Valid commands:
$0:    ip-forward
$0:    iptables-redirect
EOERR
        false
        ;;
esac

exit $?
