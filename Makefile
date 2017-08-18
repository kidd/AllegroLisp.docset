today := $(shell date +"%Y-%m-%d")
aclversion = 10.1
import:
	wget -q -r --no-parent http://franz.com/support/documentation/$(aclversion)/doc/index.htm
	alisp -batch -#! ./crawl.lisp
	-sh functions.sh
	mkdir -p AllegroLisp.docset/Contents/Resources/Documents/
	cp -r franz.com/support/documentation/$(aclversion)/doc/* AllegroLisp.docset/Contents/Resources/Documents/
	mv docSet.dsidx AllegroLisp.docset/Contents/Resources/

commit:
	git commit -am "Allegro from ${today}"

install:
	cp -r AllegroLisp.docset ~/.docsets
