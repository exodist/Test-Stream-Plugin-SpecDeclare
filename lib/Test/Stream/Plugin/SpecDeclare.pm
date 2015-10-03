package Test::Stream::Plugin::SpecDeclare;
use strict;
use warnings;

use Carp qw/confess croak/;

use Test::Stream::Plugin;
use Devel::Declare;
use B::Hooks::EndOfScope;

our $VERSION = "0.000001";
our $DEBUG  = 0;
our $RECORD = 0;
our @RECORD;

sub load_ts_plugin {
    my $class = shift;
    my $caller = shift;

    Devel::Declare->setup_for(
        $caller->[0],
        {
            map { $_ => { const => \&parser } } grep { $caller->[0]->can($_) } qw{
                describe    cases
                tests       it
                case
                before_all  after_all  around_all
                before_case after_case around_case
                before_each after_each around_each
            }
        },
    );
}

sub parser {
    my ($dec, $offset) = @_;
    $offset += Devel::Declare::toke_move_past_token($offset);
    $offset += Devel::Declare::toke_skipspace($offset);

    my ($name, $meta);

    my @restore;
    my $restore = sub {
        my $line = Devel::Declare::get_linestr();
        push @RECORD => [0, $line, @restore] if $RECORD;
        print "MANGLE: |$line|\n" if $DEBUG;
        for my $set (reverse @restore) {
            my ($offset, $len, $val) = @$set;
            substr($line, $offset, $len) = $val;
        }
        Devel::Declare::set_linestr($line);
        print "FIXED:  |$line|\n" if $DEBUG;
        return 0;
    };

    # Get name
    my $line = Devel::Declare::get_linestr();
    my $start = substr($line, $offset, 1);

    if ($start eq '"' || $start eq "'") {
        my $len = Devel::Declare::toke_scan_str($offset);
        $name = Devel::Declare::get_lex_stuff();
        Devel::Declare::clear_lex_stuff();
        $offset += $len;
        substr($line, $offset, 0) = ", ";
        Devel::Declare::set_linestr($line);
        push @restore => [$offset, 2, ""];
        $offset += 2;
    }
    elsif (my $nlen = Devel::Declare::toke_scan_word($offset, 1)) {
        $name = substr($line, $offset, $nlen);
        my $new = "$name => ";
        substr($line, $offset, $nlen) = $new;
        Devel::Declare::set_linestr($line);
        push @restore => [$offset, length($new), $name];
        $offset += length($new);
    }

    return $restore->() unless defined $name;

    $offset += Devel::Declare::toke_skipspace($offset);

    $line = Devel::Declare::get_linestr();
    $start = substr($line, $offset, 1);
    if ($start eq '(') {
        my $len = Devel::Declare::toke_scan_str($offset);
        $line = Devel::Declare::get_linestr();
        $meta = Devel::Declare::get_lex_stuff();
        Devel::Declare::clear_lex_stuff();
        my $new = "{$meta}, ";
        substr($line, $offset, $len) = $new;
        push @restore => [$offset, length($new), "($meta)"];
        Devel::Declare::set_linestr($line);
        $offset += length($new);
    }

    $offset += Devel::Declare::toke_skipspace($offset);
    $line = Devel::Declare::get_linestr();
    $start = substr($line, $offset, 1);

    return $restore->() unless $start eq '{';

    my $new = "sub { BEGIN { Test::Stream::Plugin::SpecDeclare::inject_scope() }; ";
    substr($line, $offset, 1) = $new;
    Devel::Declare::set_linestr($line);
    print STDERR "$line\n" if $DEBUG;
    push @RECORD => [1, $line, @restore] if $RECORD;
}

sub inject_scope {
    on_scope_end {
        my $linestr = Devel::Declare::get_linestr();
        my $offset = Devel::Declare::get_linestr_offset();
        substr($linestr, $offset, 0) = ';';
        Devel::Declare::set_linestr($linestr);
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::Stream::Plugin::SpecDeclare - Syntax sugar for
Test::Stream::Plugin::Spec.

=head1 DESCRIPTION

This plugin provides keywords for all the functions exported by
L<Test::Stream::Plugin::Spec>. These keywords give the functions better syntax
so that they work more like the C<sub> keyword.

=head1 SYNOPSIS

    use Test::Stream qw/-V1 Spec SpecDeclare/;

    # Using syntax sugar
    tests sweet {
        ok(1, "pass");
    }

    # No sugar
    tests bland => sub {
        ok(1, "pass");
    };


    # Using syntax sugar
    tests sweeter(todo => 'fixme') {
        ok(0, "fail");
    }

    # No sugar
    tests blander => {todo => 'fixme'}, sub {
        ok(0, "fail");
    };


    # Using syntax sugar
    tests 'sweetest yet'(skip => 'broken') {
        die "broken";
    }

    # No sugar
    tests 'blandest yet' => {skip => 'broken'}, sub {
        die "broken";
    };

=over 4

=item Syntax like the 'sub' keyword

    tests NAME { ... }

=item Supports meta-attributes

    tests NAME(...) { ... }

=item Can use quotes for a complex name

    tests "complex name" { ... }
    tests 'complex name' { ... }

=item Final semicolon is added for you

No need to add it yourself, just like the 'sub' keyword.

=item Does not break the old syntax

These all still work:

    tests foo => sub { ... };
    tests foo => {...}, sub { ... };
    tests "foo", {...}, sub { ... };
    tests 'foo', {...}, sub { ... };

=back

=head1 KEYWORDS

The following keywords are supported, the magic will only be added for the
functions if they have been imported into your package.

=over 4

=item describe

=item cases

=item tests

=item it

=item case

=item before_all

=item after_all

=item around_all

=item before_case

=item after_case

=item around_case

=item before_each

=item after_each

=item around_each

=back

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2015 Chad Granum E<lt>exodist7@gmail.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

=cut
