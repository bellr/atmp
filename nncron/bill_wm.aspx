<?
exit;
require("customsql.inc.aspx");
	include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
	include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");

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

$demand_info = $db->order_wm();
if(!empty($demand_info)) {

		$response = $wmxi->X3(
			$WMB,               # номер кошелька для которого запрашивается операция
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
	$hesh = md5($WMB.$ar[2].".00".$idpay[0]['id_pay']);

	for($i=0;$i<=$xmlres->operations['cnt']-1;$i++) {

		if($idpay[0]['id_pay'] == $a[$i]->orderid) {
			$hesh_in = md5($a[$i]->pursedest.$a[$i]->amount.$a[$i]->orderid);
			if($hesh == $hesh_in) {
				//функция извлечения пин-кодов
				if($demand_info[0]['status'] == "p") {$result_order = $db->open_kod($ar[3],$ar[0]);
	if($demand_info[0]['send_mail'] == "1") {
		require($home_dir."include/smtp-func.aspx");
		$mail_ini = $db->creat_mail($_POST['did'],$result_order,$demand_info[0]['order_arr'],$demand_info[0]['company']);
		$ar_mail = explode('|',$mail_ini);
		smtpmail($demand_info[0]['email'],$ar_mail[0],$ar_mail[1],$ar_mail[2]);
	}
				}
				if($demand_info[0]['status'] == "pz") {
$parser = new WMXIParser();
	$response = $wmxi->X2(intval($idpay[0]['id_pay']),$WMZ,$ar[1],floatval($ar[8]),'0','','Возврат залога по заявке №'.$ar[0],'0');
		$structure = $parser->Parse($response, DOC_ENCODING);
		$transformed = $parser->Reindex($structure, true);
		$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
		$desc_er = htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES);
			if ($kod_error == "0") {$db->demand_edit('y',$ar[0]);}
			else {$db->demand_add_coment($desc_er,$ar[0]);
			$db->demand_edit('er',$ar[0]); }
				}
				//расчет партнерской программы  и накопительной скидки
				$db->raschet_partner($ar[5],$ar[2],$ar[6]);
			}
			else {$db->demand_add_coment('Не верное значение в контрольной подписи',$ar[0]);
				$db->demand_edit('er',$ar[0]);}
		}
	}
}
}
}

?>