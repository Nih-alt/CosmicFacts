import 'dart:ui';

class StarData {
  final String name;
  final String bayer; // e.g. "α Ori"
  final double ra; // Right Ascension in HOURS (0-24)
  final double dec; // Declination in DEGREES (-90 to +90)
  final double magnitude; // lower = brighter
  final String constellation;
  final int colorTemp; // Kelvin — for star color

  const StarData({
    required this.name,
    required this.bayer,
    required this.ra,
    required this.dec,
    required this.magnitude,
    required this.constellation,
    this.colorTemp = 6000,
  });
}

// Star color helper
Color getStarColor(int kelvin) {
  if (kelvin < 3500) return const Color(0xFFFF6B35); // red/orange
  if (kelvin < 5000) return const Color(0xFFFFD700); // yellow-orange
  if (kelvin < 6500) return const Color(0xFFFFF8E1); // yellow-white
  if (kelvin < 10000) return const Color(0xFFFFFFFF); // white
  return const Color(0xFFAABBFF); // blue-white
}

const List<StarData> brightStars = [
  StarData(name: 'Sirius', bayer: 'α CMa', ra: 6.7525, dec: -16.7161, magnitude: -1.46, constellation: 'Canis Major', colorTemp: 9940),
  StarData(name: 'Canopus', bayer: 'α Car', ra: 6.3992, dec: -52.6957, magnitude: -0.72, constellation: 'Carina', colorTemp: 7400),
  StarData(name: 'Arcturus', bayer: 'α Boo', ra: 14.2610, dec: 19.1822, magnitude: -0.04, constellation: 'Boötes', colorTemp: 4300),
  StarData(name: 'Vega', bayer: 'α Lyr', ra: 18.6157, dec: 38.7836, magnitude: 0.03, constellation: 'Lyra', colorTemp: 9600),
  StarData(name: 'Capella', bayer: 'α Aur', ra: 5.2816, dec: 45.9980, magnitude: 0.08, constellation: 'Auriga', colorTemp: 4970),
  StarData(name: 'Rigel', bayer: 'β Ori', ra: 5.2423, dec: -8.2016, magnitude: 0.12, constellation: 'Orion', colorTemp: 12100),
  StarData(name: 'Procyon', bayer: 'α CMi', ra: 7.6550, dec: 5.2250, magnitude: 0.34, constellation: 'Canis Minor', colorTemp: 6530),
  StarData(name: 'Achernar', bayer: 'α Eri', ra: 1.6286, dec: -57.2367, magnitude: 0.46, constellation: 'Eridanus', colorTemp: 14000),
  StarData(name: 'Betelgeuse', bayer: 'α Ori', ra: 5.9195, dec: 7.4069, magnitude: 0.42, constellation: 'Orion', colorTemp: 3300),
  StarData(name: 'Hadar', bayer: 'β Cen', ra: 14.0637, dec: -60.3730, magnitude: 0.61, constellation: 'Centaurus', colorTemp: 25000),
  StarData(name: 'Altair', bayer: 'α Aql', ra: 19.8463, dec: 8.8683, magnitude: 0.76, constellation: 'Aquila', colorTemp: 7680),
  StarData(name: 'Aldebaran', bayer: 'α Tau', ra: 4.5988, dec: 16.5093, magnitude: 0.85, constellation: 'Taurus', colorTemp: 3900),
  StarData(name: 'Antares', bayer: 'α Sco', ra: 16.4901, dec: -26.4320, magnitude: 0.96, constellation: 'Scorpius', colorTemp: 3400),
  StarData(name: 'Spica', bayer: 'α Vir', ra: 13.4199, dec: -11.1613, magnitude: 0.97, constellation: 'Virgo', colorTemp: 22400),
  StarData(name: 'Pollux', bayer: 'β Gem', ra: 7.7553, dec: 28.0262, magnitude: 1.14, constellation: 'Gemini', colorTemp: 4865),
  StarData(name: 'Fomalhaut', bayer: 'α PsA', ra: 22.9608, dec: -29.6223, magnitude: 1.16, constellation: 'Piscis Austrinus', colorTemp: 8590),
  StarData(name: 'Deneb', bayer: 'α Cyg', ra: 20.6905, dec: 45.2803, magnitude: 1.25, constellation: 'Cygnus', colorTemp: 8525),
  StarData(name: 'Mimosa', bayer: 'β Cru', ra: 12.7953, dec: -59.6888, magnitude: 1.25, constellation: 'Crux', colorTemp: 22000),
  StarData(name: 'Regulus', bayer: 'α Leo', ra: 10.1395, dec: 11.9672, magnitude: 1.35, constellation: 'Leo', colorTemp: 12000),
  StarData(name: 'Adhara', bayer: 'ε CMa', ra: 6.9771, dec: -28.9721, magnitude: 1.50, constellation: 'Canis Major', colorTemp: 22200),
  StarData(name: 'Shaula', bayer: 'λ Sco', ra: 17.5601, dec: -37.1038, magnitude: 1.62, constellation: 'Scorpius', colorTemp: 25000),
  StarData(name: 'Castor', bayer: 'α Gem', ra: 7.5766, dec: 31.8883, magnitude: 1.58, constellation: 'Gemini', colorTemp: 8840),
  StarData(name: 'Gacrux', bayer: 'γ Cru', ra: 12.5193, dec: -57.1133, magnitude: 1.59, constellation: 'Crux', colorTemp: 3700),
  StarData(name: 'Bellatrix', bayer: 'γ Ori', ra: 5.4188, dec: 6.3497, magnitude: 1.64, constellation: 'Orion', colorTemp: 21500),
  StarData(name: 'Elnath', bayer: 'β Tau', ra: 5.4381, dec: 28.6075, magnitude: 1.65, constellation: 'Taurus', colorTemp: 13824),
  StarData(name: 'Miaplacidus', bayer: 'β Car', ra: 9.2200, dec: -69.7172, magnitude: 1.67, constellation: 'Carina', colorTemp: 8866),
  StarData(name: 'Alnilam', bayer: 'ε Ori', ra: 5.6036, dec: -1.2019, magnitude: 1.69, constellation: 'Orion', colorTemp: 26200),
  StarData(name: 'Alnitak', bayer: 'ζ Ori', ra: 5.6796, dec: -1.9425, magnitude: 1.74, constellation: 'Orion', colorTemp: 29500),
  StarData(name: 'Alioth', bayer: 'ε UMa', ra: 12.9005, dec: 55.9598, magnitude: 1.76, constellation: 'Ursa Major', colorTemp: 9020),
  StarData(name: 'Dubhe', bayer: 'α UMa', ra: 11.0621, dec: 61.7511, magnitude: 1.81, constellation: 'Ursa Major', colorTemp: 4960),
  StarData(name: 'Mirfak', bayer: 'α Per', ra: 3.4054, dec: 49.8612, magnitude: 1.79, constellation: 'Perseus', colorTemp: 6350),
  StarData(name: 'Wezen', bayer: 'δ CMa', ra: 7.1397, dec: -26.3932, magnitude: 1.83, constellation: 'Canis Major', colorTemp: 5818),
  StarData(name: 'Sargas', bayer: 'θ Sco', ra: 17.6219, dec: -42.9978, magnitude: 1.86, constellation: 'Scorpius', colorTemp: 7268),
  StarData(name: 'Kaus Australis', bayer: 'ε Sgr', ra: 18.4028, dec: -34.3846, magnitude: 1.85, constellation: 'Sagittarius', colorTemp: 9960),
  StarData(name: 'Avior', bayer: 'ε Car', ra: 8.3752, dec: -59.5095, magnitude: 1.86, constellation: 'Carina', colorTemp: 3523),
  StarData(name: 'Alkaid', bayer: 'η UMa', ra: 13.7923, dec: 49.3133, magnitude: 1.85, constellation: 'Ursa Major', colorTemp: 15400),
  StarData(name: 'Menkalinan', bayer: 'β Aur', ra: 5.9919, dec: 44.9474, magnitude: 1.90, constellation: 'Auriga', colorTemp: 9350),
  StarData(name: 'Atria', bayer: 'α TrA', ra: 16.8113, dec: -69.0277, magnitude: 1.91, constellation: 'Triangulum Australe', colorTemp: 4150),
  StarData(name: 'Alhena', bayer: 'γ Gem', ra: 6.6283, dec: 16.3993, magnitude: 1.93, constellation: 'Gemini', colorTemp: 9260),
  StarData(name: 'Peacock', bayer: 'α Pav', ra: 20.4274, dec: -56.7350, magnitude: 1.94, constellation: 'Pavo', colorTemp: 17711),
  StarData(name: 'Alsephina', bayer: 'δ Vel', ra: 8.7449, dec: -54.7088, magnitude: 1.96, constellation: 'Vela', colorTemp: 9440),
  StarData(name: 'Mirzam', bayer: 'β CMa', ra: 6.3782, dec: -17.9559, magnitude: 1.98, constellation: 'Canis Major', colorTemp: 22500),
  StarData(name: 'Polaris', bayer: 'α UMi', ra: 2.5302, dec: 89.2641, magnitude: 1.98, constellation: 'Ursa Minor', colorTemp: 6015),
  StarData(name: 'Alphard', bayer: 'α Hya', ra: 9.4597, dec: -8.6586, magnitude: 1.99, constellation: 'Hydra', colorTemp: 4120),
  StarData(name: 'Hamal', bayer: 'α Ari', ra: 2.1196, dec: 23.4624, magnitude: 2.00, constellation: 'Aries', colorTemp: 4480),
  StarData(name: 'Algieba', bayer: 'γ Leo', ra: 10.3329, dec: 19.8416, magnitude: 2.01, constellation: 'Leo', colorTemp: 4470),
  StarData(name: 'Nunki', bayer: 'σ Sgr', ra: 18.9211, dec: -26.2967, magnitude: 2.05, constellation: 'Sagittarius', colorTemp: 18700),
  StarData(name: 'Denebola', bayer: 'β Leo', ra: 11.8177, dec: 14.5722, magnitude: 2.14, constellation: 'Leo', colorTemp: 8500),
  StarData(name: 'Mira', bayer: 'ο Cet', ra: 2.3219, dec: -2.9775, magnitude: 2.0, constellation: 'Cetus', colorTemp: 2900),
  StarData(name: 'Alpheratz', bayer: 'α And', ra: 0.1397, dec: 29.0904, magnitude: 2.06, constellation: 'Andromeda', colorTemp: 13000),
  StarData(name: 'Caph', bayer: 'β Cas', ra: 0.1529, dec: 59.1497, magnitude: 2.27, constellation: 'Cassiopeia', colorTemp: 7079),
  StarData(name: 'Schedar', bayer: 'α Cas', ra: 0.6751, dec: 56.5373, magnitude: 2.23, constellation: 'Cassiopeia', colorTemp: 4552),
  StarData(name: 'Rasalhague', bayer: 'α Oph', ra: 17.5822, dec: 12.5600, magnitude: 2.07, constellation: 'Ophiuchus', colorTemp: 7880),
  StarData(name: 'Eltanin', bayer: 'γ Dra', ra: 17.9434, dec: 51.4889, magnitude: 2.24, constellation: 'Draco', colorTemp: 3930),
  StarData(name: 'Mintaka', bayer: 'δ Ori', ra: 5.5336, dec: -0.2990, magnitude: 2.23, constellation: 'Orion', colorTemp: 29500),
  StarData(name: 'Saiph', bayer: 'κ Ori', ra: 5.7959, dec: -9.6696, magnitude: 2.07, constellation: 'Orion', colorTemp: 26500),
  StarData(name: 'Alphecca', bayer: 'α CrB', ra: 15.5781, dec: 26.7147, magnitude: 2.22, constellation: 'Corona Borealis', colorTemp: 9700),
  StarData(name: 'Suhail', bayer: 'λ Vel', ra: 9.1338, dec: -43.4327, magnitude: 2.23, constellation: 'Vela', colorTemp: 3700),
  StarData(name: 'Sabik', bayer: 'η Oph', ra: 17.1728, dec: -15.7243, magnitude: 2.43, constellation: 'Ophiuchus', colorTemp: 9100),
  StarData(name: 'Phecda', bayer: 'γ UMa', ra: 11.8970, dec: 53.6948, magnitude: 2.44, constellation: 'Ursa Major', colorTemp: 9355),
  StarData(name: 'Aludra', bayer: 'η CMa', ra: 7.4017, dec: -29.3031, magnitude: 2.45, constellation: 'Canis Major', colorTemp: 15100),
  StarData(name: 'Merak', bayer: 'β UMa', ra: 11.0306, dec: 56.3824, magnitude: 2.37, constellation: 'Ursa Major', colorTemp: 9377),
  StarData(name: 'Diphda', bayer: 'β Cet', ra: 0.7265, dec: -17.9866, magnitude: 2.02, constellation: 'Cetus', colorTemp: 4797),
  StarData(name: 'Naos', bayer: 'ζ Pup', ra: 8.0597, dec: -40.0033, magnitude: 2.25, constellation: 'Puppis', colorTemp: 42000),
  StarData(name: 'Almach', bayer: 'γ And', ra: 2.0651, dec: 42.3297, magnitude: 2.10, constellation: 'Andromeda', colorTemp: 4250),
  StarData(name: 'Menkib', bayer: 'ξ Per', ra: 3.9823, dec: 35.7911, magnitude: 4.04, constellation: 'Perseus', colorTemp: 37500),
  StarData(name: 'Albireo', bayer: 'β Cyg', ra: 19.5121, dec: 27.9597, magnitude: 3.05, constellation: 'Cygnus', colorTemp: 4270),
  StarData(name: 'Sadr', bayer: 'γ Cyg', ra: 20.3705, dec: 40.2567, magnitude: 2.20, constellation: 'Cygnus', colorTemp: 5790),
  StarData(name: 'Gienah', bayer: 'γ Crv', ra: 12.2638, dec: -17.5419, magnitude: 2.58, constellation: 'Corvus', colorTemp: 12000),
  StarData(name: 'Markeb', bayer: 'κ Vel', ra: 9.3682, dec: -55.0107, magnitude: 2.47, constellation: 'Vela', colorTemp: 18000),
  StarData(name: 'Markab', bayer: 'α Peg', ra: 23.0794, dec: 15.2053, magnitude: 2.49, constellation: 'Pegasus', colorTemp: 9765),
  StarData(name: 'Alderamin', bayer: 'α Cep', ra: 21.3096, dec: 62.5857, magnitude: 2.51, constellation: 'Cepheus', colorTemp: 7700),
  StarData(name: 'Enif', bayer: 'ε Peg', ra: 21.7364, dec: 9.8750, magnitude: 2.38, constellation: 'Pegasus', colorTemp: 4462),
  StarData(name: 'Algenib', bayer: 'γ Peg', ra: 0.2206, dec: 15.1836, magnitude: 2.83, constellation: 'Pegasus', colorTemp: 21700),
  StarData(name: 'Acrab', bayer: 'β Sco', ra: 16.0905, dec: -19.8054, magnitude: 2.62, constellation: 'Scorpius', colorTemp: 28000),
  StarData(name: 'Lesath', bayer: 'υ Sco', ra: 17.5308, dec: -37.2961, magnitude: 2.69, constellation: 'Scorpius', colorTemp: 22000),
  StarData(name: 'Dschubba', bayer: 'δ Sco', ra: 16.0053, dec: -22.6217, magnitude: 2.32, constellation: 'Scorpius', colorTemp: 27400),
  StarData(name: 'Phact', bayer: 'α Col', ra: 5.6609, dec: -34.0741, magnitude: 2.65, constellation: 'Columba', colorTemp: 12963),
  StarData(name: 'Izar', bayer: 'ε Boo', ra: 14.7498, dec: 27.0742, magnitude: 2.35, constellation: 'Boötes', colorTemp: 13000),
  StarData(name: 'Zubenelgenubi', bayer: 'α Lib', ra: 14.8479, dec: -16.0418, magnitude: 2.75, constellation: 'Libra', colorTemp: 8500),
  StarData(name: 'Kochab', bayer: 'β UMi', ra: 14.8450, dec: 74.1556, magnitude: 2.07, constellation: 'Ursa Minor', colorTemp: 4030),
  StarData(name: 'Pherkad', bayer: 'γ UMi', ra: 15.3454, dec: 71.8340, magnitude: 3.05, constellation: 'Ursa Minor', colorTemp: 8280),
  StarData(name: 'Cor Caroli', bayer: 'α CVn', ra: 12.9334, dec: 38.3183, magnitude: 2.89, constellation: 'Canes Venatici', colorTemp: 11600),
  StarData(name: 'Vindemiatrix', bayer: 'ε Vir', ra: 13.0362, dec: 10.9592, magnitude: 2.83, constellation: 'Virgo', colorTemp: 5086),
  StarData(name: 'Unukalhai', bayer: 'α Ser', ra: 15.7378, dec: 6.4254, magnitude: 2.63, constellation: 'Serpens', colorTemp: 4498),
  StarData(name: 'Ankaa', bayer: 'α Phe', ra: 0.4381, dec: -42.3060, magnitude: 2.40, constellation: 'Phoenix', colorTemp: 4436),
  StarData(name: 'Sadalsuud', bayer: 'β Aqr', ra: 21.5259, dec: -5.5711, magnitude: 2.87, constellation: 'Aquarius', colorTemp: 5210),
  StarData(name: 'Sadalmelik', bayer: 'α Aqr', ra: 22.0962, dec: -0.3198, magnitude: 2.94, constellation: 'Aquarius', colorTemp: 5210),
  StarData(name: 'Tiaki', bayer: 'β Gru', ra: 22.7112, dec: -46.8846, magnitude: 2.12, constellation: 'Grus', colorTemp: 3480),
];
