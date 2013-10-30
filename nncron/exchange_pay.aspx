<?php
define('PROJECT','ATM');
define('VS_DEBUG',true);
require_once(dirname($_SERVER['DOCUMENT_ROOT'])."/core/vs.php");

require("customsql.inc.aspx");
$db = new CustomSQL($DBName);

//$demand_info = $db->demand_check($_POST['did'],'WMB');
//$result_order = $db->open_kod($demand_info[0]['order_arr'],$_POST['did']);

//smtpmail($demand_info[0]['email'],'subject',$res,'from_name');
if($_POST['LMI_SECRET_KEY'] == "16201986") {
//вывод инфы по заявке
	$demand_info = $db->demand_check($_POST['did'],'WMB');
if (!empty($_POST['LMI_HASH'])) {

	$c = explode("||",$demand_info[0]['company']);
	$company = explode("|",$c[0]);
	$purse = $db->RezervPusre($company[0],$WMB,$rezerv_WMB);
	if($demand_info[0]['oplata'] == 'WMZ') {
		$md5_demand = md5($demand_info[0]['summa'].$purse);
	} else {
		$md5_demand = md5($demand_info[0]['summa'].".00".$purse);
	}
	$md5_merchant = md5($_POST['LMI_PAYMENT_AMOUNT'].$_POST['LMI_PAYEE_PURSE']);

	if ($md5_demand == $md5_merchant) {
		//функция извлечения пин-кодов
		if($demand_info[0]['status'] == "n") {
			$result_order = $db->open_kod($demand_info[0]['order_arr'],$_POST['did']);
			
			if($demand_info[0]['send_mail'] == "1") {
				require(Config::$base[PROJECT]['ROOT'].'/include/smtp-func.aspx');
				$mail_ini = $db->creat_mail($_POST['did'],$result_order,$demand_info[0]['order_arr'],$demand_info[0]['company']);
				$ar_mail = explode('|',$mail_ini);
				smtpmail($demand_info[0]['email'],$ar_mail[0],$ar_mail[1],$ar_mail[2]);
			}
		}
		
		if($demand_info[0]['status'] == "yz") {
			include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
			include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
			$parser = new WMXIParser();
			$response = $wmxi->X2(intval($_POST['LMI_PAYMENT_NO']),$WMZ,$demand_info[0]['purse'],floatval($demand_info[0]['guarantee_price']),'0','','Возврат залога по заявке №'.$_POST['did'],'0');
			$structure = $parser->Parse($response, DOC_ENCODING);
			$transformed = $parser->Reindex($structure, true);
			$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
			$desc_er = htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES);
			if ($kod_error == "0") {$db->demand_edit('y',$_POST['did']);}
			else {$db->demand_add_coment($desc_er,$_POST['did']);
			$db->demand_edit('er',$_POST['did']); }
		}
		//расчет партнерской программы  и накопительной скидки
		$db->raschet_partner($demand_info[0]['partner_id'],$demand_info[0]['summa'],$demand_info[0]['bonus_id']);
	}
	else {
		$db->demand_add_coment('В процессе платежа были изменены параметры заявки.<br />Сообщите администрации, завка будет исполнена в ручном режиме после проверки',$_POST['did']);
		$db->demand_edit('er',$_POST['did']);
	}
}
else { $db->demand_add_coment('Не верное значение в контрольной подписи',$_POST['did']);
	$db->demand_edit('er',$_POST['did']); }
}

?>