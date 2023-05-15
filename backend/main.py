from flask import Flask
from flask_cors import CORS

from business_logic.data_processing_program import DataProcessingProgram

#from plugins.input.test_data_input_plugin import TestDataInputPlugin as InputPlugin
from plugins.input.processed_tasks_input_plugin import ProcessedTasksInputPlugin as InputPlugin

from plugins.transform.responsibilities_transform_plugin import ResponsibilitiesTransformPlugin
from plugins.output.processed_task_to_csv_output_plugin import ProcessedTaskToCsvOutputPlugin

from plugins.output.responsibility_group_output_plugin import ResponsibilityGroupOutputPlugin
from plugins.output.responsibility_history_output_plugin import ResponsibilityHistoryOutputPlugin



flask_app = Flask(__name__)
CORS(flask_app)






if __name__ == '__main__':
    input_plugin = InputPlugin()
    transform_plugins = [ ResponsibilitiesTransformPlugin('id_responsibilities')
                        ]
    output_plugins = [ ResponsibilityGroupOutputPlugin('id_responsibilities')
                      , ResponsibilityHistoryOutputPlugin('id_responsibilities')
                      ]

    program = DataProcessingProgram(flask_app,
                                    input_data_plugin=input_plugin,
                                    transform_plugins=transform_plugins,
                                    output_plugins=output_plugins)
    program.run()

    flask_app.run()