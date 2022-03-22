#!/usr/bin/env bash
set -e

export $(grep -v '^#' .env | xargs)

check_cli_tools_installed() {
    for p in pigz uplink rhash aws; do
        hash "$p" &>/dev/null && echo "$p is installed" ||
            (echo "$p is not installed" && exit 1)
    done
}

# get_node_version() {
# }

# POCKET_NODE_HTTP_URL="${POCKET_NODE_HTTP_URL:-http://localhost:8080/v1}"
POCKET_NODE_DOCKER_CONTAINER_NAME="${POCKET_NODE_DOCKER_CONTAINER_NAME:-"peer1"}"
POCKET_NODE_DATA_DIR="${POCKET_NODE_DATA_DIR:-"/data/peer1"}"
POCKET_SNAPSHOT_PATH="${POCKET_SNAPSHOT_PATH:-"/data/pocket-data-snapshot.tar"}"
POCKET_SNAPSHOT_HASHES_PATH="${POCKET_SNAPSHOT_HASHES_PATH:-"/data/pocket-data-snapshot-hashes.txt"}"
UPLINK_WRITE="${UPLINK_WRITE:-""}"
API_GATEWAY_ID="${API_GATEWAY_ID:-"nwu2m3bz8h"}"


# Check dependencies
check_cli_tools_installed

API_GATEWAY_LATEST_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar`].id | [0]')
API_GATEWAY_LATEST_MD5_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar/md5`].id | [0]')
API_GATEWAY_LATEST_SHA1_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar/sha1`].id | [0]')
API_GATEWAY_LATEST_GZ_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar.gz`].id | [0]')
API_GATEWAY_LATEST_GZ_MD5_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar.gz/md5`].id | [0]')
API_GATEWAY_LATEST_GZ_SHA1_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar.gz/sha1`].id | [0]')

datetime_tar_name=$(date +"pocket-network-data-%H%d.tar")


# Delete old archives if they exist
sudo rm -f "$POCKET_SNAPSHOT_PATH" "$POCKET_SNAPSHOT_PATH".gz

# ? check if up-to-date?

# Stop docker container
echo "Stopping $POCKET_NODE_DOCKER_CONTAINER_NAME"
docker stop "$POCKET_NODE_DOCKER_CONTAINER_NAME"

# ? verify the DB is freed up?

# create tar
echo "Creating new $POCKET_SNAPSHOT_PATH from $POCKET_NODE_DATA_DIR"

sudo tar cf "$POCKET_SNAPSHOT_PATH" --directory="$POCKET_NODE_DATA_DIR" .

# Start docker container
echo "Starting $POCKET_NODE_DOCKER_CONTAINER_NAME"
docker start "$POCKET_NODE_DOCKER_CONTAINER_NAME"

# gzip tar with pigz
echo "Creating a compressed version of $POCKET_SNAPSHOT_PATH"
sudo nice -n 5 pigz -k "$POCKET_SNAPSHOT_PATH"

# calculate hashes
echo "Calculating the hashes..."
rhash -MH "$POCKET_SNAPSHOT_PATH"* | sudo tee "$POCKET_SNAPSHOT_HASHES_PATH"

# upload tar, tar.gz

echo "Uploading $POCKET_SNAPSHOT_PATH to sj://pocket-public-blockchains/$datetime_tar_name"
uplink cp --access "$UPLINK_WRITE" "$POCKET_SNAPSHOT_PATH" "sj://pocket-public-blockchains/$datetime_tar_name" --parallelism 5 --progress false
echo "Uploading $POCKET_SNAPSHOT_PATH to sj://pocket-public-blockchains/$datetime_tar_name.gz"
uplink cp --access "$UPLINK_WRITE" "${POCKET_SNAPSHOT_PATH}.gz" "sj://pocket-public-blockchains/$datetime_tar_name.gz" --parallelism 5 --progress false

# get sharable links
tar_link=$(uplink share --url --access "$UPLINK_WRITE" "sj://pocket-public-blockchains/$datetime_tar_name" |  grep "URL  " | awk  '{print $3}')
tgz_link=$(uplink share --url --access "$UPLINK_WRITE" "sj://pocket-public-blockchains/$datetime_tar_name.gz" |  grep "URL  " | awk  '{print $3}')
echo "New sharable links generated: $tar_link, $tgz_link"

# update API gateway mock integrations
# latest tar
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_RESOURCE_ID" --http-method GET --status-code 302 --patch-operations op='replace',path='/responseParameters/method.response.header.location',value='"'"'${tar_link}?download=1'"'"' op='replace',path='/responseTemplates/text~1plain',value=\'"Redirecting to ${tar_link}?download=1"\'
# latest tar md5
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_MD5_RESOURCE_ID" --http-method GET --status-code 200 --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'$(cat /data/pocket-data-snapshot-hashes.txt | grep '.tar ' | awk '{print $2}')\'
# latest tar sha1
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_SHA1_RESOURCE_ID" --http-method GET --status-code 200 --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'$(cat /data/pocket-data-snapshot-hashes.txt | grep '.tar ' | awk '{print $3}')\'

# latest tar.gz
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_GZ_RESOURCE_ID" --http-method GET --status-code 302 --patch-operations op='replace',path='/responseParameters/method.response.header.location',value='"'"'${tgz_link}?download=1'"'"' op='replace',path='/responseTemplates/text~1plain',value=\'"Redirecting to ${tgz_link}?download=1"\'
# latest tar.gz md5
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_GZ_MD5_RESOURCE_ID" --http-method GET --status-code 200 --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'$(cat /data/pocket-data-snapshot-hashes.txt | grep '.tar.gz ' | awk '{print $2}')\'
# latest tar.gz sha1
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_GZ_SHA1_RESOURCE_ID" --http-method GET --status-code 200 --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'$(cat /data/pocket-data-snapshot-hashes.txt | grep '.tar.gz ' | awk '{print $3}')\'

# deploy api gateway
aws apigateway create-deployment --rest-api-id "$API_GATEWAY_ID" --stage-name main