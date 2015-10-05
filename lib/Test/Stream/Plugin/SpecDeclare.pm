package Test::Stream::Plugin::SpecDeclare;
use strict;
use warnings;

use Test::Stream::Plugin;

use Devel::Declare;
use B::Hooks::EndOfScope;

use PadWalker qw/peek_my peek_our/;
use Carp qw/confess croak/;

# Do not declare any variables here!!!!

my %META;
sub _metahash {
    my $string = "";
    my $vars = { %{peek_our(1)}, %{peek_my(1)} };

    {
        my $id = shift;
        my @caller = caller(0);
        my $meta = $META{$id} || return {};

        my $var_string = "";
        for my $var (keys %$vars) {
            my $end = "\$vars->{'$var'}";
            if ($var =~ m/^([\@\%\$])/) {
                $end = "${1}{$end}";
            }
            else {
                next;
            }
            $var_string .= "my $var = $end;\n";
        }

        $string = <<"        EOT";
package $caller[0];
$var_string

# This is cut off access to these variables so they can not be modified in the
# eval.
my \$vars;
my \$string;
my \%META;
# line $caller[2] "$caller[1] (SpecDeclare eval)"
my \$h = {$meta};
        EOT
    }

    my $hash = eval $string;
    die $@ unless $hash;

    return $hash;
}

# Now we can define some variables.
my $ID = 1;
our $DEBUG   = 0;
our $VERSION = "0.000002";

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

sub _inject_scope {
    on_scope_end {
        my $line = Devel::Declare::get_linestr();
        my $offset = Devel::Declare::get_linestr_offset();
        substr($line, $offset, 0) = ';';
        Devel::Declare::set_linestr($line);
        print STDERR "FINAL: |$line|\n" if $DEBUG;
    }
}

sub parser {
    my ($dec, $offset) = @_;
    my ($name, $meta);

    # Due to parsing strangeness we need to grab the meta-data and get it back
    # later. This ID is used to fetch the data later.
    my $id = $ID++;

    # This is used to back out all changes if a parsing error occurs.
    my @restore;
    my $restore = sub {
        my $line = Devel::Declare::get_linestr();
        print "MANGLE: |$line|\n" if $DEBUG;
        for my $set (reverse @restore) {
            my ($offset, $len, $val) = @$set;
            substr($line, $offset, $len) = $val;
        }
        Devel::Declare::set_linestr($line);
        print "FIXED:  |$line|\n" if $DEBUG;
        return 0;
    };

    # Skip the initial boring stuff
    $offset += Devel::Declare::toke_move_past_token($offset);
    $offset += Devel::Declare::toke_skipspace($offset);
    my $line = Devel::Declare::get_linestr();

    # After the name we use a fat comma, then get the meta hash by id, then add
    # an opening paren, which strangely works around some parser issues, we
    # will close it later
    my $post_name = " => Test::Stream::Plugin::SpecDeclare::_metahash($id), (";

    # Get the block name
    my $start = substr($line, $offset, 1);
    if ($start eq '"' || $start eq "'") {
        # Quoted name
        my $len = Devel::Declare::toke_scan_str($offset);
        $name = Devel::Declare::get_lex_stuff();
        Devel::Declare::clear_lex_stuff();
        $offset += $len;
        my $new = $post_name;
        substr($line, $offset, 0) = $new;
        Devel::Declare::set_linestr($line);
        push @restore => [$offset, length($new), ""];
        $offset += length($new);
    }
    elsif (my $nlen = Devel::Declare::toke_scan_word($offset, 1)) {
        # Bareword name
        $name = substr($line, $offset, $nlen);
        my $new = qq|"${name}"${post_name}|;
        substr($line, $offset, $nlen) = $new;
        Devel::Declare::set_linestr($line);
        push @restore => [$offset, length($new), $name];
        $offset += length($new);
    }

    # Back out if we failed to get a name
    return $restore->() unless defined $name;

    $offset += Devel::Declare::toke_skipspace($offset);

    # See if there is any meta stuff listed.
    $line = Devel::Declare::get_linestr();
    $start = substr($line, $offset, 1);
    if ($start eq '(') {
        my $len = Devel::Declare::toke_scan_str($offset);
        $meta = Devel::Declare::get_lex_stuff();
        Devel::Declare::clear_lex_stuff();
        $line = Devel::Declare::get_linestr();

        # Stash the meta stuff to get later, in perls older than 5.20 we can't
        # leave it here as it messes up the parser
        $META{$id} = $meta;

        # Replace meta with nothing except the newlines (to preserve line
        # numbers)
        # For some reason putting anything here other than whitespace causes
        # problems.
        my @newlines = $meta =~ /(\n)/g;
        my $new = join '' => @newlines;
        substr($line, $offset, $len) = $new;
        Devel::Declare::set_linestr($line);

        # This is how to back it out later
        push @restore => [$offset, length($new), "($meta)"];

        # Advance the offset
        $offset += length($new);
    }

    # Move to the start of the block
    $offset += Devel::Declare::toke_skipspace($offset);
    $line = Devel::Declare::get_linestr();
    $start = substr($line, $offset, 1);
    return $restore->() unless $start eq '{';

    # Close the paren we opened above, then inject the sub keyword and the
    # inject scope call which gets us the trailing semicolon.
    my $new = "), sub { BEGIN { Test::Stream::Plugin::SpecDeclare::_inject_scope(); }; ";
    substr($line, $offset, 1) = $new;
    Devel::Declare::set_linestr($line);
    $offset += length($new);
    print STDERR "PREFIN: |$line|\n" if $DEBUG;
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

See L<Test::Stream::Plugin::Spec> for details on each function.

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
