#!/bin/bash

function syncSourceCode {
    local directory=$1
    local project=$2
    local branch=$3
    local tag=$4
    echo "[START] sync $directory"
    if [ ! -d "$directory" ]; then
        git clone ssh://${USER_NAME}@amax01:29418/${project} -b ${branch} ${directory}
    elif [ ! -e "${directory}/AndroidManifest.xml" ]; then
        # abnormal status, re-sync project
        echo "[WARN] $directory already exist, but no source code, re-sync project..."
        if [ "${directory}" != "${DIRECTORY_AsusLauncher}" ]; then
            rm -rf ${directory}
            git clone ssh://${USER_NAME}@amax01:29418/${project} -b ${branch} ${directory}
        fi
    else
        # rebase external project
        if [ "${directory}" != "${DIRECTORY_AsusLauncher}" ]; then
            cd ${directory}

            # repository changed, re-sync project
            if [ "$(git config --get remote.origin.url)" != "ssh://${USER_NAME}@amax01:29418/${project}" ]; then
                echo "[WARN] $directory already exist, but repository changed, re-sync project..."
                rm -rf ${directory}
                git clone ssh://${USER_NAME}@amax01:29418/${project} -b ${branch} ${directory}
                if [ -n "${tag}" ]; then
                    git checkout ${tag}
                fi
                cd ..
                return;
            fi

            # checkout build file to HEAD for rebase
            local array=("build.xml" "asus_build.xml" "project.properties" "build.gradle")
            for file in $(git status --porcelain 2>/dev/null| grep "^ M" | cut -d ' ' -f3)
            do
                local found=$(echo ${array[*]} | grep ${file})
                if [ "${found}" != "" ]; then
                    git checkout ${file}
                fi
            done

            # checkout to default if not currently on a branch
            if [ -z "$(git symbolic-ref HEAD 2>/dev/null)" ]; then
                git checkout ${branch}
            fi

            # sync to latest code base
            git pull --rebase

            cd ../
        fi
    fi

    # checkout to target tag
    if [ -d "$directory" ]; then
        cd ${directory}
        if [ -n "${tag}" ]; then
            git checkout ${tag}
        fi
        cd ..
    fi
}

function syncLauncherSourceCode {
    local directory=$1
    local project=$2
    if [ ! -d "$directory" ]; then
        echo "[INFO] Choose you target branch:"
        local branch_options="AsusLauncher_1.4_dev AsusLauncher_1.4_beta AsusLauncher_1.4_play"
		if [ -z "${targetBranch}" ]; then
			select opt in ${branch_options}; do
				if [ "$opt" = "AsusLauncher_1.4_dev" ] || [ "$opt" = "AsusLauncher_1.4_beta" ] || [ "$opt" = "AsusLauncher_1.4_play" ]; then
					echo "[START] sync $directory"
					syncSourceCode ${directory} ${project} ${opt}
					echo "[Success] sync $directory"
					break
				else
					echo bad option
					exit
				fi
			done
		else
		    echo "[INFO] Choose you target branch: ${targetBranch}"
		    echo "[START] sync $directory"
            syncSourceCode ${directory} ${project} ${targetBranch}
            echo "[Success] sync $directory"
		fi;
    else
        echo "[WARN] sync fail, $directory exist"
    fi

    # fix no change id
    if [ -d "$directory" ]; then
        cp ${directory}/scripts/AntBuild/commit-msg ${directory}/.git/hooks/
    fi
}

