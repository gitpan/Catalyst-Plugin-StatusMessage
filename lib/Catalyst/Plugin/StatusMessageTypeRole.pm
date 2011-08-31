package Catalyst::Plugin::StatusMessageTypeRole;

use MooseX::Role::Parameterized;

requires 'session_prefix';

parameter 'type' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

role {
    my $param = shift;

    my $type = $param->type;

    # Hashref to hold the msgs for this type of msg
    has $type => (
        is      => 'ro',
        isa     => 'Ref', # Wish could use 'Hashref[Str]' but doesn't seem to work
        default => sub { {} },
    );
    my $prefix = 'smsg_';

    # Lookup the msg for the requested token (return '' if token not found)
    method "get_$type" => sub {
        my ($self, $token) = @_;

        my $prefix = $self->session_prefix;
        my $msg_str = $self->session->{$prefix}->{$type}->{$token} || '';
        # Return it only once
        delete $self->session->{$prefix}->{$type}->{$token};
        return $msg_str;
    };

    # Save the msg under a random token (return the token to save and use
    # for lookup on the appropriate screen)
    method "set_$type" => sub {
        my ($self, $msg_str) = @_;

        return unless $msg_str;
        my $token  = $self->_make_token;
        my $prefix = $self->session_prefix;
        $self->session->{$prefix}->{$type}->{$token} = $msg_str;
        return $token;
    };

    # Generate a random 8-digit number for a token
    sub _make_token {
        return int(rand(90_000_000))+10_000_000;
    }
};

__END__

=pod

=head1 NAME

Catalyst::Plugin::StatusMessageTypeRole - A Moose Role to do the actual saving and retrieval of status and error messages. 


=head1 SYNOPSIS

    package Catalyst::Plugin::StatusMessage;
    
    use Moose;
    
    with 'Catalyst::Plugin::StatusMessageTypeRole' => {
        type    => 'status_msg',
        handles => [qw/get_status_msg set_status_msg/],
    };
    
    ...


=head1 DESCRIPTION

A parameterized Moose Role that saves and retrieves status messages
to/from the Catalyst session.  Each message is associated with a random
token to prevent the wrong message showing up on two screens.  The
message is removed after the first time it is retrieved.


=head1 AUTHOR

Kennedy Clark, hkclark@gmail.com


=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself.

=cut

