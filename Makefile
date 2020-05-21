.PHONY: benchmark
benchmark:
	@bundle exec ruby ./benchmark/benchmark_value_objects.rb

.PHONY: examples
examples:
	@bundle exec ruby ./examples/validators.rb
