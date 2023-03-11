#!/usr/bin/perl

use strict;
use warnings;
use DBI;


# script to connect to a hlstats database and parse frags to identify players who make quick frags
# this script is designed to be run from the command line
# it will output a list of players who have made quick frags and the time of the events
# use prepared statements to prevent sql injection

# Database
my $db_host = "localhost";
my $db_name = "hlxce";
my $db_user = "hlxce";
my $db_pass = "hlxce";

# Connect to database
my $dbh = DBI->connect("DBI:mysql:database=$db_name;host=$db_host", $db_user, $db_pass) or die "Can't connect to database: $DBI::errstr";

# Get all frags for a player
sub getFragsForPlayer ( $ ) {
    my $playerId = shift;
    my $sth = $dbh->prepare("SELECT *,unix_timestamp(eventTime) as timestamp FROM hlstats_Events_Frags WHERE killerId = ? ORDER BY eventTime ASC");
    $sth->execute($playerId);
    my @frags = ();
    while (my $ref = $sth->fetchrow_hashref()) {
        push @frags, $ref;
    }
    $sth->finish();
    return @frags;
}


# Get all players
sub getAllPlayers ( ) {
    my $sth = $dbh->prepare("SELECT playerId,name FROM hlstats_PlayerNames");
    $sth->execute();
    my @players = ();
    while (my $ref = $sth->fetchrow_hashref()) {
        push @players, $ref;
    }
    $sth->finish();
    return @players;
}

# Get all frags
my @players = getAllPlayers ( );

# Loop through all players
foreach my $player ( @players ) {
    my @frags = getFragsForPlayer ( $player->{playerId} );

    # Loop through all frags for a player and identify 3+ quick frags based on eventTime
    my $quickfrags = 0;
    my $lastfragtime = 0;
    
    foreach my $frag ( @frags ) {
        if ( $frag->{timestamp} - $lastfragtime < 5 ) {
            $quickfrags++;
        } else {
            if ( $quickfrags >= 3 ) {
                print $player->{name} . " made ".$quickfrags." quick frags on map: ".$frag->{map}." at: ".$frag->{eventTime}."\n";
            }
            $quickfrags = 0;
        }
        $lastfragtime = $frag->{timestamp};
    }
}

$dbh->disconnect();
