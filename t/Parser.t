use Test::Stream -V1, -SpecDeclare;

tests simple_magic { ok(1, "simple_magic") }
tests simple_clear => sub { ok(1, "simple_clear") };

tests "complex magic"(skip => undef) { ok(1, "complex magic") }
tests complex_clear => {skip => undef}, sub { ok(1, "complex magic") };

done_testing;
