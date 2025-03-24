#!/usr/local/bin/perl
use Math::Trig;

$fn1="planetarium/data/constellation_name_sjis.csv";
$fn2="center.data";
$fn3="name.data";

open(FIN1,$fn1);
open(FIN2,$fn2);
open(FOUT,">$fn3");

for($i=0;$i<89;$i++){
    $x=<FIN1>;
    chomp($x);
    @w=split(/,/,$x);
    $y=<FIN2>;
    chomp($y);
    @u=split(/, /,$y);
    $name=$w[2];
    $cx  =$u[1];
    $cy  =$u[2];
    printf FOUT ("%s, %.2f, %.2f\n",$name,$cx,$cy);
}

close(FIN1);
close(FIN2);
close(FOUT);
