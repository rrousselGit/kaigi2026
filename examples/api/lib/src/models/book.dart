import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

@JsonSerializable()
class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String synopsis;
  final double rating;
  final String genre;
  final int pages;
  final int publishYear;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.synopsis,
    required this.rating,
    required this.genre,
    required this.pages,
    required this.publishYear,
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);
}

final List<Book> sampleBooks = [
  const Book(
    id: '1',
    title: 'The Cosmic Horizon',
    author: 'Elena Rostova',
    description:
        'A breathtaking journey through deep space and human consciousness.',
    synopsis:
        'When humanity detects a harmonic signal emanating from the outer boundary of the solar system, commander Maya Vance leads an expedition into uncharted territory. What begins as a mission of discovery turns into a profound exploration of human destiny, time dilation, and the mysterious forces binding galaxies together.',
    rating: 4.9,
    genre: 'Sci-Fi',
    pages: 412,
    publishYear: 2024,
  ),
  const Book(
    id: '2',
    title: 'Chronicles of Aethelgard',
    author: 'Marcus Vance',
    description:
        'An epic tale of magic, forgotten empires, and ancient secrets.',
    synopsis:
        'Deep beneath the mist-shrouded peaks of Aethelgard lies the Sunstone artifact, capable of altering the weave of time. Young scholar Kaelen stumbles upon an ancient codex detailing the downfall of the First Dynasty, unraveling a plot that threatens to plunge the realm into endless winter.',
    rating: 4.8,
    genre: 'Fantasy',
    pages: 538,
    publishYear: 2023,
  ),
  const Book(
    id: '3',
    title: 'Architects of Mind',
    author: 'Dr. Sarah Lin',
    description:
        'Exploring neural interfaces and the future of human intelligence.',
    synopsis:
        'Synthesizing neuroscience, artificial intelligence, and cognitive philosophy, Dr. Lin provides an illuminating look at how synthetic neural networks and biological brains are merging. A groundbreaking work on the boundary between biological perception and digital consciousness.',
    rating: 4.7,
    genre: 'Technology',
    pages: 320,
    publishYear: 2025,
  ),
  const Book(
    id: '4',
    title: 'The Whisper in the Fog',
    author: 'Arthur Pendelton',
    description: 'A Victorian mystery filled with dark intrigue and secrets.',
    synopsis:
        'In autumn 1888, London inspector James Sterling investigates a series of impossible vanishing acts along the Thames. Clues point to an elusive society operating in hidden underground tunnels, where secrets from the Crimean War threaten to surface.',
    rating: 4.6,
    genre: 'Mystery',
    pages: 364,
    publishYear: 2022,
  ),
  const Book(
    id: '5',
    title: 'Echoes of the Silent Forest',
    author: 'Clara Thorne',
    description:
        'A poetic novel of love, loss, and nature in remote Scandinavia.',
    synopsis:
        'Nestled in a remote Scandinavian valley, Astrid tends to an ancient boreal forest that remembers generations of human sorrow. When a lost botanist arrives seeking rare flora, their shared solitude unveils forgotten truths about memory and forgiveness.',
    rating: 4.8,
    genre: 'Fiction',
    pages: 288,
    publishYear: 2024,
  ),
  const Book(
    id: '6',
    title: 'Quantum Resonance',
    author: 'Viktor Kane',
    description: 'Parallel universes collide in this high-stakes thriller.',
    synopsis:
        'Theoretical physicist Leo Miller accidentally initiates a quantum resonance cascade, causing glimpses of alternate timelines to bleed into his daily reality. Hunted by covert agents and racing against temporal instability, Leo must stabilize the multiversal leak before realities collapse.',
    rating: 4.9,
    genre: 'Sci-Fi',
    pages: 460,
    publishYear: 2025,
  ),
  const Book(
    id: '7',
    title: 'Shadows of the Neon Grid',
    author: 'Ren Takeda',
    description:
        'A dark cybernetic noir set in the sprawling megacity of Neo-Sora.',
    synopsis:
        'In Neo-Sora, data is currency and memories can be stolen. Hacker Iris Kross uncovers a encrypted data capsule containing proof of corrupted neural uploads by corporate moguls. With rogue bio-drones on her trail, she must navigate the neon-lit underworld to release the truth.',
    rating: 4.7,
    genre: 'Cyberpunk',
    pages: 380,
    publishYear: 2024,
  ),
  const Book(
    id: '8',
    title: 'The Obsidian Citadel',
    author: 'Lyra Vance',
    description: 'A dark high fantasy of elemental magic and war.',
    synopsis:
        'The Obsidian Citadel has stood impregnable for millennia, guarded by elemental mages. When an ancient corruption infects the citadel\'s mana core, outcast elementalist Rowan must forge an uneasy alliance with old enemies to save the realm from total annihilation.',
    rating: 4.9,
    genre: 'Fantasy',
    pages: 612,
    publishYear: 2023,
  ),
  const Book(
    id: '9',
    title: 'Algorithm of Destiny',
    author: 'Julian Mercier',
    description:
        'How predictive algorithms shape economics, politics, and daily lives.',
    synopsis:
        'Mercier explores how predictive modeling went from stock market forecasting to influencing global elections and personal behavior. Drawing on insider interviews with top tech pioneers, this book charts the invisible code guiding human choices.',
    rating: 4.5,
    genre: 'Technology',
    pages: 295,
    publishYear: 2024,
  ),
  const Book(
    id: '10',
    title: 'The Venetian Conspiracy',
    author: 'Isabella Rossi',
    description:
        'A gripping art mystery spanning centuries in Renaissance Venice.',
    synopsis:
        'Art historian Elena Bianchi discovers a hidden sketch beneath a Tintoretto masterpiece in Venice. The sketch points to a secret society that has manipulated European balance of power since 1510. As assassins close in, Elena races through secret Venetian canals.',
    rating: 4.8,
    genre: 'Thriller',
    pages: 420,
    publishYear: 2023,
  ),
  const Book(
    id: '11',
    title: 'Beneath the Starlit Canopy',
    author: 'Oliver Wright',
    description:
        'A heartwarming story of second chances set in a quiet coastal town.',
    synopsis:
        'Architect Sam returns to his hometown of St. Jude Bay to renovate an abandoned lighthouse. There he meets Hannah, an astronomer running stargazing tours. Together, they rediscover hope, community, and romance under the coastal night sky.',
    rating: 4.6,
    genre: 'Romance',
    pages: 310,
    publishYear: 2022,
  ),
  const Book(
    id: '12',
    title: 'Empires of the Sunken Epoch',
    author: 'Dr. Alistair Finch',
    description:
        'A comprehensive history of forgotten Bronze Age maritime civilizations.',
    synopsis:
        'Utilizing state-of-the-art underwater archaeology and LiDAR scanning, Dr. Finch reconstructs lost trading empires of the Bronze Age Mediterranean and Red Sea, illuminating how trade networks flourished before catastrophic bronze collapse.',
    rating: 4.7,
    genre: 'History',
    pages: 540,
    publishYear: 2021,
  ),
  const Book(
    id: '13',
    title: 'Meditations on Modern Being',
    author: 'Soren Lindqvist',
    description:
        'Philosophical inquiries into attention, quietude, and purpose.',
    synopsis:
        'Lindqvist weaves existentialism, Stoicism, and modern psychology into a reflective guide on preserving clarity and meaning amidst digital noise, hyper-connectivity, and the accelerated tempo of 21st-century existence.',
    rating: 4.8,
    genre: 'Philosophy',
    pages: 250,
    publishYear: 2024,
  ),
  const Book(
    id: '14',
    title: 'The Alchemy of Stars',
    author: 'Astrid Lindholm',
    description:
        'A space opera featuring starship captains, stellar alchemy, and empire.',
    synopsis:
        'In the Solari Dominion, stellar alchemists harvest energy directly from dying red giants. Captain Valen Vance discovers a dying star exhibiting impossible sub-atomic signatures, triggering a war between interstellar empires desperate for endless power.',
    rating: 4.7,
    genre: 'Sci-Fi',
    pages: 390,
    publishYear: 2023,
  ),
  const Book(
    id: '15',
    title: 'The Midnight Library Mystery',
    author: 'Evelyn Hayes',
    description:
        'A cozy mystery where rare book manuscripts hold answers to murder.',
    synopsis:
        'When the curator of the Royal Archival Library is found poisoned in the restricted rare vaults, assistant librarian Nora Hart relies on marginalia notes left in 17th-century texts to unmask the killer before the next manuscript vanishes.',
    rating: 4.5,
    genre: 'Mystery',
    pages: 330,
    publishYear: 2024,
  ),
  const Book(
    id: '16',
    title: 'Voices from the Singularity',
    author: 'Kenji Sato',
    description:
        'Deep dive into autonomous AI agents, alignment, and synthetic ethics.',
    synopsis:
        'Sato analyzes the rapidly evolving ecosystem of autonomous agent architectures, exploring self-improving reasoning loops, decision alignment, and the sociopolitical ramifications of artificial general intelligence.',
    rating: 4.9,
    genre: 'Technology',
    pages: 405,
    publishYear: 2025,
  ),
  const Book(
    id: '17',
    title: 'Tales from the Forgotten Realm',
    author: 'Garth Blackwood',
    description:
        'An anthology of mythical creatures, ancient oaths, and heroic quests.',
    synopsis:
        'Set across the enchanted archipelagos of Eldoria, this collection of interconnected fables recounts legendary dragons, cursed swords, and wandering bards whose songs alter the fabric of destiny itself.',
    rating: 4.6,
    genre: 'Fantasy',
    pages: 480,
    publishYear: 2022,
  ),
  const Book(
    id: '18',
    title: 'The Cipher of Alexandria',
    author: 'Helena Vance',
    description:
        'A pulse-pounding thriller surrounding an ancient decrypted papyrus.',
    synopsis:
        'Cryptographer Dr. Julian Blake decodes a fragment from the Great Library of Alexandria, discovering coordinates to an underground vault hidden in Cairo. With mercenary groups pursuing him, Julian must solve ancient riddles before history is rewritten.',
    rating: 4.7,
    genre: 'Thriller',
    pages: 445,
    publishYear: 2023,
  ),
  const Book(
    id: '19',
    title: 'The Last Beacon of Hope',
    author: 'Darius Croft',
    description:
        'Humanity\'s final colony ship searches for a hospitable world.',
    synopsis:
        'Aboard the generation ship *Astraea*, third-generation engineer Valerie detects an anomaly in deep space that might be a habitable exoplanet—or a lethal trap set by an ancient alien intelligence.',
    rating: 4.8,
    genre: 'Sci-Fi',
    pages: 510,
    publishYear: 2024,
  ),
  const Book(
    id: '20',
    title: 'Beyond the Horizon Line',
    author: 'Amara Okafor',
    description:
        'An inspiring account of solo oceanic navigation and marine ecology.',
    synopsis:
        'Okafor recounts her 300-day solo circumnavigation of the globe, blending peril on open seas with moving observations of marine conservation, whale migration, and human resilience under extreme isolation.',
    rating: 4.9,
    genre: 'Non-Fiction',
    pages: 360,
    publishYear: 2025,
  ),
  const Book(
    id: '21',
    title: 'The Haunted Manor of Blackwood',
    author: 'Edgar Sterling',
    description:
        'A chilling gothic horror story of ancestral curses and phantoms.',
    synopsis:
        'When Clara inherits her family\'s secluded estate in foggy Yorkshire, she uncovers eerie journal entries detailing a dark pact made by her ancestors. As shadows lengthen, nightmarish visions haunt the grand halls.',
    rating: 4.4,
    genre: 'Horror',
    pages: 275,
    publishYear: 2023,
  ),
  const Book(
    id: '22',
    title: 'The Renaissance Pioneer',
    author: 'Catherine DuPont',
    description:
        'The definitive biography of an unsung female polymath of 16th century Florence.',
    synopsis:
        'DuPont brings to life the story of Camilla Rossi, an extraordinary Florentine astronomer, inventor, and philosopher whose groundbreaking treatises influenced Galileo and Kepler despite societal restrictions.',
    rating: 4.8,
    genre: 'Biography',
    pages: 490,
    publishYear: 2022,
  ),
  const Book(
    id: '23',
    title: 'Chasing the Solstice Cloud',
    author: 'Nicolette Blanc',
    description:
        'A whimsical literary tale of artists, cloud-watchers, and summer dreams.',
    synopsis:
        'In a picturesque village high in the French Alps, a quirky group of meteorologists and painters gather every summer solstice to paint rare cloud formations, forging deep friendships and transforming their perspectives on life.',
    rating: 4.6,
    genre: 'Fiction',
    pages: 340,
    publishYear: 2024,
  ),
  const Book(
    id: '24',
    title: 'The Silicon Frontier',
    author: 'Marcus Sterling',
    description:
        'Inside the race for quantum computing supremacy and next-gen hardware.',
    synopsis:
        'Sterling gives a riveting behind-the-scenes account of the rival laboratories pushing quantum processors to room-temperature stability, detailing the engineering breakthroughs and intellectual property battles redefining computing.',
    rating: 4.7,
    genre: 'Technology',
    pages: 385,
    publishYear: 2025,
  ),
  const Book(
    id: '25',
    title: 'Curse of the Sunken Kingdom',
    author: 'Rowan Thornwood',
    description:
        'An underwater fantasy world filled with sea dragons and merfolk lore.',
    synopsis:
        'Beneath the turbulent waves of the Abyssal Ocean, Princess Nerida must reclaim her rightful throne from a usurper king who has summoned dark leviathans to enslave the undersea kingdoms.',
    rating: 4.8,
    genre: 'Fantasy',
    pages: 570,
    publishYear: 2023,
  ),
];
