#!/usr/local/bin/perl
use Math::Trig;

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
#(450,450)	 (13050,450)
#   +-------6750------+
#   |	     |	      | w=12600
# 4725-------+--------+
#   |	     |	      | h= 8550
#   +--------+--------+
#(450,9000)	 (13050,9000)
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
$dc = 0;	# declination center	 中心位置の赤緯
    
# frame      2=bold
#print "2 2 0 2 0 7 50 -1 -1 0.000 0 0 -1 0 0 5\n";
#print "        450 450 13050 450 13050 9000 450 9000 450 450\n";

&radec;		# 赤経 赤緯線の表示
&boundary;	# 星座境界の表示
&constellation; # 星座線の表示
&name;		# 星座名の表示
#&legend;	# 星のサイズ表示
&magellan;	# マゼラン雲の表示
&star;		# 恒星
&starname;	# 恒星名
&messier;	# メシエ（＋名前）
&cluster;	# 星団
&nebula;	# 星雲

$garaxylimit=13;
$garaxynamelimit=12;

$fn1="garaxy.data";

open(FIN,$fn1);
$n=0;
while($x=<FIN>){
    chomp($x);
    @w=split(/, /,$x);
    $w[0] =~ s/NGC//;
    $ra  = periodic($w[1]-$rc);
    $dec = $w[2];
    $mag = $w[3];
    if($mag>$garaxylimit){ next; }
    if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
    ($px,$py)=cylindrical($ra,$dec);
    if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
    $r = 12;
    #	   楕円     0:black   -1:not fill
    printf("1 1 0 1 0 7 50 -1 -1 0.000 1 0.0000 ");
    printf("%d %d %d %d %d %d %d %d\n",$px,$py,2*$r,$r,$px,$py,($px+2*$r),$py+$r);
    if($mag>$garaxynamelimit){ next; }
    $px += 35;
    $py += 25;
    printf("4 0 0 50 -1 16 4 0.0000 4 75 150 %d %d %s\\001\n",$px,$py,$w[0]);
}
close(FIN);


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
	$ra1  = periodic($w[0]-$rc);
	$dec1 = $w[1];
	$ra2  = periodic($w[2]-$rc);
	$dec2 = $w[3];
	if($ra1<-90 || $ra1>90){
	    if($ra2<-90 || $ra2>90){ next; }	# 裏側は表示しない
	}
	($px1,$py1)=cylindrical($ra1,$dec1);
	($px2,$py2)=cylindrical($ra2,$dec2);
	&drawline($px1,$py1,$px2,$py2,2,0);	# 2,0=dotted, black
    }
    close(FIN);
    # 赤経表示
    for($ra=$rc-$rr;$ra<=$rc+$rr;$ra=$ra+15){
	$ra1 = ($ra-$rc)-0.15;
	$dec1=	$dc	-0.7;
	 ($px,$py)=cylindrical($ra1,$dec1);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	if($ra<0){
	    $h=($ra+360)/15;
	}elsif($ra>345){
	    $h=($ra-360)/15;
	}else{
	    $h=$ra/15;
	}
	#		       7pt
	printf("4 0 0 50 -1 16 7 0.0000 4 105 195 %d %d %dh\\001\n",$px,$py,$h);
    }
    # 赤緯表示
    for($dec=$dc-$dr;$dec<=$dc+$dr;$dec=$dec+10){
	$ra1 = ($rc -$rc) -0.15;
	$dec1=	$dec	  +0.15;
	($px,$py)=cylindrical($ra1,$dec1);
	printf("4 0 0 50 -1 16 7 0.0000 4 105 195 %d %d %+d\\001\n",$px,$py,$dec);
    }
}

sub boundary{
    # 星座境界の表示
    $fn1="boundary.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$ra1  = periodic($w[0]-$rc);
	$dec1 = $w[1];
	$ra2  = periodic($w[2]-$rc);
	$dec2 = $w[3];
	if($ra1<-90 || $ra1>90){
	    if($ra2<-90 || $ra2>90){ next; }	# 裏側は表示しない
	}
	($px1,$py1)=cylindrical($ra1,$dec1);
	($px2,$py2)=cylindrical($ra2,$dec2);
	&drawline($px1,$py1,$px2,$py2,1,32);	# 1,32=dashed, grey
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
	$ra1  = periodic($w[0]-$rc);	# 中心を(0,0)に移動 ra回転
	$dec1 = $w[1];			# dec回転は cylindrical でやる
	$ra2  = periodic($w[2]-$rc);
	$dec2 = $w[3];
	if($ra1<-90 || $ra1>90){
	    if($ra2<-90 || $ra2>90){ next; }	# 裏側は表示しない
	}
	($px1,$py1)=cylindrical($ra1,$dec1);
	($px2,$py2)=cylindrical($ra2,$dec2);
	&drawline($px1,$py1,$px2,$py2,0,32);	# 0,32=solid, grey
    }
    close(FIN);
}

