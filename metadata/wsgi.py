from metadata_service import create_app

app = create_app(config_module_class='configs.config.MetadataConfig')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