function checkAndExtractAARfiles {
    local directory=$1
    # aar for ant build and Android Studio
    if ls -d ${directory}/*.aar ;then
        local aar_files=$(ls -d ${directory}/*.aar)
        for aar in ${aar_files}
        do
            local aar_for_studio=$(echo ${aar}|cut -d '.' -f1)/$(echo ${aar}|cut -d '/' -f2)
            if diff ${aar} ${aar_for_studio} >/dev/null ; then
                echo "[Info] $aar and $aar_for_studio same"
                continue;
            else
                echo "[Info] $aar and $aar_for_studio different"
            fi

            local aar_folder=$(echo ${aar}|cut -d '.' -f1)
            # rm assets copyed from unzipped .aar
            local copyed_assets=$(find ${aar_folder}/assets/ -type f | cut -d '/' -f4,5)
            for copyed_asset in ${copyed_assets}
            do
                rm -r ${directory}/assets/${copyed_asset}
                echo ${copyed_asset}
            done
            # remove any file except build.xml asus_build.xml project.projecties pre-load in aar folder
            all_files_in_aar_folder=$(ls ${aar_folder})
            local array=("build.xml" "asus_build.xml" "project.properties" "pre-load" "build.gradle")
            for file in ${all_files_in_aar_folder}
            do
                local found=$(echo ${array[*]} | grep ${file})
                if [ "${found}" != "" ]; then
                    echo "[Info] ignore ${file}"
                else
                    rm -rf ${aar_folder}/${file}
                fi
            done

            #unzip aar files
            find ${aar} -exec sh -c 'unzip -od "${1%.*}" "$1"' _ {} \;

            # move aar resource
            mkdir -p ${aar_folder}/src
            mkdir -p ${aar_folder}/pre-load
            mkdir -p ${aar_folder}/libs
            cp ${aar_folder}/*.jar ${aar_folder}/libs/
            for nativeso in $(ls ${aar_folder}/jni)
            do
                cp -arp ${aar_folder}/jni/${nativeso} ${aar_folder}/libs/
            done
            export INTERNAL_PROJECTS=$(echo ${INTERNAL_PROJECTS} ${aar_folder})
            cp -arp ${aar_folder}/assets/* ${directory}/assets/
            # cp aar for Android Studio
            cp ${aar} ${aar_folder}/
        done
    else
        echo "[Info] Don't have AAR files"
    fi
}

function syncExternalProject {
    local directory=$1

    if [ -d "$directory" ]; then
        local tag_array=$(echo ${CURRENT_EXTERNAL_TAG_LIST} | tr " " "\n")
        source ${directory}/scripts/AntBuild/external/sync.conf
        for dir in $(ls -d ${directory}/scripts/AntBuild/external/*/)
        do
            local dirName=$(echo ${dir}|cut -d '/' -f5)
            local projectName=$(echo ${dirName}|cut -d '_' -f1) # remove version, e.g. _1.0
            eval directory=DIRECTORY_\${projectName}
            eval branch=BRANCH_\${projectName}
            eval project=PROJECT_\${projectName}

            local tag=$(printf -- '%s\n' "${tag_array[@]}" | grep -m 1 -i ${projectName})

            syncSourceCode ${!directory} ${!project} ${!branch} ${tag}
            echo "#########"
        done
    else
        echo "[WARN] sync external project fail, $directory exist"
    fi
}

