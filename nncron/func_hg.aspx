<?
if($_POST[to] == 'Bill') {
	$b = Bill($_POST[id_pay],$_POST[did],$_POST[out_val]);
	if($b[status] == '0') {echo "0|".$b[billID];}
}
elseif($_POST[to] == 'InfoBill') {
	echo $b  = InfoBill($_POST[id_pay]);
	//if($b == 'Payed') {echo "Payed";}
}
elseif($_POST[to] == 'Billwm') {
	include("xml/conf.php");
	include("xml/wmxiparser.php");
	$parser = new WMXIParser();
$response = $wmxi->X1($_POST["id_pay"],trim($_POST["wmid"]),$_POST["storepurse"],$_POST["amount"],trim($_POST["desc"]),'PinShop.by','0','1');
	$structure = $parser->Parse($response, DOC_ENCODING);
	$transformed = $parser->Reindex($structure, true);
	$kod_er = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
	$desc_er = htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES);
	echo $kod_er."|".$desc_er;
}


//соединение с сервером hutkigrosh
function sendToHG( $req, $url, $data, $cookies, $method ) {
	$req -> setUrl( $url );
	$req -> setHeaders( array( "Content-Type" => "application/xml", "Content-Length" => strlen( $data ) ) );
	$req -> setMethod( $method );
	$req -> setRawPostData( $data );
	$req -> enableCookies();
	if( $cookies != null ) $req->setCookies( $cookies );
	$req -> send();
	return $req -> getResponseBody();
}
//выписка счета
function Bill($id_pay,$did,$amount) {
$url = "https://www.hutkigrosh.by/API/v1/Security/LogIn";
$req =& new HTTPRequest( $url );
$dataXML = "<Credentials xmlns=\"http://www.hutkigrosh.by/api\">". "<user>support@pinshop.by</user>". "<pwd>Dbnfkbr_109987</pwd>". "</Credentials>";
$login = sendToHG( $req, $url, $dataXML, null, HTTP_METH_POST );
$cookies = $req -> getCookies();
$xmlres = simplexml_load_string($login);
	if($xmlres[0]) {
// Выставляем новый счет
$url = "https://www.hutkigrosh.by/API/v1/Invoicing/Bill";
$dueDt = date('Y-m-d',mktime(0,0,0,date('m'),date('d')+1,date('Y')));
$addedDt = date('Y-m-d');
$time = date('H:i:s');
$dataXML = "<Bill xmlns=\"http://www.hutkigrosh.by/api/invoicing\">
<billID>2</billID>
<eripId>10002001</eripId>
<invId>{$did}</invId>
<dueDt>{$dueDt}T{$time}</dueDt>
<addedDt>{$addedDt}T{$time}</addedDt>
<fullName>-</fullName>
<mobilePhone>-</mobilePhone>
<notifyByMobilePhone>false</notifyByMobilePhone>
<notifyByEMail>false</notifyByEMail>
<fullAddress>-</fullAddress>
<amt>{$amount}.000000</amt>
<curr>BYR</curr>
<statusEnum>NotSet</statusEnum>
<products>
<ProductInfo>
<desc>Оплата заказа №{$did}</desc>
<count>1</count>
<amt>{$amount}.000000</amt>
</ProductInfo>
</products>
</Bill>";
$bill = sendToHG( $req, $url, $dataXML, $cookies, HTTP_METH_POST );
sendToHG( $req, "https://www.hutkigrosh.by/API/v1/Security/LogOut", "", $cookies, HTTP_METH_POST );
$xmlres = simplexml_load_string($bill);
$return[status] = $xmlres->status; $return[billID] = $xmlres->billID;
return $return;
	}
}
//информация по счету
function InfoBill($id_pay) {
$url = "https://www.hutkigrosh.by/API/v1/Security/LogIn";
$req =& new HTTPRequest( $url );
$dataXML = "<Credentials xmlns=\"http://www.hutkigrosh.by/api\">". "<user>support@pinshop.by</user>". "<pwd>Dbnfkbr_109987</pwd>". "</Credentials>";
$login = sendToHG( $req, $url, $dataXML, null, HTTP_METH_POST );
$cookies = $req -> getCookies();
$xmlres = simplexml_load_string($login);
	if($xmlres[0]) {
	$info_bill = sendToHG( $req, "https://www.hutkigrosh.by/API/v1/Invoicing/Bill(".$id_pay.")", "", $cookies, HTTP_METH_GET );
	sendToHG( $req, "https://www.hutkigrosh.by/API/v1/Security/LogOut", "", $cookies, HTTP_METH_POST );
	$xmlres = simplexml_load_string($info_bill);
	return $xmlres->bill->statusEnum;
	}
}

/*function InfoBill1($id_pay) {
$url = "https://www.hutkigrosh.by/API/v1/Security/LogIn";
$req =& new HTTPRequest( $url );
$dataXML = "<Credentials xmlns=\"http://www.hutkigrosh.by/api\">". "<user>support@pinshop.by</user>". "<pwd>Dbnfkbr_109987</pwd>". "</Credentials>";
// Начинаем сеанс, если в ответ приходит false, значит аутентификация
// провалилась и дальнейшие вызовы бессмысленные
$login = sendToHG( $req, $url, $dataXML, null, HTTP_METH_POST );
$cookies = $req -> getCookies();
// Получаем информацию о счете
$url = "https://www.hutkigrosh.by/API/v1/Invoicing/Bill({$id_pay})";
echo "Get Bill : ".sendToHG( $req, $url, "", $cookies, HTTP_METH_GET )."<br/>";
// Завершаем сеанс
$url = "https://www.hutkigrosh.by/API/v1/Security/LogOut";
echo "Logout: ".sendToHG( $req, $url, "", $cookies, HTTP_METH_POST )."<br/>";
}*/
?>