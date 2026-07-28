-- Rever: Full seed — topics, sources, concepts, and learning objects
-- Run AFTER 001_initial_schema.sql
-- All IDs are hardcoded so relationships are deterministic

-- ==================== TOPICS ====================

INSERT INTO topics (id, name, slug, description, icon, color, sort_order) VALUES
    ('a0000001-0000-0000-0000-000000000001', 'Technology',  'technology',  'Computers, software, and digital systems',         'code',                '#6C63FF', 1),
    ('a0000001-0000-0000-0000-000000000002', 'Science',     'science',     'Physics, chemistry, biology and more',             'biotech',             '#00D9A6', 2),
    ('a0000001-0000-0000-0000-000000000003', 'Mathematics', 'mathematics', 'Numbers, patterns, and logical reasoning',          'calculate',           '#FF6B6B', 3),
    ('a0000001-0000-0000-0000-000000000004', 'History',     'history',     'Events, civilizations, and stories of the past',   'history',             '#FFD93D', 4),
    ('a0000001-0000-0000-0000-000000000005', 'Psychology',  'psychology',  'Mind, behavior, and human cognition',              'psychology',          '#8B83FF', 5),
    ('a0000001-0000-0000-0000-000000000006', 'Finance',     'finance',     'Money, investing, and financial literacy',         'account_balance',     '#00E6B3', 6),
    ('a0000001-0000-0000-0000-000000000007', 'Philosophy',  'philosophy',  'Thinking about thinking, existence, and knowledge', 'self_improvement',    '#FF8C42', 7),
    ('a0000001-0000-0000-0000-000000000008', 'Space',       'space',       'Astronomy, planets, stars, and the universe',      'rocket_launch',       '#4A90D9', 8),
    ('a0000001-0000-0000-0000-000000000009', 'Arts',        'arts',        'Visual arts, music, literature, and expression',   'palette',             '#E040FB', 9),
    ('a0000001-0000-0000-0000-000000000010', 'Health',      'health',      'Fitness, nutrition, medicine, and wellbeing',      'favorite',            '#00BCD4',10),
    ('a0000001-0000-0000-0000-000000000011', 'Nature',      'nature',      'Environment, ecology, plants, and animals',        'forest',              '#4CAF50',11),
    ('a0000001-0000-0000-0000-000000000012', 'Engineering', 'engineering', 'Mechanical, electrical, civil, industrial systems', 'precision_manufacturing', '#FF5722',12)
ON CONFLICT (slug) DO NOTHING;

-- ==================== SOURCES ====================

INSERT INTO sources (id, title, url, source_type, license) VALUES
    ('c0000001-0000-0000-0000-000000000001', 'Wikipedia — Transformer architecture',  'https://en.wikipedia.org/wiki/Transformer_(deep_learning_architecture)', 'article', 'CC-BY-SA'),
    ('c0000001-0000-0000-0000-000000000002', 'Khan Academy — Photosynthesis',         'https://www.khanacademy.org/science/biology/photosynthesis',             'article', 'CC-BY-NC-SA'),
    ('c0000001-0000-0000-0000-000000000003', 'Stanford Encyclopedia — Descartes',     'https://plato.stanford.edu/entries/descartes/',                          'article', 'CC-BY'),
    ('c0000001-0000-0000-0000-000000000004', 'NASA — Solar System Overview',          'https://solarsystem.nasa.gov/solar-system/our-solar-system/',            'article', 'Public Domain'),
    ('c0000001-0000-0000-0000-000000000005', 'Investopedia — Compound Interest',      'https://www.investopedia.com/terms/c/compoundinterest.asp',              'article', 'Editorial'),
    ('c0000001-0000-0000-0000-000000000006', 'Psychology Today — Classical Conditioning', 'https://www.psychologytoday.com/us/basics/classical-conditioning',    'article', 'Editorial'),
    ('c0000001-0000-0000-0000-000000000007', 'History.com — French Revolution',       'https://www.history.com/topics/france/french-revolution',              'article', 'Editorial'),
    ('c0000001-0000-0000-0000-000000000008', 'Brilliant — Calculus Fundamentals',      'https://brilliant.org/courses/calculus-fundamentals/',                  'article', 'Proprietary')
ON CONFLICT DO NOTHING;

