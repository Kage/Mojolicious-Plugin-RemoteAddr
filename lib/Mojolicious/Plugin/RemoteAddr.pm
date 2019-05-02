package Mojolicious::Plugin::RemoteAddr;
use Mojo::Base 'Mojolicious::Plugin';
use Net::CIDR::Lite;

our $VERSION = '0.04';

sub register {
    my ($self, $app, $conf) = @_;

    $conf->{order} ||= ['x-real-ip', 'x-forwarded-for', 'tx'];

    $conf->{trust} ||= ['0.0.0.0/0', '::/0'];

    $app->helper( remote_addr => sub {
        my $c = shift;

        my $cidr = Net::CIDR::Lite->new;
        foreach my $trust ( @{ $conf->{trust} } ) {
            $cidr->add_any($trust);
        }
        my $src_addr = $c->tx->remote_address;
        return $src_addr unless
            defined $src_addr && $cidr->find($src_addr);

        foreach my $place ( @{ $conf->{order} } ) {
            if ( $place eq 'x-real-ip' ) {
                my $ip = $c->req->headers->header('X-Real-IP');
                return $ip if $ip;
            } elsif ( $place eq 'x-forwarded-for' ) {
                my $ip = $c->req->headers->header('X-Forwarded-For');
                return $ip if $ip;
            } elsif ( $place eq 'tx' ) {
                my $ip = $c->tx->remote_address;
                return $ip if $ip;
            }
        }

        return;
    });
}

1;
__END__
=head1 NAME

Mojolicious::Plugin::RemoteAddr - an easy way of getting remote ip address

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('RemoteAddr');

  # In controller
  my $ip = $self->remote_addr;

=head1 DESCRIPTION

L<Mojolicious::Plugin::RemoteAddr> adds simple helper "remote_addr" which returns an ip address of a remote host, It tries getting remote ip in different ways.
Firstly, it takes 'X-Real-IP' header. Secondly, it takes 'X-Forwarded-For' header. If they are empty it takes the ip from current request transaction.

You can also specify a list of trusted source IP addresses, ranges, or CIDRs that are allowed to set the header. This supports all definition types from
L<Net::CIDR::Lite>.

=head1 CONFIG

=head2 order

Lookup order. Default is ['x-real-ip', 'x-forwarded-for', 'tx']

If you do not have reverse proxy then set order to ['tx'] to avoid ip-address spoofing.

Supported places:

=over 4

=item 'x-real-ip'

'X-Real-IP' request header

=item 'x-forwarded-for'

'X-Forwarded-For' request header

=item 'tx'

current request transaction

=back

=head2 trust

Source IPs or CIDRs to trust as a source of the reverse proxt header. Default is ['0.0.0.0/0', '::/0']

If you do have reverse proxy then you should set this to the source IP of your reverse proxy to avoid ip-address spoofing.

Supports all IP, CIDR, and range definition types from L<Net::CIDR::Lite>.

=head1 HELPERS

=head2 remote_addr

Returns remote IP address

=head1 AUTHOR

Viktor Turskyi <koorchik@cpan.org>

=head1 CONTRIBUTORS

* dsteinbrunner@github
* Kage@github

=head1 BUGS

Please report any bugs or feature requests to Github L<https://github.com/koorchik/Mojolicious-Plugin-RemoteAddr>

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<Net::CIDR::Lite>, L<http://mojolicio.us>.

=cut
