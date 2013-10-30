<?php
	# ��������� �����
	define("DOC_ENCODING", "windows-1251");

include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");

	# ��������� � ��������� ������ �����
	if (count($_POST) > 0) {

		$response = $wmxi->X3(
			$_POST["purse"],               # ����� �������� ��� �������� ������������� ��������
			intval($_POST["wmtranid"]),    # ����� ����� > 0
			intval($_POST["tranid"]),      # ����� �������� � ������� ����� �����������; ����� ����� ����� ��� �����
			intval($_POST["wminvid"]),     # ����� ����� > 0
			intval($_POST["orderid"]),     # ����� ����� � ������� ����� ��������; ����� ����� ����� ��� �����
			trim($_POST["datestart"]),     # �������� ��:��:��
			trim($_POST["datefinish"])     # �������� ��:��:��
		);

		# ���������� ������ ������ �������
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");

		# ������ ������ �������
		$parser = new WMXIParser();

		# ��������������� ����� ������� � ���������. ������� ���������:
		# - XML-����� �������
		# - ���������, ������������ �� �����. �� ��������� ������������ UTF-8
		$structure = $parser->Parse($response, DOC_ENCODING);

		# ����������� ������� ��������� � ����� ������� ��� �������.
		# �� ������������� ��������� ����� �������������� � � �����������, ���� �� ��������
		# ��������� ���������� ����� (��������, ������ ����������)
		# ���� ���������� � ���������� XML-����� ������ ���, �� ������ �������� �����
		# ���������� � false - � ����� ������ ��������� ������ ����� ����������
		$transformed = $parser->Reindex($structure, false);
	}


?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
	<title>������� �� �������� <?echo $_POST["purse"];?></title>
	<meta http-equiv="Content-Type" content="text/html; charset=<?=DOC_ENCODING;?>" />
	<link rel="stylesheet" type="text/css" href="http://atm.pinshop.by/nncron/xml/x/style.css" />
</head>
<body>
	��������� �������� ����������:
	<a href="http://webmoney.ru/rus/developers/interfaces/xml/ophistory/index.shtml">http://webmoney.ru/rus/developers/interfaces/xml/ophistory/index.shtml</a>
	<br />

	<form action="" method="post">

		<label>����� �������� ��� �������� ������������� ��������:</label>
		<input type="text" name="purse" value="Z389628940270" />
		<br/>

		<label>����� �������� (� ������� WebMoney):</label>
		<input type="text" name="wmtranid" value="0" />
		<br/>

		<label>����� ��������:</label>
		<input type="text" name="tranid" value="0" />
		<br/>

		<label>����� ����� (� ������� WebMoney) �� �������� ����������� ��������:</label>
		<input type="text" name="wminvid" value="0" />
		<br/>

		<label>����� �����:</label>
		<input type="text" name="orderid" value="0" />
		<br/>

		<label>����������� ����� � ���� ���������� ��������:</label>
		<input type="text" name="datestart" value="20100101 00:00:00" />
		<br/>

		<label>������������ ����� � ���� ���������� ��������:</label>
		<input type="text" name="datefinish" value="20100131 00:00:00" />
		<br/>

		<input type="submit" value="�������� ������" />
		<br/>

	</form>

	<!--pre><?=htmlspecialchars(@$response, ENT_QUOTES);?></pre-->
	<!--pre><?=htmlspecialchars(print_r(@$structure, true), ENT_QUOTES);?></pre-->
	<!--pre><?=htmlspecialchars(print_r(@$transformed, true), ENT_QUOTES);?></pre-->

	<pre><!-- ������ � ���������� �������� ������������� ������� ����� ��������� ������ � ������� -->
<table width="100%" bgColor="#ebebeb"  border="0" cellspacing="1" cellpadding="0">
	<tr bgColor="#f8f8ff" align="center">
		<td>��� ��������</td>
		<td>�����</td>
		<td>��������</td>
		<td>����</td>
	</tr>
		<?
		$c_summ_in =0;
		$c_summ_out =0;
			$items = @$structure["0"]["node"]["1"]["node"];
			$items = is_array($items) ? $items : array();
			foreach($items as $k => $v) {
				$vv = $parser->Reindex($v["node"], true);
		?>
<tr bgcolor="#ffffff" align="center">
		<td>
<?
		if(htmlspecialchars(@$vv["pursedest"], ENT_QUOTES) == $_POST["purse"]) {echo "�������� ������";
		$c_summ_in = $c_summ_in + htmlspecialchars(@$vv["amount"], ENT_QUOTES);}
		else {echo "��������� ������"; $c_summ_out = $c_summ_out + htmlspecialchars(@$vv["amount"], ENT_QUOTES);}

?>
</td>
		<td><?=htmlspecialchars(@$vv["amount"], ENT_QUOTES); ?></td>
		<td><?=htmlspecialchars(@$vv["desc"], ENT_QUOTES); ?></td>
		<td><?=htmlspecialchars(@$vv["dateupd"], ENT_QUOTES); ?></td>
	</tr>


<!-- 			<b>� <?=$k;?></b>
			�����������: <b><?=htmlspecialchars(@$vv["pursesrc"], ENT_QUOTES); ?></b>
			����������: <b><?=htmlspecialchars(@$vv["pursedest"], ENT_QUOTES); ?></b>
			�����: <b><?=htmlspecialchars(@$vv["amount"], ENT_QUOTES); ?></b>
			���������: <b><?=htmlspecialchars(@$vv["comiss"], ENT_QUOTES); ?></b>
			��������: <b><?=htmlspecialchars(@$vv["desc"], ENT_QUOTES); ?></b>
			������: <b><?=htmlspecialchars(@$vv["datecrt"], ENT_QUOTES); ?></b>
			������: <b><?=htmlspecialchars(@$vv["dateupd"], ENT_QUOTES); ?></b> -->

	<? }
	echo "</table>
�������� �������� : {$c_summ_in}<br />
��������� �������� : {$c_summ_out}<br />";
?>
		��� ������: <b><?=htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES); ?></b>
		�������� ������: <b><?=htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES); ?></b>

	</pre>

</body>
</html>