-- ==================== TECHNOLOGY — 4 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0001-0000-0000-000000000001', 'How Transformers Work',
     'how-transformers-work',
     'Transformers are a neural network architecture that revolutionized AI by processing entire sequences in parallel using self-attention, enabling models like GPT and BERT.',
     'beginner', 8),
    ('b0000001-0001-0000-0000-000000000002', 'Machine Learning vs Deep Learning',
     'ml-vs-deep-learning',
     'Machine learning teaches computers to learn from data without explicit programming. Deep learning is a subset using multi-layered neural networks for complex patterns.',
     'beginner', 6),
    ('b0000001-0001-0000-0000-000000000003', 'How the Internet Works',
     'how-internet-works',
     'The internet is a global network of computers communicating via TCP/IP protocols. Data is broken into packets, routed through nodes, and reassembled at the destination.',
     'beginner', 5),
    ('b0000001-0001-0000-0000-000000000004', 'Encryption & Cybersecurity',
     'encryption-cybersecurity',
     'Encryption scrambles data using keys so only authorized parties can read it. It is the foundation of secure communication, online banking, and password protection.',
     'intermediate', 7)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0001-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000001'),
    ('b0000001-0001-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000001'),
    ('b0000001-0001-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000001'),
    ('b0000001-0001-0000-0000-000000000004', 'a0000001-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0001-0000-0000-000000000001', 'card', 'Transformer Architecture',
     '{"body": "A transformer is a deep learning architecture introduced in 2017 by Google researchers. Unlike older recurrent neural networks that processed data sequentially, transformers process entire sequences at once using a mechanism called self-attention. This parallelization made training much faster and enabled models to capture long-range dependencies in text. Transformers are the backbone of modern AI systems including GPT, BERT, Claude, and Gemini.",
       "key_points": ["Introduced in 2017 by Google in the paper Attention Is All You Need", "Uses self-attention to weigh the importance of different parts of the input", "Processes entire sequences in parallel, not sequentially", "Powers virtually all modern large language models"]}',
     'beginner', 120, 'c0000001-0000-0000-0000-000000000001'),
    ('b0000001-0001-0000-0000-000000000001', 'quiz', 'Transformer Quick Quiz',
     '{"questions": [{"question": "What year was the transformer architecture introduced?", "options": ["2015", "2017", "2019", "2021"], "correct_index": 1}, {"question": "What mechanism allows transformers to process entire sequences at once?", "options": ["Recurrence", "Convolution", "Self-attention", "Backpropagation"], "correct_index": 2}, {"question": "Which of these is NOT built on transformer architecture?", "options": ["GPT", "BERT", "Claude", "ResNet"], "correct_index": 3}]}',
     'beginner', 180, 'c0000001-0000-0000-0000-000000000001'),

    ('b0000001-0001-0000-0000-000000000002', 'card', 'ML vs Deep Learning',
     '{"body": "Machine learning is a broad field of artificial intelligence where computers learn patterns from data without being explicitly programmed for every rule. Algorithms like decision trees, SVM, and random forests fall under classic ML. Deep learning is a specialized subset where neural networks with many layers (hence deep) automatically learn hierarchical features. While classic ML often requires manual feature engineering, deep learning learns features directly from raw data, making it especially powerful for images, audio, and text.",
       "key_points": ["All deep learning is machine learning, but not all ML is deep learning", "Classic ML: random forests, SVMs, logistic regression (good for structured data)", "Deep learning: CNNs, RNNs, transformers (excels at unstructured data like images, text, audio)", "Deep learning needs more data and compute but often achieves higher accuracy"]}',
     'beginner', 90, null),

    ('b0000001-0001-0000-0000-000000000003', 'card', 'How the Internet Works',
     '{"body": "The internet is a global network of interconnected computers that communicate using standardized protocols, primarily TCP/IP. When you send data (like opening a webpage), your device breaks it into small packets. Each packet travels independently through routers, potentially taking different paths to the destination, where they are reassembled. This packet-switching design makes the internet resilient — if one route fails, packets automatically reroute. Your device is identified by an IP address, and domain names (like google.com) are translated to IP addresses by DNS servers.",
       "key_points": ["Data is broken into packets that travel independently", "TCP ensures reliable delivery, IP handles routing", "DNS translates domain names to IP addresses", "Packet switching makes the network fault-tolerant"]}',
     'beginner', 90, null),

    ('b0000001-0001-0000-0000-000000000004', 'card', 'Encryption Basics',
     '{"body": "Encryption is the process of scrambling data using a cryptographic key so that only someone with the matching key can read it. There are two main types: symmetric encryption uses the same key for encryption and decryption (like AES), while asymmetric encryption uses a public key to encrypt and a private key to decrypt (like RSA). HTTPS uses TLS/SSL to encrypt communication between your browser and websites, protecting passwords, credit cards, and personal data from eavesdroppers on the network.",
       "key_points": ["Symmetric encryption: same key for encrypt and decrypt (fast, used for bulk data)", "Asymmetric encryption: public/private key pair (slower, used for key exchange)", "HTTPS = HTTP + TLS/SSL encryption", "End-to-end encryption ensures only sender and receiver can read messages"]}',
     'intermediate', 120, null);
INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0001-0000-0000-000000000004', 'quiz', 'Cybersecurity Quiz',
     '{"questions": [{"question": "What does HTTPS add to regular HTTP?", "options": ["Faster speeds", "Encryption", "More storage", "Better graphics"], "correct_index": 1}, {"question": "In asymmetric encryption, which key can be shared publicly?", "options": ["Private key", "Secret key", "Public key", "Session key"], "correct_index": 2}]}',
     'intermediate', 120, null);

-- ==================== SCIENCE — 3 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0002-0000-0000-000000000001', 'Photosynthesis Explained',
     'photosynthesis',
     'Photosynthesis is how plants convert sunlight, water, and CO₂ into glucose and oxygen. It happens in chloroplasts through light-dependent and light-independent reactions.',
     'beginner', 6),
    ('b0000001-0002-0000-0000-000000000002', 'The Periodic Table',
     'periodic-table',
     'The periodic table organizes elements by atomic number, grouping them by chemical properties. Rows are periods, columns are groups with similar electron configurations.',
     'beginner', 7),
    ('b0000001-0002-0000-0000-000000000003', 'Evolution by Natural Selection',
     'natural-selection',
     'Darwin''s theory: organisms with traits better suited to their environment survive and reproduce more, passing those traits to future generations — driving species adaptation.',
     'intermediate', 8)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0002-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000002'),
    ('b0000001-0002-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000002'),
    ('b0000001-0002-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0002-0000-0000-000000000001', 'card', 'How Photosynthesis Works',
     '{"body": "Photosynthesis occurs in plant cells'' chloroplasts, which contain chlorophyll — the pigment that gives plants their green color and captures light energy. The process has two stages. In the light-dependent reactions, sunlight splits water molecules, releasing oxygen and creating energy carriers ATP and NADPH. In the Calvin cycle (light-independent), CO₂ is fixed into glucose using those energy carriers. The overall equation: 6CO₂ + 6H₂O + sunlight → C₆H₁₂O₆ + 6O₂.",
       "key_points": ["Chlorophyll in chloroplasts captures sunlight", "Light-dependent reactions: water split → O₂ released + ATP/NADPH produced", "Calvin cycle: CO₂ → glucose using ATP/NADPH", "Plants are the base of almost every food chain"]}',
     'beginner', 90, 'c0000001-0000-0000-0000-000000000002'),
    ('b0000001-0002-0000-0000-000000000001', 'quiz', 'Photosynthesis Quiz',
     '{"questions": [{"question": "Where does photosynthesis occur in a plant cell?", "options": ["Mitochondria", "Nucleus", "Chloroplast", "Ribosome"], "correct_index": 2}, {"question": "What gas is released during photosynthesis?", "options": ["CO₂", "Oxygen", "Nitrogen", "Hydrogen"], "correct_index": 1}, {"question": "Which pigment captures light energy?", "options": ["Melanin", "Chlorophyll", "Hemoglobin", "Carotene"], "correct_index": 1}]}',
     'beginner', 120, 'c0000001-0000-0000-0000-000000000002'),

    ('b0000001-0002-0000-0000-000000000002', 'card', 'The Periodic Table',
     '{"body": "The periodic table arranges 118 confirmed elements in order of increasing atomic number. Elements in the same column (group) have the same number of valence electrons, so they exhibit similar chemical behavior. For example, Group 1 (alkali metals) are highly reactive, while Group 18 (noble gases) are inert. Rows are called periods, and as you move across a period, atomic radius decreases while ionization energy increases. The table is divided into metals (left), non-metals (right), and metalloids (along the staircase).",
       "key_points": ["Elements arranged by increasing atomic number", "Groups (columns) share similar chemical properties due to same valence electron count", "Periods (rows) show trends in atomic radius and ionization energy", "Three broad categories: metals, non-metals, metalloids"]}',
     'beginner', 90, null),

    ('b0000001-0002-0000-0000-000000000003', 'card', 'Natural Selection',
     '{"body": "Natural selection, proposed by Charles Darwin in 1859, is the primary mechanism of evolution. The core idea is simple: individuals in a population vary in their traits. Some traits give individuals a survival or reproductive advantage in their specific environment. These individuals are more likely to survive, reproduce, and pass those advantageous traits to their offspring. Over generations, this process causes populations to become better adapted to their environment. Given enough time and isolation, populations can diverge into entirely new species.",
       "key_points": ["Variation exists naturally in all populations", "Traits that improve survival/reproduction are more likely to be passed on", "Adaptation happens gradually over generations, not within a single lifetime", "Fossil records and DNA evidence strongly support evolution"]}',
     'intermediate', 120, null);

