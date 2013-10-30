<?php
require("customsql.inc.aspx");
echo "dssdsdsd";
	//include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
	//include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
$db = new CustomSQL($DBName);
$hour = date("H");
$min = date("i");
$days = date("d");
$mon = date("m");
$yaer = date("Y");

$data_tom = date( "Y-m-d",mktime(0,0,0,$mon,$days-1,$yaer) );
$data_old = date("Y-m-d",mktime(0,0,0,$mon,$days-2,$yaer) );
$time = date("H:i");

$res = eWebmoney::x9(null,'primary_wmid');
d($res);
exit;
$sel_del_dem = $db->sel_del_dem($data_tom,$time,$data_old);
foreach($sel_del_dem as $ar) {
	//echo "{$ar[0]}<br>";
	$db->del_dem($ar[0]);
	$db->del_idpay($ar[0]);
}


//обновление WMB кошелька
	//$response = $wmxi->X9($wmid);
	
	$res = eWebmoney::x9(null,'primary_wmid');
	foreach($res->purses->purse as $r) {
		echo $r->pursename.' - '.$r->amount.' '.$r->desc.'<br>';
	}
	
	
	$xmlres = simplexml_load_string($response);

	for ($i=0; $i<=10; $i++) {
		if ($xmlres->purses->purse[$i]->pursename == $WMB) $balance_in = $xmlres->purses->purse[$i]->amount - $xmlres->purses->purse[$i]->amount*0.008;
	}
	if($balance_in>0) {$db->upd_bal(sprintf("%8.0f ",$balance_in),'WMB');}
?>
