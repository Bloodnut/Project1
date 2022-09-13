#!/usr/bin/perl

use CGI;
use DBI qw(:sql_types);

print "Content-Type: text/plain; charset=UTF-8\n\n";
my $queryString = $ENV{'QUERY_STRING'};
my $q = new CGI;
my $captureCPU = $q->param(cpu);
my $captureRAM = $q->param(ram);
print "\nWelcome to my new default landing page!\nHere's the query string you fed: $queryString";
print "\n\n If there's a value above, this worked! Here's the CPU: $captureCPU \n and here's the RAM: $captureRAM\n";
my $push = `/usr/bin/echo 'this script worked!! Here is the CPU: $captureCPU \n and here is the RAM: $captureRAM\n' >> /var/www/html/didThisWork.txt`;

print $push;

# JUICEY DATABASE STUFF

# Connect to the db, die if it doesn't work
my $dbh = DBI->connect("DBI:mysql:testdb", 'apacheserver', "Server123!x");
die "failed to connect to MySQL database:DBI->errstr()" unless($dbh);

# query prep and execute
my $sql = 'INSERT INTO cpuram (cpu, ram) VALUES (?, ?)';
my $sth = $dbh->prepare($sql)
                   or die "prepare statement failed: $dbh->errstr()";

$sth->execute($captureCPU, $captureRAM) or die "execution failed: $dbh->errstr()";

# disconnect from the dbh and finish
$sth->finish();
$dbh->disconnect();