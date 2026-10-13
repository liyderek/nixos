default:
    @just --list

rebuild host="":
    ./nix.sh rebuild "{{host}}"

build host="":
    ./nix.sh build "{{host}}"

check:
    ./nix.sh check

upgrade host="":
    ./nix.sh upgrade "{{host}}"

work host="":
    ./nix.sh work "{{host}}"

update input="" host="":
    ./nix.sh update "{{host}}" "{{input}}"

clean *args:
    ./nix.sh clean {{args}}

edit:
    ./nix.sh edit
