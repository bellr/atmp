<?php
require("customsql.inc.aspx");

$db = new CustomSQL($DBName);
$hour = date("H");
$min = date("i");
$days = date("d");
$mon = date("m");
$yaer = date("Y");

$data_tom = date( "Y-m-d",mktime(0,0,0,$mon,$days-1,$yaer) );
$data_old = date("Y-m-d",mktime(0,0,0,$mon,$days-2,$yaer) );
$time = date("H:i");

$sel_del_dem = $db->sel_del_dem($data_tom,$time,$data_old);

foreach($sel_del_dem as $ar) {
	$db->del_dem($ar[0]);
	$db->del_idpay($ar[0]);
}

//обновление WMB кошелька
	$PP = Extension::Payments()->getParam('payments','webmoney');
	$res = Extension::Payments()->Webmoney()->x9(null,'primary_wmid');

	foreach ($res->purses->purse as $r) {
		$workWMID = Extension::Payments()->Webmoney()->getWorkWMID();
		if ($r->pursename == $PP->WMID[$workWMID]['WMB']) $balance_in = $r->amount - $r->amount*0.008;
	}
echo $balance_in;
	$db->upd_bal(sprintf("%8.0f ",$balance_in),'WMB');
?>
