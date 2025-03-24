#!/usr/local/bin/perl
use Math::Trig;

# header
($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
$year += 1900;
$mon++;
print "%!PS-Adobe-3.0\n";
print "%%Title: star chart\n";
print "%%Creator: fig2dev imitation\n";
print "%%CreationDate: $year-$mon-$mday $hour:$min:$sec\n";
open(FIN,"psheader.data");
while($x=<FIN>){
    print $x;
}
close(FIN);

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

$clusterlimit=10;	# 星団の最小光度
$clusternamemaglimit=6; # 星団名をつける最小光度
$clusternamesizelimit=15; # 星団名をつける最小サイズ(分)
$nebulamaglimit=10;	# 星雲の最小光度
$nebulasizelimit=10;	# 星雲の最小大サイズ(分), 名前もつく
$garaxylimit=12;	# 銀河の最小光度
$garaxynamelimit=10;	# 銀河名をつける最小光度

print "7.500 slw\n";	# line widthの設定
print "0 slc\n";	# line ?
print "0 slj\n";	# line ?

# 南極用
&radec;			# 赤経 赤緯線
#&boundary;		# 星座境界
&constellation; 	# 星座線
&name;			# 星座名
&star;			# 恒星
&starname;		# 恒星名
#&cluster;		# 星団

print "2.500 slw\n";	# line width 1/3 に
#&nebula;		# 星雲
&magellan;		# マゼラン雲の表示
#&garaxy;		# 銀河

print "% here ends figure;\n";
print "pagefooter\n";
print "showpage\n";
print "%%Trailer\n";
print "%EOF\n";

exit;


#===============================================================

sub radec{
    # 赤経 赤緯線の表示
    $fn1="radec.data";
    open(FIN,$fn1);
    $n=0;
    $dr=90-$range/3;		# 90 -> dr=60度まで
    while($x=<FIN>){
	chomp($x);
	@w=split(/,/,$x);
	$ra1  = $w[0];
	$dec1 = $w[1];
	$ra2  = $w[2];
	$dec2 = $w[3];
#	if($dec2>-$dr){ next; }			# 範囲外を無視
	if($dec1<-80 || $dec2<-80){ next; }	# 範囲外を無視
	$dec1 = 90+$dec1;
	$dec2 = 90+$dec2;
	$px1 = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py1 = $yc - $sf*$dec1*sin(pi*$ra1/180);
	$px2 = $xc + $sf*$dec2*cos(pi*$ra2/180);
	$py2 = $yc - $sf*$dec2*sin(pi*$ra2/180);
	&drawline($px1,$py1,$px2,$py2,2,0);	# 2,0=dotted, black
    }
    close(FIN);
    # 赤経表示
    for($ra=0;$ra<360;$ra=$ra+15){
	$ra1 = $ra;
	$dec1= -$dr;
	$dec1 = 90+$dec1+1;
	$px = $xc + $sf*$dec1*cos(pi*$ra1/180)-120;
	$py = $yc - $sf*$dec1*sin(pi*$ra1/180)+70;
	$h=$ra1/15;
	#			7pt
	printf("/Helvetica ff 111.13 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%dh) col0 sh gr\n",$h);
    }
    # 赤緯表示
    for($dec=-80;$dec<=-$dr;$dec=$dec+10){
	$ra1 = 270;
	$dec1 = 90+$dec;
	$px = $xc + $sf*$dec1*cos(pi*$ra1/180)+20;
	$py = $yc - $sf*$dec1*sin(pi*$ra1/180)-20;
	printf("/Helvetica ff 111.13 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%+d) col0 sh gr\n",$dec);
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
	$ra1  = $w[0];
	$dec1 = $w[1];
	$ra2  = $w[2];
	$dec2 = $w[3];
#	if($dec1<$dr && $dec1<$dr){ next; }	# 範囲外を無視
	$dec1 = 90+$dec1;
	$dec2 = 90+$dec2;
	$px1 = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py1 = $yc - $sf*$dec1*sin(pi*$ra1/180);
	$px2 = $xc + $sf*$dec2*cos(pi*$ra2/180);
	$py2 = $yc - $sf*$dec2*sin(pi*$ra2/180);
	&drawline($px1,$py1,$px2,$py2,1,32);	# 1,32=dotted, grey
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
	$ra1  = $w[0];
	$dec1 = $w[1];
	$ra2  = $w[2];
	$dec2 = $w[3];
#	if($dec1<$dr && $dec1<$dr){ next; }	# 範囲外を無視
	$dec1 = 90+$dec1;
	$dec2 = 90+$dec2;
	$px1 = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py1 = $yc - $sf*$dec1*sin(pi*$ra1/180);
	$px2 = $xc + $sf*$dec2*cos(pi*$ra2/180);
	$py2 = $yc - $sf*$dec2*sin(pi*$ra2/180);
	&drawline($px1,$py1,$px2,$py2,0,32);	# 0,32=solid, grey
    }
    close(FIN);
}

sub magellan{
    # Magellan
    @w=("LMC", 80.89375, -69.75611, 4,
	"SMC", 13.18667, -72.82861, 2);
    for($i=0;$i<2;$i++){
	$name= $w[$i*4];
	$ra1 = $w[$i*4+1];
	$dec1= $w[$i*4+2];
	$dec1 = 90+$dec1;
	$px = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py = $yc - $sf*$dec1*sin(pi*$ra1/180);
	$r = $sf*$w[$i*4+3];
	printf("%% Ellipse\n");
	printf("n %d %d %d %d 0 360 DrawEllipse gs col0 s gr\n",$px,$py,$r,$r);
	printf("/Helvetica ff 95.25 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%s) col0 sh gr\n",$name);
    }
}

sub name{
    $fn1="name.data";
    open(FIN,$fn1);
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$name= $w[0];
	$ra1  = $w[1];
	$dec1 = $w[2];
	$dec1 = 90+$dec1;
	$px = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py = $yc - $sf*$dec1*sin(pi*$ra1/180);
	$len = 80*length($name);		# はみ出る名前は表示しない
	if($px<$origin || ($px>$right-$len) || $py<$origin || $py>$bottom){ next; }
	#			10 point
	printf("/Helvetica ff 158.75 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%s) col32 sh gr\n",$name);
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
	$ra1  = $w[0];
	$dec1 = $w[1];
	$dec1 = 90+$dec1;
	$px = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py = $yc - $sf*$dec1*sin(pi*$ra1/180);
	$mag = $w[2];
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	if($mag<1.5){		$r=20;		# 20 → 実サイズ 1mm
	}elsif($mag<2.5){	$r=15;
	}elsif($mag<3.5){	$r=10;
	}elsif($mag<5.0){	$r= 5;
	}elsif($mag<7.0){	$r= 1;
	}else{		next;  }	# 7等以下は表示しない
	#		col0:black & fill
	printf("%% Ellipse\n");
	printf("n %d %d %d %d 0 360 DrawEllipse",$px,$py,$r,$r);
	printf(" gs 0.00 setgray ef gr gs col0 s gr\n");
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
	$ra1  = $w[1];
	$dec1 = $w[2];
	$dec1 = 90+$dec1;
	$px = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py = $yc - $sf*$dec1*sin(pi*$ra1/180);
	$px += 30;
	$py += 35;
	$len = 48*length($name);		# はみ出る名前は表示しない
	if($px<$origin || $px>($right-$len) || $py<$origin || $py>$bottom){ next; }
        printf("/Helvetica ff 158.75 scf sf\n");
        # printf("/Helvetica ff 95.25 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%s) col0 sh gr\n",$name);
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
	$name=$w[0];
	$ra1  = $w[1];
	$dec1 = $w[2];
	$dec1 = 90+$dec1;
	$mag = $w[3];
	$size= $w[4];
	if($mag>$clusterlimit){ next; }
	$px = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py = $yc - $sf*$dec1*sin(pi*$ra1/180);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	&drawcluster($px,$py);
	if($mag<$clusternamemaglimit || $size>$clusternamesizelimit){
	    # NGC name
	    $px += 45;
	    $py += 30;
	    printf("/Helvetica ff 63.50 scf sf\n");
	    printf("%d %d m\n",$px,$py);
	    printf("gs 1 -1 sc (%s) col0 sh gr\n",$name);
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
	$name = $w[0];
	$ra1  = $w[1];
	$dec1 = $w[2];
	$dec1 = 90+$dec1;
	$mag = $w[3];
	if($mag>10){ next; }
	$px = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py = $yc - $sf*$dec1*sin(pi*$ra1/180);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$mag = $w[3];
	$size = $w[4];
	if($mag<$nebulamaglimit || $size>$nebulasizelimit){ # 明るいか大きいものを表示
	    printf("% Polyline\n");
	    printf("n %d %d m ",$px +5,$py-29);
	    printf("%d %d l gs col0 s gr\n",$px-29,$py+5);
	    printf("% Polyline\n");
	    printf("n %d %d m ",$px+17,$py-25);
	    printf("%d %d l gs col0 s gr\n",$px-25,$py+17);
	    printf("% Polyline\n");
	    printf("n %d %d m ",$px+25,$py-17);
	    printf("%d %d l gs col0 s gr\n",$px-17,$py+25);
	    printf("% Polyline\n");
	    printf("n %d %d m ",$px+29,$py -5);
	    printf("%d %d l gs col0 s gr\n",$px -5,$py+29);
	    $px += 60;
	    $py += 30;
	    printf("/Helvetica ff 63.50 scf sf\n");
	    printf("%d %d m\n",$px,$py);
	    printf("gs 1 -1 sc (%s) col0 sh gr\n",$name);
	}
    }
    close(FIN);
}

sub garaxy{
    $fn1="garaxy.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$w[0] =~ s/NGC//;
	$name=$w[0];
	$ra1  = $w[1];
	$dec1 = $w[2];
	$dec1 = 90+$dec1;
	$px = $xc + $sf*$dec1*cos(pi*$ra1/180);
	$py = $yc - $sf*$dec1*sin(pi*$ra1/180);
	$mag = $w[3];
	if($mag>$garaxylimit){ next; }
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$r = 12;
	printf("%% Ellipse\n");
	printf("n %d %d %d %d 0 360 DrawEllipse gs col0 s gr\n",$px,$py,2*$r,$r);
	if($mag>$garaxynamelimit){ next; }
	$px += 35;
	$py += 25;
	printf("/Helvetica ff 63.50 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%s) col0 sh gr\n",$name);
    }
    close(FIN);
}

