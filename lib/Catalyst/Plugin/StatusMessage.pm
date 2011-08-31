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

# Holds and handles normal (non-error) messages
with 'Catalyst::Plugin::StatusMessageTypeRole' => {
    type    => 'status_msg',
    handles => [qw/get_status_msg set_status_msg/],
};

# Holds and handles error messages
with 'Catalyst::Plugin::StatusMessageTypeRole' => {
    type    => 'error_msg',
    handles => [qw/get_error_msg set_error_msg/],
};


# Load both messages that match the token param (mid=###) into the stash
# for display by the view.
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

=pod

=head1 NAME

Catalyst::Plugin::StatusMessage - Handle passing of status (success and error) messages between screens of a web application.


=head1 SYNOPSIS

In MyApp.pm:
    use Catalyst qr/
        StatusMessage
    /;

In controller where you want to save a message for display on the next
page (here, once the "delete" action taken is complete, we are
redirecting to a "list" page to show the status [we don't want to leave
the delete action in the browser URL]):

   $c->response->redirect($c->uri_for($self->action_for('list'),
        {mid => $c->set_status_msg("Deleted widget")}));

Or, to save an error message:

   $c->response->redirect($c->uri_for($self->action_for('list'),
        {mid => $c->set_error_msg("Error deleting widget")}));

Then, in the controller action that corresponds to the redirect above:

    sub list :Path {
        my ($self, $c) = @_;
        ...
        $c->load_status_msgs;
        ...
    }

And, to display the output (here using L<Template|Template Toolkit>):

    ...
    <span class="message">[% status_msg %]</span>
    <span class="error">[% error_msg %]</span>
    ...


=head1 DESCRIPTION

There are a number of ways people commonly use to pass "status messages"
between screens in a web application.

=over 4

=item *

Using $c->stash: The stash only exists for a single request, so this
approach can leave the wrong URL in the user's browser.

=item *

Using $c->flash: This allows the application to redirect to an
appropriate URL, but it can display lead to a race condition where the
wrong status message is displayed in the wrong browser window or tab.

=item *

Query parameters in the URL: This suffers from issues related to
long/ugly URLs and leaves the message displayed even after a browser
refresh.

=back

This plugin attempts to address these issues through the following mechanisms:

=over 4

=item *

Stores messages in the C<$c-E<gt>session> so that the application is free
to redirect to the appropriate URL after an action is taken.

=item *

Associates a random 10-digit "token" with each messages, so it's completely
unambiguous what message should be shown in each window/tab.

=item *

Only requires that the token (not the full message) be included in the
redirect URL.

=item *

Automatically removes the message after the first time it is displayed.
That way, if users hit refresh in their browsers they only see the
messages the first time.

=back



=head1 CONFIGURABLE OPTIONS


=head2 session_prefix

The location inside $c->session where messages will be stored.  Defaults
to "C<status_msg>".


=head2 token_param

The name of the URL param that holds the token on the page where you
want to retrieve/display the status message.  Defaults to "C<mid>".


=head1 METHODS


=head2 load_status_msgs

Load both messages that match the token parameter on the URL (e.g.,
http://myserver.com/widgits/list?mid=1234567890) into the stash
for display by the view.

In general, you will want to include this in an C<auto> or "base" (if
using Chained dispatch) controller action.  Then, if you have a
"template wrapper page" that displays both "C<status_msg>" and
"C<error_msg>", you can automatically and safely send status messages to
any related controller action.


=head1 AUTHOR

Kennedy Clark, hkclark@gmail.com


=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself.


=cut

