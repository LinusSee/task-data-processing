import datetime
import models.api_models as ApiModels



test_data = [
    #
    # ProzessA AufgabeA
    #
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_A_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_A_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_A_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_A_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    

    #
    # ProzessB AufgabeA
    #
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_B_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),


    #
    # ProzessC AufgabeA
    #
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_C_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_C_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    

    #
    # ProzessD AufgabeA
    #
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_D_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_D_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_D_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_D_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
    ApiModels.ProcessedTask(datetime.datetime(2022, 6, 18, 9, 15),'G_Prozess_D_Aufgabe_A', [])
        .with_end_date(datetime.datetime(2022, 6, 24, 17, 3))
        .with_current_worker('4711'),
]



class TestDataInputPlugin(ApiModels.ReadDataPlugin):
    def data(self) -> list[ApiModels.ProcessedTask]:
        return test_data
    


'''
Für die Testdaten mögliche Gruppenhierarchie

    G_Prozess_A_Aufgabe_A
    G_Prozess_B_Aufgabe_A
    G_Prozess_C_Aufgabe_A
    G_Prozess_D_Aufgabe_A
'''