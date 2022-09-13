#!C:\Strawberry\perl\bin

use warnings;
use strict;
use autodie;
use URI; 
use LWP::UserAgent ();
use HTTP::Request::Common;


my $badusagemsg = "Bad usage: Correct usage is: Monitor.pl {\# of seconds} \n";
## 1. Get cmd line input from person... has to be a number in seconds

if ($#ARGV != 0) {
    die $badusagemsg;
}

my $time = $ARGV[0];
print "Nice one, I'll get the cpu and ram once per second for $time seconds\n\n";

## loop through $time amount of times 

for (my $i = 1; $i <= $time; $i++) {
    sendit();
    print "I've found the RAM and CPU ".$i." times\n";
}

sub sendit {
    
    #set vars
    my $baseUrl = "http://192.168.133.129";
    my $agent = new LWP::UserAgent;

    #Let's chuck our values in an array
    my $clientCPU = get_cpu();
    my $clientRAM = get_ram();

    #hash this for easy access
    my %values = (
    "cpu" => $clientCPU,
    "ram" => $clientRAM,
    );

    #build paramaters
    my $url = URI->new( $baseUrl );
    $url->query_form( %values );

    ## Let's make two requests
    my $request = HTTP::Request::Common::GET ($url);
    my $response = $agent->request($request);
}

sub get_cpu {
    print "Your CPU is: ";
    my $cpuOutput = `powershell.exe (wmic cpu get loadpercentage \/format:value)`;
    $cpuOutput =~ s/[^0-9]//g;
    print $cpuOutput . "\n";
    return $cpuOutput;
}

sub get_ram {
    print "Your RAM is: ";
    my $pscmd = "\$totalMem = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
    \$availMem = (Get-Counter \'\\Memory\\Available MBytes\').CounterSamples.CookedValue
    \[math\]\:\:round((104857600 * \$availMem / \$totalMem))";

    my $ramUsage = `powershell.exe -Command "$pscmd"`;
    print $ramUsage . "\n";
    return $ramUsage;
}