sub name{
    $fn1="name.data";
    open(FIN,$fn1);
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$name= $w[0];
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	$len = 80*length($name);		# はみ出る名前は表示しない
	if($px<$origin || ($px>$right-$len) || $py<$origin || $py>$bottom){ next; }
	#			10 point
	#			===================
	printf("4 0 32 50 -1 16 10 0.0000 4 120 210 %d %d %s\\001\n",$px,$py,$name);
    }
    close(FIN);
}

sub star{
    $fn1="hip_lite.data";
    open(FIN,$fn1);
    $n=0;	
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$ra  = periodic($w[0]-$rc);
	$dec = $w[1];
	$mag = $w[2];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	if($mag<1.5){	$r=20;		# 20 → 実サイズ 1mm
	}elsif($mag<2.5){	$r=15;
	}elsif($mag<3.5){	$r=10;
	}elsif($mag<5.0){	$r= 5;
	}elsif($mag<7.0){	$r= 1;
	}else{		next;  }	# 7等以下は表示しない
	#		0:black   20:fill
	printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
	printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
    }
    close(FIN);
}

sub starname{
    $fn1="starname.data";
    open(FIN,$fn1);
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$name= $w[0];
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	$px += 30;
	$py += 35;
	$len = 48*length($name);		# はみ出る名前は表示しない
	if($px<$origin || $px>($right-$len) || $py<$origin || $py>$bottom){ next; }
	printf("4 0 0 50 -1 16 6 0.0000 4 90 150 %d %d %s\\001\n",$px,$py,$name);
    }
    close(FIN);
}

sub magellan{
    # Magellan
    @w=("LMC", 80.89375, -69.75611, 4,
	"SMC", 13.18667, -72.82861, 2);
    for($i=0;$i<2;$i++){
	$name=$w[$i*4];
	$ra  = periodic($w[$i*4+1]-$rc);
	$dec = $w[$i*4+2];
	if($ra<-90 || $ra>90){ next; }      # 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$r = $sf*$w[$i*4+3];
	#		0:black   -1:not fill
	printf("1 3 0 1 0 7 50 -1 -1 0.000 1 0.0000 ");
	printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
	printf("4 0 0 50 -1 16 6 0.0000 4 90 150 %d %d %s\\001\n",$px,$py,$name);
    }
}

sub messier{
    $fn1="messier.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$r = 35;
	#		0:black   -1:not fill
	printf("1 3 0 1 0 7 50 -1 -1 0.000 1 0.0000 ");
	printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
	$px += 60;
	$py += 30;
	printf("4 0 0 50 -1 16 4 0.0000 4 75 150 %d %d %s\\001\n",$px,$py,$w[0]);
    }
    close(FIN);
}

sub cluster{
    $fn1="cluster.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$w[0] =~ s/NGC//;
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	$mag = $w[3];
        $size= $w[4];
	if($mag>10){ next; }
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	&drawcluster($px,$py);
        if($mag<6 || $size>15){
            # NGC name
            $px += 45;
            $py += 30;
            printf("4 0 0 50 -1 16 4 0.0000 4 75 150 %d %d %s\\001\n",$px,$py,$w[0]);
        }
    }
    close(FIN);
}

sub nebula{
    $fn1="nebula.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$w[0] =~ s/NGC//;
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$mag = $w[3];
	$size = $w[4];
	if($mag<10 || $size>10){	# 明るいか大きいものを表示
	    # $r = 30;
	    #		      32:grey     20:fill
	    # printf("1 3 0 1 32 32 50 -1 20 0.000 1 0.0000 ");
	    # printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
	    printf("2 1 0 1 0 0 50 -1 -1 0.000 0 0 -1 0 0 2\n");
	    printf("         %d %d %d %d\n",$px +5,$py-29,$px-29,$py+5);
	    printf("2 1 0 1 0 0 50 -1 -1 0.000 0 0 -1 0 0 2\n");
	    printf("         %d %d %d %d\n",$px+17,$py-25,$px-25,$py+17);
	    printf("2 1 0 1 0 0 50 -1 -1 0.000 0 0 -1 0 0 2\n");
	    printf("         %d %d %d %d\n",$px+25,$py-17,$px-17,$py+25);
	    printf("2 1 0 1 0 0 50 -1 -1 0.000 0 0 -1 0 0 2\n");
	    printf("         %d %d %d %d\n",$px+29,$py -5,$px -5,$py+29);
	    $px += 60;
	    $py += 30;
	    printf("4 0 0 50 -1 16 4 0.0000 4 75 150 %d %d %s\\001\n",$px,$py,$w[0]);
	}
    }
    close(FIN);
}

sub drawcluster{
    my ($px1,$py1) = @_;
    my $r = 1;
    printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
    printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
    $py +=15;
    printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
    printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
    $py -=30;
    printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
    printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
    $py +=8;
    $px +=13;
    printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
    printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
    $py +=15;
    printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
    printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
    $px -=27;
    printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
    printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);
    $py -=15;
    printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
    printf("%d %d %d %d %d %d %d %d\n",$px,$py,$r,$r,$px,$py,($px+$r),$py);    
}

