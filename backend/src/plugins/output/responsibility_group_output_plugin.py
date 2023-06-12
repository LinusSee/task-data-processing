import src.models.api_models as ApiModels

from flask import request
from datetime import date



class ResponsibilityGroupOutputPlugin(ApiModels.OutputPlugin):
    '''Publishes the amout of tasks in a responsibility-group at a given day.
        TODO: Publish both:
                    - Task is in a group
                    - Task is in a group and does not have a responsible worker
                        (how does this differ from currentWorker again?)
    '''
    def __init__(self, target_id):
        self.target_id = target_id
        self.type = 'PluginWithSetup'

    def setup(self, app):
        app.add_url_rule('/responsibility-groups/count', view_func=self.__responsibility_group_count_rest_resource)


    def output(self, output_data):
        self.output_data = output_data


    def __responsibility_group_count_rest_resource(self):
        filter_date_string = request.args.get('filter-date')
        filter_date = date.fromisoformat(filter_date_string)

        task_counts = self.__get_task_counts_for_group(self.output_data, filter_date)
        return_data = self.__task_counts_to_response(task_counts)

        return { 'countPerGroupName': return_data }
    

    def __get_task_counts_for_group(self, count_data, target_date):
        ''' Calculates the number of tasks in each group at a given date.
        '''
        # TODO: Possible bug for target=start or target < start
        target_days = (target_date - count_data['start_date']).days + 1
        passed_days = min(count_data['total_saved_days'], target_days)
        count_dict = dict.fromkeys(count_data['groups'].keys())

        for (group_key, group_data) in count_data['groups'].items():

            count_dict[group_key] = sum(group_data['changes'][:passed_days])

        return count_dict
    

    def __task_counts_to_response(self, task_counts):
        map_fn = lambda item: {'key': item[0], 'label': item[0].replace('_', ' '), 'count': item[1]}

        return_data = list(map(map_fn, list(task_counts.items())))
        return_data.sort(key=lambda x: x['count'])

        return return_data
