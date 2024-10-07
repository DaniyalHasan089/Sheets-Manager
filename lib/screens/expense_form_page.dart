import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // For file picker
import '../services/clickup_service.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

// Class to represent an expense entry
class ExpenseEntry {
  final String expense;
  final String cost;
  final String quantity;
  final String? vendor;
  final String expenseType;
  final String date;
  final String? reimbursed;
  final String? receiptFilePath;

  ExpenseEntry({
    required this.expense,
    required this.cost,
    required this.quantity,
    this.vendor,
    required this.expenseType,
    required this.date,
    this.reimbursed,
    this.receiptFilePath,
  });
}

class ExpenseFormPage extends StatefulWidget {
  final List<ExpenseEntry> expenseEntries;

  const ExpenseFormPage({super.key, required this.expenseEntries});

  @override
  _ExpenseFormPageState createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  String? selectedAccountId;
  String? selectedVendorId;
  DateTime? selectedDate; // Declare selectedDate as a nullable variable
  TextEditingController dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Controllers for TextFields
  TextEditingController expenseController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController reimbursedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Set a default value for selectedDate
  }

  // Dropdown values for Vendor and Expense Type
  String? selectedVendor;
  String? selectedAccountTitle;

  // File picked path
  String? receiptFilePath;

  // Dropdown options
  // Map for vendor IDs (UUIDs) from ClickUp
  Map<String, String> vendors = {
    'General Electronics': '3d32679a-1ce7-4f1a-bd2e-79bf7356bf5e',
    'Etech': '99cd78b3-5bb6-4e9b-9a66-16abe32cbff8',
  };

  final Map<String, String> accountTitles = {
    'Cash in Hand': '8ec0a5d6-bcfb-4828-a889-546c7c14cb21',
    'Cash in Bank': '301a746e-517e-4299-926e-e2d42fe70fc5',
    'Acc. Receivable': 'e5eda836-18c6-4202-8a91-1390093dfd48',
    'Notes Receivable': 'd770a29a-4b30-492e-9d5b-efd9194cd6d1',
    'Material and Parts': '6073883e-a7e1-40ab-be13-74a6805fcd49',
    'Prepaid Expenses': '6b9dca7f-54dc-41ce-9266-534dd7370573',
    'Office Supplies': 'cc9d696e-1e70-47f2-a186-2788790358c4',
    'Furniture and Fixtures': '604d0450-80dd-4758-b4ea-bdd5677bd58a',
    'Acc. Payable': '845464be-a47d-4dc9-a504-23f2d222c5f8',
    'Notes Payable': 'a0287dea-86dd-4620-ab4d-c9a6b525bab8',
    'Vendor Payment': '686af5e7-8bd2-4da2-ad73-8e246e897397',
    'Due to Employees': 'dac8de5d-3dc0-4fca-b2f4-242493ad041e',
    'Loans Payable': '06f55fc6-fa8b-4fcf-a2d0-f2ce1ab2b8ad',
    'Unearned Revenue': 'c89688bb-a8e7-45ee-8667-6b4ba6a1ddbe',
    'Common Stock': '574525cc-9a5e-4a71-b2a6-16f417e27fb9',
    'Preferred Stock': '9655e86f-049e-4bdd-9230-a9b93b3195fc',
    'Retained Earnings': 'f3569805-dc55-4372-a449-d8bdb8b27237',
    'Dividends': '38e07094-848f-444b-8fbe-f730657e9c66',
    'ESOPs': 'f6040cce-d487-45d5-90cb-dff0a9cd93b2',
    'Cash Sales': 'ebb4effc-7cb8-4540-a8fb-dbf472dc09ff',
    'Credit Sales': '9f206617-746e-4da2-bd8d-ab5255be827a',
    'Installation Revenue': 'bc701b43-9a88-4ec0-9289-2f2e5479c9d4',
    'Support Revenue': 'd51b3166-63f4-4ccc-b213-cf384ffc0e3f',
    'Other Income': '7064c6f8-9e03-4ada-9648-4bd4986d2756',
    'C.O.G.S': '10f40c0a-652c-43ba-8d53-50d6d17e6996',
    'Utility Expense': '0c7a2dfe-53a1-4177-9e06-a0ae2b0e0065',
    'Salaries and Wages': '331de75a-ed06-4385-bad2-7894f2098f79',
    'Transport Expense': '05b9eaaa-e0d0-4eb0-969c-129c33da75eb',
    'Marketing Expense': '1863690b-4e89-4cea-b850-b3fd55cdf186',
    'Depreciation Expense': 'd53a0a4a-cb83-459d-b099-ddf1e433e9e2',
    'Rent Expense': '58e84402-e0a6-4b48-8143-ae5291b4251f',
    'Maintenance Expense': '9af5ba14-cef7-425b-9d3d-c18016720c9c',
    'Travel Expense': '98201a0e-d21c-4eee-af03-a13343674241',
    'Income Tax Expense': '545148d6-06cb-4ac2-b344-0ff0b003fb33',
    'Consultancy Expense': 'a8dd824a-3b27-415b-a834-ba94dd972626',
    'Food and Drinks Expense': 'ef96cd27-2b9b-4692-a9e0-aec903a43b54',
    'Printing Expense': 'aae953b0-9bca-4b93-8f28-3a5434bff5c9',
    'Project Expense': '032b5a0f-3655-4fd0-8d37-020fe0e8dca1',
    'Owner\'s Equity': '4b12f4b3-02c7-438c-b6df-2154323dbccd',
    'Office Supplies Expense': '7cec77c2-b946-453c-be3c-2906374bdf96',
    'Repair and Maintenance Expense': '132595f8-8d84-4cfa-acfa-b0be162a86c0',
    'Devices and Equipment': '5d281a88-fcc7-48ed-9749-15cfa48bf8e7',
    'Miscellaneous Expenses': 'c9d16df0-4249-43e3-8cea-1b93e7bf33fd',
    'Employee Devices': '30f9b349-5212-47b5-adf8-06642eca4532',
    'Company Wear': 'd99fb2c0-35c4-4fb6-8ecd-d4a04ca49921',
    'Taxes and Duties': 'd8bec324-be42-452b-a8fd-220543137423',
    'Courier Expense': 'bbadff0e-6790-4d97-af07-67e9c0130083',
    'Operations Expense': '0c4805c1-1cad-48d2-93e6-9aa1dfaadb4a',
    'HR Medical': 'ae0c9b83-423c-4d87-8693-ed2a451f6964',
    'Daily Consumeables': '0962773a-9e00-4974-b65f-c8f931b28d82',
    'Challan Expenses': 'e8dc18b4-21a9-4fbc-876c-5df96e6bb10b',
  };

  // Function to pick a file
  Future<void> pickReceiptFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        receiptFilePath = result.files.single.path;
        print("Selected file path: $receiptFilePath");
      });
    }
  }

  Future<void> uploadToClickUp() async {
    try {
      if (receiptFilePath != null) {
        Dio dio = Dio();

        FormData formData = FormData.fromMap({
          "attachment": await MultipartFile.fromFile(
              receiptFilePath!), // Upload the selected file
        });

        var response = await dio.post(
          'https://api.clickup.com/api/v2/task/<task_id>/attachment',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'pk_49258133_AZ1ELD12YO9ONP5A4XKRN1ZP4GSRU8JJ',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        if (response.statusCode == 200) {
          print("File uploaded successfully");
        } else {
          print("File upload failed: ${response.statusCode}");
        }
      } else {
        print("No file selected");
      }
    } catch (e) {
      print("Error during file upload: $e");
    }
  }

  // Function to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;

        // Format the selected date for display in the TextField
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        dateController.text = formattedDate; // Update the TextField

        if (selectedDate == null) {
          print("Selected date is null!");
          return;
        }
      });
    }
  }

  // Function to show the "Data saved" popup
  void _showDataSavedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Data saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to save form data and navigate to console
  void _saveFormData() {
    if (_formKey.currentState!.validate()) {
      // Create a new ExpenseEntry object and add it to the list
      widget.expenseEntries.add(
        ExpenseEntry(
          expense: expenseController.text,
          cost: costController.text,
          quantity: quantityController.text,
          vendor: selectedVendor,
          expenseType: selectedAccountTitle!,
          date: dateController.text,
          reimbursed: reimbursedController.text.isEmpty
              ? null
              : reimbursedController.text,
          receiptFilePath: receiptFilePath,
        ),
      );

      // Show the success popup
      _showDataSavedDialog();

      // Clear the form after saving
      _formKey.currentState!.reset();
      setState(() {
        selectedVendor = null;
        selectedAccountTitle = null;
        receiptFilePath = null;
      });
    }
  }

  Future<void> createTask() async {
    if (_formKey.currentState!.validate()) {
      // Ensure that 'expense' (the task name) is not null or empty
      //String? expense = expenseController.text;
      /*if (expense == null || expense.isEmpty) {
        print("Expense (Task Name) is required.");
        return; // Exit if the task name is null or empty
      }*/

      // Create a new ExpenseEntry object
      ExpenseEntry newEntry = ExpenseEntry(
        expense: expenseController.text, // Task Name
        cost: costController.text,
        quantity: quantityController.text,
        vendor: selectedVendor, // Nullable
        expenseType: selectedAccountTitle ?? "Default Expense Type",
        date: dateController.text,
        reimbursed: reimbursedController.text.isEmpty
            ? null
            : reimbursedController.text,
        receiptFilePath: receiptFilePath,
      );

      // Format the selected date in ISO 8601 format
      String formattedDate =
          DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").format(selectedDate!);

      print(formattedDate);

      // Simplified payload for ClickUp
      Map<String, dynamic> payload = {
        "name": newEntry.expense,
        "status": "TO DO",
        "check_required_custom_fields": true,
        "custom_fields": [
          {
            "id": "42bfb728-3d37-4447-a044-54b9089a0f38", // Currency field ID
            "value": newEntry.cost // Ensure the value is double
          },
          {
            "id": "f3f3280e-8d35-49d8-8250-2a2cdb514694", // Quantity field ID
            "value": newEntry.quantity // Ensure the value is an integer
          },
          {
            "id": "ea901cea-de40-4859-9941-70f1d2da0a64", // Date field ID
            "value": (selectedDate!.millisecondsSinceEpoch)
                .round() // Ensure the date is in ISO format
          },
          {
            "id": "7a6c996d-fd4d-4267-8e8a-f73d9faf9efd",
            "value": newEntry.receiptFilePath
          },
          {
            "id": "1840c6d3-993d-4a54-a158-3a1b5d0f6ea2",
            "value": newEntry.reimbursed,
          },
          {
            "id": "50268e2b-5cb8-4126-86de-8c873f93ff16",
            "value": selectedVendorId,
            "type": "drop_down",
            "type_config": {
              "options": [
                {
                  "id": "3d32679a-1ce7-4f1a-bd2e-79bf7356bf5e",
                },
                {
                  "id": "99cd78b3-5bb6-4e9b-9a66-16abe32cbff8",
                }
              ]
            },
            "date_created": "1721074589440",
            "hide_from_guests": false,
            "required": false
          },
          {
            "id": "ab7384b8-0645-4948-a3cd-21ad80f64c4a",
            "value": selectedAccountTitle,
            "type": "drop_down",
            "type_config": {
              "sorting": "manual",
              "new_drop_down": true,
              "options": [
                {
                  "id": "8ec0a5d6-bcfb-4828-a889-546c7c14cb21",
                },
                {
                  "id": "301a746e-517e-4299-926e-e2d42fe70fc5",
                },
                {
                  "id": "e5eda836-18c6-4202-8a91-1390093dfd48",
                },
                {
                  "id": "d770a29a-4b30-492e-9d5b-efd9194cd6d1",
                },
                {
                  "id": "6073883e-a7e1-40ab-be13-74a6805fcd49",
                },
                {
                  "id": "6b9dca7f-54dc-41ce-9266-534dd7370573",
                },
                {
                  "id": "cc9d696e-1e70-47f2-a186-2788790358c4",
                },
                {
                  "id": "604d0450-80dd-4758-b4ea-bdd5677bd58a",
                },
                {
                  "id": "845464be-a47d-4dc9-a504-23f2d222c5f8",
                },
                {
                  "id": "a0287dea-86dd-4620-ab4d-c9a6b525bab8",
                },
                {
                  "id": "686af5e7-8bd2-4da2-ad73-8e246e897397",
                },
                {
                  "id": "dac8de5d-3dc0-4fca-b2f4-242493ad041e",
                },
                {
                  "id": "06f55fc6-fa8b-4fcf-a2d0-f2ce1ab2b8ad",
                },
                {
                  "id": "c89688bb-a8e7-45ee-8667-6b4ba6a1ddbe",
                },
                {
                  "id": "574525cc-9a5e-4a71-b2a6-16f417e27fb9",
                },
                {
                  "id": "9655e86f-049e-4bdd-9230-a9b93b3195fc",
                },
                {
                  "id": "f3569805-dc55-4372-a449-d8bdb8b27237",
                },
                {
                  "id": "38e07094-848f-444b-8fbe-f730657e9c66",
                },
                {
                  "id": "f6040cce-d487-45d5-90cb-dff0a9cd93b2",
                },
                {
                  "id": "ebb4effc-7cb8-4540-a8fb-dbf472dc09ff",
                },
                {
                  "id": "9f206617-746e-4da2-bd8d-ab5255be827a",
                },
                {
                  "id": "bc701b43-9a88-4ec0-9289-2f2e5479c9d4",
                },
                {
                  "id": "d51b3166-63f4-4ccc-b213-cf384ffc0e3f",
                },
                {
                  "id": "7064c6f8-9e03-4ada-9648-4bd4986d2756",
                },
                {
                  "id": "10f40c0a-652c-43ba-8d53-50d6d17e6996",
                },
                {
                  "id": "0c7a2dfe-53a1-4177-9e06-a0ae2b0e0065",
                },
                {
                  "id": "331de75a-ed06-4385-bad2-7894f2098f79",
                },
                {
                  "id": "05b9eaaa-e0d0-4eb0-969c-129c33da75eb",
                },
                {
                  "id": "1863690b-4e89-4cea-b850-b3fd55cdf186",
                },
                {
                  "id": "d53a0a4a-cb83-459d-b099-ddf1e433e9e2",
                },
                {
                  "id": "58e84402-e0a6-4b48-8143-ae5291b4251f",
                },
                {
                  "id": "9af5ba14-cef7-425b-9d3d-c18016720c9c",
                },
                {
                  "id": "98201a0e-d21c-4eee-af03-a13343674241",
                },
                {
                  "id": "545148d6-06cb-4ac2-b344-0ff0b003fb33",
                },
                {
                  "id": "a8dd824a-3b27-415b-a834-ba94dd972626",
                },
                {
                  "id": "ef96cd27-2b9b-4692-a9e0-aec903a43b54",
                },
                {
                  "id": "aae953b0-9bca-4b93-8f28-3a5434bff5c9",
                },
                {
                  "id": "032b5a0f-3655-4fd0-8d37-020fe0e8dca1",
                },
                {
                  "id": "4b12f4b3-02c7-438c-b6df-2154323dbccd",
                },
                {
                  "id": "7cec77c2-b946-453c-be3c-2906374bdf96",
                },
                {
                  "id": "132595f8-8d84-4cfa-acfa-b0be162a86c0",
                },
                {
                  "id": "5d281a88-fcc7-48ed-9749-15cfa48bf8e7",
                },
                {
                  "id": "c9d16df0-4249-43e3-8cea-1b93e7bf33fd",
                },
                {
                  "id": "30f9b349-5212-47b5-adf8-06642eca4532",
                },
                {
                  "id": "d99fb2c0-35c4-4fb6-8ecd-d4a04ca49921",
                },
                {
                  "id": "d8bec324-be42-452b-a8fd-220543137423",
                },
                {
                  "id": "bbadff0e-6790-4d97-af07-67e9c0130083",
                },
                {
                  "id": "0c4805c1-1cad-48d2-93e6-9aa1dfaadb4a",
                },
                {
                  "id": "ae0c9b83-423c-4d87-8693-ed2a451f6964",
                },
                {
                  "id": "0962773a-9e00-4974-b65f-c8f931b28d82",
                },
                {
                  "id": "e8dc18b4-21a9-4fbc-876c-5df96e6bb10b",
                }
              ]
            },
            "date_created": "1721032325250",
            "hide_from_guests": false,
            "required": false
          },
        ]
      };

      // Call ClickUp API to create the task
      ClickUpService clickUpService = ClickUpService();
      bool success = await clickUpService.createTask(payload);

      if (success) {
        // Show a success message
        _showDataSavedDialog();
      } else {
        // Handle failure, e.g., log an error or show a message to the user
        print('Failed to create task in ClickUp');
      }

      // Clear the form after saving
      _formKey.currentState!.reset();
      setState(() {
        selectedVendor = null;
        selectedAccountTitle = null;
        receiptFilePath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Expense field
                TextFormField(
                  controller: expenseController,
                  decoration: const InputDecoration(labelText: 'Expense'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the expense';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Cost field
                TextFormField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cost'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the cost';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quantity field
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Vendor dropdown
                DropdownButtonFormField<String>(
                  value: selectedVendorId, // Can be null
                  decoration: const InputDecoration(labelText: 'Vendor'),
                  items: vendors.entries.map<DropdownMenuItem<String>>(
                      (MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value, // The UUID is stored as the value
                      child: Text(entry.key), // Display the vendor name
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedVendorId =
                          newValue; // Store the selected UUID (nullable)
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Expense Type dropdown
                DropdownButtonFormField<String>(
                  value:
                      selectedAccountTitle, // Variable to store selected UUID
                  decoration: const InputDecoration(labelText: 'Account Title'),
                  items: accountTitles.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value, // UUID
                      child: Text(entry.key), // Account title name
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAccountTitle = value; // Store the selected UUID
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Date picker field (Compulsory)
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: "Select Date",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context), // Call date picker
                    ),
                  ),
                  readOnly:
                      true, // Make it read-only so user can only pick a date using the calendar
                ),
                const SizedBox(height: 16),

                // Payment Details
                TextFormField(
                  controller: reimbursedController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(labelText: 'Details'),
                ),
                const SizedBox(height: 16),

                // Upload receipt file picker (Optional)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: pickReceiptFile,
                      child: const Text('Upload Receipt'),
                    ),
                    const SizedBox(width: 16),
                    receiptFilePath != null
                        ? Text(
                            'File: ${receiptFilePath!.split('/').last}',
                            overflow: TextOverflow.ellipsis,
                          )
                        : const Text('No file selected'),
                  ],
                ),
                const SizedBox(height: 16),

                // Submit button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await uploadToClickUp();
                      createTask(); // Call the createTask method when the button is pressed
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
