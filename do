#!/usr/bin/env bash

# Exit on failure
set -e

if [ -e .env ]
  then
    source .env
fi

# Allow overriding the docker compose command. This can be useful when we need to use a docker compose configuration
# file other than the default.
if [ -z "$DOCKER_COMPOSE_COMMAND" ]
  then
    DOCKER_COMPOSE_COMMAND="docker compose"
fi

# This docker compose service is used when running commands
if [ -z "$RUN_DOCKER_SERVICE" ]
  then
    RUN_DOCKER_SERVICE="rails"
fi

export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

if [ $# -eq 0 ] || [ $1 = "help" ]
  then
    echo "do - a helper script for performing common tasks"
    echo
    echo "Usage"
    echo "  ./do <build|b>         build docker images"
    echo "  ./do <up|u>            start all or a specified docker compose services"
    echo "  ./do <stop|s>          stop all or a specified docker compose service"
    echo "  ./do <restart|rs>      restart all or a specified docker compose service"
    echo "  ./do <down|d>          stop and discard all docker compose services and networks"
    echo "  ./do <logs|l>          display the logs for all or a specified docker compose service"
    echo "  ./do <run|r>           run the specified console command in the primary docker service"
    echo "  ./do <console|c>       start a bash console in the primary docker service"
    echo "  ./do <rails|rr>        run the bin/rails binary with the given arguments"
    echo "  ./do <rake|rk>         run the bin/rake binary with the given arguments"
    echo "  ./do cs                run the rake coding standards task"
    echo "  ./do cs:fix            run the rake coding standards fix task"
    echo "  ./do <test|t>          run the unit and integration test suite"
    echo "  ./do <test:system|ts>  run the system test suite"
    echo "  ./do vr:baseline       set the visual regression baseline using the current set of snapshots"
    echo "  ./do vr:diff           compare the current set of snapshots to the baseline"
    echo "  ./do vr:heatmap        perform simulated eye tracking analysis on the current set of snapshots"
    echo "  ./do <heroku|h>        run the heroku CLI with the given arguments"
    echo "  ./do stopall           kill all docker containers running on the system"
    exit 1
fi


if [ $1 = "build" ] || [ $1 = "b" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND build ${@:2}"
    $DOCKER_COMPOSE_COMMAND build ${@:2}
    exit 0
fi

if [ $1 = "up" ] || [ $1 = "u" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND up -d --remove-orphans ${@:2}"
    $DOCKER_COMPOSE_COMMAND up -d --remove-orphans ${@:2}
    exit 0
fi

if [ $1 = "stop" ] || [ $1 = "s" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND stop ${@:2}"
    $DOCKER_COMPOSE_COMMAND stop ${@:2}
    exit 0
fi

if [ $1 = "restart" ] || [ $1 = "rs" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND restart ${@:2}"
    $DOCKER_COMPOSE_COMMAND restart ${@:2}
    exit 0
fi

if [ $1 = "down" ] || [ $1 = "d" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND down ${@:2}"
    $DOCKER_COMPOSE_COMMAND down ${@:2}
    exit 0
fi

if [ $1 = "run" ] || [ $1 = "r" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE ${@:2}"
    $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE ${@:2}
    exit 0
fi

if [ $1 = "console" ] || [ $1 = "c" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND run --rm -it $RUN_DOCKER_SERVICE ${@:2}"
    $DOCKER_COMPOSE_COMMAND run --rm -it $RUN_DOCKER_SERVICE ${@:2}
    exit 0
fi

if [ $1 = "runon" ] || [ $1 = "ro" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND exec $2 ${@:3}"
    $DOCKER_COMPOSE_COMMAND exec $2 ${@:3}
    exit 0
fi

if [ $1 = "rails" ] || [ $1 = "rr" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rails ${@:2}"
    $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rails ${@:2}
    exit 0
fi

if [ $1 = "rake" ] || [ $1 = "rk" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rake ${@:2}"
    $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rake ${@:2}
    exit 0
fi

if [ $1 = "cs" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rake standard ${@:2}"
    $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rake standard ${@:2}
    exit 0
fi

if [ $1 = "cs:fix" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rake standard:fix ${@:2}"
    $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rake standard:fix ${@:2}
    exit 0
fi

if [ $1 = "test" ] || [ $1 = "t" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rails test ${@:2}"
    $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rails test ${@:2}
    exit 0
fi

if [ $1 = "test:system" ] || [ $1 = "ts" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rails test:system ${@:2}"
    $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE bin/rails test:system ${@:2}
    exit 0
fi

if [ $1 = "heroku" ] || [ $1 = "h" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE heroku ${@:2}"
    $DOCKER_COMPOSE_COMMAND exec $RUN_DOCKER_SERVICE heroku ${@:2}
    exit 0
fi

if [ $1 = "log" ] || [ $1 = "logs" ] || [ $1 = "l" ]
  then
    echo "Running command: $DOCKER_COMPOSE_COMMAND logs ${@:2}"
    $DOCKER_COMPOSE_COMMAND logs ${@:2}
    exit 0
fi

if [ $1 = "stopall" ] || [ $1 = "s!" ]
  then
    echo "Running command: docker stop \${docker ps -q}"
    docker stop $(docker ps -q)
    exit 0
fi

if [ $1 = "stopallandup" ] || [ $1 = "su!" ]
  then
    ./do s!
    ./do u
    exit 0
fi

if [ $1 = "vr:baseline" ]
  then
    ./do ro image_processing python baseline.py
    exit 0
fi

if [ $1 = "vr:diff" ]
  then
    ./do ro image_processing python diff.py
    exit 0
fi

if [ $1 = "vr:heatmap" ]
  then
    ./do ro image_processing python simulated_eye_tracking.py
    exit 0
fi

echo "Running command: $DOCKER_COMPOSE_COMMAND ${@:1}"
$DOCKER_COMPOSE_COMMAND ${@:1}
