<?php

require("const.inc.aspx");
require("dbsql.inc.aspx");

function wm_ReqID(){
    $time=microtime();
    $int=substr($time,11);
    $flo=substr($time,2,3);
	$f=substr($int,0,7);
    return $f.$flo;
}
function edit_balance($parm) {
$parm = trim(sprintf("%8.0f ",$parm));
$invers_balance = '';
$balance = '';
	$string_len = strlen($parm);
	$c=0;
	for($i=$string_len;$i>=0;$i--) {
		$invers_balance .= $parm[$i];
		if($c == 3) $invers_balance .= " ";
		if($c == 6) $invers_balance .= " ";
		$c++;
	}
	$string_len = strlen($invers_balance);
	for($i=$string_len;$i>=0;$i--) {
		$balance .= $invers_balance[$i];
	}
return $balance;
}
function cheak_ref($http_ref) {
	$host = explode('/',$http_ref);
	if($host['2'] != 'pinshop.by' && $host['2'] != 'www.pinshop.by'){
	header("Location: http://pinshop.by");
	exit;
}
}
//КЛАСС ДЛЯ РАБОТЫ С ГЛАВНОЙ БАЗОЙ
Class CustomSQL extends DBSQL
{
   // the constructor
   function CustomSQL($DBName = "")
   {
      $this->DBSQL($DBName);
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
//отправка письма с кодами
function creat_mail($did,$result_order,$demand_info_order_arr,$demand_info_company) {
	global $support, $icq, $tel;
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

//проверка номера квитанции при оплате наличными
	function check_receipt($did,$n_receipt) {
		$sql = "select did from id_payment where id_more_pay='$n_receipt'";
		$result = $this->select($sql);
		return $result;
	}
//запись номера квитанции
	function edit_receipt($did,$n_receipt) {
		$sql = "update id_payment set id_more_pay='$n_receipt' where did='$did'";
		$this->update($sql);
	}
//добавление пинкодов в заявку после оплаты
	function add_loginpass($did,$log_pass) {
		$p = $this->selpas();
		$sql = "update orders set log_pass=(AES_ENCRYPT('$log_pass','$p[0][0]')) where did='$did'";
		$results = $this->update($sql);
		return $results;
	}
//смена статуса заявки
	function demand_edit($st,$did) {
		$sql = "update orders set status='$st' where did='$did'";
		$this->update($sql);
	}
//обновление статуса пин-кодов в базе после оплаты
	function upd_count_card($name_card,$count) {
		$sql = "update info_cards set count='$count' where card='$name_card'";
		$this->update($sql);
	}
//обновление статуса пин-кодов в базе после оплаты
	function up_st($id,$st)	{
		$sql = "update pin_cards set status='$st' where id='$id'";
		$this->update($sql);
	}
//добавление ID купленных карт в заявку после оплаты
	function add_id_cards($did,$id_cards) {
		$sql = "update orders set id_cards='$id_cards' where did='$did'";
		$results = $this->update($sql);
		return $results;
	}
   //подсчет колич
   function count_all($id,$table)
   {
    $sql = "select count($id) as stotal from $table";
	$result = $this->select($sql);
	return $result;
   }
   //подсчет количичества
   function count_pinkod($page,$record,$name_card)
   {
	$start = $page*$record;
    $sql = "select count(id) as stotal from pin_cards where name_card='$name_card' and status='1'";
	$result = $this->select($sql);
	return $result;
   }
//вывод Непрочитанных сообщений
   function support_mess($st)
   {
	$sql = "select id,message,date,time from support where status='$st' order by id";
	$result = $this->select($sql);
	return $result;
   }
//ответ на непрочитанное сообщение
   function get_info_mess($id)
   {
	$sql = "select id,ip,email,message from support where id='$id'";
	$result = $this->select($sql);
	return $result;
   }
//обновление инфы по картам
function edit_support($id)
   {
      $sql = "update support set status='1' where id='$id'";
		$this->update($sql);
   }
//подсчет количества непрочитанных сообщений в службе поддержке
function support_count()
   {
    $sql = "select count(id) as stotal from support where status='0'";
	$result = $this->select($sql);
	return $result;
   }
   function selpas()
   {
    $sql = "SELECT @password:='dbnfkbq1986'";
	$result = $this->select($sql);
	return $result;
   }
//вывод инфы о компании
   function info_company($catalog)
   {
	$sql = "select name,name_desc,remuneration from info_company where catalog='$catalog'";
	$result = $this->select($sql);
	return $result;
   }
//Вывод возможного метода оплаты
   function info_company_pay($name)
   {
	$sql = "select remuneration,WebMoney,WM_bill,WM_direct,WMZ,EasyPay,WebPay,iPay,iFree,rezerv_purse from info_company where name='$name'";
	$result = $this->select($sql);
	return $result;
   }
//обновление статуса оплаты
	function edit_pay($company,$WebMoney,$WM_bill,$WM_direct,$WMZ,$EasyPay,$WebPay,$iPay,$iFree,$rezerv_purse)
	{
	$sql = "update info_company set WebMoney='$WebMoney',WM_bill='$WM_bill',WM_direct='$WM_direct',WMZ='$WMZ',EasyPay='$EasyPay',WebPay='$WebPay',iPay='$iPay',iFree='$iFree',rezerv_purse='$rezerv_purse' where name='$company'";
	$results = $this->update($sql);
	return $results;
	}
//вывод инфы о компании
   function info_card($name_company)
   {
	$sql = "select id,name_company,card,name_card,name_desc,count,wigth_card,height_card,price,st_bonus,price_wmz from info_cards where name_company='$name_company' order BY id ASC";
	$result = $this->select($sql);
	return $result;
   }
//вывод инфы о картах
   function info_card_kesh($name_company)
   {
	$sql = "select name_card,price,count from info_cards where count>'0' and name_company='$name_company' order BY id ASC";
	$result = $this->select($sql);
	return $result;
   }
//ДОбавдение комментария админа
	function edit_remuneration($remuneration,$company)
	{
	$sql = "update info_company set remuneration='$remuneration' where name='$company'";
	$results = $this->update($sql);
	return $results;
	}
//обновление инфы по картам
function edit_card($id,$name_card,$name_desc,$count,$price,$st_bonus,$price_wmz)
   {
      $sql = "update info_cards set name_card='$name_card',name_desc='$name_desc',price='$price',count='$count',st_bonus='$st_bonus',price_wmz='$price_wmz' where id='$id'";
		$this->update($sql);
   }
//Добавление пин-кода
   function add_pinkod($name_card,$login,$pass,$serial)
   {
	  $p = $this->selpas();
      $sql = "insert into pin_cards (name_card,login,pass,serial) values ('$name_card',AES_ENCRYPT('$login','$p[0][0]'),AES_ENCRYPT('$pass','$p[0][0]'),'$serial')";
      $this->insert($sql);
	  return $p;
   }
//вывод количества карт для продажи
   function sel_count_card($card)
   {
	$sql = "select count from info_cards where card='$card'";
	$result = $this->select($sql);
	return $result;
   }
//Обновление количества карт
function update_count($card,$count)
   {
      $sql = "update info_cards set count='$count' where card='$card'";
		$this->update($sql);
   }
//Обновление количества карт
//function update_count($card)
//   {
//      $sql = "update info_cards set count=count+1 where card='$card'";
//		$this->update($sql);
//   }
//подсчет количества заявок на вывод
function count_out($name_card)
   {
    $sql = "select count(id) as stotal from pin_cards where name_card='$name_card' and status='1'";
	$result = $this->select($sql);
	return $result;
   }
//вывод инфы по заказу
   function sel_orders($did)
   {
	   $p = $this->selpas();
	$sql = "select did,oplata,purse,summa,order_arr,AES_DECRYPT(log_pass,'$p[0][0]'),email,data_pay,time_pay,coment,status,partner_id,bonus_id,id_cards,company,send_mail,type_oper from orders where did='$did'";
	$result = $this->select($sql);
	return $result;
   }
//вывод инфы по заказу для завершения покупки эл. денег
   function sel_orders_emoney($did)
   {
	$sql = "select oplata,purse,summa,order_arr,email,type_oper from orders where did='$did'";
	$result = $this->select($sql);
	return $result;
   }
//вывод инфы о карточке
   function sel_card($card)
   {
	$sql = "select card,name_card,wigth_card,height_card from info_cards where card='$card'";
	$result = $this->select($sql);
	return $result;
   }
//смена статуса заявки
	function orders_edit($status,$did)
	{
	$sql = "update orders set status='$status' where did='$did'";
	$results = $this->update($sql);
	return $results;
	}
//Новостная колонка на главной
   function book_mess($page,$record)
   {
	$start = $page*$record;
	$sql = "select id,username,contents,data,rate from book order by id DESC LIMIT $start,$record";
	$result = $this->select($sql);
	return $result;
   }
//ДОбавдение комментария админа
	function add_comment($comment,$id)
	{
	$sql = "update book set admin_comment='$comment' where id='$id'";
	$results = $this->update($sql);
	return $results;
	}
//Вывод пин-кодов по заявке
   function sel_pin($name_card)
   {
	  $p = $this->selpas();
      $sql = "select id,AES_DECRYPT(login,'$p[0][0]'),AES_DECRYPT(pass,'$p[0][0]'),status from pin_cards where name_card='$name_card' and status='1'";
      $result = $this->select($sql);
      return $result;
   }
//Вывод серийного номера карты на странице просмотра инфы по заявке
   function serial_no($id)
   {
      $sql = "select serial from pin_cards where id='$id'";
      $result = $this->select($sql);
      return $result;
   }
//Вывод активных пин-кодов
   function sel_pin_list($page,$record,$name_card)
   {
	  $start = $page*$record;
	  $p = $this->selpas();
      $sql = "select id,AES_DECRYPT(login,'$p[0][0]'),AES_DECRYPT(pass,'$p[0][0]'),status,serial from pin_cards where name_card='$name_card' and status='1' order by id DESC LIMIT $start,$record";
      $result = $this->select($sql);
      return $result;
   }
//Вывод активных пин-кодов
   function search_karta($serial,$card)
   {
	  $p = $this->selpas();
      $sql = "select id,AES_DECRYPT(login,'$p[0][0]'),AES_DECRYPT(pass,'$p[0][0]'),status,serial from pin_cards WHERE serial LIKE '%$serial%' and name_card='$card' order by id DESC";
      $result = $this->select($sql);
      return $result;
   }
//смена статуса карты
	function update_status($status,$id)
	{
	$sql = "update pin_cards set status='$status' where id='$id'";
	$results = $this->update($sql);
	return $results;
	}
//Обновление количества карт
function update_count_m($card)
   {
      $sql = "update info_cards set count=count-1 where card='$card'";
		$this->update($sql);
   }
//вывод количества карт по опреденной карте
   function sel_count($card)
   {
      $sql = "select count from info_cards where card='$card'";
      $result = $this->select($sql);
      return $result;
   }
//Обновление количества карт
function upd_cards($card,$count)
   {
      $sql = "update info_cards set count=$count where card='$card'";
		$this->update($sql);
   }
//вывод данных о заявках СТАТИСТИКА
   function stat_dem($data_n,$data_k)
   {
      $sql = "select did,oplata,summa,data_pay,time_pay,status,partner_id,bonus_id,company,id_rk from orders where data_pay >= '$data_n' and data_pay <= '$data_k' order by data_pay asc, time_pay asc";
      $result = $this->select($sql);
      return $result;
   }
//вывод данных о заявках СТАТИСТИКА
   function stat_dem_bonus($bonus_id)
   {
      $sql = "select did,oplata,summa,data_pay,time_pay,status,partner_id,bonus_id,company,id_rk from orders where bonus_id='$bonus_id' order by data_pay asc, time_pay asc";
      $result = $this->select($sql);
      return $result;
   }
//ОТЧЕТ
   function report($company,$data_n,$data_k)
   {
      $sql = "select did,oplata,summa,order_arr,email,data_pay,time_pay,status,partner_id,bonus_id from orders where company like '%$company%' and (status='y' or status='yz') and data_pay >= '$data_n' and data_pay <= '$data_k' order by data_pay asc, time_pay asc";
      $result = $this->select($sql);
      return $result;
   }
//удаление заказа
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
//Выборка инфы по номеру платежа
   function sel_ip($did)
   {
	$sql = "select id_pay,id_more_pay,addr_remote,proxy from id_payment where did='$did'";
	$result = $this->select($sql);
	return $result;
   }
//Выборка инфы по партнеру
   function selall_partner($page,$record,$sort)
   {
	$start = $page*$record;
	$sql = "select id,email,username,balance,summa_bal,count_oper,summ_oper from partner where status='1' order by $sort DESC LIMIT $start,$record";
	$result = $this->select($sql);
	return $result;
   }
//подсчет количества пользователей-партнеров
function count_partner()
{
    $sql = "select count(id) as stotal from partner where status='1'";
	$result = $this->select($sql);
	return $result;
}
//Выборка инфы по всем партнерам
   function selall_bonus($page,$record,$sort)
   {
	$start = $page*$record;
	$sql = "select id,email,summa_demand,discount,status from bonus order by $sort DESC LIMIT $start,$record";
	$result = $this->select($sql);
	return $result;
   }
//подсчет количества пользователей скидки
function count_bonus()
{
    $sql = "select count(id) as stotal from bonus";
	$result = $this->select($sql);
	return $result;
}
//Выборка инфы по партнеру
   function info_bonus($sel_id,$ID)
   {
	$sql = "select id,email,summa_demand,discount,status from bonus where $sel_id='$ID'";
	$result = $this->select($sql);
	return $result;
   }
//Обновление инфы о пользователе накопительной скидки
function update_bonus($email,$summa_demand,$discount,$st)
   {
      $sql = "update bonus set summa_demand='$summa_demand',discount='$discount',status='$st' where email='$email'";
		$this->update($sql);
   }
//удаление записей IP адресо выбранной ссылки
   function del_bonus($email)
   {
      $sql = "delete from bonus where email='$email'";
      $this->delete($sql);
   }
//Рекламная компания
//добавление компании
//Добавление пин-кода
   function add_company($site,$desc,$data)
   {
      $sql = "INSERT INTO mestkom (site,desc_company,data) VALUES ('$site', '$desc', '$data')";
      $this->insert($sql);
   }
//Вывод всех рекламных компаний
   function sel_rk()
   {
      $sql = "select * from mestkom order by id asc";
      $result = $this->select($sql);
      return $result;
   }
//Обновление количества карт
function upd_count_mest($id)
   {
      $sql = "update mestkom set referal='0' where id='$id'";
		$this->update($sql);
   }
//Вывод статистики рекламной компании
   function sel_st_rk($id_mestkom)
   {
      $sql = "select addr_remote,proxy,data from ip_mestkom where id_mestkom='$id_mestkom' order by data asc";
      $result = $this->select($sql);
      return $result;
   }
//удаление записей IP адресо выбранной ссылки
   function del_st($id)
   {
      $sql = "delete from ip_mestkom where id_mestkom='$id'";
      $this->delete($sql);
   }
//удаление записей из книги отзывов
   function del_book($id)
   {
      $sql = "delete from book where id='$id'";
      $this->delete($sql);
   }
//вывод инфы о эл. валютах
   function info_emoney($cur)
   {
	$sql = "select renewing from balance_currency where name='$cur'";
	$result = $this->select($sql);
	return $result;
   }
//Обновление информации о эл. деньгах
function edit_emoney($cur,$summa)
   {
      $sql = "update balance_currency set renewing='$summa' where name='$cur'";
		$this->update($sql);
   }
}

//$sql = "insert into mestkom (desc,data) values ('$desc','$data')";

?>