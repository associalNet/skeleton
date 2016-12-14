package App::JSon {
  use parent 'Plack::Middleware';
  use Plack::Util;

  sub call {
    my ($self, $env) = @_;
    my $res = $self->app->($env);
    Plack::Util::response_cb($res, sub {
        my $res = shift;
        my $hash = $res->[2];

        if(ref $hash eq 'HASH' && $hash->{errorMessage}) {
          #then we send error code to the user
          $res->[0] = $hash->{status};
        }

        my $json = JSON->new;
        $json->allow_blessed;
        $json->convert_blessed;

        $res->[1] = [ 'Content-Type' => 'application/json' ];
        $res->[2] = [ $json->encode($hash) ];
      });
  };

  1;
};

=put
=head1 NAME
App::JSon - a JSON wrapper for our application

=head2 WHY
Original JSON wrapper did not let me override return status code.

=item call
Code is executed after callback. If result hash has got "errorMessage" key then update the status and send error as JSON message.
Keep status (200) and send JSON otherwise.

=cut