-- ==================== MATHEMATICS — 3 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0003-0000-0000-000000000001', 'Probability Basics',
     'probability-basics',
     'Probability measures how likely an event is to occur, from 0 (impossible) to 1 (certain). Key concepts include independent events, conditional probability, and Bayes'' theorem.',
     'beginner', 6),
    ('b0000001-0003-0000-0000-000000000002', 'Calculus: Derivatives & Integrals',
     'calculus-derivatives-integrals',
     'Calculus studies change. Derivatives measure instantaneous rate of change (slope at a point). Integrals measure accumulated area under curves. They are inverse operations.',
     'intermediate', 10),
    ('b0000001-0003-0000-0000-000000000003', 'Statistical Thinking',
     'statistical-thinking',
     'Statistics is the science of collecting, analyzing, and interpreting data. Key ideas: mean/median/mode, standard deviation, correlation vs causation, and sampling.',
     'beginner', 7)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0003-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000003'),
    ('b0000001-0003-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000003'),
    ('b0000001-0003-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000003')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0003-0000-0000-000000000001', 'card', 'Understanding Probability',
     '{"body": "Probability is expressed as a number between 0 and 1, where 0 means impossible and 1 means certain. If you flip a fair coin, the probability of heads is 0.5. Two key rules: the multiplication rule for independent events (P(A and B) = P(A) × P(B)), and the addition rule for mutually exclusive events (P(A or B) = P(A) + P(B)). Conditional probability P(A|B) measures the probability of A given that B has occurred, which is the foundation of Bayes'' theorem used in machine learning and diagnostics.",
       "key_points": ["Probability ranges from 0 (impossible) to 1 (certain)", "Independent events: P(A and B) = P(A) × P(B)", "Conditional probability P(A|B) = P(A and B) / P(B)", "Bayes'' theorem updates beliefs based on new evidence"]}',
     'beginner', 90, null),
    ('b0000001-0003-0000-0000-000000000001', 'quiz', 'Probability Quiz',
     '{"questions": [{"question": "What is the probability of rolling a 6 on a fair die?", "options": ["1/2", "1/4", "1/6", "1/3"], "correct_index": 2}, {"question": "If you flip two fair coins, what is the probability both are heads?", "options": ["0.25", "0.5", "0.75", "1.0"], "correct_index": 0}]}',
     'beginner', 90, null),

    ('b0000001-0003-0000-0000-000000000002', 'card', 'Derivatives & Integrals',
     '{"body": "A derivative measures how a function changes as its input changes — essentially the slope at any point on a curve. If f(x) = x², the derivative f''(x) = 2x tells us the slope at any x. An integral measures the accumulated area under a curve between two points. The Fundamental Theorem of Calculus states that differentiation and integration are inverse operations: the integral of a derivative returns the original function. This relationship is why calculus is so powerful — it connects instantaneous rates to accumulated totals.",
       "key_points": ["Derivative = instantaneous rate of change (slope)", "Integral = accumulated area under curve", "Fundamental Theorem: integration and differentiation are inverses", "Real-world: velocity is derivative of position; distance is integral of velocity"]}',
     'intermediate', 150, 'c0000001-0000-0000-0000-000000000008'),

    ('b0000001-0003-0000-0000-000000000003', 'card', 'Thinking Statistically',
     '{"body": "Statistics helps us make sense of data. The mean (average) is sensitive to outliers, while median (middle value) is more robust. Standard deviation measures how spread out data is — a small SD means data clusters around the mean. A critical concept: correlation does not imply causation. Ice cream sales and drowning incidents both rise in summer (correlation), but eating ice cream doesn''t cause drowning — the hidden variable is hot weather. Statistical thinking means questioning sources of bias, sample size, and confounding variables before drawing conclusions.",
       "key_points": ["Mean is average; median is middle value (more robust to outliers)", "Standard deviation measures data spread", "Correlation ≠ causation — look for confounding variables", "Sample size and sampling method dramatically affect reliability"]}',
     'beginner', 90, null);

