# docker-convoy
--------------------

This image configures a convoy agent with the nfs mapper. A volume must be provided for this to work.

## usage without custom volume directory

```docker run -d --name convoy --restart always -v /var/run/convoy:/var/run/convoy -v /etc/docker/plugins:/etc/docker/plugins -v /local/share:/share convoy```

## usage with custom volume directory

```docker run -d --name convoy --restart always -v /var/run/convoy:/var/run/convoy -v /etc/docker/plugins:/etc/docker/plugins -v /local/share:/custom/share -e VOLUMES=/custom/share convoy```