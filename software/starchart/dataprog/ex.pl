#!/usr/local/bin/perl

$fn1="NI2021s.data";
open(FIN,$fn1);
$n=0;
while($x=<FIN>){
    chomp($x);
    @w=split(/ /,$x);
    $ngc[$n] = $w[0];
    $n++;
}
close(FIN);

$fn1="garaxy.data";
$fn2="exgara.data";
#$fn1="cluster.data";
#$fn2="excluster.data";
#$fn1="nebula.data";
#$fn2="exnebula.data";

open(FIN,$fn1);
open(FOUT,">$fn2");

while($x=<FIN>){
    chomp($x);
    @w=split(/, /,$x);
    $num = $w[0];
    $num =~ s/NGC//;
    $check=0;
    for($i=0;$i<$n;$i++){
	if($num==$ngc[$i]){
	    $check=1;
	    last;
	}
    }
    if($check==0){
	printf FOUT ("%s\n",$x);
    }
}
close(FIN);
close(FOUT);

exit;
