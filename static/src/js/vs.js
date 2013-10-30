function ajaxVs(parms) {

    var optReq = {
        url: parms.url || '/',
        method: parms.method || "GET",
        timeout: parms.timeout || 5000,
        async: parms.async || false,
        //onComplete: parms.onComplete || function(){ajaxComplete(optReq);},
        onError: parms.onError || function(){},
        endComplete: parms.endComplete || true, //команда на вывод сообщения об успешном завершении операции или не очень успешном. Для того, что бы не выводить сообщение об успешном выполнении операции в параметрах указать endComplete:'false'
        //onSuccess: parms.onSuccess || function(){alert('dasdasdadd');endComplete(optReq.req.responseText)},
        callback: parms.callback || false,//указываем на необходимость обработки данных после окончания запроса передается имя функции, которая будет вызвана после
        typeResponse: parms.typeResponse || "json",
        block: parms.block || "block", //метод обработки данных внутри блока, block - вывод данных в браузер, process - выводит данные в фомате json, но используется для обработки данных
        act: parms.act || "", //действие, имя операция или функции
        p: parms.p || '', //передаваемые параметры
        sl: parms.sl || true, //отображения процесса загрузки. поумолчанию load(показывать, что бы отключить необходимо в объекте передать параметр sl:"fon")
        cache: parms.cache || '0', //кеширование созданного блока
        extra: parms.extra //дополнительные параметр глобального использования в JS extra:{'appendElement':'cont_stat'}
    };

    optReq.name_block = optReq.act.split('.')[1];

    if(optReq.cache == 1) {

        if(optReq.extra.object_id) {
            optReq.name_block = optReq.extra.object_id;
        }

        console.log('load from cache '+optReq.name_block);

        if(document.getElementById(optReq.name_block)) {
            show(optReq.name_block);
            return false;
        }

        /*  if(optReq.typeResponse != 'html') {
            show('disableBg');
        } else {
            if(document.getElementById(name_block).innerHTML.length != 0) return false;
        }*/

    }

    var req = loadXMLDoc();

    if(optReq.sl == true) {show('loadingblock');}

    if (req) {

		if(optReq.method == 'GET') {
            if(optReq.p) {
                optReq.p = '&'+optReq.p
            }
            optReq.url = optReq.url+'?'+optReq.block+'='+optReq.act+optReq.p;
		}

        req.open(optReq.method, location.protocol+'//'+location.host+optReq.url, parms.async);

        if(optReq.method == 'POST') {
            req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            if (req.overrideMimeType ) req.setRequestHeader("Connection", "close");
        }

        req.onreadystatechange = function() {
            if (req.readyState == 4) {
                if (req.status == 200) {
                    optReq.req = req;
                    ajaxComplete(optReq);
                    runScript(optReq.req.responseText)
                    req = null;
                    if(optReq.sl == true) {hide('loadingblock');}
                }
                else {
                    hide('loadingblock');
                    showError('notify','Error: '+req.statusText);
                    return false;
                }
            }
        };
        req.send(optReq.block+'='+optReq.act+'&'+optReq.p);
    } else {alert('no req'); return false;}
	return true;
}

