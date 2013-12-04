function initDatapiker() {
    $('.datapiker').datepicker({
        format: 'dd-mm-yyyy'
    });
}

function reloadPage(parms) {
    var method = new Array();
    method['show_all_activity'] = 'user.show_all';
    method['show_settings'] = 'user.settings';

    if(ajaxVs({act:method[parms.resData.action],callback:'innerToHtml',extra:{'appendElement':parms.resData.content},endComplete:'false'})) {
        $('body').find('.data-user').hide();
        $('#'+parms.resData.content).show();
    }
}
function confirmVs(parms,message) {
    if(confirm(message)) {
        ajaxVs(parms);
    }
}
function statUser(parms) {document.getElementById('cont_stat').innerHTML = parms.req.responseText;}
