# HealthCareApp

**YourHealthNSDemo** is a simple healthcare application built using swift and SwiftUI.The main idea behind this project is to make it easy for patient to view their laboratory reports and understand the result associated with each reports.

For this assignment I have focused on to main sections: **Home** and **Records**.

The Home screen is intentional kept blank as requested in the assignment. The Records section allows user to browse their available lab reports and view the details of individual report.

# App Flow

1. **Home** A blank screen.
2. **Records** display the available categories. Currently only Lab & Diagnostics is included.
3. **Patient Reports** Selecting Lab & Diagnostics open the available reports such as Complete Blood Count(CBC).
4. **Report Details** Selecting a report opens its details, including the test performer, date and available vitals.

# Feature

1. Simple and clean interface
2. Two tab navigation with Home and Records.
3. Lab & Diagnostic category for browsing patient reports.
4. Individuals report details.
5. FHIR based healthcare data integration.
6. Support for loading, empty and error state.
7. Accessibility support for important UI elements.
8. Mock data support for development and testing.

# Technologies Used

1. swift
2. SwiftUI
3. Swift Concurrency(async/await)
4. Observation Framework
5. XCTest
6. URLSession
7. FHIR R4 json resources

# API Intergation

For fetching laboratory information, I have used following FHIR example.

The application reads the FHIR JSON response and extracts the information required to display patient reports.
The main resources used are:

**DiagnosticReport**

This contains the main laboratory report information, including:

- Report name
- Test performer
- Report date
- Report status
References to related observations

**Obseration**

Each Observation contains an individual test result or vital associated with a diagnostic report.
The application uses the observation references from DiagnosticReport to find and display the corresponding results.
For example, a CBC report can contain readings such as:

- Red Cell Count
- Hemoglobin
- White Blood Cell Count
The values, units and reference ranges are displayed on the report details screen whenever they are available in the response.

The data models are based on the FHIR R4 structure.

# Project Structure
**HealthCareApp**/
 **App**/
	 HealthCareApp.swift
	 AppContainer.swift
	 ContentView.swift
**Core**/
	**DesignSystem**/
		 AppTheme.swift
		 View+NavigationStyle.swift
	 **Networking**/
		 APIClient.swift
		 APIError.swift
	**FHIR**/
		 FHIRDecoder.swift
		 FHIRRecordMapper.swift
		 FHIRModels.swift
 **Data**/
	  RemoteRecordsRepository.swift
	  MockRecordsRepository.swift
**Domain**/
	**Models**/
		PatientRecord
		RecordCategory
	  Repositories/
		RecordsRepository
	**UseCases**/
		FetchRecordsUseCase
**Features**/
	 **Home**/
		HomeView
	**Records**/
		RecordsHomeView.swift
		PatientReportsListView.swift
		RecordDetailView.swift
		RecordsViewModel.swift
		**Components**/
			RecordCategoryCardView
 Tests/
 README.md

# Design and Accesssibility
I have created a small design system to maintain a consistent look throughout the application.
The theme includes shared colours and Fonts.

Accessibility has also been considered while building the screens. Important elements have accessibility labels and identifiers where needed, so that users can understand and interact with the application more easily.

# Unit Testing

I have added unit tests for the main parts of the application.

The tests currently cover:

- FHIR record mapping.
- FHIR JSON decoding.
- API requests and error handling.
- RecordsViewModel loading and filtering.
- FetchRecordsUseCase.
- MockRecordsRepository.
The unit tests are written using XCTest.

To run all unit tests, open the project in Xcode and press:

**Command + U**

The current test run passes, with approximately 75% code coverage.
UI tests are not included in the current milestone and can be added later.

# Running the Project

- Clone or download the project.
- Open YourHealthNSDemo.xcodeproj in Xcode.
- Select the YourHealthNSDemo scheme.
- Choose an iOS simulator or connected device.
- Press Command + R to build and run the application.
  
An active internet connection is required to fetch the live FHIR example data.

# Future Improvements

There are a few things I would like to add as the application grows:

- Additional healthcare record categories.
- More detailed patient information.
- UI automation tests.
- Better handling of different FHIR resource types.
- Additional accessibility improvements.

# Assumptions
While developing this application, I have made a few assumptions to keep the implementation focused on the requirements of the assignment.

1. User Authentication: The application assumes that the user is already logged in. Login, registration and logout functionality are outside the scope of this assignment.
2. Internet Connection: An active internet connection is expected when fetching laboratory reports from the FHIR API. If the network is unavailable, the application should display an appropriate error message.
3. Patient Information: The FHIR example response is treated as the available source of patient report information. A separate patient selection or patient registration flow is not included.
4. FHIR Version: The application models are designed around the FHIR R4 specification.
5. Report Availability: The application assumes that DiagnosticReport resources are available in the API response. If no reports are returned, an empty state should be displayed.
6. Observation References: Each Observation is expected to be referenced by its ID from the corresponding DiagnosticReport. Only observations that can be matched to a report are displayed under that report.
7. Report Categories: For the current assignment, only Lab & Diagnostics is implemented. Other categories, such as Appointments, are considered future enhancements.
8. Dashboard: The Home screen is intentionally blank, as specified in the assignment requirements.
9. Mock Data: Mock records are used during development and unit testing so that the application can be tested without depending on the availability of the remote API.

# Screenshots
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-10-31 at 17 25 07" src="https://github.com/user-attachments/assets/18583a86-8cb1-4f16-9544-054417659b26" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-10-31 at 17 25 24" src="https://github.com/user-attachments/assets/b6d9abfc-d7a7-4353-8f47-02e2a05970f8" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-10-31 at 17 25 19" src="https://github.com/user-attachments/assets/bd579346-1142-4b50-8a93-1636f0718522" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-10-31 at 17 25 15" src="https://github.com/user-attachments/assets/5a06fa96-f9ad-42a7-be77-9dbfced4a81b" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-10-31 at 17 25 11" src="https://github.com/user-attachments/assets/1c56c470-8fa5-4ac2-a5c0-71b96f30d2b0" />



























