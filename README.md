
## Prerequisites
Install git 
```sh
sudo apt-get install -y git
```

Install Docker CE
https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository


## Create Docker Swarm
```sh
sudo docker swarm init --advertise-addr <ip>
```
<ip> is one of the ip on this Linux

To list node joined:
```sh
sudo docker node ls
```

sudo docker stack deploy -c docker-compose-3.yml hpcc

sudo docker stack deploy -c docker-compose-3-simple.yml hpcc

sudo docker stack rm hpcc


