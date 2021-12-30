#build the docker image
docker build -t webserver-ngnix --build-arg VID_NAME1=$1 VID_NAME2=$2 VID_NAME3=$3 .

#Start the container
docker run -d -t -p 80:80 --name multimedia-networking webserver-ngnix 