<?php
define('UnitX','30'); //X軸ユニット数
define('UnitY','30'); //Y軸ユニット数
define('DataX','21'); //データベクトル
define('Nmax','500'); //学習回数
define('SigmaO',UnitX);
define('SigmaE','0.75');
define('Tau1',150);
define('Tau2',Nmax);
define('FileName','input_animal.data'); //読み込みファイル名
set_time_limit(600); //最大思考秒数
header("Content-type: text/plain");

//初期参照ベクトル決定（乱数）
mt_srand();
for($i=0;$i<UnitX;$i++){
  for($j=0;$j<UnitY;$j++){
    for($k=0;$k<DataX;$k++){
      $q = mt_rand()/mt_getrandmax();
      $w[$i][$j][$k] = $q;
    }
  }
}
//print("参照ベクトル");
//var_dump($w);

//ファイル読み込み
$i = 0;
$fp = fopen (FileName, 'r');
while ($file = fgetcsv($fp)){
  if($i < 2) $etc_data[$i] = $file;
  if($i >=2) $data[$i-2] = $file;
  $i++;
}
$DataY = $i-2;
//echo "i=$i \n\n";
//print("\n入力ベクトル\n");
//var_dump($data);

for($n=0;$n<Nmax;$n++){
  /******************************************************
  競合過程
  *******************************************************/
  //データ指定
  $t = mt_rand(0,DataX-1);
  echo "$n \n";

  //ユークリッド距離を計算
  for($i=0;$i<UnitX;$i++){
    for($j=0;$j<UnitY;$j++){
      $kyori_temp = 0;
      for($v=0;$v<DataX;$v++){
        $kyori_temp = $kyori_temp + pow(($data[$t][$v] - $w[$i][$j][$v]),2);
      }
      $kyori[$i][$j] = sqrt($kyori_temp);
    }
  }
  //print("\n距離\n");
  //var_dump($kyori);

  //最小距離とそのユニットを求めよう
  for($i=0;$i<UnitX;$i++){
    $kyorimins[$i] = min($kyori[$i]);
    $temp_q = array_keys($kyori[$i],$kyorimins[$i]);
    $kingunitYt[$i] = $temp_q[0];
  //print("部分最小距離＝$kyorimins[$i]  ユニット = $kingunitYt[$i] \n");
  }
  $kyorimin = min($kyorimins);
  $temp_w = array_keys($kyorimins,$kyorimin);
  $kingunitX = $temp_w[0];
  $kingunitY = $kingunitYt[$kingunitX];
  //print ("\n最小距離  $kyorimin  勝者ユニット ($kingunitX)($kingunitY) \n");

  /******************************************************
  協調過程
  *******************************************************/
  //近傍関数の算出
  $sigman = SigmaE + (SigmaO - SigmaE)*exp(-$n/Tau1);
  $eta = 1-($n/Tau2);
  for($x=0;$x<UnitX;$x++){
    for($y=0;$y<UnitY;$y++){
      $kyori2 = pow(($kingunitX - $x),2) + pow(($kingunitY - $y),2);
      $phin = exp(-($kyori2/(2*pow($sigman,2))));
      for($v=0;$v<DataX;$v++){
        $dw = $eta * $phin * ($data[$t][$v] - $w[$x][$y][$v]);
        $dwa[$v] = $dw;
        $w[$x][$y][$v] = $w[$x][$y][$v] + $dw;
      }
    }
  }
}

