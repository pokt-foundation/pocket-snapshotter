#!/usr/bin/env bash
set -e

export $(grep -v '^#' .env | xargs)

# POCKET_NODE_HTTP_URL="${POCKET_NODE_HTTP_URL:-http://localhost:8080/v1}"
POCKET_NODE_DOCKER_CONTAINER_NAME="${POCKET_NODE_DOCKER_CONTAINER_NAME:-"peer1"}"
POCKET_NODE_DATA_DIR="${POCKET_NODE_DATA_DIR:-"/data/peer1"}"
POCKET_SNAPSHOT_PATH="${POCKET_SNAPSHOT_PATH:-"/data/pocket-data-snapshot.tar"}"
POCKET_SNAPSHOT_HASHES_PATH="${POCKET_SNAPSHOT_HASHES_PATH:-"/data/pocket-data-snapshot-hashes.txt"}"
UPLINK_WRITE="${UPLINK_WRITE:-""}"
API_GATEWAY_ID="${API_GATEWAY_ID:-"nwu2m3bz8h"}"
API_GATEWAY_LATEST_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar`].id | [0]')
API_GATEWAY_LATEST_MD5_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar/md5`].id | [0]')
API_GATEWAY_LATEST_SHA1_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar/sha1`].id | [0]')
API_GATEWAY_LATEST_GZ_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar.gz`].id | [0]')
API_GATEWAY_LATEST_GZ_MD5_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar.gz/md5`].id | [0]')
API_GATEWAY_LATEST_GZ_SHA1_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" --output text --query 'items[?path==`/latest.tar.gz/sha1`].id | [0]')

check_cli_tools_installed() {
    for p in pigz uplink rhash aws; do
        hash "$p" &>/dev/null && echo "$p is installed" ||
            (echo "$p is not installed" && exit 1)
    done
}

# get_node_version() {
# }

datetime_tar_name=$(date +"pocket-network-data-%H%d.tar")

# Check dependencies
check_cli_tools_installed

# Delete old archives if they exist
rm "$POCKET_SNAPSHOT_PATH" "$POCKET_SNAPSHOT_PATH".gz || true

# ? check if up-to-date?

# Stop docker container
echo "Stopping $POCKET_NODE_DOCKER_CONTAINER_NAME"
docker stop "$POCKET_NODE_DOCKER_CONTAINER_NAME"

# ? verify the DB is freed up?

# create tar
echo "Creating new $POCKET_SNAPSHOT_PATH from $POCKET_NODE_DATA_DIR"

sudo tar cfv "$POCKET_SNAPSHOT_PATH" --directory="$POCKET_NODE_DATA_DIR" .

# Start docker container
echo "Starting $POCKET_NODE_DOCKER_CONTAINER_NAME"
docker start "$POCKET_NODE_DOCKER_CONTAINER_NAME"

# gzip tar with pigz
echo "Creating a compressed versiom of $POCKET_SNAPSHOT_PATH"
sudo nice -n 5 pigz -k "$POCKET_SNAPSHOT_PATH"

# calculate hashes
echo "Calculating the hashes..."
rhash -MH "$POCKET_SNAPSHOT_PATH"* > "$POCKET_SNAPSHOT_HASHES_PATH"

# upload tar, tar.gz

echo "Uploading $POCKET_SNAPSHOT_PATH to sj://pocket-public-blockchains/$datetime_tar_name"
uplink --access "$UPLINK_WRITE" cp "$POCKET_SNAPSHOT_PATH" "sj://pocket-public-blockchains/$datetime_tar_name" --parallelism 5
echo "Uploading $POCKET_SNAPSHOT_PATH to sj://pocket-public-blockchains/$datetime_tar_name.gz"
uplink --access "$UPLINK_WRITE" cp "${POCKET_SNAPSHOT_PATH}.gz" "sj://pocket-public-blockchains/$datetime_tar_name.gz" --parallelism 5

# get sharable links
tar_link=$(uplink share --url "sj://pocket-public-blockchains/$datetime_tar_name")
tgz_link=$(uplink share --url "sj://pocket-public-blockchains/$datetime_tar_name.gz")
echo "New sharable links generated: $tar_link, $tgz_link"

# update API gateway mock integrations
# latest tar
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_RESOURCE_ID" --http-method GET --status-code 302 --patch-operations op='replace',path='/responseParameters/method.response.header.Location',value=\'"${tar_link}"\' --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'"Redirecting to ${tar_link}"\'
# latest tar md5
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_MD5_RESOURCE_ID" --http-method GET --status-code 200 --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'"latest_md5 - todo cat pocket-data-snapshot-hashes.txt | grep '.tar ' | awk print \$2 "\'
# latest tar sha1
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_SHA1_RESOURCE_ID" --http-method GET --status-code 200 --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'"latest_sha1 - todo cat pocket-data-snapshot-hashes.txt | grep '.tar ' | awk print \$3 "\'

# latest tar.gz
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_GZ_RESOURCE_ID" --http-method GET --status-code 302 --patch-operations op='replace',path='/responseParameters/method.response.header.Location',value=\'"${tgz_link}"\' --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'"Redirecting to ${tgz_link}"\'
# latest tar.gz md5
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_GZ_MD5_RESOURCE_ID" --http-method GET --status-code 200 --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'"latest_md5 - todo cat pocket-data-snapshot-hashes.txt | grep '.tar.gz ' | awk print \$2 "\'
# latest tar.gz sha1
aws apigateway update-integration-response --rest-api-id "$API_GATEWAY_ID" --resource-id "$API_GATEWAY_LATEST_GZ_SHA1_RESOURCE_ID" --http-method GET --status-code 200 --patch-operations op='replace',path='/responseTemplates/text~1plain',value=\'"latest_sha1 - todo cat pocket-data-snapshot-hashes.txt | grep '.tar.gz ' | awk print \$3 "\'

# deploy api gateway
aws apigateway create-deployment --rest-api-id "$API_GATEWAY_ID" --stage-name prod