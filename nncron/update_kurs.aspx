<?
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);

//$filename = "http://atm.wm-rb.net/nncron/XMLbestRates.txt";
$filename = "https://wm.exchanger.ru/asp/XMLbestRates.asp";
$ch = curl_init();
	curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)");
curl_setopt($ch, CURLOPT_URL, $filename);
curl_setopt($ch, CURLOPT_HEADER,0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
curl_setopt($ch, CURLOPT_VERBOSE,0);
$fd = curl_exec($ch);


$xmlres = simplexml_load_string($fd);
$info = $db->ini_comission();
	for ($i = 0; $i<=32; $i++) {
		if($xmlres->row[$i]['Direct'] == 'WMZ - WMB') {
			$BaseRate = substr($xmlres->row[$i]['BaseRate'],1);
			$rate = $BaseRate - $BaseRate * $info[0]['commission']/100;
			$db->update_rate_WMZ($rate);

			}

		//$db_exchange->update_baserate($xmlres->row[$i]['Direct'],$BaseRate);
	}
if(date("d") == "01") $db->edit_emoney('WMB');
?>

