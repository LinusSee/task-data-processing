import models.api_models as ApiModels

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
        app.add_url_rule('/responsibility-groups/count', view_func=self.__rest_resource)

    def output(self, output_data):
        print('Output: ', output_data)
        self.output_data = output_data

    def __rest_resource(self):
        print('Url is: ', request.query_string)
        filter_date_string = request.args.get('filter-date')
        print(f'Filter date string is: {filter_date_string}')
        filter_date = date.fromisoformat(filter_date_string)
        print(f'Filter date is: {filter_date_string}')


        # counts = self.output_data
        # counts.sort(key=lambda x: x['count'])

        ###
        my_return = self.__aggregate_data(self.output_data, filter_date)
        return_data = []
        for item in my_return.items():
            return_data.append({'key': item[0], 'label': item[0].replace('_', ' '), 'count': item[1]})
        return_data.sort(key=lambda x: x['count'])
        ###
        #return { 'countPerGroupName': self.output_data }
        return { 'countPerGroupName': return_data }
    

    def __aggregate_data(self, count_data, target_date):
        # TODO: Possible bug for target=start or target < start
        target_days = (target_date - count_data['start_date']).days + 1
        passed_days = min(count_data['total_saved_days'], target_days)
        count_dict = dict.fromkeys(count_data['groups'].keys(), 0)
        print(f'TargetDays {target_days}')
        print(f'PassedDays {passed_days}')
        for (group_key, group_data) in count_data['groups'].items():
            # for change in group_data['changes']:
            #     count_dict[group_key] += change
            count_dict[group_key] = sum(group_data['changes'][:passed_days])

        return count_dict


    '''
    Format je task:
        [(date, group)]
    '''