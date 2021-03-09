from amundsen_application import create_app


CUSTOM_BUILD = '/usr/local/amundsen/frontend/configs/.custom_build'
app = create_app(config_module_class='configs.config.FrontendConfig',
                 template_folder=f'{CUSTOM_BUILD}/dist/templates')
app.static_folder = CUSTOM_BUILD


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
