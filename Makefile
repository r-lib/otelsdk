R/api-dev.R: tools/template/dev.R $(filter-out R/api-dev.R,$(wildcard R/*.R))
	Rscript tools/template/dev.R || rm -f R/api-dev.R
