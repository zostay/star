#!/usr/bin/perl

use lib "tools/lib";
use NQP::Configure qw(git_checkout);

my $SRC_DIR = 'src';

while (<>) {
    my ($giturl) = /(\S+)/;
    my ($basename) = $giturl =~ m{/([^/]*)$};
    my $dirname = "src/$basename";
    print "Updating $giturl\n";
    git_checkout($giturl, $dirname, 'master');
}
