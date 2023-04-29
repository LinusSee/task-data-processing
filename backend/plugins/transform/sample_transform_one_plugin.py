import models.api_models as ApiModels


class SampleTransformOnePlugin(ApiModels.TransformPlugin):
    def __init__(self, target_id):
        self.target_id = target_id

    def transform(self, data: list[ApiModels.ProcessedTask]):
        print("PluginOne", data)
        return (self.target_id, data)