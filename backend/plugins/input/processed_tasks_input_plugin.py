from datetime import datetime
import models.api_models as ApiModels

import csv




class ProcessedTasksInputPlugin(ApiModels.ReadDataPlugin):
    def data(self) -> list[ApiModels.ProcessedTask]:
        return self.__read_from_csv()
    

    def __read_from_csv(self):
        filename = 'test_data/processed_tasks.csv'

        column_indices = {}
        row_count = 0
        source_data = []
        with open(filename) as tasks_file:
            tasks_csv = csv.reader(tasks_file, delimiter=",")

            for row in tasks_csv:
                if row_count == 0:
                        # Header name=keys and index=value
                        column_indices = { key: value for value, key in enumerate(row) }
                        row_count = row_count + 1
                else:
                    source_data.append(row)
                    row_count = row_count + 1

        return self.__map_data(column_indices, source_data)


    def __map_data(self, column_indices, source_data):
        processed_tasks = []

        current_index = None
        current_task = None
        for source_row in source_data:
            if source_row[column_indices['task_index']] == current_index:
                ps_name = source_row[column_indices['ps_name']]
                ps_creation_date = self.__datetime_from_iso_string(source_row[column_indices['ps_creation_date']])
                ps_responsible_group = source_row[column_indices['ps_responsible_group']]
                ps_responsible_worker = source_row[column_indices['ps_responsible_worker']]
                ps_current_worker = source_row[column_indices['ps_current_worker']]
                processing_status = ApiModels.ProcessingStatus()
                processing_status.status_name = ps_name
                processing_status.creation_date = ps_creation_date
                processing_status.responsible_group = ps_responsible_group
                processing_status.responsible_worker = ps_responsible_worker
                processing_status.current_worker = ps_current_worker
                current_task.processing_status.append(processing_status)
            else:
                current_index = source_row[column_indices['task_index']]
                task_creation_date = self.__datetime_from_iso_string(source_row[column_indices['task_creation_date']])
                task_responsible_group = source_row[column_indices['task_responsible_group']]
                task_responsible_worker = source_row[column_indices['task_responsible_worker']]
                task_current_worker = source_row[column_indices['task_current_worker']]
                task_end_date = self.__datetime_from_iso_string(source_row[column_indices['task_end_date']])
                current_task = ApiModels.ProcessedTask(task_creation_date, task_responsible_group, [])
                current_task.with_end_date(task_end_date)
                current_task.with_responsible_worker(task_responsible_worker)
                current_task.with_current_worker(task_current_worker)

                processed_tasks.append(current_task)

        return processed_tasks


    def __datetime_from_iso_string(self, datetime_string):
        return datetime.fromisoformat(datetime_string) if datetime_string is not None and datetime_string != '' else None