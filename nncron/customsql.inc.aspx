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
//����� ��� ������ � ������� �����
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
//������� ��������� ���������� �������� WM
	function RezervPusre($company,$WMB,$rezerv_WMB) {
		$pay = $this->info_company_pay($company);
		if($pay[0]['rezerv_purse'] == 1) {$purse = $rezerv_WMB;}
		else {$purse = $WMB;}
	return $purse;
	}
//������� ���������� ���-�����
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
						else {$log_pass .= "�� ������:�� ������|"; $st = "er"; }
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
				if (!empty($info_cards)) {$body .= "<div style=\"margin-top:5px;\"><u>{$info_cards[0]['name_card']}</u>&nbsp;&nbsp;&nbsp;&nbsp;<b>".$orders[0]." ��.</b>
				</div>";
				for($i=0; $i<$orders[0]; $i++) {
					$log_pass = explode(':',$log_pass_arr[$c_pin]);
					if(empty($log_pass[0])) {
						$body .= "<div id=\"vivod_pin\" style=\"FONT-SIZE: 11px;\"><b>���-��� : </b>{$log_pass[1]} <br /><b>S/N:</b> {$log_pass[2]}</div>";
					}
					else {
$s = explode('||',$demand_info_company);
$t = explode('|',$s[$c_pin]);
switch ($t[0]) :
	case ("niks") :
					$body .= "<div id=\"vivod_pin\" style=\"float:left;margin-left:5px;margin-right:0; FONT-SIZE: 11px;\"><b>����� : </b>niks\\{$log_pass[0]}&nbsp;</div><div id=\"vivod_pin\" style=\"FONT-SIZE: 11px;\"><b>������ : </b>{$log_pass[1]}<br /><b>S/N:</b> {$log_pass[2]}</div>";
	break;
	case ("byfly") :
					$body .= "<div id=\"vivod_pin\" style=\"float:left;margin-left:5px;margin-right:0; FONT-SIZE: 11px;\" class='text_log'> <b>��� ��������� : </b>{$log_pass[0]}&nbsp;</div><div id=\"vivod_pin\" class='text_log' style=\"FONT-SIZE: 11px;\"><b>���-��� : </b>{$log_pass[1]}<br /><b>S/N:</b> {$log_pass[2]}</div>";
	break;
	default:
					$body .= "<div id=\"vivod_pin\" style=\"float:left;margin-left:5px;margin-right:0; FONT-SIZE: 11px;\"><b>����� : </b>{$log_pass[0]}&nbsp;</div><div id=\"vivod_pin\" style=\"FONT-SIZE: 11px;\"><b>������ : </b>{$log_pass[1]} <br /><b>S/N:</b> {$log_pass[2]}</div>";
	break;
endswitch;
					}
					$c_pin++;
				}
				}
		}
		}
///////�������� ������
	$from_name = "Robot PinShop.by";
	$subject = "����� �{$did} �� ��������-�������� PinShop.by";
	$body_mail = "
<div style=\"FONT-SIZE: 12px; FONT-FAMILY: Verdana; COLOR: #676767; LINE-HEIGHT: 18px;\">
<center><b>������������, ��������� ������������!</b></center><br />
-------------------------------------------------------<br />
<h2>��� ����� � {$did}</h2>
-------------------------------------------------------<br />
<br />

{$body}<br />
<br />
�� ����� ���������� ��� �� ����� �����������, ����������� �� ������ ����,<br />
����� �� ������ ������ ��������-������� PinShop.by.<br /><br />

���������� ��� �� ������������� ������ �������.<br />
��� ������ ���������� �������, ������ �� �������.<br />
<br />
--<br />
� ���������,<br />
������������� PinShop.by<br />
<br />
<a href='http://pinshop.by'>��������-������� ���-�����</a><br />
Mail: <a href='mailto:$support'>$support</a><br />
ICQ: $icq<br />
���.: $tel</div>";
return $subject."|".$body_mail."|".$from_name;
}
//����� ������� �� ���������������
   function sel_spread_wmb() {
	$sql = "SELECT o.did,o.purse,o.order_arr,ip.id_pay FROM orders as o,id_payment as ip WHERE o.purse IS NOT NULL and o.status LIKE '%yn%' and o.type_oper LIKE 'buy_emoney' and ip.did=o.did";
	$result = $this->select($sql);
	return $result;
   }
