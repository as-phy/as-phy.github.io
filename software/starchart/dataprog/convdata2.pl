#!/usr/local/bin/perl

$fn1="workdata/huruta.data";
open(FIN,$fn1);
$n=0;
while($x=<FIN>){
    chomp($x);
    $ngc[$n] = $x;
    $n++;
}
close(FIN);


$fn1="garaxy.data";
$fn2="huruta.data";

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
    if($check==1){
        printf FOUT ("%s\n",$x);
    }
}
close(FIN);
close(FOUT);

exit;


$fn1="workdata/IC.data";
$fn2="IC.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
$x=<FIN>;
while($x=<FIN>){
    chomp($x);
    @w=split(/ +/,$x);
    $num = $w[0];
    $ra  = ($w[1]+$w[2]/60+$w[3]/3600)*15;
    $dec_sign=$w[4];
    $dec_deg= $w[5];
    $dec_m  = $w[6];
    $dec_s  = $w[7];
    $mag    = $w[8];
    $dec = $dec_deg + $dec_m / 60 + $dec_s / 3600;
    $size = $w[9];
    if($dec_sign eq '-'){
        $dec = -$dec;
    }
    printf FOUT ("%s, %.4f, %.4f, %.1f, %.1f\n",$num,$ra,$dec,$mag,$size);
}
close(FIN);
close(FOUT);

exit;


$fn1="workdata/NGC.data";
$fn2="NGC.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
$x=<FIN>;
while($x=<FIN>){
    chomp($x);
    @w=split(/ +/,$x);
    $num = $w[0];
    $ra  = ($w[1]+$w[2]/60+$w[3]/3600)*15;
    $dec_sign=$w[4];
    $dec_deg= $w[5];
    $dec_m  = $w[6];
    $dec_s  = $w[7];
    $mag    = $w[8];
    $dec = $dec_deg + $dec_m / 60 + $dec_s / 3600;
    $size = $w[9];
    if($dec_sign eq '-'){
        $dec = -$dec;
    }
    printf FOUT ("NGC%s, %.4f, %.4f, %.1f, %.1f\n",$num,$ra,$dec,$mag,$size);
}
close(FIN);
close(FOUT);

exit;
