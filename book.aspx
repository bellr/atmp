<?
session_start();
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$errortag = false;
$record = "20";
if(!empty($_POST['enter'])) {
	$_SESSION['login'] = $_POST['login'];
	$_SESSION['pass'] = md5($_POST['pass']);
	header("Location: index.aspx");
}
if($_SESSION['login'] == $admin && $_SESSION['pass'] == $pass) $errortag = true;
if(!empty($_POST['send_comment'])) $sendok = $db->add_comment($_POST['comment'],$_POST['id']);
if(!empty($_GET['del'])) $db->del_book($_GET['del']);
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Просмотр/цитирование записей в книге</Title>
<link rel="stylesheet" href="http://atm.pinshop.by/include/style.css" type="text/css">
<script language='JavaScript'>
<!--
function show_comment(d) {
document.getElementById('comment').style.display = 'block';
document.form_comment.id.value = d;
}

// -->
</SCRIPT>

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
<?
if(!empty($sendok)) echo "Комментарий оставлен";



 ?>
<div id="comment" style="DISPLAY: none;" align="center">
	<form id="form_comment" name="form_comment" method="post" action="/book.aspx">
	Комментарий :<br />
		<textarea name="comment" rows="7" cols="100"></textarea><br />
		<input type="hidden" id="id" name="id" value=""  /><br />
		<input type="submit" name="send_comment" value="Отправить" />
	</form>
	<br />
</div>
<?
echo "<table width=\"100%\" cellspacing=\"0\" cellpadding=\"5\" border=1 align=\"center\">";
echo "<tr bgcolor=\"#CCCCCC\" align=\"center\">
	<td width=80%>Сообщение</td>
	<td width=10%>Дата</td>
	<td width=5%>&nbsp;</td>
	<td width=5%>&nbsp;</td>
	</tr>";

$result = $db->book_mess($_GET['page'],$record);

		foreach ($result as $ar) {
			$id = $ar["0"];
			$username = $ar["1"];
	        $contents = $ar["2"];
	        $data = $ar["3"];
			$rate = $ar["4"];


		echo "<tr bgcolor=\"#CCCCCC\">";
		echo "<td bgcolor=\"#ffffff\"><b>Автор :</b> {$username}<br />";
		if($rate == "-") echo "<font color=\"#FF0000\"><i>{$contents}</i></font>";
		else echo "<i>$contents</i>";
			echo "</td>";
		echo "<td bgcolor=\"#ffffff\" align=center>".$data."</td>";
		echo "<td bgcolor=\"#ffffff\" align=center><a href=\"javascript:show_comment({$id})\">Коментировать</a></td>";
		echo "<td bgcolor=\"#ffffff\" align=center><a href=\"book.aspx?del={$id}\">Удалить</a></td>";
		echo "</tr>";

	}
echo "</table><br /><br />";

	$number = $db->count_all('id','book');
	$posts = $number[0]["stotal"];
	$total = intval(($posts - 1) / $record) + 1;
	$page = $_GET['page'];
if ($total > 1) {
   	$i = 0;
   	while(++$i <= $total)
   	{
	if ($i == $page+1) {
	echo "<span id=\"activelink_page\" class=\"t_activelink_page\">";
	echo $page+1;
	echo "</span>&nbsp;";
	continue;
	}
	$p = $i - 1;
     	echo "<a href=\"?page=$p\"><span id=\"link_page\" class=\"t_link_page\">" . $i . "</span></a>&nbsp;";
   	}
}?>



		</td>
	</tr>
</table>
<? } ?>
</body></html>