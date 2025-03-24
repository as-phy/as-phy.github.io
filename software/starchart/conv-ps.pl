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
$range=120;	# 赤経、赤緯数値の表示範囲
$sf = 110;	# scale factor
		# 90°=140 60°=210 30°=420
$xc = 6750;	# center x
$yc = 4725;	# center y
$rc = 270;	# right ascension center 中心位置の赤経
$dc = 50;	# declination center	 中心位置の赤緯

$clusterlimit=10;	# 星団の最小光度
$clusternamemaglimit=6;	# 星団名をつける最小光度
$clusternamesizelimit=15;	# 星団名をつける最小サイズ(分)
$nebulamaglimit=10;	# 星雲の最小光度
$nebulasizelimit=10;	# 星雲の最小大サイズ(分), 名前もつく
$garaxylimit=12;	# 銀河の最小光度
$garaxynamelimit=12;	# 銀河名をつける最小光度

print "7.500 slw\n";	# line widthの設定
print "0 slc\n";
print "0 slj\n";

&radec;			# 赤経 赤緯線
#&boundary;		# 星座境界
&constellation; 	# 星座線
&name;			# 星座名
&star;			# 恒星
&starname;		# 恒星名
#&cluster;		# 星団

print "2.500 slw\n";	# line width 1/3 に
#&finestar;		# 恒星
&messier;		# メシエ
#&nebula;		# 星雲
#&garaxy;		# 銀河
&huruta;		# 古田対象
&garaxy5;		# 銀河(5'以上)
#&garaxy3;		# 銀河(3'以上)
#&magellan;		# マゼラン雲

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
	$dr=$range/3;
	if($dec1<($dc-$dr) || $dec1>($dc+$dr)){
	    if($dec2<($dc-$dr) || $dec2>($dc+$dr)){ next; }	# 裏側は表示しない
	}
	($px1,$py1)=cylindrical($ra1,$dec1);
	($px2,$py2)=cylindrical($ra2,$dec2);
	&drawline($px1,$py1,$px2,$py2,2,0);	# 2,0=dotted, black
    }
    close(FIN);
    # 赤経表示
    for($ra=$rc-$rr;$ra<=$rc+$rr;$ra=$ra+15){
	$ra1 = ($ra-$rc)-0.15;
	$dec1=  $dc     -0.7;
	($px,$py)=cylindrical($ra1,$dec1);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	if($ra<0){
	    $h=($ra+360)/15;
	}elsif($ra>345){
	    $h=($ra-360)/15;
	}else{
	    $h=$ra/15;
	}
	#			7pt
	printf("/Helvetica ff 111.13 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%dh) col0 sh gr\n",$h);
    }
    # 赤緯表示
    for($dec=$dc-$dr;$dec<=$dc+$dr;$dec=$dec+10){
	$ra1 = ($rc -$rc) -0.15;
	$dec1=  $dec      +0.15;
	($px,$py)=cylindrical($ra1,$dec1);
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
	$dr=$range/3;
	if($dec1<($dc-$dr) || $dec1>($dc+$dr)){
	    if($dec2<($dc-$dr) || $dec2>($dc+$dr)){ next; }	# 裏側は表示しない
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
	$ra  = periodic($w[0]-$rc);
	$dec = $w[1];
	$mag = $w[2];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	if($mag<1.5){		$r=20;		# 20 → 実サイズ 1mm
	}elsif($mag<2.5){	$r=15;
	}elsif($mag<3.5){	$r=10;
	}elsif($mag<4.5){	$r= 5;
	}elsif($mag<6.5){	$r= 1;
	}else{		next;  }	# 7等以下は表示しない
	#		col0:black & fill
	printf("%% Ellipse\n");
	printf("n %d %d %d %d 0 360 DrawEllipse",$px,$py,$r,$r);
	printf(" gs 0.00 setgray ef gr gs col0 s gr\n");
    }
    close(FIN);
}

