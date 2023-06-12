import src.models.api_models as ApiModels
from datetime import date
from datetime import timedelta



class ForwardingTransformPlugin(ApiModels.TransformPlugin):
    def __init__(self, target_id):
        self.target_id = target_id

    
    def transform(self, processed_tasks: list[ApiModels.ProcessedTask]):
        transformed_data = self.__transform(processed_tasks)

        return (self.target_id, transformed_data)
    

    def __transform(self, processed_tasks: list[ApiModels.ProcessedTask]):
        (start_date, group_keys) = self.__get_start_date_and_group_keys(processed_tasks)
        total_days = (date.today() - start_date).days
        print(f"groupKeys: {group_keys}")

        result = {
            'start_date': start_date,
            'total_saved_days': total_days,
            'groups': dict(list(map(lambda key: (key, {'changes': []}), group_keys)))
        }

        current_date = start_date
        for passed_days in range(total_days):
            current_date = start_date + timedelta(days=passed_days)
            for group_data in result['groups'].values():
                group_data['changes'].append({'inbound': 0, 'outbound': 0})

            for task in processed_tasks:
                current_responsible_group = None
                for status in task.processing_status:
                    if status.creation_date.date() > current_date:
                        break

                    if current_responsible_group is None:
                        current_responsible_group = status.responsible_group
                    elif status.status_name == 'FORWARDED':
                        source_group_data = result['groups'][current_responsible_group]
                        target_group_data = result['groups'][status.responsible_group]
                        # Increment forwarding source group (outbound count)
                        source_group_data['changes'][passed_days]['outbound'] += 1
                        # Increment forwarding target group (inbound count)
                        target_group_data['changes'][passed_days]['inbound'] += 1
                        # Change current responsible group
                        current_responsible_group = status.responsible_group

        return result
        

        

    def __get_start_date_and_group_keys(self, processed_tasks: list[ApiModels.ProcessedTask]):
        ''' Given a list of tasks, finds the date of the oldest task and all
            groups keys that the tasks are in or were in at some point.
        '''
        start_date = date.today() # The date of the oldest task
        keys = set()

        for task in processed_tasks:
            creation_date = task.creation_date.date()
            if creation_date < start_date:
                start_date = creation_date

            for status in task.processing_status:
                if status.responsible_group is not None and status.responsible_group != '':
                    keys.add(status.responsible_group)

        return (start_date, list(keys))