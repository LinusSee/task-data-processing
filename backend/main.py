import datetime
from flask import Flask

from business_logic.data_processing_program import DataProcessingProgram
from plugins.input.test_data_input_plugin import TestDataInputPlugin as InputPlugin
from plugins.transform.sample_transform_one_plugin import SampleTransformOnePlugin
from plugins.transform.sample_transform_two_plugin import SampleTransformTwoPlugin
from plugins.output.sample_rest_output_plugin import SampleOutputPlugin
from plugins.output.responsibility_group_output_plugin import ResponsibilityGroupOutputPlugin

flask_app = Flask(__name__)






if __name__ == '__main__':
    input_plugin = InputPlugin()
    transform_plugins = [SampleTransformOnePlugin('id_transform_one'), SampleTransformTwoPlugin('id_transform_two')]
    output_plugins = [SampleOutputPlugin('id_transform_two'), ResponsibilityGroupOutputPlugin('id_transform_one')]

    program = DataProcessingProgram(flask_app,
                                    input_data_plugin=input_plugin,
                                    transform_plugins=transform_plugins,
                                    output_plugins=output_plugins)
    program.run()

    flask_app.run()