ifndef VERSION
	VERSION=latest
endif

DOT:=.
NOTHING:=

NAME=tirex-$(VERSION)
ES_URI=http://tirexs-$(VERSION)-elasticsearch:9200
NETWORK=$(subst  $(DOT),$(NOTHING),tirexs$(VERSION)_back-tier)

build: clean
	cd dockerfiles/tirexs-$(VERSION)/ && docker-compose up -d
	docker build -t $(NAME) dockerfiles/tirexs-$(VERSION)/
	docker run --rm -t -i \
		-v `pwd`:/app \
		-e "ES_URI=$(ES_URI)" \
		--dns 8.8.8.8 \
		--network=$(NETWORK) \
		-w /app \
		$(NAME) \
		/bin/bash -c "mix deps.get"
.PHONY: build

clean:
	cd dockerfiles/tirexs-$(VERSION)/ && docker-compose rm -f
	docker rmi --force $(NAME) || true
.PHONY: clean

test: build
	sleep 60
	docker run --rm -t -i \
		-v `pwd`:/app \
		--dns 8.8.8.8 \
		-e "ES_URI=$(ES_URI)" \
		--network=$(NETWORK) \
		-w /app \
		$(NAME) \
		/bin/bash -c "mix test --no-elixir-version-check"
.PHONY: test

console:
	docker run --rm -t -i \
		-v `pwd`:/app \
		--dns 8.8.8.8 \
		-e "ES_URI=$(ES_URI)" \
		--network=$(NETWORK) \
		-w /app \
		$(NAME) \
		/bin/bash
.PHONY: console
