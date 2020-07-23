.PHONY: test

test:
	cutest -r ./test/support/helper.rb ./test/*_test.rb
