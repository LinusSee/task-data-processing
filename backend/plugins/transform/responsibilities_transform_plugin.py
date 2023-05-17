import models.api_models as ApiModels
from datetime import datetime
from datetime import date
from datetime import timedelta



class ResponsibilitiesTransformPlugin(ApiModels.TransformPlugin):
    def __init__(self, target_id):
        self.target_id = target_id

    def transform(self, processed_tasks: list[ApiModels.ProcessedTask]):
        transformed_data = self.__transform_to_changeset(processed_tasks)

        return (self.target_id, transformed_data)



    def __transform_to_changeset(self, data):
        ''' Transform to a format that allows querying the count for a specific day.
        '''
        start_date = date.today()
        keys = set()

        for task in data:
            # Only add if task is not assigned to user?
            keys.add(task.responsible_group)
            creation_date = task.creation_date.date()
            if creation_date < start_date:
                start_date = creation_date
        total_days = (date.today() - start_date).days

        result = {
            'start_date': start_date,
            'total_saved_days': total_days,
            'groups': dict.fromkeys(keys, { 'initial_count': 0, 'changes': [] })
        }
        for group_key in result['groups'].keys():
                result['groups'][group_key] = { 'initial_count': 0, 'changes': [] }
        
        # Task to current group
        current_group_dict = dict()
        current_date = start_date
        
        for passed_days in range(total_days):
            current_date = start_date + timedelta(days=passed_days)

            for group_data in result['groups'].values():
                group_data['changes'].append(0)

            for (task_index, task) in zip(range(len(data)), data):
                for status in task.processing_status:
                    if status.creation_date.date() > current_date:
                        break # Requiring sorted data so we can stop at the first date that is "too new"
                    # Possible bug, if a group changes during a day and then changes back to the original
                    # It will be counted as a change
                    if task_index in current_group_dict and current_group_dict[task_index] == status.responsible_group:
                        continue

                    if status.responsible_group == None or status.responsible_group == '':
                        continue

                    if task_index in current_group_dict:
                        previous_group = current_group_dict[task_index]
                        result['groups'][previous_group]['changes'][passed_days] -= 1
                    current_group_dict[task_index] = status.responsible_group
                    result['groups'][status.responsible_group]['changes'][passed_days] += 1

        return result

        