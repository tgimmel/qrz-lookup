#!/usr/bin/perl -w
use strict;
use Ham::Reference::QRZ;
use Data::Dumper;

my ($input, $startime, $timenow, $sesstime, %log);
$startime = time;
loadlogbook();

my $qrz = Ham::Reference::QRZ->new (
                                   username => 'ky4j',
                                   password => ''
                                  );

$qrz->login;
my $session = $qrz->get_session;
my $key = $session->{ Key };
#print "$key\n";

while ()  {
   renewses();
   print "\nEnter callsign (q to exit): ";
   chomp($input = <STDIN>);
   if ($input eq "q" || $input eq "Q") { exit; }
   if ($key) {
        $qrz->set_key($key);
   } else {
        $key = session();
   }
   lookup($input);
}
##############
#
# sub renewses
# Since we dont really know when a session expires,
# We just take a crack at it every 45 minutes.
#
sub renewses {
   $timenow = time;
   $sesstime = $timenow - $startime;
#   print "Startime: $startime  Timenow: $timenow  SessionTime: $sesstime \n";
   if ($sesstime > 2700) {
      $qrz->login;
      $session = $qrz->get_session;
      $key = $session->{ Key };
#      print "SessID: $key \n";
#      print "Session renewed. \n";
      $startime = time;
   }
}
sub lookup {
   my $call = shift;
   chomp($call);
   $qrz->set_callsign($call);
   my $listing;
   unless ($listing = $qrz->get_listing) { print "Call: Call not found!\n"; return; }
   print "\nCountry: $listing->{ country }       Call: $listing->{ call }\n";
   print "Name: $listing->{ fname } $listing->{ name }\n";
   if ($listing->{ addr1 }) { print "Addr: $listing->{ addr1 }\n"; }
   if ($listing->{ addr2 }) { print "Addr: $listing->{ addr2 }"; } else { print "\n"; }
   if ($listing->{ state }) { print "             State: $listing->{ state }\n"; } else { print "\n"; }
   if ($listing->{ url }) { print "URL: $listing->{ url }\n";
       } elsif
       ($listing->{ url }) { print "URL: $listing->{ bio }\n";
   }
   if ($listing->{ grid }) { print "Grid: $listing->{ grid }\n"; }
   if ($listing->{ qslmgr }) { print "QSL Mgr: $listing->{ qslmgr }\n";}
   ($listing->{ lotw }) ? print "LoTW: Yes\n" : print "LoTW: No\n";
   ($listing->{ eqsl }) ? print "eqsl: Yes\n" : print "eqsl: No\n";
   ($listing->{ mqsl }) ? print "Mail QSL: Yes\n" : print "Mail QSL: No\n";
   print "\n";
   print "Previous QSO's:\n";
   qsolookup(uc($call));
}

sub session {
    my $session = $qrz->get_session;
    my $key = $session->{ Key };
    return $key;
    #print Dumper($session);
}
##################
#
# sub qsolookup
# Give it a call and prints out
# QSO Records
# 
sub qsolookup {
    my $call = shift;
    my $found = 0;
    foreach my $rec (@{$log { $call }}) {
         $found = 1;
         print STDERR "$rec \n";
      }
    unless ($found) { print STDERR "None!\n"; }
}
#################
#
# sub loadlogbook
# Opens jLog logbook file and reads into
# an anonymous list with a hash for a key
#
sub loadlogbook {
                        #Set file and path for you setup
   open my $fh_log, "<", "RegularLogbook-KY4J.jdb" or die "Unable to open Logbook: $!";
   my ($line, $c, @logrec, $date, $time, $call, $band, $mode, $qsoinfo);
   while ($line = <$fh_log>) {
       chomp($line);
       $line =~ s/^\s+//g;
       ($date, $time, $call, $band, $mode) = split(/;/,$line);
       #Load the hash
       $qsoinfo = "$date $time $band $mode";
       $log{$call} = [] unless ($log{$call});  #Create empty array unless already done.
       push (@{$log{$call}}, $qsoinfo);
       $c++;
   }
   print "Loaded $c records.\n";
   close $fh_log;
}