-- ==================== HISTORY — 3 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0004-0000-0000-000000000001', 'The French Revolution',
     'french-revolution',
     'The French Revolution (1789-1799) overthrew the monarchy, established a republic, and radically transformed French society. It was driven by inequality, financial crisis, and Enlightenment ideas.',
     'beginner', 8),
    ('b0000001-0004-0000-0000-000000000002', 'World War II Overview',
     'world-war-ii',
     'World War II (1939-1945) was the deadliest conflict in history, involving most of the world''s nations. It ended with Allied victory and reshaped global power structures.',
     'intermediate', 10),
    ('b0000001-0004-0000-0000-000000000003', 'The Industrial Revolution',
     'industrial-revolution',
     'The Industrial Revolution (1760-1840) shifted production from hand tools to machines, from human/animal power to steam engines, radically transforming economies and societies.',
     'beginner', 7)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0004-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000004'),
    ('b0000001-0004-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000004'),
    ('b0000001-0004-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000004')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0004-0000-0000-000000000001', 'card', 'The French Revolution',
     '{"body": "By 1789, France was deeply unequal: the clergy (First Estate) and nobility (Second Estate) paid no taxes, while the Third Estate (everyone else) bore the entire tax burden. Combined with a massive national debt from supporting the American Revolution and poor harvests, King Louis XVI was forced to call the Estates-General — the first meeting in 175 years. The Third Estate broke away to form the National Assembly, swearing the Tennis Court Oath to write a constitution. The storming of the Bastille on July 14, 1789, became the revolution''s symbol. The monarchy fell, Louis XVI was executed, and after a turbulent decade including the Reign of Terror, Napoleon Bonaparte seized power in 1799.",
       "key_points": ["Causes: economic crisis, inequality, Enlightenment ideals", "Storming of the Bastille (July 14, 1789) — national holiday in France", "Reign of Terror (1793-94): 40,000 executed under Robespierre", "Napoleon took over in 1799, ending the revolution"]}',
     'beginner', 120, 'c0000001-0000-0000-0000-000000000007'),
    ('b0000001-0004-0000-0000-000000000001', 'quiz', 'French Revolution Quiz',
     '{"questions": [{"question": "What date was the storming of the Bastille?", "options": ["July 4, 1776", "July 14, 1789", "August 15, 1792", "January 1, 1800"], "correct_index": 1}, {"question": "Which estate paid all the taxes?", "options": ["First Estate", "Second Estate", "Third Estate", "All equally"], "correct_index": 2}]}',
     'beginner', 90, 'c0000001-0000-0000-0000-000000000007'),

    ('b0000001-0004-0000-0000-000000000002', 'card', 'World War II',
     '{"body": "World War II began when Germany invaded Poland on September 1, 1939, prompting Britain and France to declare war. The war had two main theaters: Europe (Axis: Germany, Italy, Japan vs. Allies: UK, USSR, US, France) and the Pacific (Japan vs. US). Key events include the Battle of Britain (1940), Germany''s invasion of the USSR (1941), Pearl Harbor and US entry (1941), D-Day (1944), and the atomic bombings of Hiroshima and Nagasaki (1945). The war resulted in 70-85 million deaths, the Holocaust, the creation of the UN, and the beginning of the Cold War.",
       "key_points": ["70-85 million deaths — deadliest conflict in history", "Axis powers: Germany, Italy, Japan | Allies: UK, USSR, US, China, France", "The Holocaust: 6 million Jews systematically murdered", "Ended with atomic bombs and unconditional surrender of Axis powers"]}',
     'intermediate', 150, null),

    ('b0000001-0004-0000-0000-000000000003', 'card', 'The Industrial Revolution',
     '{"body": "The Industrial Revolution began in Britain around 1760, driven by coal, iron, and technological innovation. Key inventions: the steam engine (Watt), spinning jenny (Hargreaves), and the cotton gin (Whitney). Factories centralized production, drawing rural populations into rapidly growing cities. The revolution brought immense economic growth but also child labor, dangerous working conditions, and pollution. By 1840, Britain had become the world''s first industrial nation, and the revolution spread to Europe and North America, fundamentally changing how humans live and work.",
       "key_points": ["Began in Britain around 1760 — driven by coal, iron, steam", "Major inventions: steam engine, spinning jenny, cotton gin", "Urbanization: people moved from farms to factory cities", "Negative impacts: child labor, overcrowding, pollution"]}',
     'beginner', 90, null);

