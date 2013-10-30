<?
require('customsql.inc.aspx');
require('function.aspx');
$db = new CustomSQL($DBName);
$sk = "p7hdgysf";
$prjID = "3-511-7111";
$serviceNumber = "SERTIFIKAT";
$error_kod = false;
if($_SERVER['REMOTE_ADDR'] == '89.113.17.239') {
if($_POST[serviceNumber] == 'USSD4449') {

	//проверка на наличие в системе заказа с ID SMS-запроса
	$t = $db->sel_IDpayiFree($_POST[evtId]);

	if(empty($t)) {
$h = strtoupper(md5($_POST[serviceNumber].$_POST[smsText].$_POST[country].$_POST[abonentId].$sk.$_POST[now]));
	if($h == $_POST[md5key]) {
		$reqID = wm_ReqID();
		$providerProperties = base64_decode($_POST["providerProperties"]);
		$providerProperties = '<?xml version="1.0" encoding="utf-8" ?>'.$providerProperties;
		$xmlres = simplexml_load_string($providerProperties);

		$smsText = base64_decode($_POST['smsText']);
		$article_goods = substr($smsText,4,6);
		$info_goods = $db->sel_amount($article_goods);

		if(empty($info_goods)) {$error_kod = true;}
		$kod_goods = $db->sel_kod_goods($info_goods[0]['price']);
		$kod_goods = $kod_goods[0][t_identifier].'01'.$article_goods;

			if($smsText == $kod_goods && !$error_kod) {
				$summa = $info_goods[0]['price'];
				if($info_goods[0]['type_goods'] == 'buy_pin') {
					$order = '1:'.$info_goods[0]['card'].'|';
				//резервирование заказа
				$db->rezerv_goods($info_goods[0]['card']);
				}
				elseif($info_goods[0]['type_goods'] == 'buy_emoney') {
					//Проверка на действительность кода для покупки эл. денег по низким тарифам
					$input = $db->count_wmb_input(date('Y-m'));
					$output = $db->count_wmb_output(date('Y-m'));
					foreach($output as $ar) {
						$s = explode('|',$ar[order_arr]);
						$ss = explode(':',$s[0]);
						$summ_out = $ss[0] + $summ_out;
					}
					$cur = explode('_',$info_goods[0]['name_company']);
					$remind = $db->remind($cur[0]);
					$info_currency = $db->info_currency($cur[0]);
/*
						if($remind[0][renewing] > 0) {
							if($input[0][summ]*0.992 > $summ_out-$remind[0][renewing]) {
								$balance = ($summ_out-$remind[0][renewing] + $info_currency[0]['balance']) - $input[0][summ]*0.992;
							}
							else {$cur = "none";}
						}
*/
							//if($r<=0 && $r_b<=0){$cur = "none";}
					$order = $summa.':'.$info_goods[0]['name_company'].'|';
					//$order = $kod_goods[0][t_partner].':'.$info_goods[0]['name_company'].'|';
					//резервирование заказа
					$info_goods[0]['name_company'] = $cur[0];
					$balance = $db->sel_bal($info_goods[0]['name_company']);
					$s = $balance[0]['balance']-$summa;
					if($summa <= $balance[0]['balance']) {
					$db->upd_bal($s,$info_goods[0]['name_company']);

				}
				else {echo $answ =  '<Response><ErrorText>На счету агента недостаточно средств для выполнения операции.</ErrorText></Response>';
			//echo $answ =  "<Response async='true' />";
			//SendSmsBadAnswer($prjID,$serviceNumber,$_POST['abonentId'],base64_encode("Неправильный код товара. Проверьте код и введите его  еще раз или свяжитесь с сотрудником магазина."),$_POST['now'],$sk,$xmlres->item[0],0);
			exit();
				}
				}
				$company = $info_goods[0]['name_company'].'|'.$summa.'||';
				//$company = $info_goods[0]['name_company'].'|'.$kod_goods[0][t_partner].'||';
				//$data = sprintf("%d-%02d-%02d",substr($_POST['now'],0,4),substr($_POST['now'],4,2),substr($_POST['now'],6,2));
				//$time = sprintf("%02d:%02d:%02d",substr($_POST['now'],8,2),substr($_POST['now'],10,2),substr($_POST['now'],12,2));
$db->add_order($reqID,'iFree',$summa,$order,md5(trim(stripslashes(htmlspecialchars($reqID)))),$data_pay,$time_pay,$company,$info_goods[0]['type_goods'],$_POST['abonentId'],$info_goods[0]['type_goods']);
				$db->add_id_payiFree($reqID,$_POST['evtId'],$xmlres->item[0]);
				$id_pay = $db->sel_idpay($reqID);
				echo $answ =  "<Response async='true' />";
				SendSmsAnswer($prjID,$_POST[serviceNumber],$_POST['abonentId'],base64_encode("Sertifikat bydet otgrujen posle oplati"),$_POST['now'],$sk,$xmlres->item[0],true,$id_pay[0]['id_pay'],$reqID);
			}
			else {
				echo $answ =  "<Response async='true' />";
			SendSmsBadAnswer($prjID,$serviceNumber,$_POST['abonentId'],base64_encode("Неправильный код товара. Проверьте код и введите его  еще раз или свяжитесь с сотрудником магазина."),$_POST['now'],$sk,$xmlres->item[0],0);
			}
	}	else {echo $answ =  '<Response><ErrorText>Не верная контрольная подпись.</ErrorText></Response>';}

}
else {echo $answ =  '<Response><ErrorText>Такой заказ уже существует и оплачен.</ErrorText></Response>';}
}
if($_POST['type'] == 'OUTBOUND_DELIVERY') {
	$did = $db->iFree_did($_POST['partnerMessageId']);
	$demand_info = $db->order_iFree($did[0]['did']);
	if($_POST['deliveryState'] == 'DELIVERED') {
		if($demand_info[0]['status'] == 'n') {
			if($demand_info[0]['type_oper'] == 'buy_pin') {$r = $db->open_kod($demand_info[0]['order_arr'],$did[0]['did']);}

SendSmsAnswer($prjID,$serviceNumber,$demand_info[0]['abonentId'],base64_encode("Ваш сертификат N {$did[0]['did']}. Магазин PinShop.by. Пожалуйста, сохраняйте данное сообщение до момента получения товара по этому сертификату."),$_POST['deliveryTimeUtc'],$sk,$did[0]['iFreeAbonentId'],true,$_POST['partnerMessageId'],$did[0]['did']);

/*
				if($_POST['phone'] == $_POST['frommsisdn']) {
SendSmsAnswer($prjID,$serviceNumber,$demand_info[0]['abonentId'],base64_encode("Ваш сертификат N {$did[0]['did']}. Магазин PinShop.by. Пожалуйста, сохраняйте данное сообщение до момента получения товара по этому сертификату."),$_POST['deliveryTimeUtc'],$sk,$did[0]['iFreeAbonentId'],true,$_POST['partnerMessageId'],$did[0]['did']);
				}
				elseif($_POST['phone'] != $_POST['frommsisdn']) {
SendSmsFriend($prjID,$serviceNumber,$_POST['frommsisdn'],base64_encode("Вам подарили сертификат N {$did[0]['did']} в магазине PinShop.by. Пожалуйста, сохраняйте данное сообщение до момента получения товара по этому сертификату."),$_POST['deliveryTimeUtc'],$sk,$did[0]['iFreeAbonentId'],true,$_POST['partnerMessageId'],$did[0]['did']);
				}
				*/
			$db->demand_edit('yn',$did[0]['did']);
		}
		elseif($demand_info[0]['status'] == 'yn') {
			if($demand_info[0]['type_oper'] == 'buy_pin') {
				$n_card = explode('|',$demand_info[0]['order_arr']);
				$card = explode(':',$n_card[0]);
				$db->unrezerv_goods($card[1]);
				$db->demand_edit('y',$did[0]['did']);
			}
		}
	}
	if($_POST['deliveryState'] == 'UNDELIVERED') {
		if($demand_info[0]['status'] == 'n') {
			//$db->demand_edit('er',$did[0]['did']);
			//$db->demand_add_coment('ERROR message UNDELIVERED abonent',$did[0]['did']);
			if($demand_info[0]['type_oper'] == 'buy_pin') {
				$n_card = explode('|',$demand_info[0]['order_arr']);
				$card = explode(':',$n_card[0]);
				//$db->unrezerv_goods($card[1]);
				//SendSmsAnswer($prjID,$FserviceNumber,$demand_info[0]['abonentId'],base64_encode("Sertifikat bydet otgrujen posle oplati"),$_POST['deliveryTimeUtc'],$sk,$did[0]['iFreeAbonentId'],true,$_POST['partnerMessageId'],$reqID);

			}
		}
		elseif($demand_info[0]['status'] == 'yn') {
			//SendSmsAnswer($prjID,$serviceNumber,$demand_info[0]['abonentId'],base64_encode("Ваш сертификат N {$did[0]['did']}. Магазин PinShop.by.  Пожалуйста, сохраняйте данное сообщение до момента получения товара по этому сертификату."),$_POST['deliveryTimeUtc'],$sk,$did[0]['iFreeAbonentId'],true,$_POST['partnerMessageId'],$did[0]['did']);
		}
	}
echo $answ = "<Response status='OK' />";
}
//ответ на тестовый запрос
if(!empty($_POST['test'])) {echo "<Response><SmsText>".$_POST['test']."</SmsText></Response>";}
}

