#!/usr/local/bin/perl
use Math::Trig;

$fn1="planetarium/data/boundary.csv";
$fn2="center.data";

open(FIN,$fn1);
open(FOUT,">$fn2");

$n=1;
$pp=0;
$check1=0;
$check2=0;
while($x=<FIN>){
    chomp($x);
    @w=split(/,/,$x);
    if($w[0]!=$n){
	$rsum=0;
	$dsum=0;
	for($i=0;$i<$pp;$i++){
	    if($check1==1 && $check2==1 && $ra[$i]>300){
		$ra[$i]=$ra[$i]-360;
	    }
	    $rsum=$rsum+$ra[$i];
	    $dsum=$dsum+$dec[$i];
	}
	$cx=$rsum/$pp;
	if($cx<0){ $cx += 360; }
	$cy=$dsum/$pp;
	printf FOUT ("%d, %.2f, %.2f\n",$n,$cx,$cy);
	$n++; $pp=0;
	$check1=0; $check2=0;
    }
    $ra[$pp]  = $w[1];
    if($w[1]<15){ $check1=1; }
    if($w[1]>345){ $check2=1; }
    $dec[$pp] = $w[2];
    $pp++;
}
# No.89
$rsum=0;
$dsum=0;
for($i=0;$i<$pp;$i++){
    if($check1==1 && $check2==1 && $ra[$i]>300){
	$ra[$i]=$ra[$i]-360;
    }
    $rsum=$rsum+$ra[$i];
    $dsum=$dsum+$dec[$i];
}
$cx=$rsum/$pp;
if($cx<0){ $cx += 360; }
$cy=$dsum/$pp;
printf FOUT ("%d, %.2f, %.2f\n",$n,$cx,$cy);

close(FIN);
close(FOUT);
