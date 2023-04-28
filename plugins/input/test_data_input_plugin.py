import datetime
import models.api_models as ApiModels


class TestDataInputPlugin(ApiModels.ReadDataPlugin):
    def data(self) -> list[ApiModels.ProcessedTask]:
        sample_task = ApiModels.ProcessedTask()
        sample_task.creation_date = datetime.datetime(2022, 6, 18, 9, 15)
        sample_task.end_date = datetime.datetime(2022, 6, 24, 17, 3)

        return [sample_task]