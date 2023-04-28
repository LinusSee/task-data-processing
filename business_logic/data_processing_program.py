import models.api_models as ApiModels

class DataProcessingProgram:
    def __init__(self,
                 flask_app,
                 input_data_plugin: ApiModels.ReadDataPlugin,
                 transform_plugins: ApiModels.TransformPlugin,
                 output_plugins: ApiModels.OutputPlugin):
        self.flask_app = flask_app
        self.input_data_plugin = input_data_plugin
        self.transform_plugins = transform_plugins
        self.output_plugins = output_plugins


    def run(self):
        print('Running program\n\n\n')

        data = self.input_data_plugin.data()

        transform_dict = dict()

        for transform_plugin in self.transform_plugins:
            transform_result = transform_plugin.transform(data)
            transform_dict[transform_result[0]] = transform_result[1]

        for output_plugin in self.output_plugins:
            if output_plugin.type == 'PluginWithSetup':
                output_plugin.setup(self.flask_app)
            output_plugin.output(transform_dict[output_plugin.target_id])

        print('\n\n\nEnding program')