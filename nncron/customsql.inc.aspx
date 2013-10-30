<?
include('../const.inc.aspx');
require("dbsql.inc.aspx");
function wm_ReqID(){
    $time=microtime();
    $int=substr($time,11);
    $flo=substr($time,2,3);
	$f=substr($int,0,7);
    return $f.$flo;
}
//КЛАСС ДЛЯ РАБОТЫ С ГЛАВНОЙ БАЗОЙ
Class CustomSQL extends DBSQL
{
   // the constructor
   function CustomSQL($DBName = "")
   {
      $this->DBSQL($DBName);
   }
   function selpas()
   {
    $sql = "SELECT @password:='dbnfkbq1986'";
	$result = $this->select($sql);
	return $result;
   }
//функция подставки резервного кошелька WM
	function RezervPusre($company,$WMB,$rezerv_WMB) {
		$pay = $this->info_company_pay($company);
		if($pay[0]['rezerv_purse'] == 1) {$purse = $rezerv_WMB;}
		else {$purse = $WMB;}
	return $purse;
	}
//функция извлечения пин-кодов
function open_kod($order_arr,$did) {
	$st = "y";
     		$order = explode('|',$order_arr);
		foreach($order as $ar_order) {
			if(!empty($ar_order)) {
				$orders = explode(':',$ar_order);
				$sel_count_card = $this->sel_count_card($orders[1]);
				if($sel_count_card[0]['count'] >= $orders[0]) $this->upd_count_card($orders[1],$sel_count_card[0]['count'] - $orders[0]);
				for($i=1;$i<=$orders[0];$i++) {
						$sel_pin = $this->sel_pin($orders[1]);
						$this->up_st($sel_pin[0]['id'],"0");
						if(!empty($sel_pin[0]['id'])) {
						$log_pass .= $sel_pin[0][1].":".$sel_pin[0][2].":".$sel_pin[0][3]."|";
						$id_cards .= $orders[1].":".$sel_pin[0]['id']."|";
						}
						else {$log_pass .= "Не найден:Не найден|"; $st = "er"; }
				}
			}
		}
$this->add_id_cards($did,$id_cards);
$this->demand_edit($st,$did);
$this->add_loginpass($did,$log_pass);
return $log_pass;
}

function creat_mail($did,$result_order,$demand_info_order_arr,$demand_info_company) {
	include('../const.inc.aspx');
//require("/home/bellr/data/www/pinshop.by/include/smtp-func.aspx");
		$order = explode('|',$demand_info_order_arr);
		$log_pass_arr = explode('|',$result_order);
		$c_pin = 0;
		$i = 0;
		$body = "";
		foreach($order as $ar_order) {
			if(!empty($ar_order[0])) {

			$orders = explode(':',$ar_order);
				$info_cards = $this->sel_card($orders[1]);
				if (!empty($info_cards)) {$body .= "<div style=\"margin-top:5px;\"><u>{$info_cards[0]['name_card']}</u>&nbsp;&nbsp;&nbsp;&nbsp;<b>".$orders[0]." шт.</b>
				</div>";
				for($i=0; $i<$orders[0]; $i++) {
					$log_pass = explode(':',$log_pass_arr[$c_pin]);
					if(empty($log_pass[0])) {
						$body .= "<div id=\"vivod_pin\" style=\"FONT-SIZE: 11px;\"><b>Пин-код : </b>{$log_pass[1]} <br /><b>S/N:</b> {$log_pass[2]}</div>";
					}
					else {
$s = explode('||',$demand_info_company);
$t = explode('|',$s[$c_pin]);
switch ($t[0]) :
	case ("niks") :
					$body .= "<div id=\"vivod_pin\" style=\"float:left;margin-left:5px;margin-right:0; FONT-SIZE: 11px;\"><b>Логин : </b>niks\\{$log_pass[0]}&nbsp;</div><div id=\"vivod_pin\" style=\"FONT-SIZE: 11px;\"><b>Пароль : </b>{$log_pass[1]}<br /><b>S/N:</b> {$log_pass[2]}</div>";
	break;
	case ("byfly") :
					$body .= "<div id=\"vivod_pin\" style=\"float:left;margin-left:5px;margin-right:0; FONT-SIZE: 11px;\" class='text_log'> <b>Код активации : </b>{$log_pass[0]}&nbsp;</div><div id=\"vivod_pin\" class='text_log' style=\"FONT-SIZE: 11px;\"><b>Пин-код : </b>{$log_pass[1]}<br /><b>S/N:</b> {$log_pass[2]}</div>";
	break;
	default:
					$body .= "<div id=\"vivod_pin\" style=\"float:left;margin-left:5px;margin-right:0; FONT-SIZE: 11px;\"><b>Логин : </b>{$log_pass[0]}&nbsp;</div><div id=\"vivod_pin\" style=\"FONT-SIZE: 11px;\"><b>Пароль : </b>{$log_pass[1]} <br /><b>S/N:</b> {$log_pass[2]}</div>";
	break;
endswitch;
					}
					$c_pin++;
				}
				}
		}
		}
///////Отправка письма
	$from_name = "Robot PinShop.by";
	$subject = "Заказ №{$did} из интернет-магазина PinShop.by";
	$body_mail = "
<div style=\"FONT-SIZE: 12px; FONT-FAMILY: Verdana; COLOR: #676767; LINE-HEIGHT: 18px;\">
<center><b>Здравствуйте, Уважаемый пользователь!</b></center><br />
-------------------------------------------------------<br />
<h2>Ваш заказ № {$did}</h2>
-------------------------------------------------------<br />
<br />

{$body}<br />
<br />
Мы будем благодарны Вам за любые предложения, высказанные по поводу того,<br />
какой Вы хотите видеть интернет-магазин PinShop.by.<br /><br />

Благодарим Вас за использование нашего Сервиса.<br />
Это письмо отправлено роботом, ответа не требует.<br />
<br />
--<br />
С уважением,<br />
Администрация PinShop.by<br />
<br />
<a href='http://pinshop.by'>Интернет-магазин пин-кодов</a><br />
Mail: <a href='mailto:$support'>$support</a><br />
ICQ: $icq<br />
Тел.: $tel</div>";
return $subject."|".$body_mail."|".$from_name;
}
//выбор заказов на распространение
   function sel_spread_wmb() {
	$sql = "SELECT o.did,o.purse,o.order_arr,ip.id_pay FROM orders as o,id_payment as ip WHERE o.purse IS NOT NULL and o.status LIKE '%yn%' and o.type_oper LIKE 'buy_emoney' and ip.did=o.did";
	$result = $this->select($sql);
	return $result;
   }
//вывод индетификатора товара по тарифу
   function sel_kod_goods($price)
   {
	$sql = "select t_identifier,t_partner,t_abonent from tarrifs_commerce where t_partner>='$price' order by id asc limit 1";
	$result = $this->select($sql);
	return $result;
   }
//вывод инфы о карточке
   function sel_amount($id)
   {
	$sql = "select name_company,card,price,type_goods from info_cards where id='$id' and count>'3'";
	$result = $this->select($sql);
	return $result;
   }
//Добавление заказа
  function add_order($did,$oplata,$summa,$order,$pass,$data_pay,$time_pay,$company,$type_oper,$abonentId)
   {
      $sql = "insert into orders (did,oplata,summa,order_arr,password,data_pay,time_pay,company,type_oper,abonentId) values ('$did','$oplata','$summa','$order','$pass','$data_pay','$time_pay','$company','$type_oper','$abonentId')";
      $result = $this->insert($sql);
	  return $result;
   }
//Добавление номера платежа
   function add_id_payiFree($did,$evtId,$abonentId)
   {
      $sql = "insert into id_payment (did,id_more_pay,iFreeAbonentId) values ('$did','$evtId','$abonentId')";
      $result = $this->insert($sql);
   }
//резервирование заказа
	function rezerv_goods($card)
	{
	$sql = "update info_cards set count=count-1 where card='$card'";
	$this->update($sql);
}
//резервирование заказа
	function unrezerv_goods($card)
	{
	$sql = "update info_cards set count=count+1 where card='$card'";
	$this->update($sql);
}
//поиск транзакции по uniqueMessageID
   function sel_IDpayiFree($evtId)
   {
	 $sql = "select ip.id_more_pay,o.did from id_payment as ip, orders as o where ip.id_more_pay='$evtId' and ip.did=o.did and o.oplata='iFree' and o.status='n'";

      $result = $this->select($sql);
      return $result;
   }
//функция для расчета партнерской программы  и накопительной скидки
function raschet_partner($partner_id,$summa,$bonus_id) {
		if($partner_id > 0) {
			$sum_percent = $summa * 0.05 * 0.2;
			$this->update_bal_partner($sum_percent,$summa,$partner_id);
		}
		else {
			if($bonus_id > 0) $this->update_bal_bonus($summa,$bonus_id);
		}
}
//вывод инфы о карточке
   function sel_card($card)
   {
	$sql = "select card,name_card from info_cards where card='$card'";
	$result = $this->select($sql);
	return $result;
   }
//Вывод возможного метода оплаты
   function info_company_pay($name)
   {
	$sql = "select WebMoney,EasyPay,WebPay,rezerv_purse from info_company where name='$name'";
	$result = $this->select($sql);
	return $result;
   }
//Вывод процента комиссии и базы настроек
   function ini_comission()
   {
	$sql = "select commission from ini where id='1'";
	$result = $this->select($sql);
	return $result;
   }
//Обновление курса
	function update_rate_WMZ($rate)
	{
	$sql = "update ini set rate_WMZ='$rate' where id='1'";
	$results = $this->update($sql);
	return $results;
	}
//При невозможности 100% обмена, запись комментария
	function demand_add_coment($coment,$did)
	{
	$sql = "update orders set coment='$coment' where did='$did'";
	$results = $this->update($sql);
	return $results;
	}
//смена статуса заявки
	function demand_edit($st,$did)
	{
	$sql = "update orders set status='$st' where did='$did'";
	$this->update($sql);
	}
//смена статуса заявки(залог)
	function demZalog_edit($st,$did)
	{
	$sql = "update pay_zalog set status='$st' where did='$did'";
	$this->update($sql);
	}
//вывод инфы по заявке на возврат залога
   function zalog_check($did)
   {
	$sql = "select purse_pay from pay_zalog where did='$did'";
	$result = $this->select($sql);
	return $result;
   }
//Вывод данных по заявке
   function demand_check($did,$oplata)
   {
      $sql = "select purse,summa,oplata,order_arr,email,status,partner_id,bonus_id,company,guarantee_price,send_mail from orders where did='$did' and  (oplata='$oplata' or (oplata='WMZ' and status='yz'))";
      $result = $this->select($sql);
      return $result;
   }
//Вывод статуса заявки
   function sel_st($did)
   {
      $sql = "select status from orders where did='$did'";
      $result = $this->select($sql);
      return $result;
   }
//Вывод пин-кодов по заявке
   function sel_pin($name_card)
   {
	  $p = $this->selpas();
      $sql = "select id,AES_DECRYPT(login,'$p[0][0]'),AES_DECRYPT(pass,'$p[0][0]'),serial from pin_cards where name_card='$name_card' and status='1' order BY 'id' ASC LIMIT 1";
      $result = $this->select($sql);
      return $result;
   }
//добавление пинкодов в заявку после оплаты
	function add_loginpass($did,$log_pass)
	{
	$p = $this->selpas();
	$sql = "update orders set log_pass=(AES_ENCRYPT('$log_pass','$p[0][0]')) where did='$did'";
	$results = $this->update($sql);
	return $results;
	}
//добавление ID купленных карт в заявку после оплаты
	function add_id_cards($did,$id_cards)
	{
	$sql = "update orders set id_cards='$id_cards' where did='$did'";
	$results = $this->update($sql);
	return $results;
	}
//обновление статуса пин-кодов в базе после оплаты
	function up_st($id,$st)
	{
	$sql = "update pin_cards set status='$st' where id='$id'";
	$this->update($sql);
	}
//Вывод количества достцпных для покупки карт по заявке
   function sel_count_card($name_card)
   {
      $sql = "select count from info_cards where card='$name_card'";
      $result = $this->select($sql);
      return $result;
   }
//обновление статуса пин-кодов в базе после оплаты
	function upd_count_card($name_card,$count)
	{
	$sql = "update info_cards set count='$count' where card='$name_card'";
	$this->update($sql);
	}
//Обновление баланса после оплаты в партнерке
	function update_bal_partner($sum_percent,$summa_order,$id)
	{
	$sql = "update partner set balance=balance+$sum_percent, summa_bal=summa_bal+$sum_percent, count_oper=count_oper+1, summ_oper=summ_oper+$summa_order where id='$id' and status='1'";
	$this->update($sql);
	}
//Обновление баланса после оплаты в накопительной системе
	function update_bal_bonus($summa_order,$id)
	{
	$sql = "update bonus set summa_demand=summa_demand+$summa_order where id='$id' and status='1'";
	$this->update($sql);
	}
//Вывод всех аккаунтов по указанной сумме
   function bonus($summa,$disc)
   {
      $sql = "select id,discount from bonus where summa_demand >= '$summa' and discount = '$disc'";
      $result = $this->select($sql);
      return $result;
   }
//Обновление баланса после оплаты в накопительной системе
	function bonus_edit($id,$percent)
	{
	$sql = "update bonus set discount='$percent' where id='$id' and status='1'";
	$this->update($sql);
	}
//удаление просроченных заявок
   function del_dem($did)
   {
      $sql = "delete from orders where did='$did'";
      $result = $this->delete($sql);
      return $result;
   }
//удаление номера платежа
   function del_idpay($did)
   {
      $sql = "delete from id_payment where did='$did'";
      $result = $this->delete($sql);
      return $result;
   }
//Вывод номеров заявок для удаления
   function sel_del_dem($data_tom,$time,$data)
   {
      $sql = "select did from orders where (status='n' or status='p' or status='er') and ((data_pay='$data_tom' and time_pay<='$time') or data_pay='$data' and time_pay<='$time')";
      $result = $this->select($sql);
      return $result;
   }
//Вывод номер заявки
   function sel_did($wsb_order_num)
   {
      $sql = "select did from id_payment where id_pay='$wsb_order_num'";
      $result = $this->select($sql);
      return $result;
   }
//Вывод номер заявки и номера запроса
   function iFree_did($wsb_order_num)
   {
      $sql = "select did,id_more_pay,iFreeAbonentId from id_payment where id_pay='$wsb_order_num'";
      $result = $this->select($sql);
      return $result;
   }
//Добавление номера транзакции от webpay, iPay
   function add_id_pay($transaction_id,$did)
   {
      $sql = "update id_payment set id_more_pay='$transaction_id' where did='$did'";
      $this->update($sql);
   }
//Заявки для проверки на оплату EasyPay
   function pay_easypay()
   {
      $sql = "select did,purse,status,guarantee_price from orders where (oplata='EasyPay' and status='p') or (oplata='WMZ' and status='pz')";
      $result = $this->select($sql);
      return $result;
   }
//Вывод номер транзакции
   function sel_idpay($did)
   {
      $sql = "select id_pay from id_payment where did='$did'";
      $result = $this->select($sql);
      return $result;
   }
//Вывод Заказа
   function sel_order_arr($did)
   {
      $sql = "select summa,order_arr,partner_id,bonus_id from orders where did='$did'";
      $result = $this->select($sql);
      return $result;
   }
//Вывод данных по заказу для iPay
   function order_iPay($did)
   {
      $sql = "select did,purse,summa,order_arr,status,partner_id,bonus_id,guarantee_price from orders where did='$did' and (oplata='iPay' or oplata='WMZ') and status != 'y'";
      $result = $this->select($sql);
      return $result;
   }
//Вывод данных по заказу для iPay
   function order_iFree($did)
   {
      $sql = "select order_arr,data_pay,time_pay,status,type_oper,abonentId from orders where did='$did' and oplata='iFree' and (status = 'n' or status = 'yn')";
      $result = $this->select($sql);
      return $result;
   }
//Вывод данных по заказу для iPay
   function order_iPay_e($did,$st)
   {
      $sql = "select did,purse,summa,order_arr,status from orders where did='$did' and oplata='iPay' and status = '$st'";
      $result = $this->select($sql);
      return $result;
   }
//Вывод данных по заказу для iPay
   function order_iPay_e_res($did)
   {
      $sql = "select purse,summa,order_arr from orders where did='$did' and oplata='iPay' status = 'p'";
      $result = $this->select($sql);
      return $result;
   }
//выборка типа операции
   function sel_type($did)
   {
      $sql = "select oplata,order_arr,type_oper from orders where did='$did'";
      $result = $this->select($sql);
      return $result;
   }
//выборка типа операции
   function sel_bal($name_cur)
   {
      $sql = "select * from balance_currency where name='$name_cur'";
      $result = $this->select($sql);
      return $result;
   }
//обновление баланса
   function upd_bal($bal,$name_cur)
   {
	  $sql = "update balance_currency set balance='$bal' where name='$name_cur'";
      $result = $this->update($sql);
      return $result;
   }
//Вывод данных по неоплаченным счетам(WMB)
   function order_wm()
   {
      $sql = "select did,purse,summa,order_arr,status,partner_id,bonus_id,company,guarantee_price from orders where (status='p' and oplata='WMB') or status='pz'";
      $result = $this->select($sql);
      return $result;
   }
//Вывод данных по неоплаченным счетам(WMZ)
   function order_wmz()
   {
      $sql = "select did,summa,order_arr,status,partner_id,bonus_id,company,guarantee_price from orders where status='p' and oplata='WMZ'";
      $result = $this->select($sql);
      return $result;
   }
//Формирование отчета по iFree
   function selReportiFree($s,$start,$end)
   {
      $sql = "select summa from orders where (data_pay>='{$start}' and data_pay<='{$end}') and oplata='iFree' and summa='{$s}' and (status='y' or status='yn')";
      $result = $this->select($sql);
      return $result;
   }
//обнуление суммы пополнений за текущий месяц
   function edit_emoney($cur)
   {
	  $sql = "update balance_currency set renewing='0' where name='$cur'";
      $result = $this->update($sql);
      return $result;
   }
//подсчет полученных WMB
   function count_wmb_input($month) {
	$sql = "select sum(summa) as summ from orders where type_oper='buy_pin' and oplata='WMB' and data_pay like '%$month%' and (status='y' or status='yn')";
	$result = $this->select($sql);
	return $result;
   }
//подсчет распространненных WMB
   function count_wmb_output($month) {
	$sql = "select order_arr from orders where type_oper='buy_emoney' and data_pay like '%$month%' and (status='y' or status='yn')";
	$result = $this->select($sql);
	return $result;
   }
//извлечение суммы которую купили через расчетный счет
   function remind($cur) {
	$sql = "select renewing from balance_currency where name='$cur'";
	$result = $this->select($sql);
	return $result;
   }
//вывод инфы о эл. валюте
   function info_currency($cur)
   {
	$sql = "select balance,desc_val,desc_m,WebPay,iPay,purse,com_seti from balance_currency where name='$cur'";
	$result = $this->select($sql);
	return $result;
   }
}

?>