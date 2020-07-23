.PHONY: test

test:
	cutest -r ./test/helper.rb ./test/*_test.rb
