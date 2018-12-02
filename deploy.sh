cd gitbook

if [ "$(docker ps -q -f name=programmer-notes)" ]; then
	docker stop programmer-notes
fi

docker run --rm -v "$PWD:/gitbook" -p 4000:4000 tomoyadeng/gitbook:3.2.3 gitbook install

docker run --rm -v "$PWD:/gitbook" -p 4000:4000 tomoyadeng/gitbook:3.2.3 gitbook build

docker container run \
  -d \
  -p 127.0.0.1:8081:80 \
  --rm \
  --name programmer-notes\
  --volume "$PWD/_book":/usr/share/nginx/html \
  nginx

cd ..
