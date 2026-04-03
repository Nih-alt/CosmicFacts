// DISCLAIMER: This app is unofficial. Not affiliated with NASA, ISRO, ESA, CNSA or any space agency.
// Agency names are used as informational data labels only — no official logos or emblems are used.

/// All 20 active/recent space missions.
/// Each entry uses emoji flags (not official logos) for Play Store compliance.
final List<Map<String, dynamic>> activeMissions = [
  {
    'name': 'Voyager 1',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Deep Space',
    'target': 'Interstellar Space',
    'type': 'Probe',
    'status': 'Active',
    'launchYear': 1977,
    'distanceKm': 24000000000,
    'description':
        'Humanity\'s most distant spacecraft, now in interstellar space beyond our solar system.',
    'keyDiscovery':
        'First human-made object to enter interstellar space (2012)',
    'currentActivity':
        'Transmitting plasma wave and magnetic field data from interstellar medium',
    'officialUrl': 'https://voyager.jpl.nasa.gov',
  },
  {
    'name': 'Voyager 2',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Deep Space',
    'target': 'Interstellar Space',
    'type': 'Probe',
    'status': 'Active',
    'launchYear': 1977,
    'distanceKm': 20000000000,
    'description':
        'Only spacecraft to have visited all four outer planets \u2014 Jupiter, Saturn, Uranus, Neptune.',
    'keyDiscovery':
        'Discovered active volcanoes on Io and geysers on Triton',
    'currentActivity':
        'Sending back data on magnetic field and particle environment of interstellar space',
    'officialUrl': 'https://voyager.jpl.nasa.gov',
  },
  {
    'name': 'New Horizons',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Deep Space',
    'target': 'Kuiper Belt',
    'type': 'Probe',
    'status': 'Extended Mission',
    'launchYear': 2006,
    'distanceKm': 8000000000,
    'description':
        'First spacecraft to explore Pluto up close, now exploring the Kuiper Belt.',
    'keyDiscovery':
        'Revealed Pluto has mountains, glaciers and a heart-shaped nitrogen plain',
    'currentActivity':
        'Searching for new Kuiper Belt Objects to flyby, studying heliosphere',
    'officialUrl': 'https://www.nasa.gov/mission/new-horizons/',
  },
  {
    'name': 'Juno',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Deep Space',
    'target': 'Jupiter',
    'type': 'Orbiter',
    'status': 'Extended Mission',
    'launchYear': 2011,
    'distanceKm': 778000000,
    'description':
        'Orbiting Jupiter to study its atmosphere, magnetic field and interior structure.',
    'keyDiscovery':
        'Discovered Jupiter\'s poles are covered in huge clustered cyclones',
    'currentActivity':
        'Conducting flybys of Ganymede, Europa and Io \u2014 Jupiter\'s moons',
    'officialUrl': 'https://www.nasa.gov/mission/juno/',
  },
  {
    'name': 'Perseverance',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Mars',
    'target': 'Mars',
    'type': 'Rover',
    'status': 'Active',
    'launchYear': 2020,
    'distanceKm': 225000000,
    'description':
        'Searching for signs of ancient microbial life in Jezero Crater on Mars.',
    'keyDiscovery':
        'Produced oxygen from Martian atmosphere using MOXIE experiment',
    'currentActivity':
        'Drilling rock cores for future Mars Sample Return mission',
    'officialUrl': 'https://mars.nasa.gov/mars2020/',
  },
  {
    'name': 'Curiosity',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Mars',
    'target': 'Mars',
    'type': 'Rover',
    'status': 'Active',
    'launchYear': 2011,
    'distanceKm': 225000000,
    'description':
        'Exploring Gale Crater, climbing Mount Sharp, studying Mars habitability.',
    'keyDiscovery':
        'Confirmed Mars had liquid water and conditions for microbial life billions of years ago',
    'currentActivity':
        'Climbing Mount Sharp, analyzing ancient lake bed sediment layers',
    'officialUrl': 'https://mars.nasa.gov/msl/',
  },
  {
    'name': 'MAVEN',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Mars',
    'target': 'Mars',
    'type': 'Orbiter',
    'status': 'Active',
    'launchYear': 2013,
    'distanceKm': 225000000,
    'description':
        'Studying how Mars lost its atmosphere and water over billions of years.',
    'keyDiscovery':
        'Solar wind stripped Mars atmosphere at 100 grams per second',
    'currentActivity':
        'Also serving as data relay for Curiosity and Perseverance rovers',
    'officialUrl': 'https://lasp.colorado.edu/maven/',
  },
  {
    'name': 'Mars Odyssey',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Mars',
    'target': 'Mars',
    'type': 'Orbiter',
    'status': 'Active',
    'launchYear': 2001,
    'distanceKm': 225000000,
    'description':
        'Longest-operating Mars spacecraft \u2014 mapping surface minerals and acting as relay.',
    'keyDiscovery':
        'Detected large water ice deposits just beneath Martian surface',
    'currentActivity':
        'Relaying data from Mars surface missions, thermal imaging',
    'officialUrl': 'https://mars.nasa.gov/odyssey/',
  },
  {
    'name': 'Chandrayaan-3',
    'agency': 'ISRO',
    'agencyFlag': '\u{1F1EE}\u{1F1F3}',
    'destination': 'Moon',
    'target': 'Moon South Pole',
    'type': 'Lander/Rover',
    'status': 'Completed',
    'launchYear': 2023,
    'distanceKm': 384000,
    'description':
        'India\'s historic lunar south pole landing mission with Vikram lander and Pragyan rover.',
    'keyDiscovery':
        'Confirmed presence of sulphur and other elements near lunar south pole',
    'currentActivity':
        'Mission completed \u2014 Pragyan rover in sleep mode near landing site',
    'officialUrl': 'https://www.isro.gov.in/Chandrayaan3_New.html',
  },
  {
    'name': 'Aditya-L1',
    'agency': 'ISRO',
    'agencyFlag': '\u{1F1EE}\u{1F1F3}',
    'destination': 'Sun',
    'target': 'L1 Lagrange Point',
    'type': 'Observatory',
    'status': 'Active',
    'launchYear': 2023,
    'distanceKm': 1500000,
    'description':
        'India\'s first solar mission \u2014 studying the Sun\'s corona and solar wind from L1 point.',
    'keyDiscovery':
        'First observations of solar flares and coronal mass ejections from L1',
    'currentActivity':
        'Continuous solar observation from Sun-Earth L1 Lagrange point',
    'officialUrl': 'https://www.isro.gov.in/Aditya_L1.html',
  },
  {
    'name': 'Mars Express',
    'agency': 'ESA',
    'agencyFlag': '\u{1F1EA}\u{1F1FA}',
    'destination': 'Mars',
    'target': 'Mars',
    'type': 'Orbiter',
    'status': 'Active',
    'launchYear': 2003,
    'distanceKm': 225000000,
    'description':
        'ESA\'s longest running Mars mission \u2014 radar mapping subsurface water.',
    'keyDiscovery':
        'Found evidence of liquid water lake beneath south polar ice cap',
    'currentActivity':
        'Radar sounding of Martian subsurface, atmospheric studies',
    'officialUrl':
        'https://www.esa.int/Science_Exploration/Space_Science/Mars_Express',
  },
  {
    'name': 'ExoMars TGO',
    'agency': 'ESA',
    'agencyFlag': '\u{1F1EA}\u{1F1FA}',
    'destination': 'Mars',
    'target': 'Mars',
    'type': 'Orbiter',
    'status': 'Active',
    'launchYear': 2016,
    'distanceKm': 225000000,
    'description':
        'Hunting for trace gases on Mars \u2014 especially methane as a sign of life or geology.',
    'keyDiscovery':
        'Mapped global distribution of water ice in Martian subsurface',
    'currentActivity':
        'Atmospheric trace gas analysis, acting as data relay for future missions',
    'officialUrl':
        'https://www.esa.int/Science_Exploration/Space_Science/ExoMars/Trace_Gas_Orbiter',
  },
  {
    'name': 'Solar Orbiter',
    'agency': 'ESA',
    'agencyFlag': '\u{1F1EA}\u{1F1FA}',
    'destination': 'Sun',
    'target': 'Solar Poles',
    'type': 'Observatory',
    'status': 'Active',
    'launchYear': 2020,
    'distanceKm': 150000000,
    'description':
        'First spacecraft to image the Sun\'s poles, studying solar wind origin.',
    'keyDiscovery':
        'Discovered "campfires" \u2014 miniature solar flares blanketing the Sun\'s surface',
    'currentActivity':
        'Gradually increasing orbital inclination to image solar poles directly',
    'officialUrl':
        'https://www.esa.int/Science_Exploration/Space_Science/Solar_Orbiter',
  },
  {
    'name': 'Tianwen-1',
    'agency': 'CNSA',
    'agencyFlag': '\u{1F1E8}\u{1F1F3}',
    'destination': 'Mars',
    'target': 'Mars',
    'type': 'Orbiter',
    'status': 'Active',
    'launchYear': 2020,
    'distanceKm': 225000000,
    'description':
        'China\'s first Mars mission \u2014 orbiter, lander and Zhurong rover in one launch.',
    'keyDiscovery':
        'Zhurong rover found evidence of recent water activity on Mars surface',
    'currentActivity':
        'Orbiter continuing Mars remote sensing; Zhurong in hibernation',
    'officialUrl': 'https://www.cnsa.gov.cn',
  },
  {
    'name': 'Chang\'e 6',
    'agency': 'CNSA',
    'agencyFlag': '\u{1F1E8}\u{1F1F3}',
    'destination': 'Moon',
    'target': 'Moon Far Side',
    'type': 'Sample Return',
    'status': 'Completed',
    'launchYear': 2024,
    'distanceKm': 384000,
    'description':
        'First mission to return samples from the far side of the Moon.',
    'keyDiscovery':
        'Returned 1.9 kg of samples from Moon\'s far side \u2014 first ever',
    'currentActivity': 'Samples being analyzed in Chinese laboratories',
    'officialUrl': 'https://www.cnsa.gov.cn',
  },
  {
    'name': 'Parker Solar Probe',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Sun',
    'target': 'Solar Corona',
    'type': 'Probe',
    'status': 'Active',
    'launchYear': 2018,
    'distanceKm': 6000000,
    'description':
        'Closest ever mission to the Sun \u2014 flying through the solar corona.',
    'keyDiscovery':
        'First spacecraft to fly through the Sun\'s corona and "touch" the Sun',
    'currentActivity':
        'Making increasingly close passes to the Sun, studying solar wind acceleration',
    'officialUrl': 'https://parkersolarprobe.jhuapl.edu',
  },
  {
    'name': 'James Webb Space Telescope',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Deep Space',
    'target': 'L2 Lagrange Point',
    'type': 'Observatory',
    'status': 'Active',
    'launchYear': 2021,
    'distanceKm': 1500000,
    'description':
        'Most powerful space telescope ever \u2014 seeing the first galaxies of the universe.',
    'keyDiscovery':
        'Observed galaxies from just 300 million years after the Big Bang',
    'currentActivity':
        'Deep field imaging, exoplanet atmosphere analysis, early universe study',
    'officialUrl': 'https://webb.nasa.gov',
  },
  {
    'name': 'Hubble Space Telescope',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Earth Orbit',
    'target': 'Low Earth Orbit',
    'type': 'Observatory',
    'status': 'Active',
    'launchYear': 1990,
    'distanceKm': 547,
    'description':
        'Iconic space telescope still operating after 35 years, complementing JWST.',
    'keyDiscovery':
        'Measured universe expansion rate \u2014 leading to discovery of dark energy',
    'currentActivity':
        'Operating in reduced gyroscope mode, UV observations JWST cannot do',
    'officialUrl': 'https://hubblesite.org',
  },
  {
    'name': 'International Space Station',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Earth Orbit',
    'target': 'Low Earth Orbit',
    'type': 'Space Station',
    'status': 'Active',
    'launchYear': 1998,
    'distanceKm': 0.4,
    'description':
        'Continuously crewed orbital laboratory \u2014 humans have lived here for 25+ years.',
    'keyDiscovery':
        'Over 3,000 experiments conducted \u2014 from protein crystals to fire behavior in space',
    'currentActivity':
        'Hosting 7 crew members, ongoing science experiments, commercial crew rotations',
    'officialUrl': 'https://www.nasa.gov/international-space-station/',
  },
  {
    'name': 'Artemis Program',
    'agency': 'NASA',
    'agencyFlag': '\u{1F1FA}\u{1F1F8}',
    'destination': 'Moon',
    'target': 'Lunar Orbit & Surface',
    'type': 'Crewed Mission',
    'status': 'En Route',
    'launchYear': 2025,
    'distanceKm': 384000,
    'description':
        'NASA\'s program to return humans to the Moon for the first time since Apollo.',
    'keyDiscovery':
        'Artemis I successfully completed uncrewed lunar orbit in 2022',
    'currentActivity':
        'Preparing Artemis II \u2014 first crewed lunar flyby since 1972',
    'officialUrl': 'https://www.nasa.gov/artemis/',
  },
];
