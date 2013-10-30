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

}
//echo md5('atomly');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Статистика заказов</Title>
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
		<input type="hidden" name="pass" /><br />
		<input type="submit" name="enter" value="Вход" />

	</form>

	</td></tr>
</table>
<?
}
else {
 ?>



<table width="100%" bgColor="#ebebeb"  border="0" cellspacing="1" cellpadding="0">
	<tr bgColor="#f8f8ff" align="center">

		<td>Заказ</td>
		<td>Сумма</td>
		<td>Дата</td>
	</tr>
<?

$unachieved_demand = $db->report($_GET['company']."|",$_GET['data_n'],$_GET['data_k']);
if(!empty($unachieved_demand)) {
	$summa = 0;
	foreach($unachieved_demand as $arr) {
		$sel_com = $db->info_company_pay($_GET['company']);

echo "<tr bgcolor=\"#ffffff\" align=\"center\">
		<td>";
			$dem = explode("|",$arr[3]);
		foreach($dem as $array) {
			if(!empty($array)) {
			$ar = explode(":",$array);
			$info_cards = $db->sel_card($ar[1]);
echo "<div style=\"margin:2px;\">{$info_cards[0]['name_card']}&nbsp;&nbsp;&nbsp;&nbsp;<b>".$ar[0]." шт.</b></div>";

			}
		}

		echo "</td
		<td>{$arr[2]} BYR</td>
		<td>{$arr[5]} {$arr[6]}</td>
	</tr>";
$summa = $summa + $arr[2];
	}
$prib = $summa * $sel_com[0]['remuneration']/100;
}
?>


</table>
<br /><br />

<br />
<b>Всего продано на сумму :</b> <? echo edit_balance($summa);?> BYR<br />
<b>К возврату :</b> <? echo edit_balance($summa-$prib);?> BYR<br />


<? } ?>
</body></html>