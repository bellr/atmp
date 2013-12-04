<?
class order extends Template {

    function __construct() {
        //sUser::checkLogin(Model::Organise());
    }

    public function process($P) {

        $answer['status'] = 0;

        switch ($P->action) {
            case 'delete_order':

                Model::Orders('KASSIR')->deleteOrder($P->order_id);
                $answer['message'] = 'Заказ успешно удален';

                break;
        }

        return json_encode($answer);
    }

}
