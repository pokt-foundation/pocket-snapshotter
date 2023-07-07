# pocket-snapshotter

# ⚠️ DEPRECATED ⚠️

Please follow the instructions in [this document](https://github.com/pokt-network/pocket-core/blob/staging/doc/guides/snapshot.md) instead.



## Public snapshots

If you're looking for Pocket native blockchain data snapshots, they are provided by Pocket Foundation and available via the following links:
* Uncompressed tar: `https://snapshot.nodes.pokt.network/latest.tar`
* Compressed tar.gz: `https://snapshot.nodes.pokt.network/latest.tar.gz`

The links are redirects, so if you're using `curl` make sure to add an argument to follow the redirect: `curl -L https://snapshot.nodes.pokt.network/latest.tar > ~/destination.tar`

#### Utilizing uplink CLI to download snapshots

Chances are you'll get better speeds utilizing [uplink CLI](https://docs.storj.io/dcs/downloads/download-uplink-cli/) to download the snapshot. We provide an access key that has necessary permissions. Here is an example that downloads the latest snapshot:

```
uplink cp --access=1mg7uwv6EQNyvgCxAuXBb19BZAMne2T5Qkzc5LsahbpERiXviMvENvBKN5yTf85BRRBcetZ4NWaiBri9UyvVHFBN4vaaLTRJ5AJnWfThvqkS18ftS4hyZLJ1AGaoJpdVUp6uS7zsoHXr5E22J1cN5mj2kchajtNKK7fRB6Jq5Q6cmDd5aFS1n8y9AbG6RjJFpAcdXTssmDqqYmYcTfUs89C2SBBCHTvUyScLA3hUtFLa1Cp16okDZUzwh4miPgPjr5JboR3DJby15TAvKmFttNf9Vya5sTTtya6KnrAqtwTkbPE16Eo6VjtoWwbvgT3S2FmQw3h6LNzrT3QbXaiXzK18B49S5UXSH3RbXT2xvgTFA6pbv sj://pocket-public-blockchains-main/v0-snapshots/$(curl -s https://snapshot.nodes.pokt.network/latest.tar.gz | rev | cut -d'/' -f1|rev|cut -d'?' -f1) ./destination.tar.gz
```

## Purpose
The script stops a pocket node container, creates the snapshot, turns on the node back, uploads the archive to StorJ, updates the permament link to point to the latest snapshot.

## Dependencies

### Software

* `apt-get update`
* `apt-get install pigz rhash awscli`
* install [uplink - storj CLI](https://docs.storj.io/dcs/downloads/download-uplink-cli/)

### Permissions
* AWS keys (populated via environment variable) or instance profile with permissions to read and update API Gateway Resources/Integrations.
* StorJ access token with permissions to write to the bucket.

## Configuration

Due to the nature of the script, the following configuration is necesary:

| Environment Variable                | Description                                                       |
| ----------------------------------- | ----------------------------------------------------------------- |
| `POCKET_NODE_DOCKER_CONTAINER_NAME` | Docker container of pocket node to start/stop                     |
| `POCKET_NODE_DATA_DIR`              | Full path to the directory of the pocket node                     |
| `POCKET_SNAPSHOT_PATH`              | Full path of an uncompressed archive                              |
| `POCKET_SNAPSHOT_HASHES_PATH`       | Full path of compressed archive                                   |
| `UPLINK_WRITE`                      | Storj access token that has permissions to upload the archive     |
| `API_GATEWAY_ID`                    | API Gateway ID (should be prvisioned by terraform from this repo) |
