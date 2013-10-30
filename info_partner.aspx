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
$record = 30;
$errortag = true;
if(!empty($_POST['edit_remuneration'])) {$db->edit_remuneration($_POST['percent'],$_POST['company']);}
}
//echo md5('atomly');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Главная</Title>
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
<table width="100%" border="0" cellspacing="1" cellpadding="2" bgcolor="#F2F2F2">
	<tr>
	<td align="center"><a href="info_partner.aspx?sort=id">Номер</a></td>
	<td align="center"><a href="info_partner.aspx?sort=email">E-Mail</a></td>
	<td align="center"><a href="info_partner.aspx?sort=host">Сайт</a></td>
	<td align="center"><a href="info_partner.aspx?sort=balance">Баланс</a></td>
	<td align="center"><a href="info_partner.aspx?sort=count_oper">Кол-во заверш. опер.</a></td>
	<td align="center"><a href="info_partner.aspx?sort=summ_oper">Сумма поступ. средств</a></td>
	<td align="center"><a href="info_partner.aspx?sort=summa_bal">Всего заработано</a></td>
	</tr>
<?
if(!empty($_GET['sort'])) { $result = $db->selall_partner($_GET['page'],$record,$_GET['sort']);}
else {$result = $db->selall_partner($_GET['page'],$record,'id');}


		foreach($result as $arr)
		{
		echo "
		<tr bgcolor=\"#FFFFFF\" class=text_log align=\"center\">
		<td>{$arr['0']}</td>
		<td><a href=\"user_partner.aspx?email={$arr['1']}\">{$arr['1']}</a></td>
		<td>{$arr['2']}</td>
		<td>{$arr['3']} BLR</td>
		<td>{$arr['5']}</td>
		<td>{$arr['6']} BLR</td>
		<td>{$arr['4']} BLR</td>
		</tr>";
		}
		echo "</table><center>";

	//количество заявок на вывод
$number = $db->count_partner();

	$posts = $number[0]["stotal"];
	$total = intval(($posts - 1) / $record) + 1;
	$page = $_GET['page'];
if ($total > 1)
{
   	$i = 0;
   	while(++$i <= $total)
   	{
	if ($i == $page+1) {

	echo "<span class=\"black\">";
	echo "<u>";
	echo $page+1;
	echo "</u>";
	echo "</span>&nbsp;";
	continue;
	}
	$p = $i - 1;
     	echo "<a href=\"info_partner.aspx?page=$p\"><span class=\"text_log\">" . $i . "</span></a>&nbsp;";

   	}
}
		echo "</center>";
?>


      </td>
  </tr>
</table>
		</td>
	</tr>
</table>
<? } ?>
</body></html>