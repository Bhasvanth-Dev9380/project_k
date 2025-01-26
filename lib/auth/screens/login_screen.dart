import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../utils/colors.dart';
import '../../utils/institutes.dart';
import 'google_login.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedAccountType = 'Student'; // Default to 'Student'
  bool showInstitutionSelection = false;
  TextEditingController _institutionController = TextEditingController();
  List<String> filteredInstitutes = [];

  void _selectAccountType(String accountType) {
    setState(() {
      selectedAccountType = accountType;
    });
  }

  void _filterInstitutes(String query) {
    setState(() {
      if (query.isNotEmpty) {
        // Convert Map entries to List and filter
        filteredInstitutes = institutes.keys
            .where((institute) => institute.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        filteredInstitutes = [];
      }
    });
  }

  void _onNextPressed() {
    if (showInstitutionSelection && _institutionController.text.isNotEmpty) {
      // Navigate to GoogleLoginScreen with the selected university
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoogleLoginScreen(
            selectedUniversity: _institutionController.text,
          ),
        ),
      );
    } else {
      setState(() {
        showInstitutionSelection = true;
      });
    }
  }

  Widget _getLottieAnimation() {
    switch (selectedAccountType) {
      case 'Student':
        return Lottie.asset('assets/animations/student.json', width: 400, height: 400);
      case 'Instructor':
        return Lottie.asset('assets/animations/educator.json', width: 400, height: 400);
      case 'Parent':
        return Lottie.asset('assets/animations/parent.json', width: 400, height: 400);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      body: SafeArea(
        child: showInstitutionSelection
            ? SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: _getLottieAnimation(),
              ),
              _buildInstitutionSelectionContainer(),
            ],
          ),
        )
            : Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(100),
                  ),
                ),
                child: _buildAccountSelectionContent(),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: _getLottieAnimation(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelectionContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 80),
        Text(
          "Welcome, Choose your account type to login",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        SizedBox(height: 20),
        _buildAccountTypeButton('STUDENT', 'Student'),
        _buildAccountTypeButton('INSTRUCTOR', 'Instructor'),
        _buildAccountTypeButton('PARENT', 'Parent'),
        SizedBox(height: 20),
        _buildNextButton(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInstitutionSelectionContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100),
          ),
        ),
        child: _buildInstitutionSelectionContent(),
      ),
    );
  }

  Widget _buildInstitutionSelectionContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            selectedAccountType,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Choose your institution from the below list to continue",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 20),
          _buildInstitutionInput(),
          SizedBox(height: 20),
          _buildNextButton(),
          SizedBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildInstitutionInput() {
    return Column(
      children: [
        TextField(
          controller: _institutionController,
          onChanged: _filterInstitutes,
          cursorColor: AppColors.brightOrange,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Type your Institution Name',
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 10),
        if (filteredInstitutes.isNotEmpty) // Show list only if there are filtered results
          Container(
            height: MediaQuery.of(context).size.height * 0.3, // Set a fixed height
            child: ListView.builder(
              itemCount: filteredInstitutes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredInstitutes[index], style: TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _institutionController.text = filteredInstitutes[index];
                      filteredInstitutes = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_forward, color: AppColors.brightOrange),
        onPressed: _onNextPressed,
      ),
    );
  }

  Widget _buildAccountTypeButton(String label, String accountType) {
    bool isSelected = selectedAccountType == accountType;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? AppColors.white : AppColors.brightOrange,
          backgroundColor: isSelected ? AppColors.brightOrange : AppColors.white,
          minimumSize: Size(250, 50),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onPressed: () => _selectAccountType(accountType),
        child: Text(label),
      ),
    );
  }
}
