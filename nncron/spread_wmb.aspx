<?
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);

$demand_info = $db->sel_spread_wmb();

foreach($demand_info as $ar) {

	$s  = explode('|',$ar[order_arr]);$ss  = explode(':',$s[0]);
	$ar['purse_type'] = 'WMB';
	$ar['purse_in'] = $ar['purse'];
	$ar['amount'] = floatval($ss[0]);
	$ar['desc'] = 'Чек №'.$ar[id_pay].': Распространение эл. денег (Номер кошелька: '.$ar[purse].', Сумма: '.$ss[0].' WMB)';
	$res = Extension::Payments()->Webmoney()->x2($ar,'primary_wmid');

	if ($res->retval == 0) {
		$db->demand_edit('y',$ar[did]);
	}else {
		$db->demand_add_coment($desc_er,$ar[did]);
		$db->demand_edit('er',$ar[did]);
	}
}
?>
