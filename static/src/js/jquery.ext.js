$.fn.extend({
    activityList: function() {
        var $this = $(this);

        $('.ico-edit-tic').click(function () {
            var $obj = $(this).parent().parent().find('.item');
            var $pstr = $obj.attr('id').split('_');
            $obj.hide();
            $(this).parent().parent().find('.item-form').show();
        });

        $('.nav-link').live('click', function(e) {

            var $id = $(this).attr('id');
            var $cont = $id.split('.');

            var parm = {
                resData:{
                    action: $cont[0],
                    content: $cont[1]
                }
            };

            reloadPage(parm);
        });

        $('.sale_tickets').live('click', function(e) {

            var $id = $(this).attr('id').split('_');
           // if($id[0] == 'aid') {
           //     var $method = 'user.show_stat';
           // } else if($id[0] == 'stid') {
                var $method = 'user.sale_tickets';
            //}

            if(ajaxVs({act:$method,p:"organise_id="+$id[1]+"&activity_id="+$id[2],callback:'innerToHtml',extra:{'appendElement':'show_stat'},endComplete:'false'})) {
                $this.find('.data-user').hide();
                $('#show_stat').show();
            }
        });



    }

});


