import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Note {
  final int id;
  String subject;
  final String contenu;

  Note({
    required this.id,
    required this.subject,
    required this.contenu,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      subject: json['title'],
      contenu: json['contenu'],
    );
  }
}


class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      home: NotesForm(),
    );
  }
}

class NotesForm extends StatefulWidget {
  @override
  _NotesFormState createState() => _NotesFormState();
}

class _NotesFormState extends State<NotesForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  String? _selectedSubject;
  List<Note> notes = [];

  Future<void> saveNote() async {
  final url = Uri.parse('http://127.0.0.1:8000/api/notes/save');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'subject': _selectedSubject,
      'contenu': _contentController.text,
    }),
  );

  if (response.statusCode == 200) {
    // La note a été enregistrée avec succès, on redirige l'utilisateur vers la liste des notes
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NotesList(),
      ),
    );
  } else {
    // Il y a eu une erreur lors de l'enregistrement de la note
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add note')),
    );
  }
}



  //   Future<List<Note>> getNotes() async {
  //   final url = Uri.parse('http://127.0.0.1:8000/api/notes/liste');
  //   final response = await http.get(
  //     url,
   
  //   );
  //     List<Note> notes = [];

  //   if (response.body.isEmpty==false) {
    
  //    var notesJson = jsonDecode(response.body).cast<Map<String, dynamic>>();

  //    for (var note in notesJson) {
  //     notes.add(      Note.fromJson(note));
       
  //    }


  //     return notes;
 
  // }
  // return notes;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                items: [
                  DropdownMenuItem(child: Text('Java'), value: 'Java'),
                  DropdownMenuItem(child: Text('PHP'), value: 'PHP'),
                  DropdownMenuItem(child: Text('Algo'), value: 'Algo'),
                ],
                hint: Text('Select a subject'),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a subject';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Entrer une note (comprise entre 0 et 20)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'SVP Veuillez entre une note';
                  }
                  final note = int.tryParse(value);
                  if (note == null || note < 0 || note > 20) {
                    return 'Please enter a note between 0 and 20';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      await saveNote();
    }
  },
  child: Text('Enregistrer'),
),
            ],
          ),
        ),
      ),
    );
  }
}

class NotesList extends StatefulWidget {
  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  Future<List<Note>> getNotes() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/notes/liste');
    final response = await http.get(url);

    List<Note> notes = [];

    if (response.body.isNotEmpty) {
      var notesJson = jsonDecode(response.body).cast<Map<String, dynamic>>();

      for (var note in notesJson) {
        notes.add(Note.fromJson(note));
      }
    }

    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: getNotes(),
          builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('An error occurred'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final note = snapshot.data![index];
                  return ListTile(
                    title: Text(note.subject),
                    subtitle: Text(note.contenu),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}



void main() {
  runApp(NotesApp());
}