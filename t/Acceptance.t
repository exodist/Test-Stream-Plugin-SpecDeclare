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
 }

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
    tests foo(iso => 1) {
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

done_testing;
