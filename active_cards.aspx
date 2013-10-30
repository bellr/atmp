<?
session_start();
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$errortag = false;
$record = "30";
if(!empty($_POST['enter'])) {
	$_SESSION['login'] = md5($_POST['login']);
	$_SESSION['pass'] = md5($_POST['pass']);
	header("Location: index.aspx");
}
if($_SESSION['login'] == $admin && $_SESSION['pass'] == $pass) {

$errortag = true;
	if(!empty($_POST['status_off'])) {
		$db->update_status('0',$_POST['id']);
		$c = $db->sel_count($_GET['card']);
		$db->upd_cards($_GET['card'],$c[0]['count']-1);
	}
	if(!empty($_POST['status_on'])) {
		$db->update_status('1',$_POST['id']);
		$c = $db->sel_count($_GET['card']);
		$db->upd_cards($_GET['card'],$c[0]['count']+1);
	}
}
//echo md5('atomly');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Активные карты</Title>
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
		<td valign="top">
	<form action="active_cards.aspx?card=<? echo $_GET['card'];?>" method="POST">


	<h3>Введите серийный №</h3>

	<input type="text" name="serial">

	<input type="submit" name="search_karta" value="Поиск"><br /><br />

	</form>
<?
if(!empty($_GET['card'])) {
		if(!empty($_POST['search_karta'])) {$sel_pin = $db->search_karta($_POST['serial'],$_GET['card']);}
		else {$sel_pin = $db->sel_pin_list($_GET['page'],$record,$_GET['card']);}

echo "<table border=\"0\" width=\"750\" align=\"center\" bgcolor=\"#ebebeb\" cellspacing=\"1\">
			<tr align=\"center\" bgColor=\"#ffffff\">
				<td>ID</td>
				<td>LOGIN</td>
				<td>PASSWORD</td>
				<td>SERIAL №</td>
				<td>ACTION</td>
			</tr>";
foreach($sel_pin as $ar) {
	//print_r($ar);
			echo "<tr align=\"center\" bgColor=\"#f8f8ff\">
				<td bgColor=\"#ffffff\">{$ar[0]}</td>
				<td>{$ar[1]}</td>
				<td>{$ar[2]}</td>
				<td>{$ar[4]}</td>
				<td bgColor=\"#ffffff\">
				<form method=\"post\" action=\"?card={$_GET['card']}\">
				<input type=\"hidden\" name=\"id\" value={$ar[0]}>";
				if($ar[3]) echo "<input type=\"submit\" name=\"status_off\" value=\"Дезактивировать\">";
				if(!$ar[3]) echo "<input type=\"submit\" name=\"status_on\" value=\"Активировать\">";


				echo "</form></td>
			</tr>";
}

		echo "</table>";


	$number = $db->count_pinkod($_GET['page'],$record,$_GET['card']);
	$posts = $number[0]["stotal"];
	$total = intval(($posts - 1) / $record) + 1;
	$page = $_GET['page'];
if ($total > 1) {
   	$i = 0;
   	while(++$i <= $total)
   	{
	if ($i == $page+1) {
	echo "<span id=\"activelink_page\" align=center class=\"t_activelink_page\">";
	echo $page+1;
	echo "</span>&nbsp;";
	continue;
	}
	$p = $i - 1;
     	echo "<a href=\"?card={$_GET['card']}&page=$p\"><span id=\"link_page\" class=\"t_link_page\">" . $i . "</span></a>&nbsp;";
   	}
}
 }
 else {echo "Не выбрана компания";}
?>

		</td>
	</tr>
</table>
<? } ?>
</body></html>