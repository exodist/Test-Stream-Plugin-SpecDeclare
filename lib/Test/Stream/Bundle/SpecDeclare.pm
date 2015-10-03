package Test::Stream::Bundle::SpecDeclare;
use strict;
use warnings;

use Test::Stream::Bundle;

sub plugins {
    return (qw/Spec SpecDeclare/);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::Stream::Bundle::SpecDeclare - Bundle Spec and SpecDeclare.

=head1 DESCRIPTION

This bundle includes L<Test::Stream::Plugin::Spec> and
L<Test::Stream::Plugin::SpecDeclare>.

=head1 SYNOPSIS

    use Test::Stream qw/-V1 -SpecDeclare/;

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
