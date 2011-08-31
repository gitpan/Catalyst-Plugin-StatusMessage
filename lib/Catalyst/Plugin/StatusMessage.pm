package Catalyst::Plugin::StatusMessage;

BEGIN {
    $Catalyst::Plugin::StatusMessage::VERSION = '0.001000';
}
# ABSTRACT: Handle passing of status (success and error) messages between screens

use Moose;
use namespace::autoclean;

# The location inside $c->session where messages will be stored
has 'session_prefix' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'status_msg',
);

# The name of the URL param that holds the token
has 'token_param' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'mid', # For "Message ID"
);

# Handle normal (non-error) messages
with 'Catalyst::Plugin::StatusMessageTypeRole' => {
    type    => 'status_msg',
    handles => [qw/get_status_msg set_status_msg/],
};

# Handle error messages
with 'Catalyst::Plugin::StatusMessageTypeRole' => {
    type    => 'error_msg',
    handles => [qw/get_error_msg set_error_msg/],
};


=head2 load_status_msgs

Load both messages that match the token param (mid=###) into the stash
for display by the view.

=cut

sub load_status_msgs {
    my ($self) = @_;

    my $token  = $self->request->params->{$self->token_param} || return;

    $self->stash(
        status_msg => $self->get_status_msg($token),
        error_msg  => $self->get_error_msg($token),
    );
}

__PACKAGE__->meta->make_immutable;

__END__

