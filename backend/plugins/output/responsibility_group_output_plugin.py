import models.api_models as ApiModels

from flask import request



class ResponsibilityGroupOutputPlugin(ApiModels.OutputPlugin):
    '''Publishes the amout of tasks in a responsibility-group per time.
    '''
    def __init__(self, target_id):
        self.target_id = target_id
        self.type = 'PluginWithSetup'

    def setup(self, app):
        app.add_url_rule('/responsibility-groups/count', view_func=self.__rest_resource)

    def output(self, output_data):
        print('Output: ', output_data)
        self.output_data = output_data

    def __rest_resource(self):
        print('Url is: ', request.query_string)
        # return self.output_data
        return 'Hello there!'