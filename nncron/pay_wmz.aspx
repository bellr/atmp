<?php
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);

if($_POST['LMI_SECRET_KEY'] == "16201986") {

//вывод инфы по заявке
	$demand_info = $db->demand_check($_POST['did'],'WMZ');
if (!empty($_POST['LMI_HASH'])) {
	$md5_demand = md5($demand_info[0]['guarantee_price'].$WMZ);
	$md5_merchant = md5($_POST['LMI_PAYMENT_AMOUNT'].$_POST['LMI_PAYEE_PURSE']);

		$fd = fopen("123.log","a");
		fputs($fd, $_POST['did']." - ".$demand_info[0]['oplata']." ".$demand_info[0]['guarantee_price'].$WMZ." - ".$_POST['LMI_PAYMENT_AMOUNT'].$_POST['LMI_PAYEE_PURSE']."\n");
                fflush($fd);
		fclose($fd);


	if ($md5_demand == $md5_merchant) {
		//функция извлечения пин-кодов
		if($demand_info[0]['status'] == "n") {$result_order = $db->open_kod($demand_info[0]['order_arr'],$_POST['did']);
	if($demand_info[0]['send_mail'] == "1") {
		require($home_dir."include/smtp-func.aspx");
		$mail_ini = $db->creat_mail($_POST['did'],$result_order,$demand_info[0]['order_arr'],$demand_info[0]['company']);
		$ar_mail = explode('|',$mail_ini);
		smtpmail($demand_info[0]['email'],$ar_mail[0],$ar_mail[1],$ar_mail[2]);
	}
		}

	$status_dem = $db->sel_st($_POST['did']);
	if($status_dem[0]['status'] == "y") {$st = "yz";
	$db->demand_edit($st,$_POST['did']); }

//расчет партнерской программы  и накопительной скидки
$db->raschet_partner($demand_info[0]['partner_id'],$demand_info[0]['summa'],$demand_info[0]['bonus_id']);
	}
	else { $db->demand_add_coment('В процессе платежа были изменены параметры заявки.<br />Сообщите администрации, завка будет исполнена в ручном режиме после проверки',$_POST['did']);
	$db->demand_edit('er',$_POST['did']); }
}
else { $db->demand_add_coment('Не верное значение в контрольной подписи',$_POST['did']);
	$db->demand_edit('er',$_POST['did']); }
}
$text =
	$demand_info[0]['guarantee_price'].$WMZ."\n".
	$_POST['LMI_PAYMENT_AMOUNT'].$_POST['LMI_PAYEE_PURSE'];
/*
		$fd = fopen("123.log","w+");
		fputs($fd, $text);
                fflush($fd);
		fclose($fd);
		*/
?>