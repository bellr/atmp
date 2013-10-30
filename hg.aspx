<?
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);

$xmlres = simplexml_load_string(str_replace('\"','"',$_POST['XML']));
$sign = strtoupper(md5('j{Na#$N{d_sB#U}N*n;'.str_replace('\"','"',$_POST['XML'])));
$ar = getallheaders();

	if($ar['ServiceProvider-Signature'] == 'SALT+MD5: '.$sign) {
	$type_oper = $db->sel_type($xmlres->PersonalAccount);
		if($type_oper[0]['type_oper'] == "buy_pin") {
switch($xmlres->RequestType):

case ("ServiceInfo") :

$demand_info = $db->order_iPay($xmlres->PersonalAccount);
if($demand_info[0]["status"] == "n" ||  $demand_info[0]["status"] == "yz") {
if(!empty($demand_info)) {

$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <ServiceInfo>
    <Amount>
      <Debt>'.$demand_info[0]["summa"].'</Debt>
    </Amount>
  </ServiceInfo>
</ServiceProvider_Response>';
}
else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' не существует (просрочен) или уже оплачен!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
}
}
if($demand_info[0]["status"] == "p" || $demand_info[0]["status"] == "pz") {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' находится в процессе оплаты!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
}
	break;

case ("TransactionStart") :
	$st = $db->sel_st($xmlres->PersonalAccount);
	if($st[0]['status'] == "n") $db->demand_edit('p',$xmlres->PersonalAccount);
	if($st[0]['status'] == "yz") $db->demand_edit('pz',$xmlres->PersonalAccount);
$demand_info = $db->order_iPay($xmlres->PersonalAccount);

$db->add_id_pay($xmlres->TransactionStart->TransactionId,$xmlres->PersonalAccount);
$id_pay = $db->sel_idpay($xmlres->PersonalAccount);

if($demand_info[0]["status"] == "p" || $demand_info[0]["status"] == "pz") {
	if(!empty($demand_info)) {

if($xmlres->TransactionStart->Amount == $demand_info[0]['summa']) {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <TransactionStart>
    <ServiceProvider_TrxId>'.$id_pay[0]["id_pay"].'</ServiceProvider_TrxId>
  </TransactionStart>
</ServiceProvider_Response>';
}
else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Неверная сумма заказа!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
}
	}
	else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' не существует (просрочен) или уже оплачен!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
	}
}
/*
if($demand_info[0]["status"] == "p" || $demand_info[0]["status"] == "pz") {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' находится в процессе оплаты!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
}
*/
break;

case ("TransactionResult") :

$demand_info = $db->order_iPay($xmlres->PersonalAccount);
	if(!empty($demand_info)) {
		if(empty($xmlres->TransactionResult->ErrorText)) {
//функция извлечения пин-кодов и изменения статуса заявки
	if($demand_info[0]['status'] == "p") {$result_order = $db->open_kod($demand_info[0]['order_arr'],$xmlres->PersonalAccount);
	if($demand_info[0]['send_mail'] == "1") {
		require($home_dir."include/smtp-func.aspx");
		$mail_ini = $db->creat_mail($_POST['did'],$result_order,$demand_info[0]['order_arr'],$demand_info[0]['company']);
		$ar_mail = explode('|',$mail_ini);
		smtpmail($demand_info[0]['email'],$ar_mail[0],$ar_mail[1],$ar_mail[2]);
	}
	}
	if($demand_info[0]['status'] == "pz") {
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
$parser = new WMXIParser();
	$response = $wmxi->X2(intval($xmlres->TransactionResult->ServiceProvider_TrxId),$WMZ,$demand_info[0]['purse'],floatval($demand_info[0]['guarantee_price']),'0','','Возврат залога по заявке №'.$xmlres->PersonalAccount,'0');
		$structure = $parser->Parse($response, DOC_ENCODING);
		$transformed = $parser->Reindex($structure, true);
		$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
		$desc_er = htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES);
			if ($kod_error == "0") {$db->demand_edit('y',$xmlres->PersonalAccount);}
			else {$db->demand_add_coment($desc_er,$xmlres->PersonalAccount);
			$db->demand_edit('er',$xmlres->PersonalAccount); }
}
//расчет партнерской программы  и накопительной скидки
$db->raschet_partner($demand_info[0]['partner_id'],$demand_info[0]['summa'],$demand_info[0]['bonus_id']);

$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <TransactionResult>
   <Info>
 	 <InfoLine>Заказ номер '.$xmlres->PersonalAccount.' успешно оплачен.</InfoLine>
    </Info>
  </TransactionResult>
</ServiceProvider_Response>';
		}
		else {
	$db->demand_add_coment(iconv("utf-8","windows-1251",$xmlres->TransactionResult->ErrorText),$xmlres->PersonalAccount);
	$db->demand_edit('n',$xmlres->PersonalAccount);

$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <TransactionResult>
    <Info>
      <InfoLine>ВНИМАНИЕ! Заказ отменен!</InfoLine>
    </Info>
  </TransactionResult>
</ServiceProvider_Response>';
		}
	}
	else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' не существует (просрочен) или уже оплачен!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
	}
break;
endswitch;

$sign_ipay = strtoupper(md5('j{Na#$N{d_sB#U}N*n;'.$xml));
header("ServiceProvider-Signature: SALT+MD5: {$sign_ipay}");
echo $xml;
		}
