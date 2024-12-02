# Url: https://training.play-with-docker.com/linux-registry-part2/
# Generating the SSL Certificate in Linux
mkdir -p certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
mkdir /etc/docker/certs.d
mkdir /etc/docker/certs.d/127.0.0.1:5000
cp $(pwd)/certs/domain.crt /etc/docker/certs.d/127.0.0.1:5000/ca.crt
pkill dockerd
dockerd > /dev/null 2>&1 &


# Running the Registry Securely
mkdir registry-data
docker run -d -p 5000:5000 --name registry \
  --restart unless-stopped \
  -v $(pwd)/registry-data:/var/lib/registry -v $(pwd)/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  registry

# Accessing secure registry
docker pull hello-world
docker tag hello-world 127.0.0.1:5000/hello-world
docker push 127.0.0.1:5000/hello-world
docker pull 127.0.0.1:5000/hello-world


# Part 3 - Using Basic Authentication with a Secured Registry in Linux
# Usernames and Passwords
mkdir auth
# Set up htpasswd command line tool
sudo apt install apache2-utils
# Add auth to the docker registry
docker run --entrypoint htpasswd registry:latest -Bbn moby gordon > auth/htpasswd
# Alternative command line in case this one does not work:
# docker container run --rm --entrypoint htpasswd registry:2.6 -Bbn your-user your-password > auth/htpasswd
# for some reason the latest version of registery does not contain htpasswd

cat auth/htpasswd

# Running an Authenticated Secure Registry

docker kill registry
docker rm registry
docker run -d -p 5000:5000 --name registry \
  --restart unless-stopped \
  -v $(pwd)/registry-data:/var/lib/registry \
  -v $(pwd)/certs:/certs \
  -v $(pwd)/auth:/auth \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -e REGISTRY_AUTH=htpasswd \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
  registry

# Authenticating with the Registry
docker pull 127.0.0.1:5000/hello-world
docker login 127.0.0.1:5000

docker pull 127.0.0.1:5000/hello-world
