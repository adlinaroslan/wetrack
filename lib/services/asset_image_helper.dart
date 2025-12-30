// Shared helper to resolve asset image paths by name/brand
String getAssetImagePath(String assetName) {
  if (assetName.isEmpty) return '';
  final name = assetName.toLowerCase().trim();

  final Map<String, String> imageOptions = {
    'laminator': 'assets/images/laminator.png',
    'apacer': 'assets/images/apacer.png',
    'maxell': 'assets/images/maxell.jpg',
    'acer': 'assets/images/acer.png',
    'tv mount bracket': 'assets/images/tv mount bracket.jpg',
    'sandisk': 'assets/images/sandisk.jpg',
    'cable': 'assets/images/cable.png',
    'keelat': 'assets/images/keelat.jpg',
    'cordless blower': 'assets/images/cordless blower.jpg',
    'portable voice amplifier': 'assets/images/portable voice amplifier.jpg',
    'hdmi': 'assets/images/hdmi.jpg',
    'vga': 'assets/images/VGA.jpg',
    'ugreen adapter': 'assets/images/ugreen adapter.jpg',
    'microphone stand': 'assets/images/mic stand.png',
    'raspberry pi 4': 'assets/images/RASPBERRY PI 4B.jpg',
    'hyperx': 'assets/images/hyperx.jpg',
    'dell': 'assets/images/dell.jpg',
    'extension': 'assets/images/extension.png',
    'laptop': 'assets/images/dell.jpg',
    'laptop charger': 'assets/images/laptop_charger.png',
    'usb': 'assets/images/usb.png',
    'pendrive': 'assets/images/usb.png',
    'rca': 'assets/images/rca.png',
    'projector': 'assets/images/projector.png',
    'hdmic': 'assets/images/hdmic.jpeg',
    'mouse': 'assets/images/mouse.png',
    'projector.png': 'assets/images/projector.png',
  };

  if (imageOptions.containsKey(name)) {
    return imageOptions[name]!;
  }

  for (final entry in imageOptions.entries) {
    if (name.contains(entry.key)) return entry.value;
  }

  return '';
}
