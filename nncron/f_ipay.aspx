<?
$fSaltPlusXML='*^:s??1;"-_3=+\d/e,.)(<?xml version="1.0" encoding="windows-1251"?>
<ServiceProvider_Response>
<ServiceInfo>
<Amount Editable="Y" MinAmount="5000" MaxAmount ="1000000">
<Debt>10000</Debt>
<Penalty></Penalty>
</Amount>
<Name>
<Surname>БОНУС</Surname>
<FirstName> </FirstName>
<Patronymic> </Patronymic>
</Name>
<Info xml:space="preserve">
<InfoLine>Оплата услуг интернет-провайдера "Мир"</InfoLine>
<InfoLine>Login: ivanov</InfoLine>
</Info>
</ServiceInfo>
</ServiceProvider_Response>';
 echo md5($fSaltPlusXML);
//echo $fSaltPlusXML;

//echo "fsdsdffsdfs";
//header("ServiceProvider-Signature: SALT+MD5: 110B4544929D67DC89C0CBE395ECB6DB");

//print_r(getallheaders());
//phpinfo();
?>
<H1>Запрос задолженности</H1>
<FORM name="msgform" METHOD="POST" ACTION="http://atm.pinshop.by/nncron/ipay.aspx" enctype="multipart/form-data">
Запрос:
<TEXTAREA name="XML" cols=150 rows=20 style="font: 13px verdana;  border :1px solid;">
</TEXTAREA>
<Br>
<INPUT STYLE="border: solid 1px black;font : bold 11px Verana;" type=submit value="Отправить запрос">
</FORM>