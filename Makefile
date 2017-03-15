today := $(shell date +"%Y-%m-%d")
import:
	#wget -r --no-parent http://franz.com/support/documentation/10.0/doc/index.htm
	alisp -batch -#! ./crawl.lisp
	-sh functions.sh
	mkdir -p AllegroLisp.docset/Contents/Resources/Documents/
	cp -r franz.com/support/documentation/10.0/doc/ AllegroLisp.docset/Contents/Resources/Documents/
	mv docSet.dsidx AllegroLisp.docset/Contents/Resources/

commit:
	git commit -am "Allegro from ${today}"
