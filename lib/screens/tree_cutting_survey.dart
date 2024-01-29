import 'package:flutter/material.dart';

class TreeCuttingSurveyWidget extends StatefulWidget {
  @override
  _TreeCuttingSurveyWidgetState createState() =>
      _TreeCuttingSurveyWidgetState();
}

class _TreeCuttingSurveyWidgetState extends State<TreeCuttingSurveyWidget> {
  TextEditingController betweenTowersController = TextEditingController();
  TextEditingController surveyNumberController = TextEditingController();
  TextEditingController villageController = TextEditingController();
  TextEditingController talukController = TextEditingController();
  TextEditingController slNoController = TextEditingController();
  TextEditingController ksebController = TextEditingController();
  TextEditingController nameOfTreesController = TextEditingController();
  TextEditingController presentAgeController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController girthController = TextEditingController();
  TextEditingController yieldingController = TextEditingController();
  TextEditingController futureAgeController = TextEditingController();
  TextEditingController grossYieldController = TextEditingController();
  TextEditingController netReturnController = TextEditingController();
  TextEditingController averageNetReturnController = TextEditingController();
  TextEditingController presentWorthController = TextEditingController();
  TextEditingController compensationAssessedController =
      TextEditingController();
  TextEditingController interestedPersonsController = TextEditingController();
  TextEditingController amountApportionedController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tree Cutting Survey'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: betweenTowersController,
              decoration: InputDecoration(labelText: 'Between Towers'),
            ),
            TextFormField(
              controller: surveyNumberController,
              decoration: InputDecoration(labelText: 'Survey Number'),
            ),
            TextFormField(
              controller: villageController,
              decoration: InputDecoration(labelText: 'Village'),
            ),
            TextFormField(
              controller: talukController,
              decoration: InputDecoration(labelText: 'Taluk'),
            ),
            TextFormField(
              controller: slNoController,
              decoration: InputDecoration(labelText: 'Sl. No. given by KSEB'),
            ),
            TextFormField(
              controller: ksebController,
              decoration: InputDecoration(labelText: 'Name of KSEB'),
            ),
            TextFormField(
              controller: nameOfTreesController,
              decoration: InputDecoration(labelText: 'Name of Trees'),
            ),
            TextFormField(
              controller: presentAgeController,
              decoration: InputDecoration(labelText: 'Present Age'),
            ),
            TextFormField(
              controller: heightController,
              decoration: InputDecoration(labelText: 'Height'),
            ),
            TextFormField(
              controller: girthController,
              decoration: InputDecoration(labelText: 'Girth'),
            ),
            TextFormField(
              controller: yieldingController,
              decoration: InputDecoration(labelText: 'Yielding or Not'),
            ),
            TextFormField(
              controller: futureAgeController,
              decoration: InputDecoration(labelText: 'Future Age'),
            ),
            TextFormField(
              controller: grossYieldController,
              decoration: InputDecoration(
                  labelText: 'Approximate Gross Yield per Annum'),
            ),
            TextFormField(
              controller: netReturnController,
              decoration: InputDecoration(labelText: 'Net Return per Annum'),
            ),
            TextFormField(
              controller: averageNetReturnController,
              decoration: InputDecoration(
                  labelText: 'Average Net Return per Annum Future Years'),
            ),
            TextFormField(
              controller: presentWorthController,
              decoration:
                  InputDecoration(labelText: 'Present Worth for A Years'),
            ),
            TextFormField(
              controller: compensationAssessedController,
              decoration:
                  InputDecoration(labelText: 'Compensation Assessed (BXC)'),
            ),
            TextFormField(
              controller: interestedPersonsController,
              decoration: InputDecoration(
                  labelText:
                      'Name of Interested Persons with Nature of Interest'),
            ),
            TextFormField(
              controller: amountApportionedController,
              decoration: InputDecoration(
                  labelText: 'Amount Apportioned or Offered to Each'),
            ),
            TextFormField(
              controller: remarksController,
              decoration: InputDecoration(labelText: 'Remarks'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Create a TreeCuttingSurvey object and populate it with the captured data
                TreeCuttingSurvey survey = TreeCuttingSurvey(
                  betweenTowers: betweenTowersController.text,
                  surveyNumber: surveyNumberController.text,
                  village: villageController.text,
                  taluk: talukController.text,
                  slNo: int.parse(slNoController.text),
                  kseb: ksebController.text,
                  nameOfTrees: nameOfTreesController.text,
                  presentAge: int.parse(presentAgeController.text),
                  height: double.parse(heightController.text),
                  girth: double.parse(girthController.text),
                  isYielding: yieldingController.text.toLowerCase() == 'yes',
                  futureAge: int.parse(futureAgeController.text),
                  approximateGrossYieldPerAnnum:
                      double.parse(grossYieldController.text),
                  netReturnPerAnnum: double.parse(netReturnController.text),
                  averageNetReturnPerAnnumFutureYears:
                      double.parse(averageNetReturnController.text),
                  presentWorthForAYears:
                      double.parse(presentWorthController.text),
                  compensationAssessed: compensationAssessedController.text,
                  interestedPersons: interestedPersonsController.text,
                  amountApportioned: amountApportionedController.text,
                  remarks: remarksController.text,
                );

                // Process the captured survey data as needed
                _processTreeCuttingSurvey(survey);

                // Clear the text fields
                _clearTextFields();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _processTreeCuttingSurvey(TreeCuttingSurvey survey) {
    // Process the captured tree cutting survey data here
    debugPrint('Tree Cutting Survey Data:');
    debugPrint('Between Towers: ${survey.betweenTowers}');
    debugPrint('Survey Number: ${survey.surveyNumber}');
    debugPrint('Village: ${survey.village}');
    // ... debugPrint other survey data properties or perform any desired operations
  }

  void _clearTextFields() {
    // Clear the text fields after submission
    betweenTowersController.clear();
    surveyNumberController.clear();
    villageController.clear();
    talukController.clear();
    slNoController.clear();
    ksebController.clear();
    nameOfTreesController.clear();
    presentAgeController.clear();
    heightController.clear();
    girthController.clear();
    yieldingController.clear();
    futureAgeController.clear();
    grossYieldController.clear();
    netReturnController.clear();
    averageNetReturnController.clear();
    presentWorthController.clear();
    compensationAssessedController.clear();
    interestedPersonsController.clear();
    amountApportionedController.clear();
    remarksController.clear();
  }
}

class TreeCuttingSurvey {
  final String betweenTowers;
  final String surveyNumber;
  final String village;
  final String taluk;
  final int slNo;
  final String kseb;
  final String nameOfTrees;
  final int presentAge;
  final double height;
  final double girth;
  final bool isYielding;
  final int futureAge;
  final double approximateGrossYieldPerAnnum;
  final double netReturnPerAnnum;
  final double averageNetReturnPerAnnumFutureYears;
  final double presentWorthForAYears;
  final String compensationAssessed;
  final String interestedPersons;
  final String amountApportioned;
  final String remarks;

  TreeCuttingSurvey({
    required this.betweenTowers,
    required this.surveyNumber,
    required this.village,
    required this.taluk,
    required this.slNo,
    required this.kseb,
    required this.nameOfTrees,
    required this.presentAge,
    required this.height,
    required this.girth,
    required this.isYielding,
    required this.futureAge,
    required this.approximateGrossYieldPerAnnum,
    required this.netReturnPerAnnum,
    required this.averageNetReturnPerAnnumFutureYears,
    required this.presentWorthForAYears,
    required this.compensationAssessed,
    required this.interestedPersons,
    required this.amountApportioned,
    required this.remarks,
  });
}
