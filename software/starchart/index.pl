#!/usr/local/bin/perl

print "<!DOCTYPE HTML>\n";
print "<HTML>\n";
print " <HEAD>\n";
print "  <TITLE>Index of starchart</TITLE>\n";
print " </HEAD>\n";
print " <BODY>\n";
print "<H1>Index of starchart</H1>\n";
open(FIN,"filelist");
while($x=<FIN>){
    chomp($x);
    printf("<LI><a href=\"%s\"> %s </a></LI>\n",$x,$x);
}
close(FIN);
print "</UL>\n";
print "</BODY>\n</HTML>\n";
