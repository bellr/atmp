<?php
require("customsql.inc.aspx");
//require("constructor_exch_auto.aspx");
$db = new CustomSQL($DBName);
//$db_admin = new CustomSQL_admin($DBName_admin);

/////платежный терминал Webpay
if(!empty($_POST['wsb_signature']) && $_POST['payment_method'] == "cc") {

$batch_timestamp = $_POST['batch_timestamp'];
$currency_id = $_POST['currency_id'];
$amount = $_POST['amount'];
$payment_method = $_POST['payment_method'];
$order_id = $_POST['order_id'];
$site_order_id = $_POST['site_order_id'];
$transaction_id = $_POST['transaction_id'];
$payment_type = $_POST['payment_type'];
$rrn = $_POST['rrn'];
$key = "webpaydbnfkbq1986";

$hesh = md5($batch_timestamp.$currency_id.$amount.$payment_method.$order_id.$site_order_id.$transaction_id.$payment_type.$rrn.$key);

	if($hesh == $_POST['wsb_signature']) {
$did = $db->sel_did($site_order_id);
$demand_info = $db->demand_check($did[0]['did'],'WebPay');

//функция извлечения пин-кодов и изменения статуса заявки
	if($demand_info[0]['status'] == "n") {$result_order = $db->open_kod($demand_info[0]['order_arr'],$did[0]['did']);
	if($demand_info[0]['send_mail'] == "1") {
		require($home_dir."include/smtp-func.aspx");
		$mail_ini = $db->creat_mail($_POST['did'],$result_order,$demand_info[0]['order_arr'],$demand_info[0]['company']);
		$ar_mail = explode('|',$mail_ini);
		smtpmail($demand_info[0]['email'],$ar_mail[0],$ar_mail[1],$ar_mail[2]);
	}
	}
	if($demand_info[0]['status'] == "yz") {
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
$parser = new WMXIParser();
	$response = $wmxi->X2(intval($_POST['wsb_order_num']),$WMZ,$demand_info[0]['purse'],floatval($demand_info[0]['guarantee_price']),'0','','Возврат залога по заявке №'.$_POST['wsb_seed'],'0');
		$structure = $parser->Parse($response, DOC_ENCODING);
		$transformed = $parser->Reindex($structure, true);
		$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
		$desc_er = htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES);
			if ($kod_error == "0") {$db->demand_edit('y',$_POST['wsb_seed']);}
			else {$db->demand_add_coment($desc_er,$_POST['wsb_seed']);
			$db->demand_edit('er',$_POST['wsb_seed']); }
}
//запись ID транзакции от Webpay
	$db->add_id_pay($transaction_id,$did[0]['did']);

//расчет партнерской программы  и накопительной скидки
$db->raschet_partner($demand_info[0]['partner_id'],$demand_info[0]['summa'],$demand_info[0]['bonus_id']);

	}
	else { $db->demand_add_coment('В процессе платежа были изменены параметры заявки. Сообщите администрации, завка будет исполнена в ручном режиме после проверки',$did[0]['did']);
	$db->demand_edit('er',$did[0]['did']); }
}
/*
$text =
	$batch_timestamp."\n".
	$currency_id."\n".
	$amount."\n".
	$payment_method."\n".
	$order_id."\n".
	$site_order_id."\n".
	$transaction_id."\n".
	$payment_type."\n".
	$rrn."\n".
	$key."\n
	log_pass - ".$result_order;

		$fd = fopen("123.log","w+");
		fputs($fd, $text);
                fflush($fd);
		fclose($fd);
*/
?>