sub finestar{
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
	if($mag<6.5){		next;
	}elsif($mag<7.5){	$r=1;	# 7.5等まで小さく表示
	}else{			next; }
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
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	$px += 30;
	$py += 35;
	$len = 48*length($name);		# はみ出る名前は表示しない
	if($px<$origin || $px>($right-$len) || $py<$origin || $py>$bottom){ next; }
	printf("/Helvetica ff 111.13 scf sf\n");
	# printf("/Helvetica ff 95.25 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%s) col0 sh gr\n",$name);
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
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$r = $sf*$w[$i*4+3];
	printf("%% Ellipse\n");
	printf("n %d %d %d %d 0 360 DrawEllipse gs col0 s gr\n",$px,$py,$r,$r);
	printf("/Helvetica ff 95.25 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%s) col0 sh gr\n",$name);
    }
}

sub messier{
    $fn1="messier.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$name = $w[0];
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$r = 35;
	#		col0:black &  not fill
	printf("%% Ellipse\n");
	printf("n %d %d %d %d 0 360 DrawEllipse gs col0 s gr\n",$px,$py,$r,$r);
	$px += 60;
	$py += 30;
	printf("/Helvetica ff 63.50 scf sf\n");
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
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	$mag = $w[3];
	$size= $w[4];
	if($mag>$clusterlimit){ next; }
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
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
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
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
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	$mag = $w[3];
	if($mag>$garaxylimit){ next; }
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
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

sub huruta{
    $fn1="huruta.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$w[0] =~ s/NGC//;
	$name=$w[0];
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	$mag = $w[3];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$r = 12;
	printf("%% Ellipse\n");
	printf("n %d %d %d %d 0 360 DrawEllipse gs col1 s gr\n",$px,$py,2*$r,$r);
	$px += 35;
	$py += 25;
	printf("/Helvetica ff 111.13 scf sf\n");
#	printf("/Helvetica ff 63.50 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%s) col1 sh gr\n",$name);
    }
    close(FIN);
}

sub garaxy5{
    $fn1="garaxy5.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$w[0] =~ s/NGC//;
	$name=$w[0];
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	$mag = $w[3];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$r = 12;
	printf("%% Ellipse\n");
	printf("n %d %d %d %d 0 360 DrawEllipse gs col3 s gr\n",$px,$py,2*$r,$r);
	$px += 35;
	$py += 25;
	printf("/Helvetica ff 111.13 scf sf\n");
#	printf("/Helvetica ff 63.50 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%s) col3 sh gr\n",$name);
    }
    close(FIN);
}

sub garaxy3{
    $fn1="garaxy3.data";
    open(FIN,$fn1);
    $n=0;
    while($x=<FIN>){
	chomp($x);
	@w=split(/, /,$x);
	$w[0] =~ s/NGC//;
	$name=$w[0];
	$ra  = periodic($w[1]-$rc);
	$dec = $w[2];
	$mag = $w[3];
	if($ra<-90 || $ra>90){ next; }	# 裏側は表示しない
	($px,$py)=cylindrical($ra,$dec);
	if($px<$origin || $px>$right || $py<$origin || $py>$bottom){ next; }
	$r = 12;
	printf("%% Ellipse\n");
	printf("n %d %d %d %d 0 360 DrawEllipse gs col2 s gr\n",$px,$py,2*$r,$r);
	$px += 35;
	$py += 25;
	printf("/Helvetica ff 63.50 scf sf\n");
	printf("%d %d m\n",$px,$py);
	printf("gs 1 -1 sc (%s) col2 sh gr\n",$name);
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
    printf("% Polyline\n");
    if($type==2){			# dotted
	printf(" [15 30] 30 sd\n");
    }elsif($type==1){			# dashed
	printf(" [30] 0 sd\n");
    }					# 0: solid
    printf("n %d %d m\n",$px1,$py1);
    printf(" %d %d l gs col%d s gr  [] 0 sd\n",$px2,$py2,$color);
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

