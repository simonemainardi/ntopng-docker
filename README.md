# ntopng-docker
Dockerfile and entrypoint aimed at running ntopng within a docker container.

An entrypoint allows you to choose the behavior of the container. By default,
containers are run by an unprivileged `ntopng` user that is in the sudoers.

## malware-traffic-analysis
This behavior is meant to analyze and process pcap files from `http://malware-traffic-analysis.net/`.
When the docker container is run with `malware-traffic-analysis` as first argument
it tries to download zipped pcap files present in the URL specified ad second argument.
Zipped pcap files are then decompressed and a bash shell is left to the user that can
run ntopng on the downloaded pcaps.

## shell
When the docker container is run with `shell` as first argument it executes the
container and gives the user a bash promt that can be used to perform any action
within the container.

# Usage

## Build Docker Image
```
/home/simone/ntopng-docker# docker build -t ntopng-docker -f Dockerfile.ntopng .
```

## Run Docker container
### malware-traffic-analysis
pcap analysis doesn't need host interfaces access. Mapping a port suffices.

```
docker  run -p 3000:3000 -it ntopng-docker malware-traffic-analysis http://malware-traffic-analysis.net/2016/09/06
docker  run -p 3000:3000 -it ntopng-docker malware-traffic-analysis http://malware-traffic-analysis.net/2016/09/06 infected
```

### shell
Start a shell inside the docker container.

```
root@devel:/home/simone/ntopng-docker# docker run -it ntopng-docker shell
Starting redis-server: redis-server.
Enterning ntopng container in shell (interactive) mode
ntopng@ce8ece096275:~$ 
```
