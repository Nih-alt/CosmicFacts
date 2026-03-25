class Astronaut {
  final String name;
  final String country;
  final String agency;
  final String role;
  final String famousMission;
  final String achievement;
  final String born;
  final String bio;
  final String flag;
  final bool isActive;

  const Astronaut({
    required this.name,
    required this.country,
    required this.agency,
    required this.role,
    required this.famousMission,
    required this.achievement,
    required this.born,
    required this.bio,
    required this.flag,
    required this.isActive,
  });
}

const allAstronauts = <Astronaut>[
  // ══════════════════════════════════════
  // LEGENDS
  // ══════════════════════════════════════
  Astronaut(
    name: 'Yuri Gagarin', country: 'Russia', agency: 'Roscosmos',
    role: 'Cosmonaut', famousMission: 'Vostok 1',
    achievement: 'First human in space (1961)',
    born: '1934',
    bio: 'Soviet pilot who became the first human to journey into outer space on April 12, 1961. His flight lasted 108 minutes and changed history forever.',
    flag: '\u{1F1F7}\u{1F1FA}', isActive: false,
  ),
  Astronaut(
    name: 'Neil Armstrong', country: 'USA', agency: 'NASA',
    role: 'Commander', famousMission: 'Apollo 11',
    achievement: 'First person to walk on the Moon (1969)',
    born: '1930',
    bio: 'American astronaut and the first person to walk on the Moon. His words "one small step for man" became humanity\'s most iconic quote.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Buzz Aldrin', country: 'USA', agency: 'NASA',
    role: 'Pilot', famousMission: 'Apollo 11',
    achievement: 'Second person to walk on the Moon (1969)',
    born: '1930',
    bio: 'American astronaut who walked on the Moon during Apollo 11. He has since been a passionate advocate for human missions to Mars.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Valentina Tereshkova', country: 'Russia', agency: 'Roscosmos',
    role: 'Cosmonaut', famousMission: 'Vostok 6',
    achievement: 'First woman in space (1963)',
    born: '1937',
    bio: 'Soviet cosmonaut who became the first woman to fly in space. She orbited Earth 48 times during her three-day mission.',
    flag: '\u{1F1F7}\u{1F1FA}', isActive: false,
  ),
  Astronaut(
    name: 'John Glenn', country: 'USA', agency: 'NASA',
    role: 'Pilot', famousMission: 'Mercury-Atlas 6',
    achievement: 'First American to orbit Earth (1962)',
    born: '1921',
    bio: 'American astronaut and senator who was the first American to orbit Earth. He returned to space at age 77, becoming the oldest person in space.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Alan Shepard', country: 'USA', agency: 'NASA',
    role: 'Commander', famousMission: 'Apollo 14',
    achievement: 'First American in space (1961)',
    born: '1923',
    bio: 'American astronaut who became the first American in space and later walked on the Moon during Apollo 14, where he famously hit golf balls.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),

  // ══════════════════════════════════════
  // INDIAN SPACE HEROES
  // ══════════════════════════════════════
  Astronaut(
    name: 'Rakesh Sharma', country: 'India', agency: 'ISRO',
    role: 'Cosmonaut', famousMission: 'Soyuz T-11',
    achievement: 'First Indian in space (1984)',
    born: '1949',
    bio: 'Indian Air Force pilot who became the first Indian citizen to travel to space. When PM Indira Gandhi asked how India looked from space, he replied "Sare jahan se achha."',
    flag: '\u{1F1EE}\u{1F1F3}', isActive: false,
  ),
  Astronaut(
    name: 'Kalpana Chawla', country: 'India', agency: 'NASA',
    role: 'Mission Specialist', famousMission: 'STS-87',
    achievement: 'First Indian-origin woman in space (1997)',
    born: '1962',
    bio: 'Indian-American astronaut and aerospace engineer. She tragically died in the Space Shuttle Columbia disaster in 2003.',
    flag: '\u{1F1EE}\u{1F1F3}', isActive: false,
  ),
  Astronaut(
    name: 'Sunita Williams', country: 'USA', agency: 'NASA',
    role: 'Commander', famousMission: 'Expedition 33',
    achievement: 'Indian-origin ISS Commander',
    born: '1965',
    bio: 'American astronaut of Indian-Slovenian heritage. She holds the record for total spacewalks by a female astronaut and has spent over 322 days in space.',
    flag: '\u{1F1EE}\u{1F1F3}', isActive: true,
  ),

  // ══════════════════════════════════════
  // MODERN ERA
  // ══════════════════════════════════════
  Astronaut(
    name: 'Chris Hadfield', country: 'Canada', agency: 'CSA',
    role: 'Commander', famousMission: 'Expedition 35',
    achievement: 'First Canadian ISS Commander',
    born: '1959',
    bio: 'Canadian astronaut famous for his social media presence from space and his rendition of David Bowie\'s Space Oddity recorded aboard the ISS.',
    flag: '\u{1F1E8}\u{1F1E6}', isActive: false,
  ),
  Astronaut(
    name: 'Tim Peake', country: 'UK', agency: 'ESA',
    role: 'Flight Engineer', famousMission: 'Expedition 46',
    achievement: 'First British ESA astronaut on ISS',
    born: '1972',
    bio: 'British ESA astronaut and former Army Air Corps officer. He ran the London Marathon from space on a treadmill aboard the ISS.',
    flag: '\u{1F1EC}\u{1F1E7}', isActive: true,
  ),
  Astronaut(
    name: 'Peggy Whitson', country: 'USA', agency: 'NASA',
    role: 'Commander', famousMission: 'Expedition 16',
    achievement: 'Most experienced female astronaut',
    born: '1960',
    bio: 'American biochemist and astronaut who holds the US record for most time in space (665 days) and most spacewalks by a woman.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Scott Kelly', country: 'USA', agency: 'NASA',
    role: 'Commander', famousMission: 'Expedition 46',
    achievement: 'Spent 1 year in space',
    born: '1964',
    bio: 'American astronaut who spent 340 consecutive days in space as part of a twin study comparing him with his identical twin brother Mark.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Christina Koch', country: 'USA', agency: 'NASA',
    role: 'Flight Engineer', famousMission: 'Expedition 61',
    achievement: 'Longest single spaceflight by a woman',
    born: '1979',
    bio: 'American astronaut who set the record for the longest single spaceflight by a woman at 328 days. She participated in the first all-female spacewalk.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: true,
  ),
  Astronaut(
    name: 'Mae Jemison', country: 'USA', agency: 'NASA',
    role: 'Mission Specialist', famousMission: 'STS-47',
    achievement: 'First African-American woman in space (1992)',
    born: '1956',
    bio: 'American engineer, physician, and astronaut who became the first African-American woman in space.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),

  // ══════════════════════════════════════
  // SPACEX ERA
  // ══════════════════════════════════════
  Astronaut(
    name: 'Doug Hurley', country: 'USA', agency: 'SpaceX',
    role: 'Commander', famousMission: 'Crew Dragon Demo-2',
    achievement: 'First crewed SpaceX flight (2020)',
    born: '1966',
    bio: 'American astronaut who along with Bob Behnken flew the first crewed SpaceX mission, returning human spaceflight to US soil.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Jared Isaacman', country: 'USA', agency: 'SpaceX',
    role: 'Commander', famousMission: 'Inspiration4',
    achievement: 'First all-civilian orbital mission (2021)',
    born: '1983',
    bio: 'American billionaire entrepreneur who commanded Inspiration4, the first all-civilian orbital spaceflight.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: true,
  ),

  // ══════════════════════════════════════
  // INTERNATIONAL
  // ══════════════════════════════════════
  Astronaut(
    name: 'Yang Liwei', country: 'China', agency: 'CNSA',
    role: 'Taikonaut', famousMission: 'Shenzhou 5',
    achievement: 'First Chinese person in space (2003)',
    born: '1965',
    bio: 'Chinese military pilot who became China\'s first person in space, making China the third country to independently send a human into orbit.',
    flag: '\u{1F1E8}\u{1F1F3}', isActive: true,
  ),
  Astronaut(
    name: 'Soichi Noguchi', country: 'Japan', agency: 'JAXA',
    role: 'Mission Specialist', famousMission: 'STS-114',
    achievement: 'Japanese astronaut on 3 different spacecraft',
    born: '1965',
    bio: 'Japanese astronaut who has flown on the Space Shuttle, Soyuz, and SpaceX Crew Dragon \u2014 the only person to fly on all three.',
    flag: '\u{1F1EF}\u{1F1F5}', isActive: true,
  ),
  Astronaut(
    name: 'Samantha Cristoforetti', country: 'Italy', agency: 'ESA',
    role: 'Flight Engineer', famousMission: 'Expedition 42',
    achievement: 'First Italian woman in space',
    born: '1977',
    bio: 'Italian ESA astronaut and fighter pilot. She held the record for longest uninterrupted spaceflight by a European astronaut.',
    flag: '\u{1F1EE}\u{1F1F9}', isActive: true,
  ),

  // ══════════════════════════════════════
  // EARLY SPACE RACE HEROES
  // ══════════════════════════════════════
  Astronaut(
    name: 'Alexei Leonov', country: 'Russia', agency: 'Roscosmos',
    role: 'Cosmonaut', famousMission: 'Voskhod 2',
    achievement: 'First person to walk in space (1965)',
    born: '1934',
    bio: 'Soviet cosmonaut who performed the first-ever spacewalk. His 12-minute EVA almost ended in disaster when his spacesuit inflated in the vacuum.',
    flag: '\u{1F1F7}\u{1F1FA}', isActive: false,
  ),
  Astronaut(
    name: 'Jim Lovell', country: 'USA', agency: 'NASA',
    role: 'Commander', famousMission: 'Apollo 13',
    achievement: 'Led Apollo 13 crew safely home',
    born: '1928',
    bio: 'American astronaut who commanded the ill-fated Apollo 13 mission. His leadership during the crisis brought the crew safely back to Earth.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Sally Ride', country: 'USA', agency: 'NASA',
    role: 'Mission Specialist', famousMission: 'STS-7',
    achievement: 'First American woman in space (1983)',
    born: '1951',
    bio: 'American physicist and astronaut who became the first American woman in space. She later advocated for STEM education for young girls.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Michael Collins', country: 'USA', agency: 'NASA',
    role: 'Pilot', famousMission: 'Apollo 11',
    achievement: 'Apollo 11 command module pilot',
    born: '1930',
    bio: 'American astronaut who orbited the Moon alone during Apollo 11 while Armstrong and Aldrin walked on the surface. Often called "the loneliest man."',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),

  // ══════════════════════════════════════
  // CHINESE TAIKONAUTS
  // ══════════════════════════════════════
  Astronaut(
    name: 'Liu Yang', country: 'China', agency: 'CNSA',
    role: 'Taikonaut', famousMission: 'Shenzhou 9',
    achievement: 'First Chinese woman in space (2012)',
    born: '1978',
    bio: 'Chinese military pilot who became the first Chinese woman in space when she flew aboard Shenzhou 9 to the Tiangong-1 space lab.',
    flag: '\u{1F1E8}\u{1F1F3}', isActive: true,
  ),
  Astronaut(
    name: 'Zhai Zhigang', country: 'China', agency: 'CNSA',
    role: 'Commander', famousMission: 'Shenzhou 7',
    achievement: 'First Chinese spacewalker (2008)',
    born: '1966',
    bio: 'Chinese taikonaut who performed China\'s first-ever spacewalk during the Shenzhou 7 mission. He later commanded Shenzhou 13.',
    flag: '\u{1F1E8}\u{1F1F3}', isActive: true,
  ),

  // ══════════════════════════════════════
  // MIDDLE EAST
  // ══════════════════════════════════════
  Astronaut(
    name: 'Sultan Al Neyadi', country: 'UAE', agency: 'MBRSC',
    role: 'Mission Specialist', famousMission: 'SpaceX Crew-6',
    achievement: 'First Arab astronaut on long-duration mission',
    born: '1981',
    bio: 'Emirati astronaut who became the first Arab to undertake a long-duration spaceflight, spending six months aboard the ISS.',
    flag: '\u{1F1E6}\u{1F1EA}', isActive: true,
  ),
  Astronaut(
    name: 'Hazzaa AlMansoori', country: 'UAE', agency: 'MBRSC',
    role: 'Spaceflight Participant', famousMission: 'Soyuz MS-15',
    achievement: 'First Emirati in space (2019)',
    born: '1983',
    bio: 'Emirati military pilot who became the first person from the UAE to go to space, spending eight days aboard the ISS.',
    flag: '\u{1F1E6}\u{1F1EA}', isActive: true,
  ),

  // ══════════════════════════════════════
  // AFRICAN & SOUTH AMERICAN
  // ══════════════════════════════════════
  Astronaut(
    name: 'Mark Shuttleworth', country: 'South Africa', agency: 'Roscosmos',
    role: 'Spaceflight Participant', famousMission: 'Soyuz TM-34',
    achievement: 'First African in space (2002)',
    born: '1973',
    bio: 'South African-British entrepreneur who became the first African citizen and second self-funded space tourist to fly into space.',
    flag: '\u{1F1FF}\u{1F1E6}', isActive: false,
  ),
  Astronaut(
    name: 'Marcos Pontes', country: 'Brazil', agency: 'AEB',
    role: 'Spaceflight Participant', famousMission: 'Soyuz TMA-8',
    achievement: 'First Brazilian in space (2006)',
    born: '1963',
    bio: 'Brazilian Air Force pilot who became the first Brazilian and first Portuguese-speaking person to go to space.',
    flag: '\u{1F1E7}\u{1F1F7}', isActive: false,
  ),

  // ══════════════════════════════════════
  // JAPANESE
  // ══════════════════════════════════════
  Astronaut(
    name: 'Akihiko Hoshide', country: 'Japan', agency: 'JAXA',
    role: 'Commander', famousMission: 'Expedition 65',
    achievement: 'Japanese ISS Commander',
    born: '1968',
    bio: 'Japanese astronaut who served as ISS Commander. He has completed multiple spacewalks and spent over 340 days in space across three missions.',
    flag: '\u{1F1EF}\u{1F1F5}', isActive: true,
  ),
  Astronaut(
    name: 'Koichi Wakata', country: 'Japan', agency: 'JAXA',
    role: 'Commander', famousMission: 'Expedition 39',
    achievement: 'Most experienced Japanese astronaut',
    born: '1963',
    bio: 'Japanese astronaut who has spent over 500 days in space across five missions, making him the most experienced Japanese space traveler.',
    flag: '\u{1F1EF}\u{1F1F5}', isActive: true,
  ),

  // ══════════════════════════════════════
  // SPACEX CREW & MODERN
  // ══════════════════════════════════════
  Astronaut(
    name: 'Hayley Arceneaux', country: 'USA', agency: 'SpaceX',
    role: 'Medical Officer', famousMission: 'Inspiration4',
    achievement: 'Youngest American in orbit (2021)',
    born: '1991',
    bio: 'American physician assistant and cancer survivor who became the youngest American to orbit Earth at age 29 during the Inspiration4 mission.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Bob Behnken', country: 'USA', agency: 'NASA',
    role: 'Joint Operations Commander', famousMission: 'Crew Dragon Demo-2',
    achievement: 'First crewed SpaceX flight (2020)',
    born: '1970',
    bio: 'American astronaut who along with Doug Hurley flew the historic first crewed SpaceX mission. He has completed 10 spacewalks.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: true,
  ),

  // ══════════════════════════════════════
  // ISS CREW & NOTABLE
  // ══════════════════════════════════════
  Astronaut(
    name: 'Thomas Pesquet', country: 'France', agency: 'ESA',
    role: 'Commander', famousMission: 'Expedition 65',
    achievement: 'First French ISS Commander',
    born: '1978',
    bio: 'French ESA astronaut, pilot, and black belt in judo. He was the first French commander of the ISS and is one of Europe\'s most popular astronauts.',
    flag: '\u{1F1EB}\u{1F1F7}', isActive: true,
  ),
  Astronaut(
    name: 'Luca Parmitano', country: 'Italy', agency: 'ESA',
    role: 'Commander', famousMission: 'Expedition 61',
    achievement: 'First Italian ISS Commander',
    born: '1976',
    bio: 'Italian ESA astronaut and Air Force pilot. He survived a dangerous water leak in his spacesuit during a spacewalk in 2013.',
    flag: '\u{1F1EE}\u{1F1F9}', isActive: true,
  ),
  Astronaut(
    name: 'Alexander Gerst', country: 'Germany', agency: 'ESA',
    role: 'Commander', famousMission: 'Expedition 57',
    achievement: 'First German ISS Commander',
    born: '1976',
    bio: 'German ESA astronaut and geophysicist. He became the first German to command the ISS and is known for his stunning photos from space.',
    flag: '\u{1F1E9}\u{1F1EA}', isActive: true,
  ),
  Astronaut(
    name: 'Oleg Kononenko', country: 'Russia', agency: 'Roscosmos',
    role: 'Commander', famousMission: 'Expedition 70',
    achievement: 'Record holder for most time in space',
    born: '1964',
    bio: 'Russian cosmonaut who holds the record for the most cumulative time spent in space, surpassing 1000 days in orbit across five missions.',
    flag: '\u{1F1F7}\u{1F1FA}', isActive: true,
  ),
  Astronaut(
    name: 'Frank Rubio', country: 'USA', agency: 'NASA',
    role: 'Flight Engineer', famousMission: 'Expedition 68/69',
    achievement: 'Longest US spaceflight (371 days)',
    born: '1975',
    bio: 'American astronaut who set the record for the longest single spaceflight by an American at 371 days due to a Soyuz coolant leak.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: true,
  ),
  Astronaut(
    name: 'Jasmin Moghbeli', country: 'USA', agency: 'NASA',
    role: 'Commander', famousMission: 'SpaceX Crew-7',
    achievement: 'First Iranian-American woman in space',
    born: '1983',
    bio: 'American astronaut and Marine helicopter pilot. She became the first Iranian-American woman in space aboard SpaceX Crew-7.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: true,
  ),
  Astronaut(
    name: 'Andreas Mogensen', country: 'Denmark', agency: 'ESA',
    role: 'Commander', famousMission: 'Expedition 70',
    achievement: 'First Danish astronaut',
    born: '1976',
    bio: 'Danish ESA astronaut who became the first Dane in space. He later commanded the ISS during Expedition 70.',
    flag: '\u{1F1E9}\u{1F1F0}', isActive: true,
  ),

  // ══════════════════════════════════════
  // INDIAN GAGANYAAN CANDIDATES
  // ══════════════════════════════════════
  Astronaut(
    name: 'Prashanth Nair', country: 'India', agency: 'ISRO',
    role: 'Gaganyaan Pilot', famousMission: 'Gaganyaan (upcoming)',
    achievement: 'Selected for India\'s first crewed mission',
    born: '1976',
    bio: 'Group Captain in the Indian Air Force, selected as one of four astronaut candidates for ISRO\'s Gaganyaan mission, India\'s first crewed spaceflight.',
    flag: '\u{1F1EE}\u{1F1F3}', isActive: true,
  ),
  Astronaut(
    name: 'Angad Pratap', country: 'India', agency: 'ISRO',
    role: 'Gaganyaan Pilot', famousMission: 'Gaganyaan (upcoming)',
    achievement: 'Selected for India\'s first crewed mission',
    born: '1982',
    bio: 'Group Captain in the Indian Air Force, selected for ISRO\'s Gaganyaan crew. He trained with Roscosmos in Russia for spaceflight readiness.',
    flag: '\u{1F1EE}\u{1F1F3}', isActive: true,
  ),

  // ══════════════════════════════════════
  // MORE NOTABLE ASTRONAUTS
  // ══════════════════════════════════════
  Astronaut(
    name: 'Eileen Collins', country: 'USA', agency: 'NASA',
    role: 'Commander', famousMission: 'STS-93',
    achievement: 'First female Space Shuttle Commander',
    born: '1956',
    bio: 'American astronaut who became the first female pilot and first female commander of a Space Shuttle mission.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Guion Bluford', country: 'USA', agency: 'NASA',
    role: 'Mission Specialist', famousMission: 'STS-8',
    achievement: 'First African-American in space (1983)',
    born: '1942',
    bio: 'American aerospace engineer and Air Force pilot who became the first African-American to go to space aboard the Space Shuttle Challenger.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Sergei Krikalev', country: 'Russia', agency: 'Roscosmos',
    role: 'Flight Engineer', famousMission: 'ISS Expedition 1',
    achievement: 'Spent 803 days in space across 6 missions',
    born: '1958',
    bio: 'Russian cosmonaut who was stranded on Mir when the Soviet Union dissolved. He later became one of the first ISS crew members.',
    flag: '\u{1F1F7}\u{1F1FA}', isActive: false,
  ),
  Astronaut(
    name: 'Wally Funk', country: 'USA', agency: 'Blue Origin',
    role: 'Spaceflight Participant', famousMission: 'NS-16',
    achievement: 'Oldest person in space at 82 (2021)',
    born: '1939',
    bio: 'American aviator who was part of the Mercury 13 program in the 1960s. She finally reached space at age 82 aboard a Blue Origin flight.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: false,
  ),
  Astronaut(
    name: 'Anousheh Ansari', country: 'Iran/USA', agency: 'Roscosmos',
    role: 'Spaceflight Participant', famousMission: 'Soyuz TMA-9',
    achievement: 'First female private space explorer (2006)',
    born: '1966',
    bio: 'Iranian-American engineer and entrepreneur who became the first female private space explorer and the first Iranian in space.',
    flag: '\u{1F1EE}\u{1F1F7}', isActive: false,
  ),
  Astronaut(
    name: 'Yi So-yeon', country: 'South Korea', agency: 'KARI',
    role: 'Spaceflight Participant', famousMission: 'Soyuz TMA-12',
    achievement: 'First Korean in space (2008)',
    born: '1978',
    bio: 'South Korean astronaut who became the first Korean to fly in space, conducting scientific experiments aboard the ISS.',
    flag: '\u{1F1F0}\u{1F1F7}', isActive: false,
  ),
  Astronaut(
    name: 'Jessica Watkins', country: 'USA', agency: 'NASA',
    role: 'Mission Specialist', famousMission: 'SpaceX Crew-4',
    achievement: 'First Black woman on ISS crew (2022)',
    born: '1988',
    bio: 'American geologist and astronaut who became the first Black woman to serve on a long-duration ISS mission aboard SpaceX Crew-4.',
    flag: '\u{1F1FA}\u{1F1F8}', isActive: true,
  ),
];
