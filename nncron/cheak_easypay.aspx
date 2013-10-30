<?php
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$pay = $db->pay_easypay();
if(!empty($pay)) {
	foreach($pay as $ar) {
		$idpay = $db->sel_idpay($ar[0]);
$wsdl = 'https://ssl.easypay.by/xml/easypay.wsdl';

//параметры для вызова функции получения оплаченных счетов (EP_GetPaidInvoices)
$params_EP_GetPaidInvoices = array(
'mer_no' =>'ok0425', //тестовый ПТС
'pass' =>'RtyUpvD567nM', //пароль на тестовый ПТС
'order' =>$idpay[0]['id_pay'], //номер счетапо которому производиться проверка
);
//---------------------------------------------------------------------------
global $wsdl, $params_EP_GetPaidInvoices, $params_EP_IsInvoicePaid;
//создание клиента
$client = new SoapClient($wsdl, array('trace' => 1, 'encoding'=>'windows-1251'));
//может возникнуть исключение SoapFault при неявном формировании входных и выходных xml-пакетов
try {
$answer = $client->EP_IsInvoicePaid($params_EP_GetPaidInvoices);
} catch (SoapFault $fault) {
print "ExeptionIsCatchedByUser!<br>faultcode: $fault->faultcode;
faultstring: $fault->faultstring<br>";
}
//разбираем ответ
	if($answer->status->code == 200) {
			$order_arr = $db->sel_order_arr($ar[0]);
			if($ar[2] == "p") {$result_order = $db->open_kod($order_arr[0]['order_arr'],$ar[0]);
	if($demand_info[0]['send_mail'] == "1") {
		require($home_dir."include/smtp-func.aspx");
		$mail_ini = $db->creat_mail($_POST['did'],$result_order,$demand_info[0]['order_arr'],$demand_info[0]['company']);
		$ar_mail = explode('|',$mail_ini);
		smtpmail($demand_info[0]['email'],$ar_mail[0],$ar_mail[1],$ar_mail[2]);
	}
			}
			if($ar[2] == "pz") {
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
$parser = new WMXIParser();
	$response = $wmxi->X2(intval($idpay[0]['id_pay']),$WMZ,$ar[1],floatval($ar[3]),'0','','Возврат залога по заявке №'.$ar[0],'0');
		$structure = $parser->Parse($response, DOC_ENCODING);
		$transformed = $parser->Reindex($structure, true);
		$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
		$desc_er = htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES);
			if ($kod_error == "0") {$db->demand_edit('y',$ar[0]);}
			else {$db->demand_add_coment($desc_er,$ar[0]);
			$db->demand_edit('er',$ar[0]); }
				}
//расчет партнерской программы  и накопительной скидки
			$db->raschet_partner($order_arr[0]['partner_id'],$order_arr[0]['summa'],$order_arr[0]['bonus_id']);
		}
	}
}
?>
