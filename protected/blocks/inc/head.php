<?
class head extends Template {

    public function block() {

        $controller = inputData::init()->controller;
        $css = Config::$processorVars[$controller]['css'];
        $js = Config::$processorVars[$controller]['js'];
        $default_css = array('default.css' => 'dynamic');
        $default_js = array('vs.js' => 'dynamic');

        $this->vars['css'] = sSystem::getStaticData(array_merge($default_css,(array)$css),'css','link',array('rel' => 'stylesheet'));
        $this->vars['js'] = sSystem::getStaticData(array_merge((array)$js,$default_js),'js','script');

        return $this;
    }

}
