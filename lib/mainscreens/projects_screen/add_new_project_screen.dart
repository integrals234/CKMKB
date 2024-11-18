// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously// lib/screens/new_project_screen.dart, sort_child_properties_last
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robosoc/utilities/image_picker.dart';
import 'package:robosoc/utilities/project_provider.dart';
import 'package:robosoc/models/project_model.dart';

class NewProjectScreen extends StatefulWidget {
  @override
  _NewProjectScreenState createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _link = '';
  dynamic _imageFile;
  bool _isUploading = false;

  Widget _buildImagePreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: _imageFile != null
              ? (kIsWeb
                  ? NetworkImage(_imageFile.path)
                  : FileImage(_imageFile) as ImageProvider)
              : null,
          child: _imageFile == null
              ? Icon(Icons.add_photo_alternate, size: 40)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 20,
            child: IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () => ImagePickerUtils.showImageSourceDialog(
                context,
                (image) => setState(() => _imageFile = image),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      try {
        _formKey.currentState!.save();
        final imageUrl = await ImagePickerUtils.uploadImage(_imageFile, 'project_images');

        final newProject = Project(
          id: '',
          title: _title,
          description: _description,
          link: _link,
          imageUrl: imageUrl ?? '',
        );

        await Provider.of<ProjectProvider>(context, listen: false).addProject(newProject);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add project: $e')),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Project'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImagePreview(),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
                  onSaved: (value) => _title = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
                  onSaved: (value) => _description = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Google Drive Link'),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter a link' : null,
                  onSaved: (value) => _link = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isUploading ? null : _submitForm,
                  child: _isUploading 
                    ? CircularProgressIndicator()
                    : Text('Add Project'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}