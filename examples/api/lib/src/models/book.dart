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
];