function setExternalAntConfig {
    local directory=$1
    if [ -d "$directory" ]; then
        for dir in $(ls -d ${directory}/scripts/AntBuild/external/*/)
        do
            local dirName=$(echo ${dir}|cut -d '/' -f5)
            if [ -d "$dirName" ]; then
                cp -r ${directory}/scripts/AntBuild/external/${dirName} .
                echo "[Success] setup external project $dirName ant build config"
            fi
        done
    fi
}

function getExternalTagList {
    local directory=$1

    cd ${directory}
    echo "[Info] Current branch tag is $(git describe --abbrev=0)"
    echo "[Info] Type the tag that you want to check (press [ENTER] to skip, or enter 0 to use current branch tag), followed by [ENTER]:"
    input_tag="0"
    if [ -n "${input_tag}" ]; then
        if [ "${input_tag}" = "0" ]; then
            input_tag=$(git describe --abbrev=0)
        else
            input_tag=${input_tag}
        fi
    else
        cd ..
        return;
    fi
    cd ..
    local launcher_project_name=$(echo ${input_tag} | cut -d '_' -f1)
    local launcher_project_version=$(echo ${input_tag} | cut -d '_' -f2)
    local launcher_version_first=$(echo ${launcher_project_version} | cut -d '.' -f1)
    local launcher_version_second=$(echo ${launcher_project_version} | cut -d '.' -f2)
    local launcher_version_third=$(echo ${launcher_project_version} | cut -d '.' -f3)
    local launcher_version_fourth=$(echo ${launcher_project_version} | cut -d '.' -f4)
    PATH_LAUNCHER_VERSION=$(echo ${launcher_project_name}/${launcher_version_first}.${launcher_version_second}.${launcher_version_third}/${launcher_version_fourth})

    mountApkPool

    if [ -d "${MOUNT_APK_POOL}/${PATH_LAUNCHER_VERSION}" ]; then
        local version_code=$(grep VERSION_CODE ${MOUNT_APK_POOL}/${PATH_LAUNCHER_VERSION}/build_config/build.cfg | cut -d '=' -f2)
        local version_name=$(grep VERSION_NAME ${MOUNT_APK_POOL}/${PATH_LAUNCHER_VERSION}/build_config/build.cfg | cut -d '=' -f2)
        CURRENT_EXTERNAL_TAG_LIST=$(grep EXTERNAL_TAG_LIST ${MOUNT_APK_POOL}/${PATH_LAUNCHER_VERSION}/build_config/build.cfg | cut -d '=' -f2)

        echo "[Info] VERSION_CODE: ${version_code}"
        echo "[Info] VERSION_NAME: ${version_name}"
        echo "[Info] APK PATH in local: ${MOUNT_APK_POOL}/${PATH_LAUNCHER_VERSION}/"
        echo "[Info] APK PATH in remote: ${REMOTE_APK_POOL_PATH}/${PATH_LAUNCHER_VERSION}/"
        echo ""

        if [ -n "${CURRENT_EXTERNAL_TAG_LIST}" ]; then
            echo "[Info] CURRENT_EXTERNAL_TAG_LIST:"
            echo "${CURRENT_EXTERNAL_TAG_LIST}"
            echo "[Info] Enter the external tag that you want to checkout (press [ENTER] to skip all, or enter 0 to apply all tag, enter -1 to gen release note), followed by [ENTER]:"
            external_tag_checkout="0";

            if [ -n "${external_tag_checkout}" ]; then
                if [ "${external_tag_checkout}" = "0" ]; then
                    echo "[Info] apply all tag"
                elif [ "${external_tag_checkout}" = "-1" ]; then
                    release_note ${directory} ${input_tag}
                    exit;
                else
                    CURRENT_EXTERNAL_TAG_LIST=${external_tag_checkout}
                fi
            else
                CURRENT_EXTERNAL_TAG_LIST=""
            fi
        fi

    else
        echo "[WARN] wrong tag"
    fi

}

function mountApkPool {
    # require sudo to mount remote folder
    if ! mount | grep ${MOUNT_APK_POOL} > /dev/null; then
        echo "[Info] Mount APK_POOL require root (only once)"
        sudo mkdir ${MOUNT_APK_POOL}
        if ! dpkg -l | grep cifs-utils > /dev/null; then
            echo "[Info] Install cifs-utils for mount"
            sudo apt-get install cifs-utils
        fi
        sudo mount -t cifs ${REMOTE_APK_POOL_PATH} ${MOUNT_APK_POOL} -o guest
        echo mount | grep ${MOUNT_APK_POOL}
        # remove mount folder
        # sudo umount /mnt/APK_Pool
        # sudo rm /mnt/APK_Pool/ -r
    fi
}

function release_note() {
    local directory=$1
    local current_tag=$2

    cd ${directory}
    echo "[Info] Previous branch tag is $(git describe --abbrev=0 --tags ${current_tag}^)"
    echo "[Info] Type the tag that you want to check (press [ENTER] to use previous branch tag, or enter target tag), followed by [ENTER]:"
    read previous_tag
    if [ -n "${previous_tag}" ]; then
        previous_tag=${previous_tag}
    else
        previous_tag=$(git describe --abbrev=0 --tags ${current_tag}^)

    fi
    cd ..
    local launcher_project_name=$(echo ${previous_tag} | cut -d '_' -f1)
    local launcher_project_version=$(echo ${previous_tag} | cut -d '_' -f2)
    local launcher_version_first=$(echo ${launcher_project_version} | cut -d '.' -f1)
    local launcher_version_second=$(echo ${launcher_project_version} | cut -d '.' -f2)
    local launcher_version_third=$(echo ${launcher_project_version} | cut -d '.' -f3)
    local launcher_version_fourth=$(echo ${launcher_project_version} | cut -d '.' -f4)
    PATH_PREVIOUS_LAUNCHER_VERSION=$(echo ${launcher_project_name}/${launcher_version_first}.${launcher_version_second}.${launcher_version_third}/${launcher_version_fourth})

    mountApkPool

    if [ -d "${MOUNT_APK_POOL}/${PATH_PREVIOUS_LAUNCHER_VERSION}" ]; then
        PREVIOUS_EXTERNAL_TAG_LIST=$(grep EXTERNAL_TAG_LIST ${MOUNT_APK_POOL}/${PATH_PREVIOUS_LAUNCHER_VERSION}/build_config/build.cfg | cut -d '=' -f2)
        echo "[Info] PREVIOUS_EXTERNAL_TAG_LIST:"
        echo "${PREVIOUS_EXTERNAL_TAG_LIST}"
    else
        echo "[WARN] wrong tag"
    fi


    echo "###########################"
    echo "[Info] generate release note"
    echo "#########" > release_note.txt
    local release_note_path=$(readlink -f release_note.txt)
    echo "[Info] ${directory} from ${previous_tag} to ${current_tag}" >> ${release_note_path}
    echo "---------" >> ${release_note_path}

    cd ${directory}
    git log ${previous_tag}..${current_tag} --pretty="%s (%an)" >> ${release_note_path}
    cd ..

    for dir in $(ls -d ${directory}/scripts/AntBuild/external/*/)
    do
        local dirName=$(echo ${dir}|cut -d '/' -f5)
        local projectName=$(echo ${dirName}|cut -d '_' -f1) # remove version, e.g. _1.0

        local tag_array=$(echo ${CURRENT_EXTERNAL_TAG_LIST} | tr " " "\n")
        local previous_tag_array=$(echo ${PREVIOUS_EXTERNAL_TAG_LIST} | tr " " "\n")
        local external_current_tag=$(printf -- '%s\n' "${tag_array[@]}" | grep -m 1 -i ${projectName})
        local external_previous_tag=$(printf -- '%s\n' "${previous_tag_array[@]}" | grep -m 1 -i ${projectName})

        if [ -n "${external_previous_tag}" ] && [ "${external_previous_tag}" != "${external_current_tag}" ]; then
            echo "#########" >> ${release_note_path}
            echo "[Info] ${projectName} from ${external_previous_tag} to ${external_current_tag}" >> ${release_note_path}
            echo "---------" >> ${release_note_path}
            cd ${dirName}
            git log ${external_previous_tag}..${external_current_tag} --pretty="%s (%an)" >> ${release_note_path}
            cd ..
        fi
    done
    echo "[Info] complete! see ${release_note_path}"
    echo "###########################"
}

