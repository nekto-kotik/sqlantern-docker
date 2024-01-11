# SQLantern for Docker
A Dockerfile which runs SQLantern in a compact environment with Apache and mod_php (built on Alpine Linux, ~30MB installed).

_Your databases must accept external connections for this setup to work._

SQLantern is a multi-panel and multi-screen database manager.\
Read more about it [in the official repository](https://github.com/nekto-kotik/sqlantern).\
Visit demo at [sqlantern.com](https://sqlantern.com/)

## Usage
* Pull docker image and run:
```
docker pull nektowastaken/sqlantern
docker run -d -p 1111:1111 --rm nektowastaken/sqlantern
```

* Or build and run the container from source:
```
docker build -t sqlantern
docker run -d -p 1111:1111 --rm sqlantern
```

* Open "http://localhost:1111/" in your web-browser (if you run Docker on the same machine).

* If "localhost" doesn't work, the container also responds to:
  -  "http://sqlantern.local:1111/" (add it to your "hosts", using your Docker host's IP)
  -  Docker host IP address, e.g. "http://192.168.1.112:1111/"

## Notes
SQLantern in this container is always fresh (always cloned from the public repository).

Web-server in the container listens to port 1111 internally.

This container SHOULD NOT be used on machines, exposed to the internet: "multihost" is enabled in SQLantern, making it a potential proxy for a brute force or DDOS attack.\
It SHOULD be used behind a firewall or in dev environment with closed/limited ports.
