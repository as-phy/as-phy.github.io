#!/usr/local/bin/perl

$fn1="NI2021.data";
$fn2="messier.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
while($x=<FIN>){
    chomp($x);
    @w=split(/ /,$x);
    $num  = $w[0];
    $ra  = ($w[1]+$w[2]/60+$w[3]/3600)*15;
    $dec = $w[4]+$w[5]/60+$w[6]/3600;
    $name = $w[7];
    printf FOUT ("%s, %f, %f, NGC%s\n",$name,$ra,$dec,$num);
}
close(FIN);
close(FOUT);

exit;

