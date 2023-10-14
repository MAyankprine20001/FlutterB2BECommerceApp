import 'package:e_commerce_app_flutter/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:e_commerce_app_flutter/screens/edit_product/provider_models/ProductDetails.dart';
import 'package:e_commerce_app_flutter/services/local_files_access/local_files_access_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

abstract class LocalFileHandlingException {
  String _message;
  LocalFileHandlingException(this._message);
  String get message => _message;
  @override
  String toString() {
    return message;
  }
}

class LocalFileHandlingStorageReadPermissionDeniedException
    extends LocalFileHandlingException {
  LocalFileHandlingStorageReadPermissionDeniedException(
      {String message = "Storage Read permissions not granted"})
      : super(message);
}

Future<void> addImageButtonCallback({int index, BuildContext context}) async {
  final productDetails = Provider.of<ProductDetails>(context, listen: false);
  if (index == null && productDetails.selectedImages.length >= 3) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Max 3 images can be uploaded")));
    return;
  }
  String path;
  String snackbarMessage;
  try {
    path = await choseImageFromLocalFiles(context);
    if (path == null) {
      throw LocalImagePickingUnknownReasonFailureException();
    }
  } on LocalFileHandlingStorageReadPermissionDeniedException catch (e) {
    Logger().i("Storage Read Permission Denied Exception: ${e.message}");
    snackbarMessage = "Storage Read Permission Denied: ${e.message}";
  } on LocalFileHandlingException catch (e) {
    Logger().i("Local File Handling Exception: ${e.message}");
    snackbarMessage = "Error handling local file: ${e.message}";
  } catch (e) {
    Logger().i("Unknown Exception: $e");
    snackbarMessage = "An unknown error occurred: ${e.toString()}";
  } finally {
    if (snackbarMessage != null) {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
  }
  if (path == null) {
    return;
  }
  if (index == null) {
    productDetails
        .addNewSelectedImage(CustomImage(imgType: ImageType.local, path: path));
  } else {
    productDetails.setSelectedImageAtIndex(
        CustomImage(imgType: ImageType.local, path: path), index);
  }
}
