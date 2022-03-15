#!/bin/bash

arg_category=''
while [[ $# -gt 0 ]]
do
    case $1 in
        nginx)
            arg_domain="$2"
            shift 2
            ;;
        --pass|-p)
            arg_pass="$2"
            shift 2
            ;;
        --tls)
            arg_tls="true"
            shift
            ;;
        --cert)
            arg_pass="$2"
            shift 2
            ;;
        --cert-key)
            arg_pass="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

echo $@
source ./test2.sh