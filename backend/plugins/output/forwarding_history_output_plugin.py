import models.api_models as ApiModels

from flask import request
import time
from datetime import date
from datetime import timedelta



class ForwardingHistoryOutputPlugin(ApiModels.OutputPlugin):
    def __init__(self, target_id):
        self.target_id = target_id
        self.type = 'PluginWithSetup'

    def setup(self, app):
        app.add_url_rule('/forwarding/<group_key>/history', view_func=self.__forwarding_history_rest_resource)

    def output(self, output_data):
        self.output_data = output_data


    def __forwarding_history_rest_resource(self, group_key):
        ''' For a certain group return the inbound and outbound forwardings for
            each day in a given range.
        '''
        past_days = int(request.args.get('past-days'))

        return self.__get_task_count_for_group(past_days, group_key, self.output_data)
    
    def __get_task_count_for_group(self, past_days, group_key, count_data):
        start_day = max(0, count_data['total_saved_days'] - past_days)
        start_date = date.today() - timedelta(days=past_days)

        counts = count_data['groups'][group_key]['changes'][start_day:]

        forwarding_counts = [ self.__create_count_for_date(start_date, index, count) for index, count in enumerate(counts)]

        return self.__forwarding_counts_to_response(group_key, forwarding_counts)


    def __create_count_for_date(self, start_date, index, count_data):
        target_date = start_date + timedelta(days=index)
        count_date = time.mktime(target_date.timetuple())
        return { 'countDate': count_date, 'inbound': count_data['inbound'], 'outbound': count_data['outbound']}
    

    def __forwarding_counts_to_response(self, group_key, forwarding_counts):
        return { 'countHistory': forwarding_counts
                , 'groupLabel': group_key}