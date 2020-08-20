#!/bin/bash

function display_usage {
	echo "Script for moving a tagged docker image from one repository to another repository;"
	echo "including all the architecture images."
	echo "Prerequisites: "
	echo " - docker (experimental features enabled); for creating manifests"
	echo " - jq; for parsing json"
	echo
	echo "Syntax: ./run.sh <source repository/image:tag> <destination repository/image>"
	echo
}

if [  $# -le 1 ];then
	display_usage
	exit 1
fi

if [[ ( $# == "--help") ||  $# == "-h" ]];then
	display_usage
	exit 1
fi

srcImageTag=$1
destImage=${2%%:*}
srcImage=${srcImageTag%%:*}
img_names=""
manifestArray=$(docker manifest inspect ${srcImageTag} | jq -c '.manifests[] | {digest: .digest, os: .platform.os, arch: .platform.architecture, variant: .platform.variant}')

for t in ${manifestArray[@]}; do
	digest=$(echo $t | jq -r '.digest')
	os=$(echo $t | jq -r '.os')
	arch=$(echo $t | jq -r '.arch')
	variant=$(echo $t | jq -r '.variant')

	imageSHA="${srcImageTag}@${digest}"
	newImageSha="${destImage}:${os}-${arch}"
	if [ "$variant" != 'null' ];then
		newImageSha="${newImageSha}-${variant}"
	fi

	imgNames+=" ${newImageSha}"

	# # 1. docker pull
	docker pull $imageSHA

	# 2. docker tag
	docker tag ${imageSHA} ${newImageSha}

	# 3. docker push
	docker push ${newImageSha}

	# 4. docker rmi
	imgIds=$(docker images --filter=reference="${srcImage}" --format "{{.ID}}")
	if [[ -n ${imgIds} ]];then
		docker rmi -f $imgIds
	fi
done

if [[ -n ${imgNames} ]];then
	docker manifest create "${destImage}:latest" ${imgNames}
	# Use the following line for docker hub
	docker manifest push "${destImage}:latest"
	# Use the following line for a private repository
	# docker manifest push --insecure "${destImage}:latest"
else
	echo "No images available"
fi