-- ==================== PSYCHOLOGY — 3 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0005-0000-0000-000000000001', 'Classical Conditioning',
     'classical-conditioning',
     'Classical conditioning, discovered by Pavlov, is a learning process where a neutral stimulus becomes associated with a response through repeated pairing with a naturally triggering stimulus.',
     'beginner', 5),
    ('b0000001-0005-0000-0000-000000000002', 'Cognitive Biases',
     'cognitive-biases',
     'Cognitive biases are systematic patterns of deviation from rational judgment. They are mental shortcuts (heuristics) that evolved to help us decide quickly but often lead to errors.',
     'beginner', 6),
    ('b0000001-0005-0000-0000-000000000003', 'The Growth Mindset',
     'growth-mindset',
     'Carol Dweck''s theory: people with a growth mindset believe abilities can be developed through effort, while a fixed mindset sees abilities as innate and unchangeable.',
     'beginner', 5)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0005-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000005'),
    ('b0000001-0005-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000005'),
    ('b0000001-0005-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000005')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0005-0000-0000-000000000001', 'card', 'Classical Conditioning',
     '{"body": "Ivan Pavlov famously discovered classical conditioning while studying digestion in dogs. He noticed that dogs would salivate not just when food touched their tongues, but also when they saw the lab assistant who usually fed them. In his experiment: food (unconditioned stimulus) naturally triggers salivation (unconditioned response). By repeatedly ringing a bell (neutral stimulus) before presenting food, the bell alone eventually triggered salivation — now a conditioned response. This basic learning mechanism explains everything from phobias to advertising jingles to emotional reactions to songs.",
       "key_points": ["Unconditioned stimulus naturally triggers a response", "Neutral stimulus is paired repeatedly with UCS", "After conditioning, neutral stimulus alone triggers the response", "Explains phobias, habits, emotional associations"]}',
     'beginner', 90, 'c0000001-0000-0000-0000-000000000006'),
    ('b0000001-0005-0000-0000-000000000001', 'quiz', 'Classical Conditioning Quiz',
     '{"questions": [{"question": "Who discovered classical conditioning?", "options": ["Freud", "Pavlov", "Skinner", "Piaget"], "correct_index": 1}, {"question": "In Pavlov''s experiment, the bell started as a:", "options": ["Unconditioned stimulus", "Conditioned response", "Neutral stimulus", "Reinforcer"], "correct_index": 2}, {"question": "When the bell alone triggers salivation, salivation is now a:", "options": ["Conditioned response", "Unconditioned response", "Neutral response", "Reflex"], "correct_index": 0}]}',
     'beginner', 120, 'c0000001-0000-0000-0000-000000000006'),

    ('b0000001-0005-0000-0000-000000000002', 'card', 'Cognitive Biases',
     '{"body": "Cognitive biases are mental shortcuts that help us make quick decisions but can systematically lead us astray. Confirmation bias: we favor information that confirms our existing beliefs. Availability heuristic: we judge the likelihood of events by how easily examples come to mind (making rare dramatic events seem more common). Anchoring bias: we rely too heavily on the first piece of information we receive. Dunning-Kruger effect: people with low ability overestimate their skill, while experts underestimate theirs. Recognizing these biases is the first step to making better decisions.",
       "key_points": ["Confirmation bias: seek evidence that supports our views", "Availability heuristic: vivid examples feel more probable", "Anchoring: first information disproportionately influences judgment", "Dunning-Kruger: unskilled overestimate, skilled underestimate"]}',
     'beginner', 90, null),

    ('b0000001-0005-0000-0000-000000000003', 'card', 'Growth Mindset',
     '{"body": "Stanford psychologist Carol Dweck identified two mindsets after decades of research. Fixed mindset: intelligence and talent are static givens. People with this mindset avoid challenges (to protect their ego), give up easily, ignore feedback, and feel threatened by others'' success. Growth mindset: intelligence can be developed through effort, learning, and persistence. These people embrace challenges, persist through setbacks, learn from criticism, and find inspiration in others'' success. Dweck''s research shows that teaching a growth mindset improves academic achievement, especially for struggling students.",
       "key_points": ["Fixed mindset: talent is innate, avoid challenges, give up easily", "Growth mindset: ability can grow, embrace challenges, persist", "Mindset can be changed through specific interventions", "Praises effort and strategy, not intelligence"]}',
     'beginner', 90, null);

-- ==================== FINANCE — 3 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0006-0000-0000-000000000001', 'Compound Interest',
     'compound-interest',
     'Compound interest is interest earned on both the initial principal AND accumulated interest. It makes money grow exponentially over time — the most powerful force in finance.',
     'beginner', 5),
    ('b0000001-0006-0000-0000-000000000002', 'Stock Market Basics',
     'stock-market-basics',
     'The stock market lets people buy and own shares of public companies. Prices fluctuate based on supply, demand, and company performance. Long-term investing historically yields ~7-10% annual returns.',
     'beginner', 7),
    ('b0000001-0006-0000-0000-000000000003', 'Budgeting & Saving',
     'budgeting-saving',
     'A budget tracks income vs expenses. The 50/30/20 rule allocates 50% to needs, 30% to wants, 20% to savings. Building an emergency fund of 3-6 months of expenses is the first financial goal.',
     'beginner', 5)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0006-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000006'),
    ('b0000001-0006-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000006'),
    ('b0000001-0006-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000006')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0006-0000-0000-000000000001', 'card', 'Compound Interest',
     '{"body": "Albert Einstein reportedly called compound interest the eighth wonder of the world. If you invest $1,000 at 10% annual return, after year 1 you have $1,100. Year 2: you earn 10% on $1,100 = $1,210. Year 3: $1,331. After 30 years, that $1,000 grows to $17,449 — without adding a single additional dollar! This exponential growth is why starting early matters enormously. The Rule of 72 estimates doubling time: 72 ÷ annual interest rate = years to double. At 10%, your money doubles every 7.2 years.",
       "key_points": ["Interest earned on both principal AND accumulated interest", "Exponential growth: small amounts become huge over decades", "Rule of 72: 72 ÷ rate = years to double your money", "Starting early is the single biggest factor in wealth building"]}',
     'beginner', 90, 'c0000001-0000-0000-0000-000000000005'),
    ('b0000001-0006-0000-0000-000000000001', 'quiz', 'Compound Interest Quiz',
     '{"questions": [{"question": "The Rule of 72 estimates:", "options": ["Tax rate", "Doubling time", "Inflation rate", "Risk level"], "correct_index": 1}, {"question": "If you invest $100 at 10% for 20 years, roughly how much do you have?", "options": ["$300", "$672", "$1,000", "$2,000"], "correct_index": 1}]}',
     'beginner', 90, 'c0000001-0000-0000-0000-000000000005'),

    ('b0000001-0006-0000-0000-000000000002', 'card', 'Stock Market Basics',
     '{"body": "A stock represents partial ownership in a company. When you buy a share of Apple, you own a tiny piece of Apple. Companies issue stock to raise capital, and investors buy stock hoping the company will grow and the share price will rise. The stock market (like NYSE or Nasdaq) is where these shares are traded. Prices fluctuate daily based on news, earnings reports, market sentiment, and economic data. Over the long term (20+ years), the S&P 500 has returned about 10% annually before inflation (~7% after).",
       "key_points": ["A stock = partial ownership of a company", "Stock exchanges (NYSE, Nasdaq) facilitate buying and selling", "Long-term S&P 500 returns: ~10%/year before inflation", "Diversification across many stocks reduces risk"]}',
     'beginner', 90, null),

    ('b0000001-0006-0000-0000-000000000003', 'card', 'Budgeting & Saving',
     '{"body": "Budgeting is simply telling your money where to go instead of wondering where it went. The 50/30/20 rule is a simple framework: 50% of after-tax income goes to needs (housing, food, utilities, transportation), 30% to wants (entertainment, dining out, hobbies), and 20% to savings and debt repayment. Before investing, build an emergency fund covering 3-6 months of essential expenses. Then focus on high-interest debt (credit cards), then retirement accounts (401k, IRA), then other investments.",
       "key_points": ["50/30/20 rule: needs/wants/savings", "Emergency fund: 3-6 months of essential expenses first", "Pay off high-interest debt before investing", "Automate savings so you pay yourself first"]}',
     'beginner', 90, null);