//����� �������������� ������ �� ������
   function sel_kod_goods($price)
   {
	$sql = "select t_identifier,t_partner,t_abonent from tarrifs_commerce where t_partner>='$price' order by id asc limit 1";
	$result = $this->select($sql);
	return $result;
   }
//����� ���� � ��������
   function sel_amount($id)
   {
	$sql = "select name_company,card,price,type_goods from info_cards where id='$id' and count>'3'";
	$result = $this->select($sql);
	return $result;
   }
//���������� ������
  function add_order($did,$oplata,$summa,$order,$pass,$data_pay,$time_pay,$company,$type_oper,$abonentId)
   {
      $sql = "insert into orders (did,oplata,summa,order_arr,password,data_pay,time_pay,company,type_oper,abonentId) values ('$did','$oplata','$summa','$order','$pass','$data_pay','$time_pay','$company','$type_oper','$abonentId')";
      $result = $this->insert($sql);
	  return $result;
   }
//���������� ������ �������
   function add_id_payiFree($did,$evtId,$abonentId)
   {
      $sql = "insert into id_payment (did,id_more_pay,iFreeAbonentId) values ('$did','$evtId','$abonentId')";
      $result = $this->insert($sql);
   }
//�������������� ������
	function rezerv_goods($card)
	{
	$sql = "update info_cards set count=count-1 where card='$card'";
	$this->update($sql);
}
//�������������� ������
	function unrezerv_goods($card)
	{
	$sql = "update info_cards set count=count+1 where card='$card'";
	$this->update($sql);
}
//����� ���������� �� uniqueMessageID
   function sel_IDpayiFree($evtId)
   {
	 $sql = "select ip.id_more_pay,o.did from id_payment as ip, orders as o where ip.id_more_pay='$evtId' and ip.did=o.did and o.oplata='iFree' and o.status='n'";

      $result = $this->select($sql);
      return $result;
   }
//������� ��� ������� ����������� ���������  � ������������� ������
function raschet_partner($partner_id,$summa,$bonus_id) {
		if($partner_id > 0) {
			$sum_percent = $summa * 0.05 * 0.2;
			$this->update_bal_partner($sum_percent,$summa,$partner_id);
		}
		else {
			if($bonus_id > 0) $this->update_bal_bonus($summa,$bonus_id);
		}
}
//����� ���� � ��������
   function sel_card($card)
   {
	$sql = "select card,name_card from info_cards where card='$card'";
	$result = $this->select($sql);
	return $result;
   }
//����� ���������� ������ ������
   function info_company_pay($name)
   {
	$sql = "select WebMoney,EasyPay,WebPay,rezerv_purse from info_company where name='$name'";
	$result = $this->select($sql);
	return $result;
   }
//����� �������� �������� � ���� ��������
   function ini_comission()
   {
	$sql = "select commission from ini where id='1'";
	$result = $this->select($sql);
	return $result;
   }
//���������� �����
	function update_rate_WMZ($rate)
	{
	$sql = "update ini set rate_WMZ='$rate' where id='1'";
	$results = $this->update($sql);
	return $results;
	}
//��� ������������� 100% ������, ������ �����������
	function demand_add_coment($coment,$did)
	{
	$sql = "update orders set coment='$coment' where did='$did'";
	$results = $this->update($sql);
	return $results;
	}
//����� ������� ������
	function demand_edit($st,$did)
	{
	$sql = "update orders set status='$st' where did='$did'";
	$this->update($sql);
	}
//����� ������� ������(�����)
	function demZalog_edit($st,$did)
	{
	$sql = "update pay_zalog set status='$st' where did='$did'";
	$this->update($sql);
	}
//����� ���� �� ������ �� ������� ������
   function zalog_check($did)
   {
	$sql = "select purse_pay from pay_zalog where did='$did'";
	$result = $this->select($sql);
	return $result;
   }
//����� ������ �� ������
   function demand_check($did,$oplata)
   {
      $sql = "select purse,summa,oplata,order_arr,email,status,partner_id,bonus_id,company,guarantee_price,send_mail from orders where did='$did' and  (oplata='$oplata' or (oplata='WMZ' and status='yz'))";
      $result = $this->select($sql);
      return $result;
   }
