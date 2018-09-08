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
my %commands;

my $progress_startcount = 0;
my $progress_exitcount = 0;

#================================================================
# This is to allow runtime modification of the number of parallel jobs.
# If the limit is increased, new jobs start 

sub increase_limit { ++$nparallel; }
$SIG{USR1} = \&increase_limit;

sub decrease_limit { --$nparallel unless $nparallel < 2; }
$SIG{USR2} = \&decrease_limit;


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

    print localtime() . " [",++$progress_startcount,"]: About to do: $line";

    my $pid = fork();
    die "Can't fork: $!\n" unless defined $pid;
    if($pid) {
	$commands{$pid} = $line;
	chomp $commands{$pid};
	return $pid;
    }

    # We are in the child
    exec $line;
}

sub start_new_jobs() {
    my $nstarted = 0;

  STARTLOOP: while(1+$#kids < $nparallel) {
      my $pid = newchild();
      if($pid > 0) {
	  push @kids, $pid;
	  print localtime() . ": Process $pid started\n";
	  ++$nstarted;
      }
      else {
	  last STARTLOOP;
      }
  }

    return $nstarted;
}

#================================================================
my $nnew = 0;
my $last_printed_limit = $nparallel;
do {
    my @newkids;
    foreach my $kid (@kids) {
	my $pid = waitpid($kid, WNOHANG);
	my $pidstatus = $?;
	if(0 == $pid) {
	    push @newkids, $kid;
	}
	else {
	    print localtime() . " [",++$progress_exitcount,"]: Process $pid finished with status $pidstatus ( ".$commands{$pid}." )\n";
	    delete $commands{$pid};
	}
    }

    @kids = @newkids;

    $nnew = start_new_jobs();

    sleep 1;
    if($last_printed_limit != $nparallel) {
	print localtime() . " Current nparallel = $nparallel\n";
	$last_printed_limit = $nparallel;
    }

} while (($#kids > -1) || ($nnew > 0));

print localtime() . ": All done\n";

exit 0;
