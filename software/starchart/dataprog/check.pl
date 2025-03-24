#!/usr/local/bin/perl

$fn1="hip_lite_major.data";

open(FIN,$fn1);
while($x=<FIN>){
    chomp($x);
    @w=split(/,/,$x);
    $x{$w[0]} = $w[1];
    $y{$w[0]} = $w[2];
}
close(FIN);

$fn1="hip_constellation_line_star.data";
$fn2="comp.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
while($x=<FIN>){
    chomp($x);
    @w=split(/,/,$x);
    $s = $w[0];
    $u = $w[1];
    $v = $w[2];
    if($u != $x{$s}){
	if($v != $y{$s}){
	    printf FOUT ("%s, %f, %f, %f, %f\n",$s,$u,$x{$s},$v,$y{$s});
	}
    }
}
close(FIN);
close(FOUT);
