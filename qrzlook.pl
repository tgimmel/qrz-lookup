#!/usr/bin/perl -w
use strict;
use Ham::Reference::QRZ;
use Data::Dumper;

my ($input, $startime, $timenow, $sesstime);
$startime = time;

my $qrz = Ham::Reference::QRZ->new (
                                   username => 'yourCall',
                                   password => 'ChangeMe'
                                  );
#little add

$qrz->login;
my $session = $qrz->get_session;
my $key = $session->{ Key };
print "$key \n";
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
   print "Startime: $startime  Timenow: $timenow  SessionTime: $sesstime \n";
   if ($sesstime > 2700) {
      $qrz->login;
      $session = $qrz->get_session;
      $key = $session->{ Key };
      print "SessID: $key \n";
      print "Session renewed. \n";
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
}

sub session {
    my $session = $qrz->get_session;
    my $key = $session->{ Key };
    return $key;
    #print Dumper($session);
}
   #my $bio = $qrz->get_bio;
   #my $dxcc = $qrz->get_dxcc;
   #my $session = $qrz->get_session;

   #dump the data to see how it's structured
   #print Dumper($listing);
   #print Dumper($bio);
   #print Dumper($dxcc);
   #print Dumper($session);




