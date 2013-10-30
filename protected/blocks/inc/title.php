<?
class title extends Template {

    public function block() {
        $P = inputData::init();

        $app_name = Config::$base[PROJECT]['APP_NAME'];
        if($P->controller == 'tickets') {
            $this->vars['title'] = 'Билеты '.$app_name;

        }elseif($P->controller == 'order') {
            $this->vars['title'] = 'Просмотр заказа '.$app_name;

        } elseif($P->controller == 'checktickets') {
            $this->vars['title'] = 'Проверка билета '.$app_name;

        } elseif($P->controller == 'registration') {
            $this->vars['title'] = 'Регистрация организатора '.$app_name;

        } elseif($P->controller == 'login') {
            $this->vars['title'] = 'Авторизация организатора '.$app_name;

        } elseif($P->controller == 'user') {
            $this->vars['title'] = 'Кабинет организатора '.$app_name;

        } elseif($P->controller == 'activity') {

            $res = Model::Activity()->getInfo($P->object,$P->object_id);

            $this->vars['title'] = $res['activity_name'];
            $this->vars['description'] = $res['description'];
        }

        return $this;
    }
}

?>
