#!/bin/bash

RUN_PATH="."

USERNAME=${CIRCLE_PROJECT_USERNAME}
REPONAME=${CIRCLE_PROJECT_REPONAME}

BRANCH=${CIRCLE_BRANCH:-master}

DOCKER_USER=${DOCKER_USER}
DOCKER_PASS=${DOCKER_PASS}


################################################################################

# command -v tput > /dev/null && TPUT=true
TPUT=

_echo() {
    if [ "${TPUT}" != "" ] && [ "$2" != "" ]; then
        echo -e "$(tput setaf $2)$1$(tput sgr0)"
    else
        echo -e "$1"
    fi
}

_result() {
    echo
    _echo "# $@" 4
}

_command() {
    echo
    _echo "$ $@" 3
}






_docker() {
    echo "helloooooo"

    if [ ! -f ${RUN_PATH}/VERSION ]; then
        _result "not found VERSION"
        return
    fi

    # release version
    MAJOR=$(cat ${RUN_PATH}/VERSION | xargs | cut -d'.' -f1)
    MINOR=$(cat ${RUN_PATH}/VERSION | xargs | cut -d'.' -f2)
    PATCH=$(cat ${RUN_PATH}/VERSION | xargs | cut -d'.' -f3)

    if [ "${PATCH}" != "x" ]; then
        VERSION="${MAJOR}.${MINOR}.${PATCH}"
        printf "${VERSION}" > ${RUN_PATH}/VERSION
    else
        VERSION="${MAJOR}.${MINOR}.${CIRCLE_BUILD_NUM}"
        printf "${VERSION}" > ${RUN_PATH}/VERSION
    fi

    _result "VERSION=${VERSION}"

    _command "docker login -u $DOCKER_USER"
    docker login -u $DOCKER_USER -p $DOCKER_PASS

    _command "docker build -t ${USERNAME}/${REPONAME}:${VERSION} ."
    docker build -f ${PARAM:-Dockerfile} -t ${USERNAME}/${REPONAME}:${VERSION} .

    _command "docker push ${USERNAME}/${REPONAME}:${VERSION}"
    docker push ${USERNAME}/${REPONAME}:${VERSION}

    _command "docker tag ${USERNAME}/${REPONAME}:${VERSION} ${USERNAME}/${REPONAME}:latest"
    docker tag ${USERNAME}/${REPONAME}:${VERSION} ${USERNAME}/${REPONAME}:latest

    _command "docker push ${USERNAME}/${REPONAME}:latest"
    docker push ${USERNAME}/${REPONAME}:latest

    _command "docker logout"
    docker logout
}




################################################################################


_docker
