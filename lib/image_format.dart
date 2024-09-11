import 'package:image/image.dart';

const jpeg = ['jpg', 'jpeg'];
const png = ['png'];
const tga = ['tga'];
const webp = ['webp'];
const gif = ['gif'];
const tiff = ['tif', 'tiff'];
const psd = ['psd'];
const exr = ['exr'];
const bmp = ['bmp'];
const ico = ['ico'];
const pvr = ['pvr'];
const pnm = ['pnm', 'pbm', 'pgm', 'ppm'];

const images = <String>[
  ...jpeg,
  ...png,
  ...tga,
  ...webp,
  ...gif,
  ...tiff,
  ...psd,
  ...exr,
  ...bmp,
  ...ico,
  ...pvr,
  ...pnm,
];

bool isImage(String name) {
  name = name.toLowerCase();
  for (var image in images) {
    if (name.endsWith(".$image")) {
      return true;
    }
  }
  return false;
}

bool isSupportedImage(String name) {
  final decoder = findDecoderForNamedImage(name);
  return decoder != null;
}
