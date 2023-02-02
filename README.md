# Implement-VPN-System-with-Containers
CS-E4000 - Seminar in Computer Science: Implementing a Virtual Private Network System among Containers

## Notes
Run with docker-compose
```bash
docker compose up
docker exec -it client-a2 bash
```

failed to create network implement-vpn-system-with-containers_cloud_network_s: Error response from daemon: Pool overlaps with other one on this address space

https://stackoverflow.com/questions/50959523/i-want-to-create-2-docker-networks-with-same-ip-range

Docker compose uses alphabetical order to determine eth0, eth1, ... https://github.com/docker/compose/issues/8561
