#!/bin/bash
set -e # Stop on first error
set -u # Stop when using uninitialized variables
#set -x # Print each command

function print_man {
echo
echo Usage
echo ====================================================================================
echo ./$(basename $0) [CMD] [OPTS]
echo
echo [CMD] : [backup\|restore] 
echo         backup:  Backs up docker volume into compressed tar file
echo         restore: Restores a compressed tar file to a Docker volume
echo
echo backup [OPTS]  
echo    -c,--container CONTAINER_ID     Docker container ID which volumes to be backed up
echo    -o,--outputpath OUTPUT_PATH     Output path of the backup tar file
echo
echo restore [OPTS]  
echo    -i,--inputpath INPUT_PATH       Full input path of the backup tar file
echo    -v,--volume VOLUME_NAME         Docker container ID which volumes to be restored
echo
}

function check_arg_exists {
    if [ -z "$2" ] ;
    then
        echo Argument missing: "$1" 
        ABORT=1
    fi
}


function parse_opts {
    set +u

    DRY_RUN=0
    while [ ! -z "$1" ]; do
    case "$1" in
        --container|-c)
            shift
            CONTAINER_ID="$1"
            ;;
        --outputpath|-o)
            shift
            OUTPUT_PATH="$1"
            ;;
        --inputpath|-i)
            shift
            INPUT_PATH="$1"
            ;;
        --volume|-v)
            shift
            VOLUME="$1"
            ;;
        --dry-run|-n)
            DRY_RUN=1
            ;;
        *)
            echo Unknown option "$1"
            ;;
    esac
    shift
    done

    set -u
}

function backup_container_volumes {

    echo "Executing Backup"
    echo
    # Check the required args are provided
    parse_opts "$@"
    set +u
    ABORT=0
    check_arg_exists "-c,--container CONTAINER_ID" $CONTAINER_ID 
    check_arg_exists "-o,--outputpath OUTPUT_PATH" $OUTPUT_PATH 
    if [ "$ABORT" -eq 1 ];
    then
        print_man
        exit 0
    fi
    set -u

    #Execute backup

    BACKUP_VOLS="$(docker inspect \
    --format='{{range $p, $conf := .Mounts}}tar czf /backup/docker.'${CONTAINER_ID}'.volume.{{$conf.Name}}.tar.gz {{$conf.Destination}} && {{end}}' ${CONTAINER_ID}) echo Done"

    MY_EXE="docker run --rm --volumes-from ${CONTAINER_ID} \
            -v ${OUTPUT_PATH}:/backup \
            alpine:latest \
            sh -c \"${BACKUP_VOLS}\" \
            "

    if [ $DRY_RUN -eq 1 ];
    then
        echo $MY_EXE
    else
        #set +x
        eval $MY_EXE
    fi

    exit 0
    docker run --rm --volumes-from $CONTAINER_ID \
        -v "$OUTPUT_PATH":/backup \
        alpine:latest \
        sh -c "$BACKUP_VOLS echo Done"

}

# Determine the main command
if [ -z "$1" ];
then
    print_man;
    exit 0;
fi

CMD="$1"
shift 

case "$CMD" in
        backup)
            backup_container_volumes "$@"
            ;;
        restore)
            ;;
        *)
            echo Unknown command: "$CMD"
            print_man
            ;;
esac

exit 0