$str = "\nTime: ".$data_pay." ".$time_pay." IP: ".$_SERVER['REMOTE_ADDR']." Proxy ".$_SERVER['HTTP_X_FORWARDED_FOR']."===========================\n";
if(!empty($_POST["evtId"])) $str .= "[evtId]={".$_POST["evtId"]."}\n";
if(!empty($_POST["phone"])) $str .= "[phone]={".$_POST["phone"]."}\n";
//$str .= "[frommsisdn]=".$_POST['frommsisdn']."\n";
if(!empty($_POST["abonentId"])) $str .= "[abonentId]={".$_POST["abonentId"]."}\n";
//$str .= "[country]=".$_POST["country"]."\n";
if(!empty($_POST["serviceNumber"])) $str .= "[serviceNumber]={".$_POST["serviceNumber"]."}\n";
if(!empty($_POST["operatorId"])) $str .= "[operatorId]={".$_POST["operatorId"]."}\n";
//$str .= "[networkId]=".$_POST["networkId"]."\n";
//$str .= "[network]=".$_POST["network"]."\n";
if(!empty($_POST["smsText"])) $str .= "[smsText]={".base64_decode($_POST['smsText'])."}\n";
if(!empty($_POST["now"])) $str .= "[now]={".$_POST["now"]."}\n";
//if(!empty($_POST["md5key"])) $str .= "[md5key]=".$_POST["md5key"]."\n";
//$str .= "[$h]=".$h."\n";
//$str .= "[data_$h]=".$_POST[serviceNumber]."|".$_POST[smsText]."|".$_POST[country]."|".$_POST[abonentId]."|".$sk."|".$_POST[now]."\n";
if(!empty($_POST["test"])) $str .= "[test]={".$_POST["test"]."}\n";
if(!empty($_POST["retry"])) $str .= "[retry]={".$_POST["retry"]."}\n";
if(!empty($_POST["debug"])) $str .= "[debug]={".$_POST["debug"]."}\n";
if(!empty($_POST["type"])) $str .= "[type]={".$_POST["type"]."}\n";
if(!empty($_POST["deliveryState"])) $str .= "[deliveryState]={".$_POST["deliveryState"]."}\n";
if(!empty($_POST["partnerMessageId"])) $str .= "[partnerMessageId]={".$_POST["partnerMessageId"]."}\n";
if(!empty($_POST["outboundMessageId"])) $str .= "[outboundMessageId]={".$_POST["outboundMessageId"]."}\n";
if(!empty($_POST["deliveryTimeUtc"])) $str .= "[deliveryTimeUtc]={".$_POST["deliveryTimeUtc"]."}\n";
if(!empty($demand_info[0]['status'])) $str .= "[status]={".$demand_info[0]['status']."}\n";
if(!empty($s)) $str .= "[balance]=".$s." >={".$limitWMB_iFree."}\n";
if(!empty($answ)) $str .= "{".$answ."}\n\n";


		$fd = fopen("log_ifree.log","a");
		fputs($fd, $str);
                fflush($fd);
		fclose($fd);

?>