function loadXMLDoc() {
    try {
        req = new XMLHttpRequest();
    } catch (trymicrosoft) {
        try {
            req = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (othermicrosoft) {
            try {
                req = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (failed) {
                req = false;
            }
        }
    }
    return req;
}
function ajaxComplete(parms) {
    action = parms.act.split('.')[1];

    if(!document.getElementById(parms.name_block) && parms.block == "block" || parms.cache == 1) {

        document.getElementById('disableBg').innerHTML = '';
        var l = cElem({element:'div',id:parms.name_block,classN:action+' disable-cont'},document.getElementById('disableBg'));
        l.innerHTML = parms.req.responseText;
        show('disableBg');

    } else if(parms.typeResponse == 'html') {
        //if(document.getElementById(action).innerHTML.length == 0) {
            document.getElementById(parms.name_block).innerHTML = parms.req.responseText;
       // }
    } else {
        if(parms.endComplete == true) endComplete(parms.req.responseText);
    }

    if(parms.callback) callbackVs(parms);
}
function callbackVs(parms) {
    try {parms.resData = JSON.parse(parms.req.responseText);}
    catch (failed) {parms.resData = parms.req.responseText;}
    eval(parms.callback+"(parms)");
}
function endComplete(successData) {
    var successData = eval("("+successData+")");

    if(successData.status == 0) {
        var boxClassName = 'loadingDoc';
        var waitTime = 2000;
    } else if(successData.status == 1) {
        var boxClassName = 'resError';
        var waitTime = 4000;
    } else if(successData.status == 10) {
        var boxClassName = 'loadingDoc';
        var waitTime = 1500;
        remove(action);
    }

    document.getElementById('notify').className = boxClassName;
    document.getElementById('notify').innerHTML = successData.message;
    show('notifyblock');
    setTimeout(function(){hide('notifyblock');}, waitTime);
}

function CreatElement(element,id,classN) {
    var el = document.createElement(element);
    if(id) {el.id = id;}
    if(classN) {el.className = classN;}
    document.body.appendChild(el);
    return document.getElementById(id);
}
function cElem(e,app) {
    var el = document.createElement(e.element);
    if(e.id) {el.id = e.id;}
    if(e.classN) {el.className = e.classN;}
    app.appendChild(el);
    return el;
}
function cElemData(element,id,classN,app,data) {
    var el = document.createElement(element);
    if(id) {el.id = id;}
    if(classN) {el.className = classN;}
    app.appendChild(el);
    el.appendChild(document.createTextNode(data));
    return el;
}
function cInput(element,type,name,classN,app) {
    var el = document.createElement(element);
    el.type = type;
    el.name = name;
    el.className = classN;
    el.size = '5';
    el.length = '5';
    app.appendChild(el);
    return el;
}
function CountSymbol(obj,count) {if(text(obj).length > count) {alert(mes['countError']);}}
function creatDate() {
    var t=new Date();
    var d=t.getDate();
    var m=t.getMonth();
    var y=t.getFullYear();
    var h=t.getHours()
    var min=t.getMinutes()
    if (d<=9) d='0'+d;
    if (m<=9) m='0'+m;
    if (h<=9) h='0'+h;
    if (min<=9) min='0'+min;
    return d+'.'+m+'.'+y+' '+h+':'+min;
}
function setCookie(name,value,expires,domain) {
    var oneWeek = expires * 24 * 60 * 60 * 1000;
    var expDate = new Date () ;
    expDate.setTime (expDate.getTime() + oneWeek);
    document.cookie=name+"="+value+";expires="+expDate. toGMTString()+"; path=/; "+domain;
}
function getCookie(name) {
    var prefix = name + "="
    var cookieStartIndex = document.cookie.indexOf(prefix)
    if (cookieStartIndex == -1)
        return null
    var cookieEndIndex = document.cookie.indexOf
        (";", cookieStartIndex + prefix.length)
    if (cookieEndIndex == -1)
        cookieEndIndex = document.cookie.length
    return unescape(document.cookie.substring
        (cookieStartIndex + prefix.length, cookieEndIndex))
}

function deleteCookie(name, path, domain) {
    if (getCookie(name)) {
        document.cookie = name + "=" +
            ((path) ? "; path=" + path : "") +
            ((domain) ? "; domain=" + domain : "") +
            "; expires=Thu, 01-Jan-70 00:00:01 GMT"
    }
}

function serialize(a) {
    var s = [];
    if ( a.constructor == Array || typeof a == 'object') {
        for ( var i = 0; i < a.length; i++ ) {
            if(a[i].getAttribute('type') == "checkbox" || a[i].getAttribute('type') == "radio") {
                if(a[i].checked){
                    s.push(a[i].name + "=" + encodeURIComponent( a[i].value ) );
                }
            } else {
                if(a[i].name != '') {
                    s.push(a[i].name + "=" + encodeURIComponent( a[i].value ) );
                }
            }
        }

    } else {
        for ( var j in a )
            s.push( j + "=" + encodeURIComponent( a[j] ) );
    }
    return s.join("&");
}


function clearFomrValue(obj) {
    var select=document.getElementsByTagName("select");
    if(select){for(var i=0;i<select.length;i++){if(obj[select[i].getAttribute('name')]){if(obj[select[i].getAttribute('name')].value) {obj[select[i].getAttribute('name')].value = 'none';}}}}
    var textarea=document.getElementsByTagName("textarea");
    if(textarea){for(var i=0;i<textarea.length; i++ ){if(obj[textarea[i].getAttribute('name')]){if(obj[textarea[i].getAttribute('name')].value) {obj[textarea[i].getAttribute('name')].value = '';}}}}
    var input=document.getElementsByTagName("input");
    if(input){for(var i=0;i<input.length;i++){if(obj[input[i].getAttribute('name')]) {if(obj[input[i].getAttribute('name')].value) {obj[input[i].getAttribute('name')].value = '';}}}}
}

function hide(id){if(typeof id != 'object') {id=document.getElementById(id);}id.style.display = 'none';}
function closeWin(id){remove(id);hide('disableBg');}
function show(id){if(typeof id != 'object') {id=document.getElementById(id);}id.style.display = 'block';}
function showHide(id) {if(typeof id != 'object') {id=document.getElementById(id);}console.log(id.style.display);if(id.style.display=='none'){show(id);}else{hide(id);}}
function showError(id,message){show(id); document.getElementById(id).innerHTML = message;}

/*function hidePopup(id) {
    hide('disableBg');
    remove(id);
}*/
function remove(id) {
    if(typeof id != 'object') {
        var e=document.getElementById(id);
        if (e) e.parentNode.removeChild(e);
    } else {for(var i in id){remove(id[i]);}}
}
function before(parent,before,elem) {
    if (elem==null) {
        elem = before;
        before = parent;
        parent = before.parentNode;
    }
    var elems = checkElem(elem);
    for(var i=elems.length-1;i>=0;i--) {
        parent.insertBefore(elems[i],before);
    }
}
function append(parent,elem) {
    if(elem != null) {
        var elems=checkElem(elem);
        for (var i=0;i<elems.length;i++) {
            parent.appendChild(elems[i]);
        }
    }
}
function checkElem(a) {
    var r = [];
    if(a.constructor != Array) a=[a];
    for (var i=0;i<a.length;i++) {
        if (a[i].constructor == String) {
            var div=document.createElement("div");
            div.innerHTML=a[i];
            for ( var j=0; j<div.childNodes.length; j++)
                r[r.length] = div.childNodes[j];
        } else if(a[i].length ) {
            for (var j=0; j<a[i].length; j++)
                r[r.length] = a[i][j];
        } else {r[r.length] = a[i];}
    }
    return r;
}

//возвращает массив найденных елементов
function findElement(name,type) {
    //заменить на el.querySelector('.test') и на document.querySelectorAll('UL > LI:last-child');
    var r=[]; var re=new RegExp("(^|\\s)"+name+"(\\s|$)");
    if(typeof type=='object') {var e=type.getElementsByTagName("*");}
    else {var e=document.getElementsByTagName(type || "*");}
    for (var j=0;j<e.length;j++) {if(re.test(e[j].className)) {r.push(e[j]);}}
    if(r.length==1) {r=r[0];}
    return r;
}

initDOMParser = function() {
    if (typeof DOMParser == "undefined") {
        DOMParser = function () {}

        DOMParser.prototype.parseFromString = function (str, contentType) {
            if (typeof ActiveXObject != "undefined") {
                var d = new ActiveXObject("MSXML.DomDocument");
                d.loadXML(str);
                return d;
            } else if (typeof XMLHttpRequest != "undefined") {
                var req = new XMLHttpRequest;
                req.open("GET", "data:" + (contentType || "application/xml") +
                    ";charset=utf-8," + encodeURIComponent(str), false);
                if (req.overrideMimeType) {
                    req.overrideMimeType(contentType);
                }
                req.send(null);
                return req.responseXML;
            }
        }
    } else {
        (function(DOMParser) {
            "use strict";
            var DOMParser_proto = DOMParser.prototype, real_parseFromString = DOMParser_proto.parseFromString;
            try {
                if ((new DOMParser).parseFromString("", "text/html")) return;
            } catch (ex) {}

            DOMParser_proto.parseFromString = function(markup, type) {
                if (/^\s*text\/html\s*(?:;|$)/i.test(type)) {
                    var doc = document.implementation.createHTMLDocument("");
                    if (markup.toLowerCase().indexOf('<!doctype') > -1) doc.documentElement.innerHTML = markup;
                    else doc.body.innerHTML = markup;
                    return doc;
                } else return real_parseFromString.apply(this, arguments);
            };
        }(DOMParser));
    }
}

function runScript(html) {
    initDOMParser();
    var doc = new DOMParser().parseFromString(html, 'text/html');
    eval(text(doc.getElementsByTagName("script")));
}

function text(e) {var t="";var e=e.childNodes||e;for(var j=0;j<e.length;j++){t+=e[j].nodeType!=1?e[j].nodeValue : text(e[j].childNodes);}return t;}
function isDOMReady() {
    if (domReady.done) return false;
    if (document && document.getElementsByTagName && document.getElementById && document.body) {
        clearInterval(domReady.timer);
        domReady.timer = null;
        for (var i=0; i<domReady.ready.length;i++)
            domReady.ready[i]();
        domReady.ready = null;
        domReady.done = true;
    }
}
function domReady(f) {
    if (domReady.done) return f();
    if (domReady.timer) {
        domReady.ready.push(f);
    } else {
        //addEvent(window, "load", isDOMReady);
        domReady.ready = [f];
        domReady.timer = setInterval(isDOMReady, 13);
    }
}

function BrowserGo(parms) {document.location.href = HOME_URL+parms.resData.href;}
function appendTo(parms) {append(document.getElementById(parms.resData.appendElement),parms.resData.html);}
function innerTo(parms) {document.getElementById(parms.resData.appendElement).innerHTML = parms.resData.html;}
function innerToHtml(parms) {document.getElementById(parms.extra.appendElement).innerHTML = parms.req.responseText;}