-- ==================== PHILOSOPHY — 2 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0007-0000-0000-000000000001', 'Descartes: I Think, Therefore I Am',
     'descartes-cogito',
     'René Descartes doubted everything he could possibly doubt until he reached one certainty: the very act of doubting proves a thinking self exists — Cogito, ergo sum.',
     'intermediate', 6),
    ('b0000001-0007-0000-0000-000000000002', 'The Trolley Problem',
     'trolley-problem',
     'The trolley problem is an ethical thought experiment: should you pull a lever to divert a runaway trolley from killing five people to killing one? It explores utilitarian vs deontological ethics.',
     'beginner', 5)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0007-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000007'),
    ('b0000001-0007-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000007')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0007-0000-0000-000000000001', 'card', 'Descartes — Cogito Ergo Sum',
     '{"body": "René Descartes was a 17th-century French philosopher who wanted to find absolutely certain knowledge. He used a method of radical doubt: he would doubt anything that could possibly be false. He doubted his senses (they sometimes deceive us), his body (he might be dreaming), even the external world (an evil demon could be tricking him). But he realized that the very act of doubting requires a thinking entity doing the doubting. This led to his famous conclusion: Cogito, ergo sum — I think, therefore I am. This became the foundation of modern Western philosophy, establishing that the mind is better known than the body.",
       "key_points": ["Method of radical doubt: doubt everything possible", "Even if an evil demon deceives me, I must exist to be deceived", "Cogito ergo sum: the first certainty — thinking proves existence", "Mind-body dualism: mind and body are separate substances"]}',
     'intermediate', 120, 'c0000001-0000-0000-0000-000000000003'),
    ('b0000001-0007-0000-0000-000000000001', 'quiz', 'Descartes Quiz',
     '{"questions": [{"question": "What did Descartes conclude was absolutely certain?", "options": ["The existence of God", "The existence of the external world", "His own existence as a thinking thing", "The reliability of senses"], "correct_index": 2}, {"question": "What method did Descartes use?", "options": ["Empirical observation", "Radical doubt", "Faith-based reasoning", "Logical positivism"], "correct_index": 1}]}',
     'intermediate', 90, 'c0000001-0000-0000-0000-000000000003'),

    ('b0000001-0007-0000-0000-000000000002', 'card', 'The Trolley Problem',
     '{"body": "The trolley problem, introduced by philosopher Philippa Foot in 1967, asks: a runaway trolley is barreling toward five people tied to the track. You can pull a lever to divert it onto a side track with one person. Should you? Utilitarians say yes — save five at the cost of one (maximize total well-being). Deontologists say no — actively diverting the trolley makes you responsible for the one death, violating the duty not to kill. This simple scenario reveals deep tensions in moral philosophy and has real-world applications in self-driving car ethics and military drone decision-making.",
       "key_points": ["Utilitarianism: choose the action that produces the best outcome for the most people", "Deontology: follow moral rules regardless of consequences", "The lever-pulling version vs the fat man pushing version change the moral calculus", "Relevant to AI ethics: how should autonomous vehicles prioritize lives?"]}',
     'beginner', 90, null);

-- ==================== SPACE — 3 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0008-0000-0000-000000000001', 'The Solar System',
     'the-solar-system',
     'Our solar system has one star (the Sun), eight planets, five dwarf planets, and countless smaller bodies orbiting due to gravity. Inner planets are rocky; outer planets are gas giants.',
     'beginner', 6),
    ('b0000001-0008-0000-0000-000000000002', 'Black Holes',
     'black-holes',
     'A black hole is a region of spacetime where gravity is so strong that nothing — not even light — can escape. They form when massive stars collapse under their own gravity.',
     'intermediate', 7),
    ('b0000001-0008-0000-0000-000000000003', 'The Big Bang Theory',
     'big-bang-theory',
     'The Big Bang theory describes the universe''s origin ~13.8 billion years ago from an infinitely hot, dense point. Space itself has been expanding ever since, forming galaxies and stars.',
     'beginner', 6)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0008-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000008'),
    ('b0000001-0008-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000008'),
    ('b0000001-0008-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000008')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0008-0000-0000-000000000001', 'card', 'Our Solar System',
     '{"body": "The Sun contains 99.86% of all mass in the solar system. The eight planets are split into two groups. Inner planets (Mercury, Venus, Earth, Mars) are rocky and relatively small. Outer planets (Jupiter, Saturn, Uranus, Neptune) are gas or ice giants with rings and many moons. Beyond Neptune lies the Kuiper Belt with dwarf planets like Pluto. The solar system formed from a rotating cloud of gas and dust about 4.6 billion years ago, with the Sun igniting at the center and planets accreting from the surrounding disk.",
       "key_points": ["99.86% of the solar system''s mass is in the Sun", "Inner planets: rocky, small — Mercury, Venus, Earth, Mars", "Outer planets: gas/ice giants — Jupiter, Saturn, Uranus, Neptune", "The solar system is 4.6 billion years old"]}',
     'beginner', 90, 'c0000001-0000-0000-0000-000000000004'),
    ('b0000001-0008-0000-0000-000000000001', 'quiz', 'Solar System Quiz',
     '{"questions": [{"question": "How many planets are in our solar system?", "options": ["7", "8", "9", "10"], "correct_index": 1}, {"question": "Which planet is known as the Red Planet?", "options": ["Venus", "Jupiter", "Mars", "Saturn"], "correct_index": 2}, {"question": "What is the largest planet?", "options": ["Saturn", "Neptune", "Jupiter", "Uranus"], "correct_index": 2}]}',
     'beginner', 120, 'c0000001-0000-0000-0000-000000000004'),

    ('b0000001-0008-0000-0000-000000000002', 'card', 'Black Holes',
     '{"body": "A black hole forms when a massive star (at least 20 times the Sun''s mass) runs out of nuclear fuel and collapses under its own gravity. The core compresses into an infinitely dense point called a singularity. The event horizon is the boundary beyond which nothing can escape. There are three types: stellar-mass (a few to 100 solar masses), supermassive (millions to billions of solar masses at centers of galaxies), and intermediate. In 2019, the Event Horizon Telescope captured the first-ever image of a black hole in galaxy M87.",
       "key_points": ["Formed by the collapse of massive stars", "Event horizon: point of no return — not even light escapes", "Supermassive black holes exist at the center of most galaxies", "First direct image captured in 2019 (M87)"]}',
     'intermediate', 120, null),

    ('b0000001-0008-0000-0000-000000000003', 'card', 'The Big Bang',
     '{"body": "The Big Bang wasn''t an explosion in space — it was the expansion of space itself. About 13.8 billion years ago, all matter, energy, and spacetime were compressed into an infinitely hot, dense singularity. It began expanding, cooling as it grew. Within seconds, fundamental particles formed. After 380,000 years, atoms formed, releasing the cosmic microwave background radiation we still detect today. Over billions of years, gravity pulled matter into galaxies, stars, and planets. Evidence includes cosmic expansion (redshift), the CMB, and abundance of light elements.",
       "key_points": ["The universe began ~13.8 billion years ago from a hot, dense state", "Space itself is expanding — galaxies are moving apart", "Cosmic microwave background is the afterglow of the Big Bang", "All evidence confirms the theory: redshift, CMB, element abundance"]}',
     'beginner', 90, 'c0000001-0000-0000-0000-000000000004');

