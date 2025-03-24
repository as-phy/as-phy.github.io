#!/usr/local/bin/perl

$fn1="planetarium/data/catalog.dat";
$fn2="tycho.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
while($x=<FIN>){
    chomp($x);
    @w=split(/\|/,$x);
    $ra = $w[2];
    $dec= $w[3];
    $bt = $w[17];
    $vt = $w[19];
    $mag=($vt+$bt)/2;
    $hip= $w[23];
    $hip =~ s/[A-z]//ge;
    printf FOUT ("%.3f, %.3f, %.1f, %s\n",$ra,$dec,$mag,$hip);
}
close(FIN);
close(FOUT);
