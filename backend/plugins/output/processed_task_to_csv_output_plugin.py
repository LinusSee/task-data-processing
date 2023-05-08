import models.api_models as ApiModels

import csv
from datetime import datetime



class ProcessedTaskToCsvOutputPlugin(ApiModels.OutputPlugin):
    '''Writes ProcessedTasks to a csv
    '''
    def __init__(self, target_id):
        self.target_id = target_id
        self.type = 'PluginWithoutSetup'

    def output(self, output_data):
        filename = './test_data/processed_tasks.csv'
        headers = ['task_index', 'task_creation_date', 'task_end_date', 'task_responsible_group', 'task_responsible_worker', 'task_current_worker',
                   'ps_creation_date', 'ps_responsible_group', 'ps_responsible_worker']
        
        rows = []

        task_index = 0
        for task in output_data:
            rows.append(self.__map_task(task_index, task))
            for processing_status in task.processing_status:
                rows.append(self.__map_processing_status(task_index, task, processing_status))
            task_index = task_index + 1
            

        with open(filename, 'w', newline='') as csv_file:
            writer = csv.writer(csv_file)
            writer.writerow(headers)
            writer.writerows(rows)

        print('Output: ', output_data)
        self.output_data = output_data


    def __map_task(self, task_index, task):
        return [ task_index
                , self.__datetime_to_iso_string(task.creation_date)
                , self.__datetime_to_iso_string(task.end_date)
                , task.responsible_group
                , None # Dont want to send those to myself
                , None # Dont want to send those to myself
                , None
                , None
                , None
                ]
    
    def __map_processing_status(self, task_index, task, processing_status):
        return [ task_index
                , self.__datetime_to_iso_string(task.creation_date)
                , self.__datetime_to_iso_string(task.end_date)
                , task.responsible_group
                , None # Dont want to send those to myself
                , None # Dont want to send those to myself
                , self.__datetime_to_iso_string(processing_status.creation_date)
                , None # Dont want to send those to myself
                , None # Dont want to send those to myself
                ]
    

    def __datetime_to_iso_string(self, datetime_string):
        return datetime.isoformat(datetime_string) if datetime_string is not None else None

