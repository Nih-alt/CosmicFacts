class SpaceQuote {
  final String quote;
  final String author;
  final String role;
  final String category;

  const SpaceQuote({
    required this.quote,
    required this.author,
    required this.role,
    required this.category,
  });
}

const List<SpaceQuote> allSpaceQuotes = [
  // ═══════════════════════════════════════
  // EXPLORATION (1-20)
  // ═══════════════════════════════════════
  SpaceQuote(
    quote: "That's one small step for man, one giant leap for mankind.",
    author: 'Neil Armstrong',
    role: 'Astronaut',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'The Earth is the cradle of humanity, but mankind cannot stay in the cradle forever.',
    author: 'Konstantin Tsiolkovsky',
    role: 'Rocket Scientist',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'To confine our attention to terrestrial matters would be to limit the human spirit.',
    author: 'Stephen Hawking',
    role: 'Physicist',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: "I don't think the human race will survive the next thousand years, unless we spread into space.",
    author: 'Stephen Hawking',
    role: 'Physicist',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: "Space is for everybody. It's not just for a few people in science or math, or for a select group of astronauts.",
    author: 'Christa McAuliffe',
    role: 'Teacher/Astronaut',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'We choose to go to the Moon in this decade and do the other things, not because they are easy, but because they are hard.',
    author: 'John F. Kennedy',
    role: 'US President',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'Somewhere, something incredible is waiting to be known.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: "The dinosaurs became extinct because they didn't have a space program.",
    author: 'Larry Niven',
    role: 'Author',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'When I first looked back at the Earth, standing on the Moon, I cried.',
    author: 'Alan Shepard',
    role: 'Astronaut',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: "Once you've been in space, you appreciate how small and fragile the Earth is.",
    author: 'Valentina Tereshkova',
    role: 'First Woman in Space',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'Mars is there, waiting to be reached.',
    author: 'Buzz Aldrin',
    role: 'Astronaut',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'Exploration is in our nature. We began as wanderers, and we are wanderers still.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'The path to the stars is steep and dangerous. But we are not afraid.',
    author: 'Yuri Gagarin',
    role: 'First Human in Space',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'When you launch in a rocket, you\'re not really flying that rocket. You\'re just sort of hanging on.',
    author: 'Michael P. Anderson',
    role: 'Astronaut',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'For all its material advantages, the sedentary life has left us edgy, unfulfilled. Even after 400 generations in villages and cities, we haven\'t forgotten. The open road still softly calls.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'The exploration of space will go ahead, whether we join in it or not.',
    author: 'John F. Kennedy',
    role: 'US President',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'I believe that space travel will one day become as common as airline travel is today.',
    author: 'Buzz Aldrin',
    role: 'Astronaut',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'Across the sea of space, the stars are other suns.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'The greatest gain from space travel consists in the extension of our knowledge.',
    author: 'Wernher von Braun',
    role: 'Rocket Engineer',
    category: 'Exploration',
  ),
  SpaceQuote(
    quote: 'Orbiting Earth in the spaceship, I saw how beautiful our planet is. People, let us preserve and increase this beauty, not destroy it!',
    author: 'Yuri Gagarin',
    role: 'First Human in Space',
    category: 'Exploration',
  ),

  // ═══════════════════════════════════════
  // UNIVERSE (21-40)
  // ═══════════════════════════════════════
  SpaceQuote(
    quote: 'The universe is under no obligation to make sense to you.',
    author: 'Neil deGrasse Tyson',
    role: 'Astrophysicist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: "Two things are infinite: the universe and human stupidity; and I'm not sure about the universe.",
    author: 'Albert Einstein',
    role: 'Physicist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'We are a way for the universe to know itself.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'The cosmos is within us. We are made of star-stuff.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'Look up at the stars and not down at your feet.',
    author: 'Stephen Hawking',
    role: 'Physicist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'The nitrogen in our DNA, the calcium in our teeth, the iron in our blood — were all made in the interiors of collapsing stars.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'Every atom in your body came from a star that exploded.',
    author: 'Lawrence Krauss',
    role: 'Physicist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'The universe is not only queerer than we suppose, but queerer than we can suppose.',
    author: 'J.B.S. Haldane',
    role: 'Biologist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'In the beginning the Universe was created. This has made a lot of people very angry and been widely regarded as a bad move.',
    author: 'Douglas Adams',
    role: 'Author',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'We are all connected; To each other, biologically. To the earth, chemically. To the rest of the universe atomically.',
    author: 'Neil deGrasse Tyson',
    role: 'Astrophysicist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'The universe seems neither benign nor hostile, merely indifferent.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'Not only is the universe stranger than we imagine, it is stranger than we can imagine.',
    author: 'Sir Arthur Eddington',
    role: 'Astrophysicist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'The universe is a pretty big place. If it\'s just us, seems like an awful waste of space.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'There are more stars in the universe than grains of sand on all of Earth\'s beaches.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'The eternal silence of these infinite spaces frightens me.',
    author: 'Blaise Pascal',
    role: 'Mathematician',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'One of the basic rules of the universe is that nothing is perfect. Perfection simply doesn\'t exist.',
    author: 'Stephen Hawking',
    role: 'Physicist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'The universe is big. It\'s vast and complicated and ridiculous. And sometimes, very rarely, impossible things just happen and we call them miracles.',
    author: 'Steven Moffat',
    role: 'Screenwriter',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'We are just an advanced breed of monkeys on a minor planet of a very average star. But we can understand the Universe.',
    author: 'Stephen Hawking',
    role: 'Physicist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'The more clearly we can focus our attention on the wonders of the universe, the less taste we shall have for destruction.',
    author: 'Rachel Carson',
    role: 'Marine Biologist',
    category: 'Universe',
  ),
  SpaceQuote(
    quote: 'I am putting myself to the fullest possible use, which is all I think that any conscious entity can ever hope to do.',
    author: 'Arthur C. Clarke',
    role: 'Science Fiction Author',
    category: 'Universe',
  ),

  // ═══════════════════════════════════════
  // SCIENCE (41-60)
  // ═══════════════════════════════════════
  SpaceQuote(
    quote: 'Imagination is more important than knowledge.',
    author: 'Albert Einstein',
    role: 'Physicist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'The important thing is not to stop questioning.',
    author: 'Albert Einstein',
    role: 'Physicist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'Science is not only a disciple of reason but also one of romance and passion.',
    author: 'Stephen Hawking',
    role: 'Physicist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: "The good thing about science is that it's true whether or not you believe in it.",
    author: 'Neil deGrasse Tyson',
    role: 'Astrophysicist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'If you wish to make an apple pie from scratch, you must first invent the universe.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'Equipped with his five senses, man explores the universe around him and calls the adventure Science.',
    author: 'Edwin Hubble',
    role: 'Astronomer',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'The most beautiful thing we can experience is the mysterious. It is the source of all true art and science.',
    author: 'Albert Einstein',
    role: 'Physicist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'Science is a way of thinking much more than it is a body of knowledge.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'Gravity explains the motions of the planets, but it cannot explain who set the planets in motion.',
    author: 'Isaac Newton',
    role: 'Physicist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'If I have seen further it is by standing on the shoulders of giants.',
    author: 'Isaac Newton',
    role: 'Physicist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'The saddest aspect of life right now is that science gathers knowledge faster than society gathers wisdom.',
    author: 'Isaac Asimov',
    role: 'Science Fiction Author',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'Somewhere, something incredible is waiting to be known.',
    author: 'Sharon Begley',
    role: 'Science Journalist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'The scientist is not a person who gives the right answers, he\'s one who asks the right questions.',
    author: 'Claude Levi-Strauss',
    role: 'Anthropologist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'Research is what I\'m doing when I don\'t know what I\'m doing.',
    author: 'Wernher von Braun',
    role: 'Rocket Engineer',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'The science of today is the technology of tomorrow.',
    author: 'Edward Teller',
    role: 'Physicist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'Nothing in life is to be feared, it is only to be understood.',
    author: 'Marie Curie',
    role: 'Physicist/Chemist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'I have not failed. I\'ve just found 10,000 ways that won\'t work.',
    author: 'Thomas Edison',
    role: 'Inventor',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'The only source of knowledge is experience.',
    author: 'Albert Einstein',
    role: 'Physicist',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'Any sufficiently advanced technology is indistinguishable from magic.',
    author: 'Arthur C. Clarke',
    role: 'Science Fiction Author',
    category: 'Science',
  ),
  SpaceQuote(
    quote: 'Physics is the universe\'s operating system.',
    author: 'Steven R Garman',
    role: 'Author',
    category: 'Science',
  ),

  // ═══════════════════════════════════════
  // INDIA / ISRO (61-80)
  // ═══════════════════════════════════════
  SpaceQuote(
    quote: 'We will not simply be exploring space — we will be contributing to the betterment of humanity.',
    author: 'Vikram Sarabhai',
    role: 'Father of Indian Space Program',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'Dream, dream, dream. Dreams transform into thoughts and thoughts result in action.',
    author: 'APJ Abdul Kalam',
    role: 'Scientist/President',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'You have to dream before your dreams can come true.',
    author: 'APJ Abdul Kalam',
    role: 'Scientist/President',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'My mission Chandrayaan-3 proved that even a developing nation can touch the Moon.',
    author: 'S. Somanath',
    role: 'ISRO Chairman',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'Space science and technology can be the catalyst for India\'s all-round development.',
    author: 'Vikram Sarabhai',
    role: 'ISRO Founder',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'If you want to shine like a sun, first burn like a sun.',
    author: 'APJ Abdul Kalam',
    role: 'Scientist/President',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'Great dreams of great dreamers are always transcended.',
    author: 'APJ Abdul Kalam',
    role: 'Scientist/President',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'We must think and act like a nation of a billion people and not like that of a million people.',
    author: 'APJ Abdul Kalam',
    role: 'Scientist/President',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'India reached Mars on a budget less than a Hollywood movie. That\'s Indian ingenuity.',
    author: 'Narendra Modi',
    role: 'Prime Minister of India',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'ISRO has shown that space exploration is not the monopoly of a few wealthy nations.',
    author: 'K. Radhakrishnan',
    role: 'Former ISRO Chairman',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'There are no boundaries for Indian scientists and engineers.',
    author: 'Satish Dhawan',
    role: 'ISRO Chairman',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'We are doing space technology for the benefit of the common man.',
    author: 'Vikram Sarabhai',
    role: 'ISRO Founder',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'India is not just reaching for the stars — we are also bringing the benefits back to Earth.',
    author: 'K. Sivan',
    role: 'Former ISRO Chairman',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'Failure is a stepping stone to success. We learned from Chandrayaan-2 and succeeded with Chandrayaan-3.',
    author: 'S. Somanath',
    role: 'ISRO Chairman',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'Excellence is a continuous process and not an accident.',
    author: 'APJ Abdul Kalam',
    role: 'Scientist/President',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'When we landed on the Moon\'s south pole, it was not just India\'s achievement — it was humanity\'s.',
    author: 'S. Somanath',
    role: 'ISRO Chairman',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'Science and technology have made India a space-faring nation.',
    author: 'Satish Dhawan',
    role: 'ISRO Chairman',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'The best brains of the nation may be found on the last benches of the classroom.',
    author: 'APJ Abdul Kalam',
    role: 'Scientist/President',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'Man needs his difficulties because they are necessary to enjoy success.',
    author: 'APJ Abdul Kalam',
    role: 'Scientist/President',
    category: 'India',
  ),
  SpaceQuote(
    quote: 'We had the courage to attempt what many thought impossible for India.',
    author: 'K. Sivan',
    role: 'Former ISRO Chairman',
    category: 'India',
  ),

  // ═══════════════════════════════════════
  // HUMANITY (81-100)
  // ═══════════════════════════════════════
  SpaceQuote(
    quote: 'Earth is a very small stage in a vast cosmic arena.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'From out there on the Moon, international politics look so petty.',
    author: 'Edgar Mitchell',
    role: 'Astronaut',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'I know the sky is not the limit because there are footprints on the Moon.',
    author: 'Buzz Aldrin',
    role: 'Astronaut',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'The Earth is what we all have in common.',
    author: 'Wendell Berry',
    role: 'Author',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'When you look at the stars and the galaxy, you feel that you are not just from any particular piece of land, but from the solar system.',
    author: 'Kalpana Chawla',
    role: 'Astronaut',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'It suddenly struck me that that tiny pea, pretty and blue, was the Earth. I put up my thumb and shut one eye, and my thumb blotted out the planet Earth.',
    author: 'Neil Armstrong',
    role: 'Astronaut',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'To be the first to enter the cosmos, to engage single-handedly in an unprecedented duel with nature — could one dream of anything more?',
    author: 'Yuri Gagarin',
    role: 'First Human in Space',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'Mankind is drawn to the heavens for the same reason we were once drawn into unknown lands and across the open sea.',
    author: 'Ronald Reagan',
    role: 'US President',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'Our two greatest problems are gravity and paperwork. We can lick gravity, but sometimes the paperwork is overwhelming.',
    author: 'Wernher von Braun',
    role: 'Rocket Engineer',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'That\'s here. That\'s home. That\'s us. On it everyone you love, everyone you know, everyone you ever heard of, every human being who ever was, lived out their lives.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'The view of Earth is absolutely spectacular, and the feeling of looking back and seeing your planet as a planet is just an extraordinary feeling.',
    author: 'Sally Ride',
    role: 'Astronaut',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'In the long run, a single-planet species will not survive.',
    author: 'Michael Griffin',
    role: 'NASA Administrator',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'The Earth was small, light blue, and so touchingly alone, our home that must be defended like a holy relic.',
    author: 'Aleksei Leonov',
    role: 'First Spacewalker',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'There is perhaps no better a demonstration of the folly of human conceits than this distant image of our tiny world.',
    author: 'Carl Sagan',
    role: 'Astronomer',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'Returning to the Moon is an important step for our space program. Establishing an extended human presence on the Moon could vastly reduce the costs of further space exploration.',
    author: 'Buzz Aldrin',
    role: 'Astronaut',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'You develop an instant global consciousness, a people orientation, an intense dissatisfaction with the state of the world, and a compulsion to do something about it.',
    author: 'Edgar Mitchell',
    role: 'Astronaut',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'On this shrunken globe, men can no longer live as strangers.',
    author: 'Adlai Stevenson',
    role: 'Politician',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'Space exploration is a force of nature unto itself that no other force in society can rival.',
    author: 'Neil deGrasse Tyson',
    role: 'Astrophysicist',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'What everyone in the astronaut corps shares in common is not gender or ethnic background, but motivation, perseverance, and desire — the desire to participate in a voyage of discovery.',
    author: 'Ellen Ochoa',
    role: 'Astronaut',
    category: 'Humanity',
  ),
  SpaceQuote(
    quote: 'Space travel benefits us here on Earth. And we ain\'t stopped yet. There\'s more exploration ahead.',
    author: 'Mae Jemison',
    role: 'Astronaut',
    category: 'Humanity',
  ),
];
