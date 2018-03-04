npm install -g gitbook-cli@2.3.1
cd gitbook

gitbook install
gitbook build

if [ "$(docker ps -q -f name=programmer-notes)" ]; then
	docker stop programmer-notes
fi

docker container run \
  -d \
  -p 127.0.0.1:8081:80 \
  --rm \
  --name programmer-notes\
  --volume "$PWD/_book":/usr/share/nginx/html \
  nginx

cd ..
