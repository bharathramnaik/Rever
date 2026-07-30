CREATE TABLE quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    author TEXT NOT NULL,
    source TEXT,
    category TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "quotes_read" ON quotes FOR SELECT USING (true);

INSERT INTO quotes (text, author, source, category) VALUES
('The only true wisdom is in knowing you know nothing.', 'Socrates', 'Plato''s Apology', 'wisdom'),
('The unexamined life is not worth living.', 'Socrates', 'Plato''s Apology', 'philosophy'),
('Cogito, ergo sum — I think, therefore I am.', 'René Descartes', 'Meditations on First Philosophy', 'philosophy'),
('The greatest glory in living lies not in never falling, but in rising every time we fall.', 'Nelson Mandela', 'Long Walk to Freedom', 'perseverance'),
('The way to get started is to quit talking and begin doing.', 'Walt Disney', NULL, 'action'),
('Your time is limited, so don''t waste it living someone else''s life.', 'Steve Jobs', 'Stanford Commencement', 'life'),
('The future belongs to those who believe in the beauty of their dreams.', 'Eleanor Roosevelt', NULL, 'dreams'),
('If you look at what you have in life, you''ll always have more.', 'Oprah Winfrey', NULL, 'gratitude'),
('Life is what happens when you''re busy making other plans.', 'John Lennon', 'Beautiful Boy', 'life'),
('Spread love everywhere you go. Let no one ever come to you without leaving happier.', 'Mother Teresa', NULL, 'love'),
('Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.', 'Buddha', NULL, 'mindfulness'),
('The only impossible journey is the one you never begin.', 'Tony Robbins', NULL, 'action'),
('It is during our darkest moments that we must focus to see the light.', 'Aristotle', NULL, 'hope'),
('In the middle of difficulty lies opportunity.', 'Albert Einstein', NULL, 'perspective'),
('The mind is everything. What you think you become.', 'Buddha', NULL, 'mind'),
('Two roads diverged in a wood, and I took the one less traveled by, and that has made all the difference.', 'Robert Frost', 'The Road Not Taken', 'choices'),
('Be yourself; everyone else is already taken.', 'Oscar Wilde', NULL, 'authenticity'),
('Imperfection is beauty, madness is genius and it''s better to be absolutely ridiculous than absolutely boring.', 'Marilyn Monroe', NULL, 'authenticity'),
('The only thing we have to fear is fear itself.', 'Franklin D. Roosevelt', 'Inaugural Address', 'courage'),
('Ask not what your country can do for you — ask what you can do for your country.', 'John F. Kennedy', 'Inaugural Address', 'service'),
('Imagination is more important than knowledge.', 'Albert Einstein', NULL, 'creativity'),
('The best way to predict the future is to create it.', 'Peter Drucker', NULL, 'action'),
('Success is not final, failure is not fatal: it is the courage to continue that counts.', 'Winston Churchill', NULL, 'perseverance'),
('The purpose of our lives is to be happy.', 'Dalai Lama', NULL, 'happiness'),
('Get busy living or get busy dying.', 'Stephen King', 'Rita Hayworth and Shawshank Redemption', 'life'),
('You miss 100% of the shots you don''t take.', 'Wayne Gretzky', NULL, 'action'),
('Whether you think you can or you think you can''t, you''re right.', 'Henry Ford', NULL, 'mindset'),
('The greatest wealth is to live content with little.', 'Plato', NULL, 'contentment'),
('Happiness depends upon ourselves.', 'Aristotle', NULL, 'happiness'),
('The journey of a thousand miles begins with one step.', 'Lao Tzu', 'Tao Te Ching', 'action'),
('Knowing yourself is the beginning of all wisdom.', 'Aristotle', NULL, 'wisdom'),
('We are what we repeatedly do. Excellence, then, is not an act, but a habit.', 'Aristotle', 'Nicomachean Ethics', 'excellence'),
('The only way to do great work is to love what you do.', 'Steve Jobs', 'Stanford Commencement', 'passion'),
('In three words I can sum up everything I''ve learned about life: it goes on.', 'Robert Frost', NULL, 'life'),
('What lies behind us and what lies before us are tiny matters compared to what lies within us.', 'Ralph Waldo Emerson', NULL, 'strength'),
('To be yourself in a world that is constantly trying to make you something else is the greatest accomplishment.', 'Ralph Waldo Emerson', NULL, 'authenticity'),
('The important thing is not to stop questioning. Curiosity has its own reason for existing.', 'Albert Einstein', NULL, 'curiosity'),
('Live as if you were to die tomorrow. Learn as if you were to live forever.', 'Mahatma Gandhi', NULL, 'learning'),
('It does not matter how slowly you go as long as you do not stop.', 'Confucius', NULL, 'perseverance'),
('The best time to plant a tree was 20 years ago. The second best time is now.', 'Chinese Proverb', NULL, 'action');