//����� ������� ������
   function sel_st($did)
   {
      $sql = "select status from orders where did='$did'";
      $result = $this->select($sql);
      return $result;
   }
//����� ���-����� �� ������
   function sel_pin($name_card)
   {
	  $p = $this->selpas();
      $sql = "select id,AES_DECRYPT(login,'$p[0][0]'),AES_DECRYPT(pass,'$p[0][0]'),serial from pin_cards where name_card='$name_card' and status='1' order BY 'id' ASC LIMIT 1";
      $result = $this->select($sql);
      return $result;
   }
//���������� �������� � ������ ����� ������
	function add_loginpass($did,$log_pass)
	{
	$p = $this->selpas();
	$sql = "update orders set log_pass=(AES_ENCRYPT('$log_pass','$p[0][0]')) where did='$did'";
	$results = $this->update($sql);
	return $results;
	}
//���������� ID ��������� ���� � ������ ����� ������
	function add_id_cards($did,$id_cards)
	{
	$sql = "update orders set id_cards='$id_cards' where did='$did'";
	$results = $this->update($sql);
	return $results;
	}
//���������� ������� ���-����� � ���� ����� ������
	function up_st($id,$st)
	{
	$sql = "update pin_cards set status='$st' where id='$id'";
	$this->update($sql);
	}
//����� ���������� ��������� ��� ������� ���� �� ������
   function sel_count_card($name_card)
   {
      $sql = "select count from info_cards where card='$name_card'";
      $result = $this->select($sql);
      return $result;
   }
//���������� ������� ���-����� � ���� ����� ������
	function upd_count_card($name_card,$count)
	{
	$sql = "update info_cards set count='$count' where card='$name_card'";
	$this->update($sql);
	}
//���������� ������� ����� ������ � ���������
	function update_bal_partner($sum_percent,$summa_order,$id)
	{
	$sql = "update partner set balance=balance+$sum_percent, summa_bal=summa_bal+$sum_percent, count_oper=count_oper+1, summ_oper=summ_oper+$summa_order where id='$id' and status='1'";
	$this->update($sql);
	}
//���������� ������� ����� ������ � ������������� �������
	function update_bal_bonus($summa_order,$id)
	{
	$sql = "update bonus set summa_demand=summa_demand+$summa_order where id='$id' and status='1'";
	$this->update($sql);
	}
//����� ���� ��������� �� ��������� �����
   function bonus($summa,$disc)
   {
      $sql = "select id,discount from bonus where summa_demand >= '$summa' and discount = '$disc'";
      $result = $this->select($sql);
      return $result;
   }
//���������� ������� ����� ������ � ������������� �������
	function bonus_edit($id,$percent)
	{
	$sql = "update bonus set discount='$percent' where id='$id' and status='1'";
	$this->update($sql);
	}
//�������� ������������ ������
   function del_dem($did)
   {
      $sql = "delete from orders where did='$did'";
      $result = $this->delete($sql);
      return $result;
   }
//�������� ������ �������
   function del_idpay($did)
   {
      $sql = "delete from id_payment where did='$did'";
      $result = $this->delete($sql);
      return $result;
   }
//����� ������� ������ ��� ��������
   function sel_del_dem($data_tom,$time,$data)
   {
      $sql = "select did from orders where (status='n' or status='p' or status='er') and ((data_pay='$data_tom' and time_pay<='$time') or data_pay='$data' and time_pay<='$time')";
      $result = $this->select($sql);
      return $result;
   }
//����� ����� ������
   function sel_did($wsb_order_num)
   {
      $sql = "select did from id_payment where id_pay='$wsb_order_num'";
      $result = $this->select($sql);
      return $result;
   }
//����� ����� ������ � ������ �������
   function iFree_did($wsb_order_num)
   {
      $sql = "select did,id_more_pay,iFreeAbonentId from id_payment where id_pay='$wsb_order_num'";
      $result = $this->select($sql);
      return $result;
   }
//���������� ������ ���������� �� webpay, iPay
   function add_id_pay($transaction_id,$did)
   {
      $sql = "update id_payment set id_more_pay='$transaction_id' where did='$did'";
      $this->update($sql);
   }
//������ ��� �������� �� ������ EasyPay
   function pay_easypay()
   {
      $sql = "select did,purse,status,guarantee_price from orders where (oplata='EasyPay' and status='p') or (oplata='WMZ' and status='pz')";
      $result = $this->select($sql);
      return $result;
   }
