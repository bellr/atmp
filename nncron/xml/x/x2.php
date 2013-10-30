<?php
	//require_once("_header.php");

	# Получение и обработка данных формы
	if (count($_POST) > 0) {

	define('PROJECT','ATM');
	define('VS_DEBUG',true);

	require_once(dirname($_SERVER['DOCUMENT_ROOT'])."/core/vs.php");
	
	$ar['purse_type'] = 'WMB';
	$ar['id_pay'] = $_POST["tranid"];
	$ar['purse_in'] = $_POST["pursedest"];
	$ar['amount'] = floatval($_POST["amount"]);
	//$ar['desc'] = 'Чек №'.$_POST["tranid"].': Распространение эл. денег (Номер кошелька: '.$ar['purse_in'].', Сумма: '.$_POST["amount"].' WMB)';
	$ar['desc'] = $_POST["desc"];
	$res = Extension::Payments()->Webmoney()->x2($ar,'primary_wmid');
d($res);

	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
	<title>X2</title>
	<meta http-equiv="Content-Type" content="text/html; charset=<?=DOC_ENCODING;?>" />
	<meta name="author" content="DKameleon" />
	<meta name="site" content="http://my-tools.net/wmxi/" />
	<link rel="stylesheet" type="text/css" href="style.css" />
</head>
<body>
	Детальное описание параметров:
	<a href="http://webmoney.ru/rus/developers/interfaces/xml/purse2purse/index.shtml" target="_blank">Детальное описание параметров</a>
	<br />

	<form action="" method="post">

		<label>номер перевода:</label>
		<input type="text" name="tranid" value="2" />
		<br/>

		<label>номер кошелька с которого выполняется перевод (отправитель):</label>
		<input type="text" name="pursesrc" value="Z418424195200" />
		<br/>

		<label>номер кошелька, но который выполняется перевод (получатель):</label>
		<input type="text" name="pursedest" value="Z444481839817" />
		<br/>

		<label>переводимая сумма:</label>
		<input type="text" name="amount" value="0.01" />
		<br/>

		<label>срок протекции сделки в днях:</label>
		<input type="text" name="period" value="0" />
		<br/>

		<label>код протекции сделки:</label>
		<input type="text" name="pcode" value="" />
		<br/>

		<label>описание оплачиваемого товара или услуги:</label>
		<input type="text" name="desc" size="200" value="Чек №25322 : Распространение эл. денег (Номер кошелька:B212923445663, Сумма: 150000  WMB)" />
		<br/>

		<label>номер счета (в системе WebMoney), по которому выполняется перевод:</label>
		<input type="text" name="wminvid" value="0" />
		<br/>

		<input type="submit" value="отправить перевод" />
		<br/>

	</form>

	<pre><?=htmlspecialchars(@$response, ENT_QUOTES);?></pre>
	<!--pre><?=htmlspecialchars(print_r(@$structure, true), ENT_QUOTES);?></pre-->
	<!--pre><?=htmlspecialchars(print_r(@$transformed, true), ENT_QUOTES);?></pre-->

	<pre><!-- ×èòàåì è îòîáðàæàåì ýëåìåíòû îáðàáîòàííîãî ìàññèâà ïîñëå ïîëó÷åíèÿ îòâåòà ñ ñåðâåðà -->
		Íîìåð ïåðåâîäà: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["tranid"], ENT_QUOTES); ?></b>
		Îòïðàâèòåëü: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["pursesrc"], ENT_QUOTES); ?></b>
		Ïîëó÷àòåëü: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["pursedest"], ENT_QUOTES); ?></b>
		Ñóììà: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["amount"], ENT_QUOTES); ?></b>
		Êîììèññèÿ: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["comiss"], ENT_QUOTES); ?></b>
		Òèï ïåðåâîäà: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["opertype"], ENT_QUOTES); ?></b>
		Ñðîê ïðîòåêöèè: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["period"], ENT_QUOTES); ?></b>
		Íîìåð ñ÷žòà: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["wminvid"], ENT_QUOTES); ?></b>
		Îïèñàíèå: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["desc"], ENT_QUOTES); ?></b>
		Ñîçäàí: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["datecrt"], ENT_QUOTES); ?></b>
		Èçìåíží: <b><?=htmlspecialchars(@$transformed["w3s.response"]["operation"]["dateupd"], ENT_QUOTES); ?></b>
		Êîä îøèáêè: <b><?=htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES); ?></b>
		Îïèñàíèå îøèáêè: <b><?=htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES); ?></b>
	</pre>

</body>
</html>
