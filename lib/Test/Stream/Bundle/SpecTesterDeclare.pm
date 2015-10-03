package Test::Stream::Bundle::SpecTesterDeclare;
use strict;
use warnings;

use Test::Stream::Bundle;

sub plugins {
    return (qw/-Tester Spec SpecDeclare/);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::Stream::Bundle::SpecTesterDeclare - Bundle Spec, Tester, and SpecDeclare.

=head1 DESCRIPTION

This bundle includes L<Test::Stream::Plugin::Spec>,
L<Test::Stream::Plugin::SpecDeclare>, and L<Test::Stream::Bundle::Tester>.

=head1 SYNOPSIS

    use Test::Stream qw/-V1 -SpecTesterDeclare/;

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
