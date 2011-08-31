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

