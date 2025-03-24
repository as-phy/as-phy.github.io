#!/usr/local/bin/perl
use Math::Trig;

$fn1="boundary.data.org";
$fn2="boundary.data";

open(FIN,$fn1);
open(FOUT,">$fn2");
while($x=<FIN>){
    chomp($x);
    @w=split(/,/,$x);
    $ra1  = $w[0];
    $dec1 = $w[1];
    $ra2  = $w[2];
    $dec2 = $w[3];
    $rd1 = abs($ra2-$ra1)*cos(pi*($dec2+$dec1)/360);
    $rd2 = abs($dec2-$dec1);
    $rd  = $rd1*$rd1+$rd2*$rd2; 
    if($rd<25){ # 调违が５刨笆布
	printf FOUT ("%f, %f, %f, %f\n",$ra1,$dec1,$ra2,$dec2);
    }elsif($rd<100){ # 面爬を１改掐れる
	$rmid=($ra2+$ra1)/2;
	$dmid=($dec2+$dec1)/2;
	printf FOUT ("%f, %f, %f, %f\n",$ra1,$dec1,$rmid,$dmid);
	printf FOUT ("%f, %f, %f, %f\n",$rmid,$dmid,$ra2,$dec2);
    }else{ # 面爬を２改掐れる
	$rmid1=(  $ra2 +2*$ra1 )/3;
	$dmid1=(  $dec2+2*$dec1)/3;
	$rmid2=(2*$ra2 +  $ra1 )/3;
	$dmid2=(2*$dec2+  $dec1)/3;
	printf FOUT ("%f, %f, %f, %f\n",$ra1  ,$dec1 ,$rmid1,$dmid1);
	printf FOUT ("%f, %f, %f, %f\n",$rmid1,$dmid1,$rmid2,$dmid2);
	printf FOUT ("%f, %f, %f, %f\n",$rmid2,$dmid2,$ra2  ,$dec2 );
    }
}
close(FIN);
close(FOUT);
