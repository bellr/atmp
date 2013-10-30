<?
define('PROJECT','ATM');
define('PROJECT_ROOT',dirname(__FILE__));
define('VS_DEBUG',true);

require_once(dirname(PROJECT_ROOT)."/core/vs.php");

//header('Content-Type: text/html; charset=windows-1251');
											//!!!!!!!!!!!ВНИМАНИЕ!!! ПРОВЕРЬ ПРАВИЛЬНОСТЬ ПУТЕЙ ПРИ ЗАКАЧКЕ НА СЕРВЕР!!!!!!!!!!!
//$home_dir = "Z:/home/pinshop.by/www/";
$home_dir = Config::$base['HOME']['ROOT']."/";

//$atm_dir = "Z:/home/pinshop.by/atm/";
$atm_dir = Config::$base[PROJECT]['ROOT']."/";

											//!!!!!!!!!!!ВНИМАНИЕ!!! ПРОВЕРЬ ПРАВИЛЬНОСТЬ ПУТЕЙ ПРИ ЗАКАЧКЕ НА СЕРВЕР!!!!!!!!!!!
$admin = "7434751bba80a787da91f6ee30b2f6c1";
$pass = "ea664726e360cb2f06df175bfaa24835";
$key_ad = "dbnfkbq1986";
$robot = "robot@pinshop.by";
$support = "support@pinshop.by";
$icq = "5600-454-91";
$tel = "+375 (29) 117 60 44";
$data_pay = date("Y-m-d");
$time_pay = date("H:i:s");

//разбиение на страницы
$record = 10;
$wmid = "871652566746";
$WMB = "B956112978613";
$WMZ = "Z389628940270";
$rezerv_WMB = "B308022676518";

$limitWMB_iFree = '50000';
?>