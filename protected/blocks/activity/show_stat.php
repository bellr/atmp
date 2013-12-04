<?
class show_stat extends Template {

    function __construct() {
        //sUser::checkLogin(Model::Organise());
    }

    public function block() {

        //exit('delete method');
        $P = inputData::init();

        if(!empty($P->date_start)) {
            $this->vars['date_start'] = $ds = date_parse($P->date_start);
            $this->vars['date_end'] = $de = date_parse($P->date_end);

            $date_start = mktime(0, 0, 0, $ds['month'], $ds['day'], $ds['year']);
            $date_end = mktime(23, 59, 59, $de['month'], $de['day'], $de['year']);

            $sql_dop = " add_date BETWEEN '{$date_start}' and '{$date_end}'";
            $this->tmplName = 'data';
        } else {
            $sql_dop = " add_date >= ".mktime(0, 0, 0, date('m',time()), date('d',time()), date('Y',time()));
            $this->vars['date_start'] = $this->vars['date_end'] = date('d-m-Y');
        }

        $order = dataBase::kassir()->select('orders',
            'order_id, activity_id, total, indentificator, fname, lname, email, add_date, order_data, status, comment, type_payment, a.activity_name, pa.place',
            "left join activity as a using(activity_id)
            left join place_activity as pa using(place_id)
            where {$sql_dop}",'order by order_id desc');

        if(!empty($order)) {
            foreach($order as $o) {

                $order_data = json_decode($o['order_data'],true);
                $tickets = Model::Info_ticket('KASSIR')->get($o['activity_id']);
                $placement = Model::Info_ticket('KASSIR')->ticketOrder($tickets,$order_data);

                foreach($placement as $p) {
                    $o['data_tickets'] .= $p['placement_name'].' — '.$order_data[$p['info_ticket']].' шт.<br />';
                }

                if($o['status'] == 1) {
                    $o['url_tickets'] = HTML::a(array('href' => Config::$base['KASSIR_URL'].'/tickets/'.$o['indentificator'].'/', 'target' => '_blank'),'tickets');
                    $o['delete_order'] = HTML::span(array(
                        'class' => 'tag-a',
                        'onClick' => "confirmVs({url:'/index.php',block:'process',act:'activity.order',p:'action=delete_order&order_id={$o['order_id']}'},'Будут удалены созданные билеты! Вы действительно хотите удалить этот заказ?');"
                    ),'Delete');
                }

                $o['total'] = sFormatData::getMoneyFormat($o['total']);
                $o['date'] = date('d.m.Y H:i:s',$o['add_date']);
                $o['status_class'] = Model::Orders('KASSIR')->status_class[$o['status']];
                $o['status'] = Model::Orders('KASSIR')->status_name[$o['status']];
                $o['type_payment'] = Model::Orders('KASSIR')->typePayment[$o['type_payment']];

                if(!empty($o['comment'])) {

                    $comment_message = Config::getSysMessages($o['comment']);
                    if(!isset($comment_message)) {
                        $comment_message = $o['comment'];
                    }

                    $o['comment_data'] = HTML::div(array('class' => 'red'),$comment_message);
                }

                $vars['item'] .= $this->iterate_tmpl('activity',__CLASS__,'item_activity',$o);
                unset($o['data_tickets']);
            }

             $this->vars['show_data'] = $this->iterate_tmpl('activity',__CLASS__,'show_data',$vars);

            if($P->action == 'show_period') {
                $this->tmplName = 'data_stat';
            }

        } else {
            $this->vars['show_data'] = $this->iterate_tmpl('activity',__CLASS__,'data_empty');
        }

        $this->vars['date_start'] = !empty($P->date_start) ? $P->date_start : date('d-m-Y',time());
        $this->vars['date_end'] = !empty($P->date_end) ? $P->date_end : date('d-m-Y',time());
        $this->vars['organise_id'] = $P->organise_id;
        $this->vars['activity_id'] = $P->activity_id;

        return $this;
    }

}
