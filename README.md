# Docker Volume Archiver

A bash script to backup and restore docker volumes for archiving purpose.


## Usage
```
$> ./docker-volume-archiver.sh [CMD] [OPTS]
```
**[CMD] : [backup|restore]**
backup: Backs up docker volume into compressed tar file
restore: Restores a compressed tar file to a Docker volume

- backup [OPTS]

`-c,--container CONTAINER_ID` Docker container ID which volumes to be backed up
`-o,--outputpath OUTPUT_PATH` Output path of the backup tar file

- restore [OPTS]

`-i,--inputpath INPUT_PATH` Full input path of the backup tar file
`-v,--volume VOLUME_NAME` Docker container ID which volumes to be restored
