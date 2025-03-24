#!/usr/local/bin/perl

# header
print "#FIG 3.2\n";
print "Landscape\n";
print "Center\n";
print "Metric\n";
print "A4\n";
print "100.00\n";
print "Single\n";
print "-2\n";
print "1200 2\n";
print "0 32 #808080\n";		# user defined color "grey"

# size w = (29.7/2.54)*1200 = 14031 
# この計算だと 1cm = 472 dot になるが、実際にやってみると
# 1cm = 450 dot になっているようだ。したがって
# size w = 29.7*450 = 13365
# size y = 21.0*450 =  9450
#
#(450,450)       (13050,450)
#   +-------6750------+
#   |        |        | w=12600
# 4725-------+--------+
#   |        |        | h= 8550
#   +--------+--------+
#(450,9000)      (13050,9000)
#
# range (-6300,-4275)-(6300,4275)
#
# 横90度の範囲を表示するとして
# 12600/90=140倍にすると、縦61度ぐらい（上下30度）

$origin=450;
$right=13050;
$bottom=9000;
$range=90;	# 表示範囲
$sf = 140;	# scale factor
		# 90°=140 60°=210 30°=420 
$xc = 6750;	# center x
$yc = 4725;	# center y
$rc = 90;	# right ascension center 中心位置の赤経
$dc = 0;	# declination center     中心位置の赤緯

# frame      2=bold
#print "2 2 0 2 0 7 50 -1 -1 0.000 0 0 -1 0 0 5\n";
#print "        450 450 13050 450 13050 9000 450 9000 450 450\n";

&radec;		# 赤経 赤緯線の表示
&boundary;	# 星座境界の表示
#&constellation; # 星座線の表示
&legend;	# 星のサイズ表示

$fn1="hip_lite.data";

open(FIN,$fn1);
$n=0;
while($x=<FIN>){
    chomp($x);
    @w=split(/, /,$x);
    $ra  = $w[0]-$rc;
    $dec = $w[1]-$dc;
    $mag = $w[2];
    if($ra <-$rr || $ra >$rr){ next; }
    if($dec<-$dr || $dec>$dr){ next; }
    $x = $xc-$ra *$sf;		# 右が赤経が小さい
    $y = $yc-$dec*$sf;		# 上が赤緯が小さい
    if($mag<1.5){	$r=20;	# 20 → 実サイズ 1mm
    }elsif($mag<2.5){	$r=15;
    }elsif($mag<3.5){	$r=10;
    }elsif($mag<5.0){	$r= 5;
    }elsif($mag<7.0){	$r= 1;
    }else{		next;  }
    #                 0:black 20:fill
    printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
    printf("%d %d %d %d %d %d %d %d\n",$x,$y,$r,$r,$x,$y,($x+$r),$y);
}
close(FIN);

#			10 point
#			===================  x    y
printf("4 0 0 50 -1 16 10 0.0000 4 120 210 7380 3780 Ori\\001\n");

exit;


#===============================================================

sub radec{
    # 赤経 赤緯線の表示
    $fn1="radec.data";
    open(FIN,$fn1);
    $n=0;
    $rr=$range/2;
    $dr=$range/3;
    while($x=<FIN>){
	chomp($x);
	@w=split(/,/,$x);
	$ra1  = $w[0]-$rc;	# 中心を(0,0)に移動
	$dec1 = $w[1]-$dc;
	$ra2  = $w[2]-$rc;
	$dec2 = $w[3]-$dc;
	if($ra1<-$rr || $ra1>$rr || $dec1<-$dr || $dec1>$dr){
	    if($ra2<-$rr || $ra2>$rr || $dec2<-$dr || $dec2>$dr){ next; }
	}
	$px1 = $xc-$ra1 *$sf;
	$py1 = $yc-$dec1*$sf;
	$px2 = $xc-$ra2 *$sf;
	$py2 = $yc-$dec2*$sf;
	#          2:dotted         2:ratio
	print "2 1 2 1 0 7 50 -1 -1 2.000 0 0 -1 0 0 2\n";
	printf("         %d %d %d %d\n",$px1,$py1,$px2,$py2);
    }
    close(FIN);
    # 赤経表示
    for($ra=$rc-$rr;$ra<=$rc+$rr;$ra=$ra+15){
	$ra1 = ($ra-0.15)-$rc;
	$dec1= ($dc-0.7)-$dc;
	$px = $xc-$ra1 *$sf;
	$py = $yc-$dec1*$sf;
	#                      7pt
	printf("4 0 0 50 -1 16 7 0.0000 4 75 135 %d %d %dh\\001\n",$px,$py,$ra/15);
    }
    # 赤緯表示
    for($dec=$dc-$dr;$dec<=$dc+$dr;$dec=$dec+10){
        $ra1 = ($rc -0.15)-$rc;
        $dec1= ($dec+0.15)-$dc;
        $px = $xc-$ra1 *$sf;
        $py = $yc-$dec1*$sf;
	printf("4 0 0 50 -1 16 7 0.0000 4 75 135 %d %d %+d\\001\n",$px,$py,$dec);
    }
}