function readParams() {
	params=${@};
	echo "length of params: ${#params}"
	for param in $params
	do
	    local cmd="$(echo ${param} | sed 's/=.*//')";
		local value="$(echo ${param} | sed 's/.*=//')";
		if [ "$cmd" == "b" -o "$cmd" == "B" ]; then
		    targetBranch="${value}";
		    echo "target bransh: ${targetBranch}";
		fi;
	done
}

targetBranch="";
readParams ${@};

#####################################

echo "###########################"
echo "[Info] version 1.6"

#####################################

USER_NAME=$(git config user.email | cut -d '@' -f1 | awk '{print tolower($0)}')
#if [ ! -z "${1}" ]; then
#    USER_NAME=${1}
#fi
echo "[Info] SSH user is $USER_NAME"
echo "[Info] Customize SSH user in param 1 if connect fail"

if [ -z "$USER_NAME" ]; then
    echo "[FATAL] SSH user is is empty"
    exit
fi
echo "###########################"

#####################################

DIRECTORY_AsusLauncher="AsusLauncher"
PROJECT_AsusLauncher="amax_L/packages/apps/AsusLauncher"

MOUNT_APK_POOL="/mnt/APK_Pool"
REMOTE_APK_POOL_PATH="//10.78.24.10/AMAX-release/APK_Pool"

#####################################
syncLauncherSourceCode ${DIRECTORY_AsusLauncher} ${PROJECT_AsusLauncher}
echo "###########################"
checkAndExtractAARfiles ${DIRECTORY_AsusLauncher}
echo "###########################"
getExternalTagList ${DIRECTORY_AsusLauncher}
echo "###########################"

#set external project
syncExternalProject ${DIRECTORY_AsusLauncher}
echo "###########################"
setExternalAntConfig ${DIRECTORY_AsusLauncher}
echo "###########################"

echo "[Info] Finish deploy AsusLauncher"