/************************
    勝者ユニットはどれだ
*************************/
for($u=0;$u<$DataY;$u++){
  //ユークリッド距離を計算
  for($i=0;$i<UnitX;$i++){
    for($j=0;$j<UnitY;$j++){
      $kyori_temp = 0;
      for($v=0;$v<DataX;$v++){
        $kyori_temp = $kyori_temp + pow(($data[$u][$v] - $w[$i][$j][$v]),2);
      }
      $kyori[$i][$j] = sqrt($kyori_temp);
    }
  }
  //最小距離とそのユニットを求めよう
  for($i=0;$i<UnitX;$i++){
    $kyorimins[$i] = min($kyori[$i]);
    $temp_q = array_keys($kyori[$i],$kyorimins[$i]);
    $kingunitYt[$i] = $temp_q[0];
  }
  $kyorimin = min($kyorimins);
  $temp_w = array_keys($kyorimins,$kyorimin);
  $kingunitX = $temp_w[0];
  $kingunitY = $kingunitYt[$kingunitX];
  print ("\n $u " .$etc_data[1][$u+1]    ."勝者ユニット ($kingunitX)($kingunitY) \n");
  $out[$kingunitY][$kingunitX] = $etc_data[1][$u+1];
}

echo "\n\n距離だよー\n";

/* 色づけ */
//距離算出
for($i=0;$i<UnitY;$i++){
  for($j=0;$j<UnitX;$j++){
    $bunnbo = 0;
    $ketugou_kyori=0;
    for($l=-1;$l<=1;$l++){
      for($k=-1;$k<=1;$k++){
        if($l+$i>=0 and $l+$i<UnitY and $k+$j>=0 and $k+$j<UnitX and !($k==0 and $l==0)){
          $bunnbo++;
          $kyori_temp = 0;
          for($v=0;$v<DataX;$v++){
            $kyori_temp = $kyori_temp + pow(($w[$i][$j][$v] - $w[$l][$k][$v]),2);
          }
          $ketugou_kyori = $ketugoukyori + sqrt($kyori_temp);
        }
      }
    }
    $temp_miko = $ketugou_kyori / $bunnbo;
    $out_kyori[$i][$j] = $temp_miko;
    if($i==0 and $j==0){
      $out_kyori_max = $temp_miko;
      $out_kyori_min = $temp_miko;
      echo "\n 初期max = " .$out_kyori_max;
      echo "\n 初期min = " .$out_kyori_min;
    }
    if($temp_miko > $out_kyori_max){
      $out_kyori_max = $temp_miko;
    }
    if($temp_miko < $out_kyori_min){
      $out_kyori_min = $temp_miko;
    }
  }
}
echo "\n max = " .$out_kyori_max;
echo "\n min = " .$out_kyori_min;

for($i=0;$i<UnitY;$i++){
  for($j=0;$j<UnitX;$j++){
    $k_hoge = ($out_kyori[$i][$j] - $out_kyori_min) * (765 / ($out_kyori_max - $out_kyori_min));
    $k_temp = round($k_hoge);
    echo $k_temp ."\n";
    if($k_temp<=255){
      $hoge = sprintf('%02X',255-$k_temp);
      $color[$i][$j] = $hoge;
      $hoge = sprintf('%02X',$k_temp);
      $color[$i][$j] .= $hoge;
      $color[$i][$j] .= "00";
      $color[$i][$j] .= "#";
    }elseif($k_temp<=510){
      $color[$i][$j] = "00";
      $hoge = sprintf('%02X',510-$k_temp);
      $color[$i][$j] .= $hoge;
      $color[$i][$j] .= "●";
      $hoge = sprintf('%02X',$k_temp);
      $color[$i][$j] .= $hoge;
      $color[$i][$j] .= "&";
    }else{
      $color[$i][$j] = "00";
      $color[$i][$j] .= "00";
      $hoge = sprintf('%02X',765-$k_temp);
      $color[$i][$j] .= $hoge;
    }
  }
}
var_dump($color);
/* HTLM 出力*/
$html = "<table border='0'><tbody>";
for($i=0;$i<UnitY;$i++){
  $html .="<tr>";
  for($j=0;$j<UnitX;$j++){
    $html .= '<td width="50" bgcolor="#' .$color[$i][$j]  .'">.' .$out[$i][$j] ."</td>";
  }
}
unlink('out.html');
$fout = fopen('out.html' , 'w');
fwrite($fout,$html);

var_dump($outc);

echo "<h2>演算終了！！！";
echo '<a href="out.html">●</a>';
?>
