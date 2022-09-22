#!/usr/bin/perl
use warnings;
use strict;
use File::Find qw/find/;
use autodie qw/open close/;
use Cwd qw/abs_path/;
use Data::Dumper;

## search to see if incoming and outgoing
## trunk group files exist

## files to seek
my $files = [];

# search and get the name of files
find(
    sub {
        push @$files => abs_path($_) if /\.*?\.csv$/i;
    },
    "datafiles"
);

if ( scalar(@$files) != 2 ) {
    print "There must be atleast two files in 'datafiles' directory.\n";
    exit 1;
}
else {
    my $counter = 0;
    for (@$files) {
        $counter++
          if
/ne_5_Incoming_Calls_through_Trunk_Groups|ne_5_Outgoing_Calls_through_Trunk_Groups/;
    }
    exit 1 if $counter != 2;
}

for my $file (@$files) {
    if ( $file eq '.' ) {
        next;
    }
    read_file($file);
}

sub read_file {
    ( my $file ) = shift;

    my $content = {};
    my $header;

    open my $fh, '<', "$file";
    while (<$fh>) {
        if (/.?((outgo|incom)ing)/i) {
            print $1, $/;
            $header = $1;
        }
        else {
            my $data = [ split /,/ ];
            my $day =
              @{ [ split /\s+?/ => @$data[2] ] }[0];
            $day =~s/"(.+)/$1/;
						push @{$content->{$header}{$day}{@$data[0]}} => [@$data[4..9]]
              #print join " | " => @$data[ 0, 2, 4 .. 9 ], $/;

        }
    }
		close $fh;
		print Dumper($content)

}
