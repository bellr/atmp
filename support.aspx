<?
session_start();
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$errortag = false;
$sestag = false;
if($_SESSION['login'] == $admin || $_SESSION['pass'] == $pass) $sestag = true;
if(!empty($_POST['mail_send'])) {
$reply_mess = $_POST['reply_mes'];
$message = $_POST['message'];

	require("include/smtp-func.aspx");
	$from_name = "Support. Team, PinShop.by";
	$subject = "Ответ по вашему запросу";
	$body = "<center>Здравствуйте.</center><br />
Вы писали :<br />
<blockquote>$message</blockquote><br />
{$reply_mess}<br />
<br />--<br />
С уважением,<br />
Администрация PinShop.by<br />
<a href='http://pinshop.by'>Интернет-магазин по продаже пин-кодов</a><br />
Mail: <a href='mailto:$support'>$support</a><br />
ICQ: $icq
";

smtpmail($_POST['email'],$subject,$body,$from_name);
	$db->edit_support($_POST['id']);
	$send = "ok";
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Служба поддержки</Title>
<link rel="stylesheet" href="http://atm.pinshop.by/include/style.css" type="text/css">
<script type="text/javascript">
<!--
function show_hide(d){
var id=document.getElementById(d);
if(id) id.style.display=id.style.display=='none'?'block':'none';
}
//-->
</script>
</head>
<body>
<?
if(!$sestag) {
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
?>
<? include('include/head.aspx'); ?>
<table width=100% bgColor="#ebebeb" cellpadding="5">
	<tr bgColor="#ffffff">
		<td width="200" valign="top">
<? include('include/top.aspx'); ?>
</td>
		<td>
<?
	if ($_GET['id']) {
		$db->edit_support($_GET['id']);
		$u = $db->get_info_mess($_GET['id']);
		$message = $u[0]['message'];
echo "<div align=center>
	IP : {$u[0]['ip']}
</div><br />
<div align=center>
<div align=left>
	<b>Вопрос :</b><br />
	<blockquote>{$u[0]['message']}</blockquote>
</div>

<br />
	<form method=post action=support.aspx?st=0>
		<input type=hidden name=email value={$u[0]['email']} />
		<input type=hidden name=id value={$u[0]['id']} />
		<input type=hidden name=message value=\"$message\" size=250 />
<textarea name=reply_mes rows=15 cols=100></textarea><br /><br />
<input type=submit name=mail_send value=Отправить>

	</form>
</div><br />";
}
if($send == "ok"){
echo "<div align=center>
<font size=3 color=red><b><<<Сообщение отправлено>>></b></font>
</div><br />";
}
echo "<table width=\"100%\" bgColor=\"#ebebeb\" cellspacing=\"1\" cellpadding=\"0\" border=0 align=\"center\">";
echo "<tr bgcolor=\"#f8f8ff\" align=\"center\">
	<td width=80%>Сообщение</td>
	<td width=10%>Дата</td>
	<td width=10%>&nbsp;</td>
	</tr>";

$result = $db->support_mess($_GET['st']);

		foreach ($result as $ar) {
			$id = $ar["0"];
	        $message = $ar["1"];
	        $date = $ar["2"];
	        $time = $ar["3"];

		echo "<tr bgcolor=\"#ffffff\">";
		echo "<td>".$message."</td>";
		echo "<td align=center>".$date." {$time}</td>";
		echo "<td align=center><a href=\"support.aspx?st=0&id=".$id."\">ответить</a></td>";
		echo "</tr>";

	}
echo "</table><br /><br />";
?>
		</td>
	</tr>
</table>
<? } ?>
</body></html>