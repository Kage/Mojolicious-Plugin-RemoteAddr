requires 'perl', '5.008005';

requires 'Mojolicious',     '>= 3.90';
requires 'Net::CIDR::Lite', '>= 0.21';

on test => sub {
  requires 'Test::More', '0.88';
};
