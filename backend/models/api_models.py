import datetime

class ProcessedTask:
    '''BusinessModel of a task that has been processed from some input data.
        This is the base model for all transformations that result in a userviewable output.
    '''
    creation_date: datetime.datetime
    end_date: datetime.datetime

    def __str__(self):
        return 'Created at {self.creation_date} and finished at {self.end_date}'.format(self=self)


class ReadDataPlugin:
    '''Reads input data and maps it to the business model specified by the main application.
    '''
    
    def data(self) -> list[ProcessedTask]:
        pass


class TransformPlugin:
    '''Transforms the business model and publishes it via some ID
    '''

    def transform(self, data: list[ProcessedTask]):
        pass


class OutputPlugin:
    '''Takes transformed data and outputs it.
       It find the data via a shared ID between transform and output layer
    '''

    def output(self):
        pass