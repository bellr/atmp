<?
class menu extends Template {

    public function block() {

        if(!sUser::isLogin(Model::Organise())) {
            $this->tmplName = 'empty';
            //Browser::go('/login/');
        }

        return $this;
    }
}

?>