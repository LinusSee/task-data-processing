import models.api_models as ApiModels



class SampleOutputPlugin(ApiModels.OutputPlugin):
    def __init__(self, target_id):
        self.target_id = target_id
        self.type = 'PluginWithSetup'

    def setup(self, app):
        app.add_url_rule('/', 'sampleUrl', self.__rest_resource)

    def output(self, output_data):
        print('Output: ', output_data)
        self.output_data = output_data

    def __rest_resource(self):
        # return self.output_data
        return 'Hello World!'