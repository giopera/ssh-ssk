# ssh-ssk

## Description
ssh-ssk is a project to keep safe all your ssh configs and keys by grouping them in encrypted container so you can unlock them with a single password and use all the keys in it without having to put a password on every key.

## Usage
This is a tree of the command, between one and another argument may be necessary to add a parameter based on the operation, in that case you can consult the help by pressing Enter on the half completed command.
Also every command can be abbreviated with his initial.
```
script.sh
├── keys
│   ├── generate
│   ├── add
│   ├── remove
│   ├── check
│   └── list
│
├── containers
│   ├── add
│   ├── remove
│   ├── load
│   └── unload
│
└── host
    ├── option
    │   ├── add   
    │   ├── remove
    │   ├── check  
    │   ├── list
    │   └── set
    ├── add
    ├── remove
    ├── check
    └── list
```
