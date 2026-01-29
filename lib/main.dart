import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'scripture.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final viewModel = ScriptureViewModel(ScriptureModel());
    return MaterialApp(
      home: ScriptureView(),
    );
  }
}

class ScriptureModel {


  Future<Scripture> getScriptureOfTheDay() async {
    await dotenv.load(fileName:".env");
    String token = dotenv.env['X-YVP-App-Key'] ?? '';

      Scripture? scripture;

        scripture = await getPassageId();

        String passageid = '${scripture.passageid}';
        String bibleid = '206';

        final newuri = Uri.https(
          'api.youversion.com',
          '/v1/bibles/$bibleid/passages/$passageid',
        );
        
        final newresponse = await get(
          newuri,
          headers: {
            'X-YVP-App-Key': token,
            'Content-Type': 'application/json',
            },
          );

      if (newresponse.statusCode != 200) {
        throw HttpException('Failed to update resource');
      }
      

      return Scripture.fromJson(jsonDecode(newresponse.body));
    }


    Future<Scripture> getPassageId() async {
    await dotenv.load(fileName:".env");
    String token = dotenv.env['X-YVP-App-Key'] ?? '';


    final day = "${Random().nextInt(365)}";
    final uri = Uri.https(
      'api.youversion.com',
      '/v1/verse_of_the_days/$day',
    );
    
    final response = await get(
      uri,
      headers: {
        'X-YVP-App-Key': token,
        'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw HttpException('Failed to update resource');
      }

      return Scripture.fromJson(jsonDecode(response.body));
    }

}


class ScriptureViewModel extends ChangeNotifier {
  final ScriptureModel model;
  Scripture? scripture;
  String? errorMessage;
  bool loading = false;

  ScriptureViewModel(this.model) {
    getScriptureOfTheDay();
  }

  Future<void> getScriptureOfTheDay() async {
    loading = true;
    notifyListeners();
    try {
      scripture = await model.getScriptureOfTheDay();
      print('Scripture loaded: ${scripture!.content}');
      errorMessage = null;
    } on HttpException catch (error) {
      print('Error loading scripture: ${error.message}');
      errorMessage = error.message;
      scripture = null;
    }
    loading = false;
    notifyListeners();
  }

}



class ScriptureView extends StatelessWidget {
  ScriptureView({super.key});

  final ScriptureViewModel viewModel = ScriptureViewModel(ScriptureModel());

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Scripture Generator'),
        actions: [],
        ),
        body: ListenableBuilder(
          listenable: viewModel, 
          builder: (context, child) {
            return switch ((
              viewModel.loading,
              viewModel.scripture,
              viewModel.errorMessage,
            )) {
              (true, _, _) => Center(child:CircularProgressIndicator()),
              (false, _, String message) => Center(child: Text(message)),
              (false, null, null) => Center(
                child: Text('An unknown error has occured'),
              ),
              (false, Scripture scripture, null) => Center(child: ScripturePage(
                scripture: scripture,
                nextScriptureCallback: viewModel.getScriptureOfTheDay,
              )),
            };
          },
        ),
    );
  }

}

class ScripturePage extends StatelessWidget {
  const ScripturePage({
    super.key,
    required this.scripture,
    required this.nextScriptureCallback,
  });

  final Scripture scripture;
  final VoidCallback nextScriptureCallback;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(child:
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        height: 500,
        child: Column(
          children: [
            Flexible(
              child: ScriptureWidget(
                scripture: scripture,
                ),
              ),
              ElevatedButton(
                onPressed: nextScriptureCallback, 
                child: Text('Get another scripture',style: GoogleFonts.poppins(fontSize: 14)
                ),

                ),
            ],
        )
      ),
      )
    );
  }
}


class ScriptureWidget extends StatelessWidget {
  const ScriptureWidget({super.key, required this.scripture});

  final Scripture scripture;

  @override
  Widget build(BuildContext context) {
     return Center(
      child: Column(
        spacing: 10.0,
        children: [  
          Text(
            '${scripture.content}',
             style: GoogleFonts.poppins(fontSize: 33, fontWeight: FontWeight.bold)
          ),
          Text(
            '${scripture.reference}',
             style: GoogleFonts.poppins(fontSize: 21)
          ),
        ],
      ),
    ); 
  }
}

