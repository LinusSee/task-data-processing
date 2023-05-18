import models.api_models as ApiModels
from flask import request
from datetime import date



class ForwardingGroupOutputPlugin(ApiModels.OutputPlugin):
    def __init__(self, target_id):
        self.target_id = target_id
        self.type = 'PluginWithSetup'

    def setup(self, app):
        app.add_url_rule('/forwarding/count-by-group', view_func=self.__forwarding_group_count_rest_resource)

    def output(self, output_data):
        self.output_data = output_data

    
    def __forwarding_group_count_rest_resource(self):
        filter_date_string = request.args.get('filter-date')
        filter_date = date.fromisoformat(filter_date_string)

        task_counts = self.__get_task_counts_for_groups(self.output_data, filter_date)
        return_data = self.__task_counts_to_response(task_counts)

        return { 'countPerGroupName': return_data }
    

    def __get_task_counts_for_groups(self, count_data, target_date):
        # TODO: Possible bug for target=start or target < start
        target_days = (target_date - count_data['start_date']).days + 1
        passed_days = min(count_data['total_saved_days'], target_days)
        count_dict = dict.fromkeys(count_data['groups'].keys())

        for (group_key, group_data) in count_data['groups'].items():
            count_dict[group_key] = { 'inbound': 0, 'outbound': 0 }
            inbound_source = list(map(lambda x: x['inbound'], group_data['changes'][:passed_days]))
            outbound_source = list(map(lambda x: x['outbound'], group_data['changes'][:passed_days]))

            count_dict[group_key]['inbound'] = sum(inbound_source)
            count_dict[group_key]['outbound'] = sum(outbound_source)

        return count_dict
    

    def __task_counts_to_response(self, task_counts):
        map_fn = lambda item: {'key': item[0]
                               , 'label': item[0].replace('_', ' ')
                               , 'inboundCount': item[1]['inbound']
                               , 'outboundCount': item[1]['outbound']
                               }

        return_data = list(map(map_fn, list(task_counts.items())))
        return_data.sort(key=lambda x: x['outboundCount'])
        return_data.sort(key=lambda x: x['inboundCount'])

        return return_data