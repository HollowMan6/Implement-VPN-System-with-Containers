# Implementing a Virtual Private Network System among Containers
My seminar paper for CS-E4000 - Seminar in Computer Science

## Demo
Run with docker compose:
```bash
cd src/gateway-to-gateway
docker compose up
docker exec -it client-a1 bash
docker exec -it client-b2 bash
```

## Some notes
1. failed to create network implement-vpn-system-with-containers_cloud_network_s: Error response from daemon: Pool overlaps with other one on this address space: https://stackoverflow.com/questions/50959523/i-want-to-create-2-docker-networks-with-same-ip-range
2. Docker compose uses alphabetical order to determine eth0, eth1, ...: https://github.com/docker/compose/issues/8561
