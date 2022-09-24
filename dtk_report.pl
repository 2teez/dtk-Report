#!/usr/bin/perl
use warnings;
use strict;
use File::Find qw/find/;
use autodie qw/open close/;
use Cwd qw/abs_path/;
use Data::Dumper;

## verify the timer:
## the time must be between 0 and 23
if ( $ARGV[0] < 0 && $ARGV[0] > 23 ) {
    print "Enter a valid report time between 0 & 23.";
    exit 1;
}

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

collate( read_file($files) );

sub read_file {
    my $files = shift;

    my $content = {};
    my $header;

    for my $file ( @{$files} ) {
        open my $fh, '<', "$file";
        while (<$fh>) {
            if (/.?((outgo|incom)ing)/i) {
                $header = $1;
            }
            else {
                my $data = [ split /,/ ];

                ## modified the date
                my $day =
                  @{ [ split /\s+?/ => @$data[2] ] }[0];
                $day =~ s/"(.+)/$1/;

                ## modified name
                ( my $name = @$data[0] ) =~ s/"(.*)\(.*$/$1/img;

                ## get content for each hour
                push @{ $content->{$day}{$header}{$name} } =>
                  [ @$data[ 4 .. 9 ] ]
                  if $data->[2] =~ /$ARGV[0]:00:00/;
            }
        }
        close $fh;
    }
    return $content;
}

sub collate {
    my $data = shift;
    for my $day ( sort { $a cmp $b } keys %{$data} ) {
        print $day, $/;
        for my $key ( sort { $a cmp $b } keys %{ $data->{$day} } ) {
            print $key, $/;
            print title(), $/;
            for my $name ( sort { $a cmp $b } keys %{ $data->{$day}{$key} } ) {
                print $name, "\t",
                  join( "\t" => @{ @{ $data->{$day}{$key}{$name} }[0] } ), $/;
            }
        }
    }
}

sub title {
    my $msg =
"Incoming or bidirection trunk group|Number of Installed Circuits (PIECES)|";
    $msg .=
"Number of Available Circuits (PIECES)|Number of Blocked Circuits (PIECES)|";
    $msg .=
"Call Completion Rate (PERCENT)|Answer Rate (PERCENT)	Seizure Traffic (ERL";
    return join( "\t" => @{ [ split /\|/ => $msg ] } );
}
