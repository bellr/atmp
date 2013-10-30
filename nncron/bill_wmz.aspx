<?
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$hour = date("H");
$min = date("i");
$days = date("d");
$mon = date("m");
$yaer = date("Y");

$data_tom = date("Ymd",mktime(0,0,0,$mon,$days-1,$yaer));
$data = date("Ymd");
$time_tom = date("H:i",mktime($hour-1,$min,0,0,0,0));
$time_today = date("H:i",mktime($hour+1,$min,0,0,0,0));

$demand_info = $db->order_wmz();
if(!empty($demand_info)) {

	include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
	include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
		$response = $wmxi->X3(
			$WMZ,               # номер кошелька для которого запрашивается операция
			'0',    # целое число > 0
			'0',      # номер перевода в системе учета отправителя; любое целое число без знака
			'0',     # целое число > 0
			'0',     # номер счета в системе учета магазина; любое целое число без знака
			$data_tom.' '.$time_tom.':00',     # ГГГГММДД ЧЧ:ММ:СС
			$data.' '.$time_today.':00'     # ГГГГММДД ЧЧ:ММ:СС
		);
$xmlres = simplexml_load_string(iconv("utf-8","windows-1251",$response));
$a = $xmlres->operations->operation;
if(!empty($a)) {
foreach($demand_info as $ar) {
	//$purse = $db->RezervPusre($ar[5],$WMB,$rezerv_WMB);
	$idpay = $db->sel_idpay($ar[0]);
	$hesh = md5($WMZ.$ar[7].$idpay[0]['id_pay']);

	for($i=0;$i<=$xmlres->operations['cnt']-1;$i++) {

		if($idpay[0]['id_pay'] == $a[$i]->orderid) {
			$hesh_in = md5($a[$i]->pursedest.$a[$i]->amount.$a[$i]->orderid);

			if($hesh == $hesh_in) {
				//функция извлечения пин-кодов
				if($demand_info[0]['status'] == "p")
					{$result_order = $db->open_kod($ar[2],$ar[0]);
	if($demand_info[0]['send_mail'] == "1") {
		require($home_dir."include/smtp-func.aspx");
		$mail_ini = $db->creat_mail($_POST['did'],$result_order,$demand_info[0]['order_arr'],$demand_info[0]['company']);
		$ar_mail = explode('|',$mail_ini);
		smtpmail($demand_info[0]['email'],$ar_mail[0],$ar_mail[1],$ar_mail[2]);
	}
				}
				else {$db->demand_edit('y',$_POST['did']);}
				//расчет партнерской программы  и накопительной скидки
				$db->raschet_partner($ar[3],$ar[1],$ar[4]);
			}
			else {$db->demand_add_coment('Не верное значение в контрольной подписи',$ar[0]);
				$db->demand_edit('er',$ar[0]);}
		}
	}
}
}
}
?>