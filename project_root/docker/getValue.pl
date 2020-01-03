#!/usr/bin/perl
#
#
use JSON::XS;
use Getopt::Long qw(GetOptions);
my $server = undef;
GetOptions(
	'server:s' => \$server,
) or die;

while(1)
{
 my $curl_result = `curl -s https://api.coindesk.com/v1/bpi/currentprice/usd.json`;
 my $json_hash = decode_json $curl_result;
 my $usd = $json_hash->{bpi}->{USD}->{rate};
 $usd =~ s/,//g;
 # print "$usd\n";
 my $epoch = time;
 use MongoDB ();
 #my $host_ip = `/sbin/ip route | awk '/default/ { print \$3 }'`;
 #chomp($host_ip);
 my $client = MongoDB::MongoClient->new(host => $server, port => 27017);
 my $db = $client->get_database('values_coins_3');
 my $values_coll = $db->get_collection('coins');
 my $coins = $values_coll->find;
 my $last_value = $usd;
 my $count = 1;
 my $min=$usd;
 my $max = $usd;
 my $total = $usd;
 my $avg = $usd;
 # print "Current value: $usd\n";
 #print "DB entries:\n";
 while (my $c = $coins->next)
 {
    my $coinValue = $c->{coinValue};
    my $epoch = $c->{epoch};
    #  print "CoinVal: $coinValue Epoch: $epoch\n";
    $last_value = $coinValue;
    $count++;
    $total+=$coinValue;
    $min = $coinValue if $coinValue < $min;
    $max = $coinValue if $coinValue > $max;
 }
 $values_coll->insert_one({
		 coinValue => $usd,
		 epoch => $epoch,
	 });
 my $avg_raw = $total/$count;
 $avg = sprintf("%.3f",$avg_raw);
 print "AVG: $avg MIN: $min MAX: $max\n";
 if ($usd < $last_value)
 {
   print "$usd is smaller than last value $last_value, you should buy!\n";
 }
 if ($usd > $last_value)
 {
   print "$usd is larger than last value $last_value, you should sell!\n";
 }if ($usd == $last_value)
 {
   print "$usd is the same as before, do nothing!\n";
 }
 print "=================================================================\n";
 sleep(60);
}
