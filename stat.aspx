<?
session_start();
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$errortag = false;
if(!empty($_POST['enter'])) {
	$_SESSION['login'] = md5($_POST['login']);
	$_SESSION['pass'] = md5($_POST['pass']);
	header("Location: index.aspx");
}
if($_SESSION['login'] == $admin && $_SESSION['pass'] == $pass) {

$errortag = true;
if(!empty($_POST['edit_remuneration'])) {$db->edit_remuneration($_POST['percent'],$_POST['company']);}
$data = date("Y-m-d");
$mass_day = array("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31");
$mass_mount = array("(01) Январь","(02) Февраль","(03) Март","(04) Апрель","(05) Май","(06) Июнь","(07) Июль","(08) Август","(09) Сентябрь","(10) Октябрь","(11) Ноябрь","(12) Декабрь",);
$data_mas = explode("-",$data);

}
//echo md5('atomly');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Статистика заказов</Title>
<link rel="stylesheet" href="http://atm.pinshop.by/include/style.css" type="text/css">
</head>
<body>
<?
if(!$errortag) {
?>
<table width=100% height=100%>
<tr>
<td align="center">
	<form method="post" action="/">
	Логин :
		<input type="text" name="login" /><br />
		Пароль :
		<input type="text" name="pass" /><br />
		<input type="submit" name="enter" value="Вход" />

	</form>

	</td></tr>
</table>
<?
}
else {
 include('include/head.aspx'); ?>
<table width=100% bgColor="#ebebeb" cellpadding="5">
	<tr bgColor="#ffffff">
		<td width="200" valign="top">
<? include('include/top.aspx'); ?>
</td>
		<td>
<div align="left">
	<form action="stat.aspx" method="post" style="display: inline;">
<b>Показать статистику с :</b>

			<select name="day_n">
<?
	if(!empty($_POST['day_n'])) $day_sel = $_POST['day_n'];
	else $day_sel = $data_mas[2];
	foreach($mass_day as $ar) {
		if($day_sel == $ar)echo "<option value=\"{$ar}\" selected=\"selected\">{$ar}</option>";
		else echo "<option value=\"{$ar}\">{$ar}</option>";
	}
?>
	</select></span>
	<select name="mount_n">
<?
	$c=1;
	if(!empty($_POST['mount_n'])) $mount_sel = $_POST['mount_n'];
	else $mount_sel = $data_mas[1];
	foreach($mass_mount as $ar) {
		if($mount_sel == $c) echo "<option value=\"{$c}\" selected=\"selected\">{$ar}</option>";
		else echo "<option value=\"{$c}\">{$ar}</option>";
	$c++;
	}
?>
	</select></span>
	<select name="year_n">
	<option value="2009">2009</option>
	<option value="2010">2010</option>
	<option value="2011">2011</option>
	<option value="2012">2012</option>
	<option value="2013" selected="selected">2013</option>
	</select>
<b>&nbsp;&nbsp;по :&nbsp;&nbsp;</b>
			<select name="day_k">
<?
	if(!empty($_POST['day_k'])) $day_sel = $_POST['day_k'];
	else $day_sel = $data_mas[2];
	foreach($mass_day as $ar) {
		if($day_sel == $ar)echo "<option value=\"{$ar}\" selected=\"selected\">{$ar}</option>";
		else echo "<option value=\"{$ar}\">{$ar}</option>";
	}
?>
	</select></span>
	<select name="mount_k">
<?
	$c=1;
$WMB_money = 0;
$WMB_stat = 0;
$WMZ_stat = 0;
$EasyPay_stat = 0;
$WebPay_stat = 0;
$iPay_stat = 0;
$iFree_stat = 0;

$WMB_sum_rem = 0;
$WMB_rem_commis = 0;
$WMB_return = 0;
$WMB_rashod = 0;

$WMZ_sum_rem = 0;
$WMZ_rem_commis = 0;
$WMZ_return = 0;
$WMZ_rashod = 0;
	if(!empty($_POST['mount_k'])) $mount_sel = $_POST['mount_k'];
	else $mount_sel = $data_mas[1];
	foreach($mass_mount as $ar) {
		if($mount_sel == $c) echo "<option value=\"{$c}\" selected=\"selected\">{$ar}</option>";
		else echo "<option value=\"{$c}\">{$ar}</option>";
	$c++;
	}
?>
	</select></span>
	<select name="year_k">
	<option value="2009">2009</option>
	<option value="2010">2010</option>
	<option value="2011">2011</option>
	<option value="2012">2012</option>
	<option value="2013" selected="selected">2013</option>
	</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

	<input type="submit" name="sel_mount" value="Показать" style="width:100px; "onmouseover="this.style.backgroundColor='#E8E8FF';" onmouseout="this.style.backgroundColor='#f3f7ff';" id="cursor">&nbsp;
</form>
</div>
<br />
<table width="100%" bgColor="#ebebeb"  border="0" cellspacing="1" cellpadding="0">
	<tr bgColor="#f8f8ff" align="center">
		<td>№ заявки</td>
		<td>Провайдер</td>
		<td>Сумма</td>
		<td>Дата</td>
		<td>Статус</td>
		<td>Партнер</td>
		<td>Бонус</td>
		<td>Р.Б.</td>
	</tr>
<?
$data_n = $_POST['year_n']."-".$_POST['mount_n']."-".$_POST['day_n'];
$data_k = $_POST['year_k']."-".$_POST['mount_k']."-".$_POST['day_k'];
if($data_n == "--") $data_n = $data;
if($data_k == "--") $data_k = $data;
switch ($_GET['oper']) :

	case ("dem_bonus") :
	$unachieved_demand = $db->stat_dem_bonus($_GET['id']);
	break;
	default: $unachieved_demand = $db->stat_dem($data_n,$data_k);
	break;
endswitch;
if(!empty($unachieved_demand)) {
	foreach($unachieved_demand as $arr) {
		$res_order = explode('||',$arr[8]);

		if($arr['5'] == 'n') $tag = "<font color=\"#FF0000\"><b>Не оплачена</b></font>";
		if($arr['5'] == 'p') $tag = "<font color=\"#0000FF\"><b>В процессе</b></font>";
		if($arr['5'] == 'pz') $tag = "<font color=\"#0000FF\"><b>В процессе(залог)</b></font>";
		if($arr['5'] == 'yn') $tag = "<font color=\"#0000FF\"><b>Оплачена</b></font>";
		if($arr['5'] == 'y' || $arr['5'] == 'yz') {
			$tag = "<font color=\"#008000\"><b>Выполнена</b></font>";
		foreach($res_order as $ar) {$c = explode('|',$ar);

					if($c[0] == "WMB") {$WMB_money = $WMB_money + $c[1]; $c[1] = $arr['summa'];}

		$sel_com = $db->info_company_pay($c[0]);
$s_cards = $c[1];
switch ($arr[1]) :
	case ("WMB") :
		$WMB_stat = $WMB_stat + $s_cards;
		$WMB_prihod = $WMB_prihod + $s_cards - $s_cards * (0.8+5)/100;
		$WMB_rem_commis = $WMB_rem_commis + $s_cards * ($sel_com[0]['remuneration']-0.8-5)/100;
		$WMB_return = $WMB_return + ($s_cards - $s_cards * $sel_com[0]['remuneration']/100);
	break;
	case ("WMZ") :
		$WMZ_stat = $WMZ_stat + $s_cards;
		$WMZ_prihod = $WMZ_prihod + $s_cards - $s_cards * (0.8)/100;
		$WMZ_rem_commis = $WMZ_rem_commis + $s_cards * ($sel_com[0]['remuneration']-0.8)/100;
		$WMZ_return = $WMZ_return + ($s_cards - $s_cards * $sel_com[0]['remuneration']/100);
	break;
	case ("EasyPay") :
		$EasyPay_stat = $EasyPay_stat + $s_cards;
		$EasyPay_prihod = $EasyPay_prihod + $s_cards - $s_cards * 5/100;
		$EasyPay_rem_commis = $EasyPay_rem_commis + $s_cards * ($sel_com[0]['remuneration']-5)/100;
		$EasyPay_return = $EasyPay_return + ($s_cards - $s_cards * $sel_com[0]['remuneration']/100);
	break;
	case ("WebPay") :
		$WebPay_stat = $WebPay_stat + $s_cards;
		$WebPay_prihod = $WebPay_prihod + $s_cards - $s_cards * 4/100;
		$WebPay_rem_commis = $WebPay_rem_commis + $s_cards * ($sel_com[0]['remuneration']-4)/100;
		$WebPay_return = $WebPay_return + ($s_cards - $s_cards * $sel_com[0]['remuneration']/100);
	break;
	case ("iPay") :
		$iPay_stat = $iPay_stat + $s_cards;
		$iPay_prihod = $iPay_prihod + $s_cards - $s_cards * 5/100;
		$iPay_rem_commis = $iPay_rem_commis + $s_cards * ($sel_com[0]['remuneration']-5)/100;
		$iPay_return = $iPay_return + ($s_cards - $s_cards * $sel_com[0]['remuneration']/100);
	break;
	case ("iFree") :
		$iFree_stat = $iFree_stat + $s_cards;
		$iFree_prihod = $iFree_prihod + $s_cards;
		$iFree_rem_commis = $iFree_rem_commis + $s_cards * ($sel_com[0]['remuneration'])/100;
		$iFree_return = $iFree_return + ($s_cards - $s_cards * $sel_com[0]['remuneration']/100);
	break;
endswitch;
		}
	}
	if($arr['5'] == 'er') $tag = "<font color=\"#CC0000\"><b>ОШИБКА</b></font>";


echo "<tr bgcolor=\"#ffffff\" align=\"center\">
		<td><a href=\"http://atm.pinshop.by/orders.aspx?did={$arr[0]}\">{$arr[0]}</a></td>
		<td>";
		foreach($res_order as $ar) {$c = explode('|',$ar); echo $c[0]." ";}
		echo "</td>
		<td>{$arr[2]} {$arr[1]}</td>
		<td>{$arr[3]} {$arr[4]}</td>
		<td>{$tag}</td>
		<td><a href=\"http://atm.pinshop.by/user_partner.aspx?id={$arr['6']}\">{$arr['6']}</a></td>
		<td><a href=\"http://atm.pinshop.by/user_bonus.aspx?id={$arr['7']}\">{$arr['7']}</a></td>
		<td><b>{$arr[9]}</b></td>
	</tr>";
	}
}
?>


</table>
<br /><br />
Распространено WMB на <b><?echo $WMB_money;?> рублей</b>
<table width="100%" bgColor="#ebebeb"  border="0" cellspacing="1" cellpadding="0">
	<tr bgColor="#f8f8ff" align="center">
		<td width="120"></td>
		<td>WMB</td>
		<td>WMZ</td>
		<td>EasyPay</td>
		<td>WebPay</td>
		<td>iPay</td>
		<td>iFree</td>
	</tr>
<tr bgcolor="#ffffff" align="center" class=text_log>
<?
echo "<td><b>Общая сумма:</b></td>
<td>".edit_balance($WMB_stat)." BLR<br /></td>
<td>".edit_balance($WMZ_stat)." BLR<br /></td>
<td>".edit_balance($EasyPay_stat)." BLR</td>
<td>".edit_balance($WebPay_stat)." BLR</td>
<td>".edit_balance($iPay_stat)." BLR</td>
<td>".edit_balance($iFree_stat)." BLR</td>
</tr>

<tr bgcolor=\"#ffffff\" align=\"center\" class=text_log>
<td><b>Сумма возврата:</b></td>
<td>".edit_balance($WMB_return)." BLR<br /></td>
<td>".edit_balance($WMZ_return)." BLR<br /></td>
<td>".edit_balance($EasyPay_return)." BLR</td>
<td>".edit_balance($WebPay_return)." BLR</td>
<td>".edit_balance($iPay_return)." BLR</td>
<td>".edit_balance($iFree_return)." BLR</td>
</tr>

<tr bgcolor=\"#ffffff\" align=\"center\" class=text_log>
<td><b>Приход на р/с<sup>1</sup> :</b></td>
<td>".edit_balance($WMB_prihod)." BLR<br /></td>
<td>".edit_balance($WMZ_prihod)." BLR<br /></td>
<td>".edit_balance($EasyPay_prihod)." BLR</td>
<td>".edit_balance($WebPay_prihod)." BLR</td>
<td>".edit_balance($iPay_prihod)." BLR</td>
<td>".edit_balance($iFree_prihod)." BLR</td>
</tr>

<tr bgcolor=\"#ffffff\" align=\"center\" class=text_log>
<td><b>Прибыль<sup>2</sup>:</b></td>
<td>".edit_balance($WMB_rem_commis)." BLR<br /></td>
<td>".edit_balance($WMZ_rem_commis)." BLR<br /></td>
<td>".edit_balance($EasyPay_rem_commis)." BLR</td>
<td>".edit_balance($WebPay_rem_commis)." BLR</td>
<td>".edit_balance($iPay_rem_commis)." BLR</td>
<td>".edit_balance($iFree_rem_commis)." BLR</td>
</tr>
";
?>

</table>
<br />
<sup>1</sup>Учтена комиссия платежных систем<br />
<sup>2</sup>Учтено вознаграждение минус комиссия платежных систем(прибыль с эл. систем без налогов)
</td>

	</tr>
</table>
<? } ?>
</body></html>