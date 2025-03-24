#!/usr/local/bin/perl

# 5 度置きにデータ作成
# 出力は ra =15 度置き
# 出力は dec=10 度置き

# 赤経線
for($x=0;$x<360;$x=$x+ 15 ){
    for($y=-90;$y<90;$y=$y+ 10 ){
	printf("%d, %d, %d, %d\n",$x,$y,  $x,$y+ 5);
	printf("%d, %d, %d, %d\n",$x,$y+5,$x,$y+10);
    }
}

# 赤緯線
for($y=-80;$y<90;$y=$y+ 10 ){
    for($x=0;$x<360;$x=$x+ 15 ){
	printf("%d, %d, %d, %d\n",$x,   $y,$x+ 5,$y);
	printf("%d, %d, %d, %d\n",$x+ 5,$y,$x+10,$y);
	printf("%d, %d, %d, %d\n",$x+10,$y,$x+15,$y);
    }
}

# 元は

# # 赤経線
# for($i=45;$i<=135;$i=$i+15){
#     $px = $xc-($i-90)*$sf;
#     #         (1:dashed)        2:ratio
#     print "2 1 2 1 0 7 50 -1 -1 2.000 0 0 -1 0 0 2\n";
#     printf("         %d 450 %d 9000\n",$px,$px);
#     #                    7pt
#     printf("4 0 0 50 -1 16 7 0.0000 4 75 135 %d 4820 %dh\\001\n",$px+15,$i/15);
# }
#
# # 赤緯線
# for($i=-30;$i<=30;$i=$i+10){
#     $py = $yc-$i*$sf;
#     #          2:dotted         2:ratio
#     print "2 1 2 1 0 7 50 -1 -1 2.000 0 0 -1 0 0 2\n";
#     printf("         450 %d 13050 %d\n",$py,$py);
#     printf("4 0 0 50 -1 16 7 0.0000 4 75 135 6770 %d %+d\\001\n",$py-20,$i);
# }

