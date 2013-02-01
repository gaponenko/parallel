#!/usr/bin/perl -w
#
# A script to run a number of tasks utilizing up to a given number of
# CPU cores on a host, useful on multi-core machines when a real batch
# system is not available.
#
# Andrei Gaponenko, 2013

use strict;
use POSIX ":sys_wait_h";

sub usage() {
    die "Usage:\n\n\tparallel.pl NUM_PROCS\n\nthen feed shell commands to run, one per line.\n";
}

usage() unless $#ARGV == 0;

die "Argument should be a positive integer, got $ARGV[0]\n"
    unless ($ARGV[0] =~ /^\d+$/) && ($ARGV[0] > 0);

my $nparallel = $ARGV[0];
my @kids = ();

#================================================================
sub get_next_command() {
    my $line;
    while(defined($line = <STDIN>)) {
	# skip comments and emtpy lines
	last unless (($line =~ /^ *$/)||($line =~ /^ *#/));
    }    
    return $line;
}

sub newchild() {

    return 0 unless my $line = get_next_command();

    my $pid = fork();
    die "Can't fork: $!\n" unless defined $pid;
    if($pid) {
	return $pid;
    }

    # We are in the child
    exec $line;
}

sub start_new_jobs() {
  STARTLOOP: while(1+$#kids < $nparallel) {
      my $pid = newchild();
      if($pid > 0) {
	  push @kids, $pid;
      }
      else {
	  last STARTLOOP;
      }
  }
}

#================================================================
do {
    start_new_jobs();
    sleep 1;

    print "checking status of ",(1+$#kids)," kids\n";
    my @newkids;
    foreach my $kid (@kids) {
	my $pid = waitpid($kid, WNOHANG);
	print "for kid $kid got wait = $pid\n";
	if(0 == $pid) {
	    push @newkids, $kid;
	}
    }
    @kids = @newkids;

} while ($#kids > -1);

print "All done\n";

exit 0;