sub cylindrical{
    my ($f, $t) = @_;		# $f = $ra, $t = $dec
    my $lam = $dc;
    my $sinl=sin(pi*$lam/180);	# 中心位置の移動
    my $cosl=cos(pi*$lam/180);
    my $sinf=sin(pi*$f/180);	# 準備
    my $cosf=cos(pi*$f/180);
    my $sint=sin(pi*$t/180);
    my $cost=cos(pi*$t/180);
    my $fd = atan( $cost*$sinf/($sint*$sinl+$cost*$cosf*$cosl) );	# 回転
    my $td = asin( $sint*$cosl-$cost*$cosf*$sinl );
    $sinf=sin($fd);		# 円筒座標への変換
    $cosf=cos($fd);
    $sint=sin($td);
    $cost=cos($td);
    my $r = sqrt( $sint*$sint + $cost*$cost*$cosf*$cosf );
    # 座標は rθ, π→180
    my $x = $xc - 180*$sf*$cost*$sinf/$r/pi;
    my $cc= $sint/$cost/$cosf;
    my $y = $yc - 180*$sf*atan($cc)/pi;
    return($x,$y);
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
	#		  0:black 20:fill
	printf("1 3 0 1 0 0 50 -1 20 0.000 1 0.0000 ");
	printf("%d %d %d %d %d %d %d %d\n",$x,$y,$r,$r,$x,$y,($x+$r),$y);
    }
    $px=$right-2050;
    $py=$bottom+100;
    printf("4 0 0 50 -1 16 7 0.0000 4 75 135 %d %d Mag:    1.0",$px,$py);
    printf("    2.0    3.0    4.0    <5.0\\001\n");
}

sub drawline{
    # draw line (x1,y1)-(x2,y2)
    my ($px1,$py1,$px2,$py2,$type,$color) = @_;
    if($px1<$origin || $px1>$right || $py1<$origin || $py1>$bottom){	# 1が外側
	if($px2<$origin || $px2>$right || $py2<$origin || $py2>$bottom){# 2も外側
	    return;
	}
	# 2が内側
	if($py1<$origin && $py2>=$origin){	# 上辺との交差
	    $x=($px1-$px2)*($origin-$py2)/($py1-$py2) + $px2;
	    if($x>$origin && $x<$right){
		$px1=$x;
		$py1=$origin;
	    }
	}elsif($py1>$bottom && $py2<=$bottom){	# 下辺との交差
	    $x=($px1-$px2)*($bottom-$py2)/($py1-$py2) + $px2;
	    if($x>$origin && $x<$right){
		$px1=$x;
		$py1=$bottom;
	    }
	}
	if($px1<$origin && $px2>=$origin){	# 左辺との交差
	    $y=($py1-$py2)*($origin-$px2)/($px1-$px2) + $py2;
	    if($y>$origin && $y<$bottom){
		$py1=$y;
		$px1=$origin;
	    }
	}elsif($px1>$right && $px2<=$right){	# 右辺との交差
	    $y=($py1-$py2)*($right-$px2)/($px1-$px2) + $py2;
	    if($y>$origin && $y<$bottom){
		$py1=$y;
		$px1=$right;
	    }
	}
    }else{					# 1が内側
	# 2が外側 (内側ならそのまま)
	if($py2<$origin && $py1>=$origin){	# 上辺との交差
	    $x=($px2-$px1)*($origin-$py1)/($py2-$py1) + $px1;
	    if($x>$origin && $x<$right){
		$px2=$x;
		$py2=$origin;
	    }
	}elsif($py2>$bottom && $py1<=$bottom){	# 下辺との交差
	    $x=($px2-$px1)*($bottom-$py1)/($py2-$py1) + $px1;
	    if($x>$origin && $x<$right){
		$px2=$x;
		$py2=$bottom;
	    }
	}
	if($px2<$origin && $px1>=$origin){	# 左辺との交差
	    $y=($py2-$py1)*($origin-$px1)/($px2-$px1) + $py1;
	    if($y>$origin && $y<$bottom){
		$py2=$y;
		$px2=$origin;
	    }
	}elsif($px2>$right && $px1<=$right){	# 右辺との交差
	    $y=($py2-$py1)*($right-$px1)/($px2-$px1) + $py1;
	    if($y>$origin && $y<$bottom){
		$py2=$y;
		$px2=$right;
	    }
	}
    }
    #		A B: 13 circle, 11 elliptic, 21 line
    #		 C : 0 solid, 1 dashed, 2 dotted
    #		 D : line width
    #		 E : line color 0 black, 7 white
    #		 F : fill color
    #		 H : 20 filled, -1 not filled 
    #		 J : dot-line ratio (ex. 2.0)
    #	    A B  C D  E F  G -1  H  J
    printf("2 1 %d 1 %d 7 50 -1 -1 2.000 0 0 -1 0 0 2\n",$type,$color);
    printf("         %d %d %d %d\n",$px1,$py1,$px2,$py2);
}

sub periodic{
    my ($r) = @_;
    if($rc<90 && $r>270){
	$r=$r-360;
    }elsif($rc>270 && $r<-90){
	$r=$r+360;
    }
    return($r);
}

