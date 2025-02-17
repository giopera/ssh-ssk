#!/bin/bash
# script.sh
# ├── keys
# │   ├── generate
# │   ├── add
# │   ├── remove
# │   ├── check
# │   └── list
# │
# ├── containers
# │   ├── add
# │   ├── remove
# │   ├── load
# │   └── unload
# │
# └── host
#     ├── option
#     │   ├── add   
#     │   ├── remove
#     │   ├── check  
#     │   ├── list
#     │   └── set
#     ├── add
#     ├── remove
#     ├── check
#     └── list
#
#

print_help() {
    echo "Usage: "
    echo "ssh-crypt OBJECT { COMMAND | help }"
    echo ""
    echo "OBJECT"
    echo "  key           Manage, add and remove keys in a container"
    echo "  container     Manage, create, remove and load ssh containers"
    echo "  host          Manage hosts in configurations"
    echo ""
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
    echo ""
}

containers_file="$HOME/.ssh/containers"
loaded_file="$HOME/.ssh/loaded_configs"
containers_dir="$HOME/.local/share/ssh-crypt/containers/"
container_dir=""
key_file=""

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

if ! [ -e "$containers_file" ] ; then
    touch "$containers_file"
fi

if ! [ -e "$loaded_file" ] ; then
    touch "$loaded_file"
fi

if [ -z "$1" ]; then
    print_help
    exit 1
fi

case $1 in
    k | key) # Key
        if [ -z "$2" ]; then
            print_help_k3
            exit 1
        fi

        if grep -q "$2" "$containers_file"; then
            if grep -q "$2" "$loaded_file"; then
                container_dir="$containers_dir/$2"
                case $3 in
                    g | generate) # Generate
                        ssh-keygen -f "$container_dir/$4"
                        exit 0
                        ;;
                    a | add) # Add
                        process_path "$4"
                        check_key "$result_process_path"
                        if [ -n "$key_file" ]; then
                            cp "$key_file" "$container_dir"
                            ssh-keygen -f "$container_dir/$key_file" -y > "$container_dir/$key_file.pub"
                            exit 0
                        else
                            echo "The key is not a valid key"
                            exit 1
                        fi
                        ;;
                    r | remove) # Remove
                        process_path "$4"
                        check_key "$result_process_path"
                        if [ -n "$key_file" ]; then
                            rm "$key_file"
                            exit 0
                        else
                            echo "The key is not a valid key"
                            exit 1
                        fi
                        ;;
                    c | check) # Check
                        process_path "$4"
                        check_key "$result_process_path"
                        if [ -n "$key_file" ]; then
                            echo "The key exists"
                            exit 0
                        else
                            echo "The key doesn't exist"
                            exit 1
                        fi
                        ;;
                    l | list) # List
                        find "$container_dir" -type f -name "*.pub" -exec basename {} \; | sed 's/\.pub$//'
                        exit 1
                        ;;
                    *)
                        print_help_k3
                        exit 0
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
    c | container)
        case "$3" in
            a | add) # Add
                if grep -q "$2" "$containers_file"; then
                    echo "There is already a container called like this"
                else
                    echo "$2" >> "$containers_file"
                fi
                ;;
        esac

        if grep -q "$2" "$containers_file"; then
            case "$3" in
                r | remove) # Remove
                    sed -i "/$2/d" "$containers_file"
                    ;;
                l | load) # Load
                    echo "$2" >> "$loaded_file"
                    ;;
            esac
            if grep -q "$2" "$loaded_file"; then
                case "$3" in
                    u | unload) # Unload
                        sed -i "/$2/d" "$loaded_file"
                        ;;
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
    h | host)
        case "$3" in
            o | option)
                case "$5" in
                    a | add)
                        ;;
                    r | remove)
                        ;;
                    c | check)
                        ;;
                    l | list)
                        ;;
                    s | set)
                        ;;
                esac
                ;;
            a | add)
                ;;
            r | remove)
                ;;
            c | check)
                ;;
            l | list)
                ;;
        esac

    esac
