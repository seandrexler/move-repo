# move-repo
Bash script for moving a container between repositories.

**Prerequisites**
* Docker CLI with experimental features enabled
* [jq](https://stedolan.github.io/jq/) - command-line JSON processor

**Running**
The script requires the user to provide a source container and a destination container. If no tag is provided with the source container it will grab the default tag _(latest)_ from the repository. Any tag provided with the destination container will be ignored and the destination container will be tagged with _latest_.
```sh
# Example Call
./run.sh alpine:3.12.0 my-org/alpine-copy
```
