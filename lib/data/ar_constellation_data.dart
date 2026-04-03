class ConstellationLine {
  final String star1;
  final String star2;
  const ConstellationLine(this.star1, this.star2);
}

class ARConstellationData {
  final String name;
  final List<ConstellationLine> lines;
  const ARConstellationData({required this.name, required this.lines});
}

const List<ARConstellationData> majorConstellations = [
  ARConstellationData(name: 'Orion', lines: [
    ConstellationLine('Betelgeuse', 'Bellatrix'),
    ConstellationLine('Betelgeuse', 'Alnilam'),
    ConstellationLine('Bellatrix', 'Alnilam'),
    ConstellationLine('Alnilam', 'Alnitak'),
    ConstellationLine('Alnilam', 'Mintaka'),
    ConstellationLine('Alnitak', 'Saiph'),
    ConstellationLine('Mintaka', 'Rigel'),
    ConstellationLine('Saiph', 'Rigel'),
  ]),
  ARConstellationData(name: 'Ursa Major', lines: [
    ConstellationLine('Dubhe', 'Merak'),
    ConstellationLine('Merak', 'Phecda'),
    ConstellationLine('Phecda', 'Alioth'),
    ConstellationLine('Alioth', 'Alkaid'),
    ConstellationLine('Dubhe', 'Alioth'),
  ]),
  ARConstellationData(name: 'Scorpius', lines: [
    ConstellationLine('Antares', 'Acrab'),
    ConstellationLine('Antares', 'Dschubba'),
    ConstellationLine('Antares', 'Shaula'),
    ConstellationLine('Shaula', 'Lesath'),
    ConstellationLine('Antares', 'Sargas'),
  ]),
  ARConstellationData(name: 'Cygnus', lines: [
    ConstellationLine('Deneb', 'Sadr'),
    ConstellationLine('Sadr', 'Albireo'),
    ConstellationLine('Sadr', 'Eltanin'),
  ]),
  ARConstellationData(name: 'Leo', lines: [
    ConstellationLine('Regulus', 'Algieba'),
    ConstellationLine('Algieba', 'Denebola'),
    ConstellationLine('Regulus', 'Denebola'),
  ]),
  ARConstellationData(name: 'Cassiopeia', lines: [
    ConstellationLine('Schedar', 'Caph'),
  ]),
  ARConstellationData(name: 'Gemini', lines: [
    ConstellationLine('Pollux', 'Castor'),
    ConstellationLine('Pollux', 'Alhena'),
    ConstellationLine('Castor', 'Elnath'),
  ]),
  ARConstellationData(name: 'Sagittarius', lines: [
    ConstellationLine('Kaus Australis', 'Nunki'),
    ConstellationLine('Kaus Australis', 'Shaula'),
  ]),
  ARConstellationData(name: 'Lyra', lines: [
    ConstellationLine('Vega', 'Albireo'),
  ]),
  ARConstellationData(name: 'Aquila', lines: [
    ConstellationLine('Altair', 'Rasalhague'),
  ]),
  ARConstellationData(name: 'Pegasus', lines: [
    ConstellationLine('Markab', 'Algenib'),
    ConstellationLine('Markab', 'Enif'),
    ConstellationLine('Alpheratz', 'Algenib'),
    ConstellationLine('Alpheratz', 'Markab'),
  ]),
  ARConstellationData(name: 'Virgo', lines: [
    ConstellationLine('Spica', 'Vindemiatrix'),
  ]),
];
