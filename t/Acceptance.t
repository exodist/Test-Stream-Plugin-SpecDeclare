use Test::Stream -V1, -SpecTesterDeclare;

describe wrapper {
    tests foo {
        ok(1, "Inside foo");
    }
}

describe old_wrapper => sub {
    tests old_foo => sub {
        ok(1, "Inside old_foo");
    };

    tests( 'old_bar', sub { ok(1, "Inside old_bar") } );
};

# Test that crazy whitespace is not an issue
tests
 'ugly name'
  (
    skip => undef
    )
  {
    ok(1, 'inside ugly');
    is(__LINE__, 25, "Correct line");
 }

is(__LINE__, 28, "Correct line");

before_each bef { ok(1, "before") }
around_each arr {
    ok(1, "prefix");
    $_[0]->();
    ok(1, "postfix");
}
after_each aft { ok(1, "after") }

before_all 'pre-all' {
    ok(1, 'pre all');
}

before_case 'haha' {
    ok(1, 'before case');
}

case x { ok(1, 'inside x') }
case "y" { ok(1, 'inside y') }

describe "xxx" {
    tests foo(skip => undef) {
        ok(1, "Boooya! $$");
    }

    before_each ooo {
        ok(1, "bleh");
    }

    after_each "ooo" {
        ok(1, "bleh");
    }
}

tests fail1(todo => 'this is todo') {
    ok(1, "pass");
    ok(0, "fail");
    ok(1, "pass");
}

tests fail2(skip => 'this will break') {
    die "oops";
}

sub params_skip { skip => 'skipping' }
my %params_skip = ( skip => 'skipping' );
my @params_skip = ( skip => 'skipping' );
my $params_skip = { skip => 'skipping' };

tests skip(params_skip)   { die "oops" }
tests skip(%params_skip)  { die "oops" }
tests skip(@params_skip)  { die "oops" }
tests skip(%$params_skip) { die "oops" }

sub params_todo { todo => 'a todo' }
my %params_todo = ( todo => 'a todo' );
my @params_todo = ( todo => 'a todo' );
my $params_todo = { todo => 'a todo' };

tests todo(params_todo)   { ok(0) }
tests todo(%params_todo)  { ok(0) }
tests todo(@params_todo)  { ok(0) }
tests todo(%$params_todo) { ok(0) }

is(__LINE__, 93, "Correct line");

done_testing;
