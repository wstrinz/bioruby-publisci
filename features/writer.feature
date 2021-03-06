Feature: export to various formats using writers

	In order to use RDF encoded data in other applications
	I want to export domain objects using an PubliSci::Writers object

	Scenario: write to ARFF format
		Given a ARFF writer
		When I call its from_turtle method on the file spec/turtle/bacon
		Then I should receive a .arff file as a string

  Scenario: write to CSV
    Given a CSV writer
    When I call its from_turtle method on the file spec/turtle/bacon
    Then I should receive a .csv file as a string