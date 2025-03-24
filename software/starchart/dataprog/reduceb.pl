#!/usr/local/bin/perl
use Math::Trig;

$fn1="planetarium/data/boundary.csv";
$fn2="test.data";

open(FIN,$fn1);
open(FOUT,">$fn2");

while($x=<FIN>){
    chomp($x);
    @w=split(/,/,$x);
    $ra1  = $w[1];
    $dec1 = $w[2];
    $ra2  = $w[3];
    $dec2 = $w[4];
    if($ra1>$ra2){
	$x=$ra1;  $ra1 =$ra2;  $ra2 =$x;
	$x=$dec1; $dec1=$dec2; $dec2=$x;
    }
    if($ra1==$ra2){
	if($dec1>$dec2){
	    $x=$ra1;  $ra1 =$ra2;  $ra2 =$x;
	    $x=$dec1; $dec1=$dec2; $dec2=$x;
	}
    }
    printf FOUT ("%f, %f, %f, %f\n",$ra1 ,$dec1, $ra2 ,$dec2);
}
close(FIN);
close(FOUT);

