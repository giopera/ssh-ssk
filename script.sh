#!/bin/bash

is_absolute_path() {
    case "$1" in
        /*) return 0 ;;
        *) return 1 ;;
    esac
}

process_path() {
    path=$1
    if is_absolute_path "$path"; then
        result_process_path="$path"
    else
        result_process_path="$(pwd)/$path"
    fi
}

containers_file="$HOME/.ssh/containers"
loaded_file="$HOME/.ssh/loaded_configs"
containers_dir="$HOME/.local/share/ssh-crypt/containers/"
container_dir=""
key_file=""

print_help() {
    echo "Usage: "
    echo "ssh-crypt OBJECT { COMMAND | help }"
    echo ""
    echo "OBJECT"
    echo "  key           Manage, add and remove keys in a container"
    echo "  container     Manage, create, remove and load ssh containers"
    echo "  host          Manage hosts in configurations"
}

print_help_k3(){
    echo "Usage: "
    echo "ssh-crypt key <container> { COMMAND | help }"
    echo ""
    echo "COMMAND"
    echo "  generate      Generate a key in a container"
    echo "  add           Add a key to a container from existing file"
    echo "  remove        Remove a key from a container"
    echo "  check         Check if a key exists in the container"
    echo "  list          Print a list of all the keys in a container"
}

check_key(){
    if [ ! -f "$1" ]; then
        echo "File does not exist."
        exit 1
    fi

    # Check if the file is a valid SSH private key
    key_type=$(file "$1")

    if [[ $key_type == *"RSA"* || $key_type == *"DSA"* || $key_type == *"EC"* || $key_type == *"OPENSSH"* || $key_type == *"private"* ]]; then
        key_file="$1"
    fi


}

if [ -z "$1" ]; then
    print_help
    exit 1
fi

case $1 in
    "k"*) # Key
        if [ -z "$2" ]; then
            print_help_k3
            exit 1
        fi

        if grep -q "$2" "$containers_file"; then
            if grep -q "$2" "$loaded_file"; then
                container_dir="$containers_dir/$2"
                case $3 in
                    g*) # Generate
                        ssh-keygen -f "$container_dir/$4"
                        ;;
                    a*) # Add
                        process_path "$4"
                        check_key "$result_process_path"
                        cp "$key_file" "$container_dir"
                        ;;
                    r*) # Remove
                        ;;
                    c*) # Check
                        ;;
                    l*) # List
                        find "$container_dir" -type f -name "*.pub" -exec basename {} \; | sed 's/\.pub$//'
                        ;;
                    *)
                        print_help_k3
                esac
            else
                echo "The container $2 is not loaded"
                exit 1
            fi
        else
            echo "There is no container called $2"
            exit 1
        fi
    ;;
    "c"*)
    ;;
    "h"*)
    ;;

esac