//////////////////////////////////////////////////ПОКУПКА ЭЛКЕТРОННЫХ ДЕНЕГ//////////////////////////////////////////////////
		if($type_oper[0]['type_oper'] == "buy_emoney") {

switch($xmlres->RequestType):
case ("ServiceInfo") :
$demand_info = $db->order_iPay_e($xmlres->PersonalAccount,'n');
if(!empty($demand_info)) {
			$i = explode('|',$type_oper[0]["order_arr"]);
			$info_cur = explode(':',$i[0]);
			$balance = $db->sel_bal($info_cur[1]);
	if($balance[0]['balance'] >= $info_cur[0]) {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <ServiceInfo>
    <Amount>
      <Debt>'.$demand_info[0]["summa"].'</Debt>
    </Amount>
  </ServiceInfo>
</ServiceProvider_Response>';
	}
	else {
$db->demand_edit('er',$xmlres->PersonalAccount);
$db->demand_add_coment('На счету агента недостаточно средств для выполнения операции. Администрация оповещена о данной ошибке.',$xmlres->PersonalAccount);
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>На счету агента недостаточно средств для выполнения операции.</ErrorLine>
  </Error>
</ServiceProvider_Response>';
	}
}
else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' не существует (просрочен) или уже оплачен!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
}
break;

case ("TransactionStart") :

$demand_info = $db->order_iPay_e($xmlres->PersonalAccount,'n');
	if(!empty($demand_info)) {
			$i = explode('|',$type_oper[0]["order_arr"]);
			$info_cur = explode(':',$i[0]);
			$balance = $db->sel_bal($info_cur[1]);
		if($balance[0]['balance'] >= $info_cur[0]) {
			$db->demand_edit('p',$xmlres->PersonalAccount);
			$db->add_id_pay($xmlres->TransactionStart->TransactionId,$xmlres->PersonalAccount);
			$id_pay = $db->sel_idpay($xmlres->PersonalAccount);

			if($xmlres->TransactionStart->Amount == $demand_info[0]['summa']) {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <TransactionStart>
    <ServiceProvider_TrxId>'.$id_pay[0]["id_pay"].'</ServiceProvider_TrxId>
  </TransactionStart>
</ServiceProvider_Response>';
			}
			else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Неверная сумма заказа!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
			}
		}
		else {
$db->demand_edit('er',$xmlres->PersonalAccount);
$db->demand_add_coment('На счету агента недостаточно средств для выполнения операции. Администрация оповещена о данной ошибке.',$xmlres->PersonalAccount);
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>На счету агента недостаточно средств для выполнения операции.</ErrorLine>
  </Error>
</ServiceProvider_Response>';
		}
	}
	else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' не существует (просрочен) или уже оплачен!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
	}
break;

case ("TransactionResult") :
$demand_info = $db->order_iPay_e($xmlres->PersonalAccount,'p');
	if(!empty($demand_info)) {
		if(empty($xmlres->TransactionResult->ErrorText)) {
			$i = explode('|',$type_oper[0]["order_arr"]);
			$info_cur = explode(':',$i[0]);
			$balance = $db->sel_bal($info_cur[1]);
			$update_bal = $balance[0]['balance'] - $info_cur[0];
			$db->upd_bal($update_bal,$info_cur[1]);
				if($balance[0]['balance'] >= $info_cur[0]) {

include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
$parser = new WMXIParser();
$response = $wmxi->X2(intval($xmlres->TransactionResult->ServiceProvider_TrxId),$balance[0]['purse'],$demand_info[0]['purse'],floatval($info_cur[0]),'0','','Чек №'.$xmlres->TransactionResult->ServiceProvider_TrxId.': Распространение эл. денег (Номер кошелька: '.$demand_info[0]['purse'].', Сумма: '.$info_cur[0].' WMB)','0');
		$structure = $parser->Parse($response, DOC_ENCODING);
		$transformed = $parser->Reindex($structure, true);
		$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
		$desc_er = htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES);
			if ($kod_error == "0") {$db->demand_edit('y',$xmlres->PersonalAccount);}
				else {$db->demand_add_coment($desc_er.' ERROR='.$kod_error,$xmlres->PersonalAccount);
					$db->demand_edit('er',$xmlres->PersonalAccount);}
				}
				else {
$db->demand_edit('er',$xmlres->PersonalAccount);
$db->demand_add_coment('Оплата принята. На счету агента недостаточно средств для выполнения операции. Администрация оповещена о данной ошибке.',$xmlres->PersonalAccount);
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>На счету агента недостаточно средств для выполнения операции.</ErrorLine>
  </Error>
</ServiceProvider_Response>';
				}
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <TransactionResult>
   <Info>
 	 <InfoLine>Заказ номер '.$xmlres->PersonalAccount.' успешно оплачен.</InfoLine>
    </Info>
  </TransactionResult>
</ServiceProvider_Response>';
		}
		else {
	$db->demand_add_coment(iconv("utf-8","windows-1251",$xmlres->TransactionResult->ErrorText),$xmlres->PersonalAccount);
	$db->demand_edit('n',$xmlres->PersonalAccount);
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <TransactionResult>
    <Info>
      <InfoLine>ВНИМАНИЕ! Заказ отменен!</InfoLine>
    </Info>
  </TransactionResult>
</ServiceProvider_Response>';
		}
	}
	else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' не существует (просрочен) или уже оплачен!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
	}
break;
endswitch;

$sign_ipay = strtoupper(md5('j{Na#$N{d_sB#U}N*n;'.$xml));
header("ServiceProvider-Signature: SALT+MD5: {$sign_ipay}");
echo $xml;
		}
	}

$s = $xmlres->RequestType." - ".$xmlres->PersonalAccount." koderror ".$kod_error."\n".$xml."\n".$sign_ipay."\n\n";
$fd = fopen("hg.log","a");
fputs($fd, $s);
fflush($fd);
fclose($fd);

?>
