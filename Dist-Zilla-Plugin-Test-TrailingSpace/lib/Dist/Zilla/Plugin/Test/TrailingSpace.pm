package Dist::Zilla::Plugin::Test::TrailingSpace;

our $VERSION = '0.0.2';

use Moose;
extends 'Dist::Zilla::Plugin::InlineFiles';
with 'Dist::Zilla::Role::PrereqSource';

use namespace::autoclean;

# Register the release test prereq as a "develop requires"
# so it will be listed in "dzil listdeps --author"
sub register_prereqs {
    my ($self) = @_;

    $self->zilla->register_prereqs(
        {
            type  => 'requires',
            phase => 'develop',
        },
        'Test::TrailingSpace'     => '0.0203',
    );

    return;
}

__PACKAGE__->meta->make_immutable;

1;

=pod

=encoding utf8

=head1 NAME

Dist::Zilla::Plugin::Test::TrailingSpace - test for trailing whitespace
in files.

=head1 SYNOPSIS

1. In the dist.ini:

    [Test::TrailingSpace]

2. From the command line

    $ dzil test --release

=head1 SUBROUTINES/METHODS

=head2 register_prereqs()

Needed by L<Dist::Zilla> .

=head1 SEE ALSO

=over 4

=item * L<Dist::Zilla::Plugin::Test::EOL>

Can also check for trailing whitespace.

=item * L<Dist::Zilla::Plugin::EOLTests>

Older and seems less preferable.

=item * L<Test::TrailingSpace>

A standalone test module for trailing whitespace which this is a wrapper
for.

=back

=cut

__DATA__
___[ xt/release/trailing-space.t ]___
#!perl

use strict;
use warnings;

use Test::More;

eval "use Test::TrailingSpace";
if ($@)
{
   plan skip_all => "Test::TrailingSpace required for trailing space test.";
}
else
{
   plan tests => 1;
}

# TODO: add .pod, .PL, the README/Changes/TODO/etc. documents and possibly
# some other stuff.
my $finder = Test::TrailingSpace->new(
   {
       root => '.',
       filename_regex => qr/(?:\.(?:t|pm|pl|xs|c|h|txt|pod|PL)|README|Changes|TODO|LICENSE)\z/,
   },
);

# TEST
$finder->no_trailing_space(
   "No trailing space was found."
);
