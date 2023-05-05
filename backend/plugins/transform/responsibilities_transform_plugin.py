import models.api_models as ApiModels


class ResponsibilitiesTransformPlugin(ApiModels.TransformPlugin):
    def __init__(self, target_id):
        self.target_id = target_id

    def transform(self, data: list[ApiModels.ProcessedTask]):
        counted_groups = dict()

        for task in data:
            counted_groups[task.responsible_group] = counted_groups.setdefault(task.responsible_group, 0) + 1
        
        return_data = []
        for item in counted_groups.items():
            return_data.append({'label': item[0].replace('_', ' '), 'count': item[1]})

        return (self.target_id, return_data)