-- ==================== ARTS — 2 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0009-0000-0000-000000000001', 'The Renaissance',
     'the-renaissance',
     'The Renaissance (14th-17th century) was a rebirth of art, science, and culture in Europe, rediscovering classical knowledge and producing masters like da Vinci and Michelangelo.',
     'beginner', 6),
    ('b0000001-0009-0000-0000-000000000002', 'Color Theory in Art',
     'color-theory-art',
     'Color theory explains how colors interact, harmonize, and evoke emotions. The color wheel, complementary colors, and color harmony are foundational tools for artists and designers.',
     'beginner', 5)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0009-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000009'),
    ('b0000001-0009-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000009')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0009-0000-0000-000000000001', 'card', 'The Renaissance',
     '{"body": "The Renaissance began in 14th-century Florence and spread across Europe. It marked a shift from medieval religious focus to humanism — celebrating human potential and achievement. Artists developed linear perspective, realistic anatomy, and chiaroscuro (light-shadow contrast). Leonardo da Vinci''s Mona Lisa and The Last Supper, Michelangelo''s Sistine Chapel ceiling and David, and Raphael''s School of Athens represent the period''s peak. The printing press (Gutenberg, 1440) revolutionized knowledge sharing. Science advanced with Copernicus, Galileo, and the scientific method.",
       "key_points": ["Began in Florence, Italy in the 14th century", "Humanism: focus on human potential and classical learning", "Master artists: da Vinci, Michelangelo, Raphael", "Innovations: perspective, anatomy, printing press"]}',
     'beginner', 90, null),

    ('b0000001-0009-0000-0000-000000000002', 'card', 'Color Theory',
     '{"body": "Color theory begins with the color wheel: primary colors (red, blue, yellow) mix to create secondary colors (orange, green, purple), which mix to create tertiary colors. Complementary colors are opposite on the wheel (blue/orange, red/green) and create strong contrast. Analogous colors are adjacent (blue, blue-green, green) and create harmony. Colors evoke emotions: red = energy/passion, blue = calm/trust, yellow = optimism, green = nature/peace. Artists and designers use these principles deliberately to create mood and guide viewer attention.",
       "key_points": ["Primary: red, blue, yellow → Secondary: orange, green, purple", "Complementary colors (opposite) = high contrast", "Analogous colors (adjacent) = harmonious", "Colors evoke psychological responses"]}',
     'beginner', 90, null);

-- ==================== HEALTH — 2 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0010-0000-0000-000000000001', 'How Sleep Works',
     'how-sleep-works',
     'Sleep is a complex biological process with multiple stages. It is essential for memory consolidation, immune function, toxin clearance from the brain, and emotional regulation.',
     'beginner', 6),
    ('b0000001-0010-0000-0000-000000000002', 'Nutrition Fundamentals',
     'nutrition-fundamentals',
     'Nutrition is the science of how food affects the body. Macronutrients (carbs, proteins, fats) provide energy and building blocks. Micronutrients (vitamins, minerals) support biochemical processes.',
     'beginner', 6)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0010-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000010'),
    ('b0000001-0010-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000010')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0010-0000-0000-000000000001', 'card', 'The Science of Sleep',
     '{"body": "Sleep consists of 90-minute cycles that alternate between NREM (non-rapid eye movement) and REM (rapid eye movement) sleep. NREM has three stages: N1 (light sleep, easily woken), N2 (deeper sleep — 50% of total sleep), and N3 (deep sleep or slow-wave sleep — crucial for physical restoration). REM sleep is when most dreaming occurs and is critical for memory consolidation. Adults need 7-9 hours per night. Chronic sleep deprivation increases risk of heart disease, diabetes, obesity, depression, and impaired cognitive function.",
       "key_points": ["Sleep cycles through NREM and REM every ~90 minutes", "Deep sleep (N3) = physical restoration", "REM sleep = memory consolidation and dreaming", "7-9 hours needed for adults — chronic deprivation has serious health consequences"]}',
     'beginner', 90, null),
    ('b0000001-0010-0000-0000-000000000001', 'quiz', 'Sleep Quiz',
     '{"questions": [{"question": "How long is a typical sleep cycle?", "options": ["30 minutes", "60 minutes", "90 minutes", "120 minutes"], "correct_index": 2}, {"question": "Which sleep stage is most important for memory consolidation?", "options": ["N1", "N2", "N3", "REM"], "correct_index": 3}]}',
     'beginner', 90, null),

    ('b0000001-0010-0000-0000-000000000002', 'card', 'Nutrition Basics',
     '{"body": "Macronutrients: carbohydrates (4 cal/g) are the body''s preferred energy source, proteins (4 cal/g) are for building and repairing tissues, and fats (9 cal/g) are essential for hormone production and nutrient absorption. Micronutrients: vitamins (organic) and minerals (inorganic) are needed in smaller amounts but are critical for enzyme function, immune health, and bone strength. A balanced diet includes vegetables, fruits, whole grains, lean proteins, and healthy fats. The plate method: ½ vegetables and fruits, ¼ protein, ¼ whole grains.",
       "key_points": ["Carbs = energy, Protein = building, Fat = hormones and absorption", "Vitamins and minerals are essential in small amounts", "Whole, minimally processed foods are most nutritious", "Plate method: ½ veggies/fruit, ¼ protein, ¼ grains"]}',
     'beginner', 90, null);

