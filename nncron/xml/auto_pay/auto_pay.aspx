<?
function wm_ReqID(){
    $time=microtime();
    $int=substr($time,11);
    $flo=substr($time,2,3);
	$f=substr($int,0,7);
    return $f.$flo;
}
function ReqID(){
    $time=microtime();
    $int=substr($time,11);
    $flo=substr($time,2,3);
	$f=substr($int,0,7);
    return $flo.$f;
}
$count = "count_pament_id.txt";
$ini = "ini_auto_pay.txt";

$fd_ini = fopen($ini,'r');
$line_i = fread($fd_ini,100);
fclose($fd_ini);

$ini_arr = explode('|',$line_i);

if($ini_arr[2] <= $ini_arr[3]) $summa_pay = $ini_arr[2];
else $summa_pay = $ini_arr[3];

if($ini_arr[3] > 0) {
	$fd_count = fopen($count,'r');
	$line_c = fread($fd_count,100);
	fclose($fd_count);
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
$parser = new WMXIParser();
$desc = "Оплата по заказу №".ReqID().$line_c.", ID".wm_ReqID()."";
	$response = $wmxi->X2(intval($line_c),$ini_arr[0],$ini_arr[1],floatval($summa_pay),'0','',$desc,'0');
		$structure = $parser->Parse($response, DOC_ENCODING);
		$transformed = $parser->Reindex($structure, true);
		$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
//echo $line_c;
	if ($kod_error == "0") {
//обновление номера транзакции
		$fd_с = fopen($count,"w+");
		fputs($fd_с, ++$line_c);
                fflush($fd_с);
		fclose($fd_с);
		$res = $ini_arr[3]-$summa_pay;
//		echo $ini_arr[0]."|".$ini_arr[1]."|".$summa_pay."|".$res;
//обновление оставшейся суммы для перевода

		$fd_i = fopen($ini,"w+");
		fputs($fd_i, $ini_arr[0]."|".$ini_arr[1]."|".$summa_pay."|".$res);
                fflush($fd_i);
		fclose($fd_i);
	}
}



?>