sub boundary{
    # 星座境界の表示
    $fn1="planetarium/data/boundary.csv";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/,/,$x);
	$ra1  = $w[1]-$rc;	# 中心を(0,0)に移動
	$dec1 = $w[2]-$dc;
	$ra2  = $w[3]-$rc;
	$dec2 = $w[4]-$dc;
	if($ra1<-$rr || $ra1>$rr || $dec1<-$dr || $dec1>$dr){
	    if($ra2<-$rr || $ra2>$rr || $dec2<-$dr || $dec2>$dr){ next; }
	}
	#    if($ra1<45 || $ra1>135 || $ra2<45 || $ra2>135){ next; }
	#    if($dec1<-30 || $dec1>30 || $dec2<-30 || $dec2>30){ next; }
	$px1 = $xc-$ra1 *$sf;
	$py1 = $yc-$dec1*$sf;
	$px2 = $xc-$ra2 *$sf;
	$py2 = $yc-$dec2*$sf;
	#          1:dashed          2:ratio
	print "2 1 1 1 32 7 50 -1 -1 2.000 0 0 -1 0 0 2\n";
	printf("         %d %d %d %d\n",$px1,$py1,$px2,$py2);
    }
    close(FIN);
}

sub constellation{
    # 星座線の表示
    $fn1="hip_constellation_line.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$ra1  = $w[0]-$rc;	# 中心を(0,0)に移動
	$dec1 = $w[1]-$dc;
	$ra2  = $w[2]-$rc;
	$dec2 = $w[3]-$dc;
	if($ra1<-$rr || $ra1>$rr || $dec1<-$dr || $dec1>$dr){
	    if($ra2<-$rr || $ra2>$rr || $dec2<-$dr || $dec2>$dr){ next; }
	}
	$px1 = $xc-$ra1 *$sf;
	$py1 = $yc-$dec1*$sf;
	$px2 = $xc-$ra2 *$sf;
	$py2 = $yc-$dec2*$sf;
	#          1:dashed          2:ratio
	print "2 1 0 1 32 7 50 -1 -1 2.000 0 0 -1 0 0 2\n";
	printf("         %d %d %d %d\n",$px1,$py1,$px2,$py2);
    }
    close(FIN);
}

sub legend{
    # 星のサイズ表示
    for($i=1;$i<=5;$i++){
	$x = $right-2000+$i*275;
	$y = $bottom+60;
	if($i==1){	$r=20;
	}elsif($i==2){	$r=15;
	}elsif($i==3){	$r=10;
	}elsif($i==4){	$r= 5;
	}elsif($i==5){	$r= 1; }
	#                 0:black 20:fill
	printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
	printf("%d %d %d %d %d %d %d %d\n",$x,$y,$r,$r,$x,$y,($x+$r),$y);
    }
    $px=$right-2050;
    $py=$bottom+100;
    printf("4 0 0 50 -1 16 7 0.0000 4 75 135 %d %d Mag:    1.0",$px,$py);
    printf("    2.0    3.0    4.0    <5.0\\001\n");
}