//����� ����� ����������
   function sel_idpay($did)
   {
      $sql = "select id_pay from id_payment where did='$did'";
      $result = $this->select($sql);
      return $result;
   }
//����� ������
   function sel_order_arr($did)
   {
      $sql = "select summa,order_arr,partner_id,bonus_id from orders where did='$did'";
      $result = $this->select($sql);
      return $result;
   }
//����� ������ �� ������ ��� iPay
   function order_iPay($did)
   {
      $sql = "select did,purse,summa,order_arr,status,partner_id,bonus_id,guarantee_price from orders where did='$did' and (oplata='iPay' or oplata='WMZ') and status != 'y'";
      $result = $this->select($sql);
      return $result;
   }
//����� ������ �� ������ ��� iPay
   function order_iFree($did)
   {
      $sql = "select order_arr,data_pay,time_pay,status,type_oper,abonentId from orders where did='$did' and oplata='iFree' and (status = 'n' or status = 'yn')";
      $result = $this->select($sql);
      return $result;
   }
//����� ������ �� ������ ��� iPay
   function order_iPay_e($did,$st)
   {
      $sql = "select did,purse,summa,order_arr,status from orders where did='$did' and oplata='iPay' and status = '$st'";
      $result = $this->select($sql);
      return $result;
   }
//����� ������ �� ������ ��� iPay
   function order_iPay_e_res($did)
   {
      $sql = "select purse,summa,order_arr from orders where did='$did' and oplata='iPay' status = 'p'";
      $result = $this->select($sql);
      return $result;
   }
//������� ���� ��������
   function sel_type($did)
   {
      $sql = "select oplata,order_arr,type_oper from orders where did='$did'";
      $result = $this->select($sql);
      return $result;
   }
//������� ���� ��������
   function sel_bal($name_cur)
   {
      $sql = "select * from balance_currency where name='$name_cur'";
      $result = $this->select($sql);
      return $result;
   }
//���������� �������
   function upd_bal($bal,$name_cur)
   {
	  $sql = "update balance_currency set balance='$bal' where name='$name_cur'";
      $result = $this->update($sql);
      return $result;
   }
//����� ������ �� ������������ ������(WMB)
   function order_wm()
   {
      $sql = "select did,purse,summa,order_arr,status,partner_id,bonus_id,company,guarantee_price from orders where (status='p' and oplata='WMB') or status='pz'";
      $result = $this->select($sql);
      return $result;
   }
//����� ������ �� ������������ ������(WMZ)
   function order_wmz()
   {
      $sql = "select did,summa,order_arr,status,partner_id,bonus_id,company,guarantee_price from orders where status='p' and oplata='WMZ'";
      $result = $this->select($sql);
      return $result;
   }
//������������ ������ �� iFree
   function selReportiFree($s,$start,$end)
   {
      $sql = "select summa from orders where (data_pay>='{$start}' and data_pay<='{$end}') and oplata='iFree' and summa='{$s}' and (status='y' or status='yn')";
      $result = $this->select($sql);
      return $result;
   }
//��������� ����� ���������� �� ������� �����
   function edit_emoney($cur)
   {
	  $sql = "update balance_currency set renewing='0' where name='$cur'";
      $result = $this->update($sql);
      return $result;
   }
//������� ���������� WMB
   function count_wmb_input($month) {
	$sql = "select sum(summa) as summ from orders where type_oper='buy_pin' and oplata='WMB' and data_pay like '%$month%' and (status='y' or status='yn')";
	$result = $this->select($sql);
	return $result;
   }
//������� ����������������� WMB
   function count_wmb_output($month) {
	$sql = "select order_arr from orders where type_oper='buy_emoney' and data_pay like '%$month%' and (status='y' or status='yn')";
	$result = $this->select($sql);
	return $result;
   }
//���������� ����� ������� ������ ����� ��������� ����
   function remind($cur) {
	$sql = "select renewing from balance_currency where name='$cur'";
	$result = $this->select($sql);
	return $result;
   }
//����� ���� � ��. ������
   function info_currency($cur)
   {
	$sql = "select balance,desc_val,desc_m,WebPay,iPay,purse,com_seti from balance_currency where name='$cur'";
	$result = $this->select($sql);
	return $result;
   }
}

?>