-- ==================== NATURE — 2 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0011-0000-0000-000000000001', 'The Water Cycle',
     'the-water-cycle',
     'Water continuously moves through Earth''s systems: evaporation from oceans and lakes, condensation into clouds, precipitation as rain/snow, and collection back into water bodies.',
     'beginner', 4),
    ('b0000001-0011-0000-0000-000000000002', 'Ecosystems & Biodiversity',
     'ecosystems-biodiversity',
     'An ecosystem is a community of living organisms interacting with their environment. Biodiversity — the variety of life — makes ecosystems resilient and provides essential services to humans.',
     'beginner', 6)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0011-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000011'),
    ('b0000001-0011-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000011')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0011-0000-0000-000000000001', 'card', 'The Water Cycle',
     '{"body": "Earth''s water is constantly recycled through four main processes. Evaporation: the sun heats water in oceans, lakes, and rivers, turning it into water vapor. Transpiration: plants also release water vapor through their leaves. Condensation: as water vapor rises, it cools and forms clouds. Precipitation: when clouds become heavy, water falls as rain, snow, sleet, or hail. Collection: water returns to oceans, lakes, and rivers — or soaks into the ground as groundwater. This cycle has been running for billions of years and the same water molecules are recycled over and over.",
       "key_points": ["Evaporation: liquid water → vapor (from sun''s heat)", "Condensation: vapor → clouds (cooling)", "Precipitation: water falls as rain/snow", "Collection: water returns to oceans and groundwater"]}',
     'beginner', 60, null),

    ('b0000001-0011-0000-0000-000000000002', 'card', 'Ecosystems & Biodiversity',
     '{"body": "An ecosystem includes all living things (plants, animals, microorganisms) in an area and their physical environment (soil, water, air). Energy flows through ecosystems via food chains: producers (plants) → primary consumers (herbivores) → secondary consumers (carnivores) → decomposers. Biodiversity — the variety of species, genes, and ecosystems — is crucial. Diverse ecosystems are more productive and resilient to disturbances. Human activities: deforestation, pollution, climate change, and overexploitation are causing a mass extinction event. Protecting biodiversity is not just ethical — it provides food, medicine, clean water, and climate regulation.",
       "key_points": ["Ecosystem = living community + physical environment", "Energy flows: producers → consumers → decomposers", "Biodiversity increases resilience and productivity", "Human activities are causing the 6th mass extinction"]}',
     'beginner', 90, null);

-- ==================== ENGINEERING — 2 concepts ====================

INSERT INTO concepts (id, title, slug, summary, difficulty, estimated_minutes) VALUES
    ('b0000001-0012-0000-0000-000000000001', 'How Bridges Work',
     'how-bridges-work',
     'Bridges manage two fundamental forces: compression (pushing) and tension (pulling). Different designs — beam, arch, suspension, cable-stayed — distribute these forces in different ways.',
     'beginner', 5),
    ('b0000001-0012-0000-0000-000000000002', 'Electrical Circuits Basics',
     'electrical-circuits',
     'An electrical circuit provides a closed path for current to flow. Voltage pushes, current flows, resistance opposes. Series circuits share current; parallel circuits share voltage.',
     'beginner', 6)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO concept_topics (concept_id, topic_id) VALUES
    ('b0000001-0012-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000012'),
    ('b0000001-0012-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000012')
ON CONFLICT DO NOTHING;

INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0012-0000-0000-000000000001', 'card', 'Bridge Engineering',
     '{"body": "Every bridge manages two forces: compression (forces pushing inward) and tension (forces pulling apart). A beam bridge spans simple distances — the beam bends under load, compressing the top and stretching the bottom. An arch bridge elegantly converts vertical load into compression along the curve, making it very strong. Suspension bridges (like the Golden Gate) use cables in tension to support the deck from above, enabling the longest spans. Cable-stayed bridges use direct cables from towers to deck for medium-long spans. The material choice — stone, steel, concrete — depends on which forces dominate.",
       "key_points": ["Compression: pushing force — handled well by stone/concrete", "Tension: pulling force — handled well by steel cables", "Arch bridges: convert load into compression along curve", "Suspension bridges: longest spans, cables in tension"]}',
     'beginner', 90, null),

    ('b0000001-0012-0000-0000-000000000002', 'card', 'Electrical Circuits',
     '{"body": "Electricity requires a complete circuit to flow. Voltage (V) is the electrical pressure that pushes current through a circuit — measured in volts. Current (I) is the flow of electrons — measured in amps. Resistance (R) opposes current flow — measured in ohms. Ohm''s Law (V = IR) relates all three. A series circuit has one path — current is the same everywhere, but voltage divides across components. A parallel circuit has multiple paths — voltage is the same across each branch, but current divides. This is why household wiring is parallel: all outlets get the same voltage (120V) regardless of what else is on.",
       "key_points": ["Voltage pushes, current flows, resistance opposes", "Ohm''s Law: V = I × R", "Series: same current, voltage divides", "Parallel: same voltage, current divides"]}',
     'beginner', 90, null);
INSERT INTO learning_objects (concept_id, object_type, title, content, difficulty, estimated_duration, source_id) VALUES
    ('b0000001-0012-0000-0000-000000000002', 'quiz', 'Circuits Quiz',
     '{"questions": [{"question": "What does Ohm''s Law state?", "options": ["V = I × R", "V = I + R", "V = I / R", "V = R / I"], "correct_index": 0}, {"question": "In a parallel circuit, what is the same across all branches?", "options": ["Current", "Resistance", "Voltage", "Power"], "correct_index": 2}]}',
     'beginner', 90, null);
