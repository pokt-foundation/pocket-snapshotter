# pocket-snapshotter

## Public snapshots

If you're looking for Pocket native blockchain data snapshots, they are provided by Pocket Foundation and available via the following links:
* Uncompressed tar: `https://snapshot.nodes.pokt.network/latest.tar`
* Compressed tar.gz: `https://snapshot.nodes.pokt.network/latest.tar.gz`

The links are redirects, so if you're using `curl` make sure to add an argument to follow the redirect: `curl -L https://snapshot.nodes.pokt.network/latest.tar > ~/destination.tar`

#### Utilizing uplink CLI to download snapshots

Chances are you'll get better speeds utilizing [uplink CLI](https://docs.storj.io/dcs/downloads/download-uplink-cli/) to download the snapshot. We provide an access key that has necessary permissions. Here is an example that downloads the latest snapshot:

```
uplink cp --access=147A7s3UVY6g4DhxdatsM7QMofNBJJfvcq5w9XuYjU2HrmEbr4JSbRy3NQu3mijqk7T8in1PYEAdcf11dd5yhJ4eDAn4UMppBgqcN49f2tHVcGhRV2McpvyTm4U22uXH35h14JA1YXiGdUFDss7ThTnFnPYY8uRTxmtG2UrdW9LZkmuJysNF1sU8anEGcZnGQuYWViAzVx2VwtYTrYQE5CXPQotB2rnGwFaUY9vVeTCKFC8yiwZLHxhPJdZaexrZPbBTaf1xvmuyarMchkxvbn8K7pLXfw7n2xGArJavvRK86Nj1SrRr5ws9ku9i24WbGddKWz4SNaZgUH63Wm65yK8m91kgeHLDhhhR sj://pocket-public-blockchains/$(curl -s https://snapshot.nodes.pokt.network/latest.tar.gz | rev | cut -d'/' -f1|rev|cut -d'?' -f1) ./destination.tar.gz
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
