FOREVER=./node_modules/.bin/forever
from ?= master

test:
	./node_modules/.bin/mocha ./tests/*_test.js -R spec

setup: logs
	npm install

clean:
	rm -rf node_modules

run:
	node app.js

start:
	NODE_ENV=production $(FOREVER) -m 4 -p ./logs -l server.log --append --plain start server.js

stop:
	$(FOREVER) stop server.js

restart:
	$(FOREVER) restart server.js

status:
	$(FOREVER) list

logs:
	mkdir logs

nginx/start: nginx.conf
	sudo /usr/local/nginx/sbin/nginx -c /home/$(USER)/bootstrap-cdn/nginx.conf

nginx/stop:
	sudo pkill -9 nginx

nginx/restart: nginx/stop nginx/start

nginx/reload:
	sudo pkill -HUP nginx

nginx.conf:
	sed -e "s/CURRENT_USER/$(USER)/g" .nginx.conf > nginx.conf

deploy:
	@./scripts/deploy.sh

.PHONY:
# vim: ft=make:
