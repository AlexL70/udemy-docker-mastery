docker network create --driver overlay frontnet
docker network create --driver overlay backnet
docker service create --name db --network backnet --replicas 1 --mount type=volume,source=db-data,target=/var/lib/postgresql/data -e POSTGRES_HOST_AUTH_METHOD=trust postgres:9.4
docker service create --name redis --network frontnet --replicas 1 redis:3.2
docker service create --name worker  --network frontnet --network backnet --replicas 1 bretfisher/examplevotingapp_worker
docker service create --name vote --network frontnet -p 80:80 --replicas 2 bretfisher/examplevotingapp_vote
docker service create --name result --network backnet -p 5001:80 --replicas 1 bretfisher/examplevotingapp_result