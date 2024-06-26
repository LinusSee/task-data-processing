from flask import Flask
from flask_cors import CORS

from src.business_logic.data_processing_program import DataProcessingProgram

#from src.plugins.input.test_data_input_plugin import TestDataInputPlugin as InputPlugin
from src.plugins.input.processed_tasks_input_plugin import ProcessedTasksInputPlugin as InputPlugin

from src.plugins.transform.responsibilities_transform_plugin import ResponsibilitiesTransformPlugin
from src.plugins.transform.forwarding_transform_plugin import ForwardingTransformPlugin
from src.plugins.output.processed_task_to_csv_output_plugin import ProcessedTaskToCsvOutputPlugin

from src.plugins.output.responsibility_group_output_plugin import ResponsibilityGroupOutputPlugin
from src.plugins.output.responsibility_history_output_plugin import ResponsibilityHistoryOutputPlugin
from src.plugins.output.forwarding_group_output_plugin import ForwardingGroupOutputPlugin
from src.plugins.output.forwarding_history_output_plugin import ForwardingHistoryOutputPlugin



flask_app = Flask(__name__)
CORS(flask_app)






if __name__ == '__main__':
    input_plugin = InputPlugin()
    transform_plugins = [ ResponsibilitiesTransformPlugin('id_responsibilities')
                         , ForwardingTransformPlugin('id_forwarding')
                        ]
    output_plugins = [ ResponsibilityGroupOutputPlugin('id_responsibilities')
                      , ResponsibilityHistoryOutputPlugin('id_responsibilities')
                      , ForwardingGroupOutputPlugin('id_forwarding')
                      , ForwardingHistoryOutputPlugin('id_forwarding')
                      ]

    program = DataProcessingProgram(flask_app,
                                    input_data_plugin=input_plugin,
                                    transform_plugins=transform_plugins,
                                    output_plugins=output_plugins)
    program.run()

    flask_app.run()