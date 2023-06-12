import datetime


class ProcessingStatus:
    status_name: str
    creation_date: datetime.datetime
    responsible_group: str
    responsible_worker: str #| None
    current_worker: str #| None


class ProcessedTask:
    '''BusinessModel of a task that has been processed from some input data.
        This is the base model for all transformations that result in a userviewable output.
    '''
    creation_date: datetime.datetime
    end_date: datetime.datetime #| None

    responsible_group: str
    responsible_worker: str #| None
    current_worker: str #| None

    # Gruppen können sich im Laufe der Zeit ändern
    # Einzelzuständiger vermutlich auch
    processing_status: list[(datetime.datetime, ProcessingStatus)]



    def __init__(self, creation_date, responsible_group, processing_status):
        self.creation_date = creation_date
        self.responsible_group = responsible_group
        self.processing_status = processing_status
        
        self.end_date = None
        self.responsible_worker = None
        self.current_worker = None


    def with_end_date(self, end_date):
        self.end_date = end_date
        return self
    
    def with_responsible_worker(self, responsible_worker):
        self.responsible_worker = responsible_worker
        return self
    
    def with_current_worker(self, current_worker):
        self.current_worker = current_worker
        return self


    def __str__(self):
        #return 'Created at {self.creation_date} and finished at {self.end_date}'.format(self=self)
        return f'Created at {self.creation_date} having group {self.responsible_group}'
        #return f'Task with group: {self.responsible_group}'
    





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