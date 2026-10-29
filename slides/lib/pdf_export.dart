import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Encodes [image] as a JPEG, to be used as a page of [savePdf].
///
/// Slides are stored as JPEGs, as raw pixels would make a PDF of hundreds of
/// megabytes. The encoding happens on another isolate (except on the web).
Future<Uint8List> encodePage(ui.Image image) async {
  final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return compute(_encodeJpeg, (
    pixels: pixels!,
    width: image.width,
    height: image.height,
  ));
}

Uint8List _encodeJpeg(({ByteData pixels, int width, int height}) page) {
  final image = img.Image.fromBytes(
    width: page.width,
    height: page.height,
    bytes: page.pixels.buffer,
    numChannels: 4,
  );
  return img.encodeJpg(image, quality: 90);
}

/// Asks where to save a PDF made of [pages] (see [encodePage]), each of
/// [pageSize] points, and saves it there.
///
/// On the web, the PDF is downloaded instead. Returns whether it was saved.
Future<bool> savePdf(
  List<Uint8List> pages, {
  required ui.Size pageSize,
  required String title,
  required String fileName,
}) async {
  final document = pw.Document(title: title);
  final format = PdfPageFormat(pageSize.width, pageSize.height);
  for (final page in pages) {
    document.addPage(
      pw.Page(
        pageFormat: format,
        build: (_) => pw.Image(pw.MemoryImage(page), fit: pw.BoxFit.fill),
      ),
    );
  }

  final file = XFile.fromData(
    await document.save(),
    mimeType: 'application/pdf',
    name: fileName,
  );
  if (kIsWeb) {
    await file.saveTo(fileName);
    return true;
  }

  final location = await getSaveLocation(
    suggestedName: fileName,
    acceptedTypeGroups: const [
      XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
        uniformTypeIdentifiers: ['com.adobe.pdf'],
      ),
    ],
  );
  if (location == null) return false;
  await file.saveTo(location.path);
  return true;
}
