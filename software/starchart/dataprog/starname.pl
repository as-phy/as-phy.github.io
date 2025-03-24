#!/usr/local/bin/perl

$fn1="hip_lite.data";
open(FIN,$fn1);
while($x=<FIN>){
    chomp($x);
    @w=split(/, /,$x);
    $num = $w[3];
    $ra{$num}=$w[0];
    $dec{$num}=$w[1];
}
close(FIN);

$fn1="planetarium/data/hip_proper_name.csv";
$fn2="starname.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
while($x=<FIN>){
    chomp($x);
    @w=split(/,/,$x);
    $name = $w[1];
    $num  = $w[0];
    printf FOUT ("%s, %f, %f\n",$name,$ra{$num},$dec{$num});
}
close(FIN);
close(FOUT);

exit;

