# How to fix the permissions issue

1. There's a UID and GUID mismatch between the host machine and the containers. In OCI, userid 1001 launches the service and owns the directories mounted to the containers.
2. The jupyter contaienr by default starts with the user jovyan with id 1000, to fix this we need to assign Id of the host machine user to jovyan which seems to fix all the issues in Ubuntu.
3. Better solutions exists which can be applied later, this can be used as a quick fix