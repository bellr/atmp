<?
class order extends Template {

    function __construct() {
        //sUser::checkLogin(Model::Organise());
    }

    public function process($P) {

        $answer['status'] = 0;

        switch ($P->action) {
            case 'delete_order':

                if(is_array(json_decode(htmlspecialchars_decode($P->order_data),true))) {

                    Model::Orders('KASSIR')->deleteOrder(array(
                        'order_id' => $P->order_id,
                        'order_data' => htmlspecialchars_decode($P->order_data),
                    ));
                    $answer['message'] = 'Заказ успешно удален';

                } else {
                    $answer['message'] = 'Данные заказа слишком велики для выполнения методом GET.';
                    $answer['status'] = 1;
                }


            break;
        }

        return json_encode($answer);
    }

}
