#!/usr/local/bin/perl

$fn1="planetarium/data/cluster.data";
$fn2="cluster.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
$x=<FIN>;
while($x=<FIN>){
    chomp($x);
    @w=split(/ +/,$x);
    $num = $w[0];
    $ra  = ($w[1]+$w[2]/60+$w[3]/3600)*15;
    $dec = $w[4]+$w[5]/60+$w[6]/3600;
    $mag = $w[7];
    if($w[8]>$w[9]){
	$size = $w[8];
    }else{
	$size = $w[9];
    }
    if($mag ne 'U'){
	printf FOUT ("NGC%s, %.4f, %.4f, %.1f, %.1f\n",$num,$ra,$dec,$mag,$size);
    }
}
close(FIN);
close(FOUT);

exit;

$fn1="planetarium/data/nebula.data";
$fn2="nebula.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
$x=<FIN>;
while($x=<FIN>){
    chomp($x);
    @w=split(/ +/,$x);
    $num = $w[0];
    $ra  = ($w[1]+$w[2]/60+$w[3]/3600)*15;
    $dec = $w[4]+$w[5]/60+$w[6]/3600;
    $mag = $w[7];
    if($w[8]>$w[9]){
	$size = $w[8];
    }else{
	$size = $w[9];
    }
    if($mag eq 'U'){
	printf FOUT ("NGC%s, %.4f, %.4f, U, %.1f\n",$num,$ra,$dec,$size);
    }else{
	printf FOUT ("NGC%s, %.4f, %.4f, %.1f, %.1f\n",$num,$ra,$dec,$mag,$size);
    }
}
close(FIN);
close(FOUT);

exit;

$fn1="planetarium/data/garaxy.data";
$fn2="garaxy.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
$x=<FIN>;
while($x=<FIN>){
    chomp($x);
    @w=split(/ +/,$x);
    $num = $w[0];
    $ra  = ($w[1]+$w[2]/60+$w[3]/3600)*15;
    $dec = $w[4]+$w[5]/60+$w[6]/3600;
    $mag = $w[7];
    if($w[8]>$w[9]){
	$size = $w[8];
    }else{
	$size = $w[9];
    }
    printf FOUT ("NGC%s, %.4f, %.4f, %.1f, %.1f\n",$num,$ra,$dec,$mag,$size);
}
close(FIN);
close(FOUT);

exit;

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

$fn1="planetarium/data/hip_constellation_line.csv";
$fn2="hip_constellation_line.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
while($x=<FIN>){
    chomp($x);
    @w=split(/,/,$x);
    $st = $w[1];
    $en = $w[2];
    printf FOUT ("%f, %f, %f, %f, %s\n",$ra{$st},$dec{$st},$ra{$en},$dec{$en},$w[0]);
}
close(FIN);
close(FOUT);

exit;


$fn1="planetarium/data/hip_lite_major.csv";
$fn2="hip_lite_major.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
while($x=<FIN>){
    chomp($x);
    @w=split(/,/,$x);
    $ra_h = $w[1];
    $ra_m = $w[2];
    $ra_s = $w[3];
    $dec_sign=$w[4];
    $dec_deg= $w[5];
    $dec_m  = $w[6];
    $dec_s  = $w[7];
    $mag    = $w[8];
    $ra = ($ra_h + $ra_m / 60 + $ra_s / 3600) * 15;
    $dec = $dec_deg + $dec_m / 60 + $dec_s / 3600;
    if($dec_sign==0){
	$dec = -$dec;
    }
    printf FOUT ("%f, %f, %.2f, %d\n",$ra,$dec,$mag,$w[0]);
}
close(FIN);
close(FOUT);

exit;


$fn1="planetarium/data/hip_lite.csv";
$fn2="hip_lite.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
while($x=<FIN>){
    chomp($x);
    @w=split(/,/,$x);
    $ra_h = $w[1];
    $ra_m = $w[2];
    $ra_s = $w[3];
    $dec_sign=$w[4];
    $dec_deg= $w[5];
    $dec_m  = $w[6];
    $dec_s  = $w[7];
    $mag    = $w[8];
    $ra = ($ra_h + $ra_m / 60 + $ra_s / 3600) * 15;
    $dec = $dec_deg + $dec_m / 60 + $dec_s / 3600;
    if($dec_sign==0){
	$dec = -$dec;
    }
    printf FOUT ("%f, %f, %.2f, %d\n",$ra,$dec,$mag,$w[0]);
}
close(FIN);
close(FOUT);

exit;