sub drawcluster{
    my ($px1,$py1) = @_;
    my $r = 1;
    printf("%% Ellipse\n");
    printf("n %d %d %d %d 0 360 DrawEllipse",$px,$py,$r,$r);
    printf(" gs 0.00 setgray ef gr gs col0 s gr\n");
    $py +=15;
    printf("%% Ellipse\n");
    printf("n %d %d %d %d 0 360 DrawEllipse",$px,$py,$r,$r);
    printf(" gs 0.00 setgray ef gr gs col0 s gr\n");
    $py -=30;
    printf("%% Ellipse\n");
    printf("n %d %d %d %d 0 360 DrawEllipse",$px,$py,$r,$r);
    printf(" gs 0.00 setgray ef gr gs col0 s gr\n");
    $py +=8;
    $px +=13;
    printf("%% Ellipse\n");
    printf("n %d %d %d %d 0 360 DrawEllipse",$px,$py,$r,$r);
    printf(" gs 0.00 setgray ef gr gs col0 s gr\n");
    $py +=15;
    printf("%% Ellipse\n");
    printf("n %d %d %d %d 0 360 DrawEllipse",$px,$py,$r,$r);
    printf(" gs 0.00 setgray ef gr gs col0 s gr\n");
    $px -=27;
    printf("%% Ellipse\n");
    printf("n %d %d %d %d 0 360 DrawEllipse",$px,$py,$r,$r);
    printf(" gs 0.00 setgray ef gr gs col0 s gr\n");
    $py -=15;
    printf("%% Ellipse\n");
    printf("n %d %d %d %d 0 360 DrawEllipse",$px,$py,$r,$r);
    printf(" gs 0.00 setgray ef gr gs col0 s gr\n");
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
    printf("% Polyline\n");
    if($type==2){			# dotted
	printf(" [15 30] 30 sd\n");
    }elsif($type==1){			# dashed
	printf(" [30] 0 sd\n");
    }					# 0: solid
    printf("n %d %d m\n",$px1,$py1);
    printf(" %d %d l gs col%d s gr  [] 0 sd\n",$px2,$py2,$color);
}
