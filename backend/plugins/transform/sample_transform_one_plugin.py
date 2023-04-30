import models.api_models as ApiModels


class SampleTransformOnePlugin(ApiModels.TransformPlugin):
    def __init__(self, target_id):
        self.target_id = target_id

    def transform(self, data: list[ApiModels.ProcessedTask]):
        print("PluginOne", data)
        returnData = [ { 'label': "Gruppe 1", 'count': 39 }
                     , { 'label': "Gruppe 2", 'count': 244 }
                     , { 'label': "Gruppe 4", 'count': 3109 }
                     , { 'label': "Gruppe 5", 'count': 1720 }
                    ]
        return (self.target_id, returnData)