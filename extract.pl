#!/usr/bin/perl

use strict;
use utf8;

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');

my %months = (
    'January' => 1,
    'February' => 2,
    'March' => 3,
    'April' => 4,
    'May' => 5,
    'June' => 6,
    'July' => 7,
    'August' => 8,
    'September' => 9,
    'October' => 10,
    'November' => 11,
    'December' => 12 );

while (my $line=<STDIN>) {
    chomp $line;
    my ($pdf, $terms, $t) = split/\t/,$line;

    my @fields = ();

    if (my ($day, $month, $year) = ($t =~ /([1-9]|[12][0-9]|3[01]) (January|February|March|April|May|June|July|August|September|October|November|December) (20\d\d)/)) {
        my $month_number = $months{$month};
        push @fields, "report_date=$year-". sprintf("%02d", $month_number). "-". sprintf("%02d", $day);
    }

    if (my ($number) = ($t =~ /(\d{6,7})/)) {
        push @fields, "charity_number=${number}"
    }

    print join(" ", @fields), "\n";
}
