.PHONY: all bare push clean commit
.SECONDARY: stage-0.tgz stage-1.tgz stage-2.tgz stage-3.tgz stage-4.tgz stage-0/.sentinel stage-1/.sentinel stage-2/.sentinel stage-3/.sentinel stage-4/.sentinel

EXT?=tgz

all:  bare
push: bare
	docker push     innovanon/$<
bare: stage-0.$(EXT) stage-1.$(EXT) stage-2.$(EXT) stage-3.$(EXT) stage-4.$(EXT)
	docker build -t innovanon/$@ $(TEST) .
commit:
	git add .
	git commit -m '[Makefile] commit' || :
	git pull
	git push

stage-0.tgz: stage-0/.sentinel
	cd $(shell dirname $<) && \
	tar acvf ../$@ .
	#tar acvf ../$@ --owner=0 --group=0 .
stage-1.tgz: stage-1/.sentinel
	cd $(shell dirname $<) && \
	tar acvf ../$@ .
	#tar acvf ../$@ --owner=0 --group=0 .
stage-2.tgz: stage-2/.sentinel
	cd $(shell dirname $<) && \
	tar acvf ../$@ .
	#tar acvf ../$@ --owner=0 --group=0 .
stage-3.tgz: stage-3/.sentinel
	cd $(shell dirname $<) && \
	tar acvf ../$@ .
	#tar acvf ../$@ --owner=0 --group=0 .
stage-4.tgz: stage-4/.sentinel
	cd $(shell dirname $<) && \
	tar acvf ../$@ .
	#tar acvf ../$@ --owner=0 --group=0 .

stage-0/.sentinel: $(shell find stage-0 -type f)
	openssl rand -out $@ $(shell echo '2 ^ 10' | bc )
stage-1/.sentinel: $(shell find stage-1 -type f)
	openssl rand -out $@ $(shell echo '2 ^ 10' | bc )
stage-2/.sentinel: $(shell find stage-2 -type f)
	openssl rand -out $@ $(shell echo '2 ^ 10' | bc )
stage-3/.sentinel: $(shell find stage-3 -type f)
	openssl rand -out $@ $(shell echo '2 ^ 10' | bc )
stage-4/.sentinel: $(shell find stage-4 -type f)
	openssl rand -out $@ $(shell echo '2 ^ 10' | bc )

clean:
	rm -vf stage-*.$(EXT) */.sentinel .sentinel

