#!/bin/bash

git_sqlite_path="";
git_get_number_of_logs=10;
git_saperater="@@@";
function git_helper_changePath() {
    git_sqlite_path="$1";
    echo $git_sqlite_path;
}

function git_helper_syncDatabase() {
    echo "TEST";
    git log --pretty=format:"%s$git_saperater%an$git_saperater%H$git_saperater%ae" -n $git_get_number_of_logs > "$1";
}

debugMessage "hi! git helper imported";
