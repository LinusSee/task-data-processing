import models.api_models as ApiModels

from flask import request
import time
from datetime import date
from datetime import timedelta



class ResponsibilityHistoryOutputPlugin(ApiModels.OutputPlugin):
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
        app.add_url_rule('/responsibility-groups/history', view_func=self.__responsibility_history_rest_resource)


    def output(self, output_data):
        self.output_data = output_data


    def __responsibility_history_rest_resource(self):
        past_days = int(request.args.get('past-days'))
        groups = request.args.get('group-keys').split(",")

        return_data = self.__aggregate_data(past_days, groups, self.output_data)

        return { 'groupLabels': return_data[0], 'groupCountHistory': return_data[1]}


    def __aggregate_data(self, past_days, group_keys, count_data):
        ''' Returns the number of tasks in the given group for the last x days,
            and a mapping to the group labels needed for display.
        '''
        start_day = max(0, count_data['total_saved_days'] - past_days)
        start_date = date.today() - timedelta(days=past_days)
        end_day = count_data['total_saved_days']

        # Needed to get the necessary label for the json response (based on the group index)
        result_name_dict = { 0: 'group1', 1: 'group2', 2: 'group3', 3: 'group4', 4: 'group5' }
        list_dates = []
        lists_to_zip = []

        for (group_index, group_key) in zip(range(len(group_keys)), group_keys):
            group_count_data = count_data['groups'][group_key]['changes']
            initial_count = sum(group_count_data[:start_day])
            group_result = [initial_count]
            for change_val in group_count_data[start_day:end_day]:
                group_result.append(group_result[-1] + change_val)
            list_dates.append(group_index)
            lists_to_zip.append(group_result)

        result = []
        zipped_lists = list(zip(*lists_to_zip))
        for (target_date, target_val) in zip(range(len(zipped_lists)), zipped_lists):
            target_date_foo = start_date + timedelta(days=target_date)
            target_dict = { 'countDate': time.mktime(target_date_foo.timetuple())}
            for (index, val) in zip(range(len(target_val)), target_val):
                target_key = result_name_dict[index]
                target_dict[target_key] = val
            
            result.append(target_dict)
        group_label_keys = list(result_name_dict.values())[:len(group_keys)]
        group_labels = dict(zip(group_label_keys, group_keys))

        return (group_labels, result)