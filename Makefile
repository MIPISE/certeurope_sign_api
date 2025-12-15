.PHONY: test

test:
	bundle exec cutest -r ./test/support/helper.rb ./test/*_test.rb
