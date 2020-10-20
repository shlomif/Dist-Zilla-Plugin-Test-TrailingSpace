package Dist::Zilla::Plugin::Test::TrailingSpace;

use 5.012;

use Moose;
extends 'Dist::Zilla::Plugin::InlineFiles';
with qw/Dist::Zilla::Role::TextTemplate Dist::Zilla::Role::PrereqSource/;

use namespace::autoclean;

has filename_regex => (
    is      => 'ro',
    isa     => 'Str',
    default =>
        q/(?:\.(?:t|pm|pl|xs|c|h|txt|pod|PL)|README|Changes|TODO|LICENSE)\z/,
);

around add_file => sub {
    my ( $orig, $self, $file ) = @_;

    return $self->$orig(
        Dist::Zilla::File::InMemory->new(
            name    => $file->name,
            content => $self->fill_in_string(
                $file->content,
                {
                    dist           => \( $self->zilla ),
                    filename_regex => $self->filename_regex,
                }
            )
        )
    );
};

# Register the release test prereq as a "develop requires"
# so it will be listed in "dzil listdeps --author"
sub register_prereqs
{
    my ($self) = @_;

    $self->zilla->register_prereqs(
        {
            type  => 'requires',
            phase => 'develop',
        },
        'Test::TrailingSpace' => '0.0203',
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

=head1 DESCRIPTION

This module tests adds a test for trailing whitespace in the distribution. It
accepts the following parameters:

=head2 filename_regex

The regular expression for input to Test::TrailingSpace for matching the files
to look for trailing space.

Here is an example of how to override it:

    [Test::TrailingSpace]
    filename_regex = \.(?:pm|pod)\z

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
       filename_regex => qr#{{ $filename_regex }}#,
   },
);

# TEST
$finder->no_trailing_space(
   "No trailing space was found."
);
