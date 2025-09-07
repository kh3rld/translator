-- Create custom types
CREATE TYPE difficulty_level AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE tip_type AS ENUM ('pronunciation', 'grammar', 'cultural', 'vocabulary', 'conversation');
CREATE TYPE challenge_type AS ENUM ('vocabulary', 'pronunciation', 'grammar', 'cultural', 'conversation');

-- Language categories table
CREATE TABLE language_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Languages table
CREATE TABLE languages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    native_name VARCHAR(100) NOT NULL,
    flag_emoji VARCHAR(10),
    difficulty_level difficulty_level NOT NULL,
    category VARCHAR(100) NOT NULL,
    is_popular BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Vocabulary words table
CREATE TABLE vocabulary_words (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    english_word VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    difficulty_level difficulty_level NOT NULL,
    part_of_speech VARCHAR(50),
    frequency_rank INTEGER DEFAULT 0,
    is_common BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Translations table
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vocabulary_id UUID NOT NULL REFERENCES vocabulary_words(id) ON DELETE CASCADE,
    language_code VARCHAR(10) NOT NULL REFERENCES languages(code),
    translated_word VARCHAR(200) NOT NULL,
    pronunciation VARCHAR(200),
    audio_url TEXT,
    example_sentence TEXT,
    cultural_note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(vocabulary_id, language_code)
);

-- Learning tips table
CREATE TABLE learning_tips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_code VARCHAR(10) NOT NULL REFERENCES languages(code),
    tip_type tip_type NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    difficulty_level difficulty_level NOT NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pronunciation guides table
CREATE TABLE pronunciation_guides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_code VARCHAR(10) NOT NULL REFERENCES languages(code),
    sound VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    audio_url TEXT,
    difficulty_level difficulty_level NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cultural insights table
CREATE TABLE cultural_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_code VARCHAR(10) NOT NULL REFERENCES languages(code),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    image_url TEXT,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily challenges table
CREATE TABLE daily_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_code VARCHAR(10) NOT NULL REFERENCES languages(code),
    challenge_type challenge_type NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    content JSONB NOT NULL,
    difficulty_level difficulty_level NOT NULL,
    points_reward INTEGER DEFAULT 10,
    date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(language_code, date)
);

-- User progress table
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(100) NOT NULL,
    language_code VARCHAR(10) NOT NULL REFERENCES languages(code),
    words_learned INTEGER DEFAULT 0,
    daily_streak INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0,
    last_study_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, language_code)
);

-- User vocabulary table
CREATE TABLE user_vocabulary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(100) NOT NULL,
    vocabulary_id UUID NOT NULL REFERENCES vocabulary_words(id) ON DELETE CASCADE,
    mastery_level INTEGER DEFAULT 0 CHECK (mastery_level >= 0 AND mastery_level <= 5),
    times_reviewed INTEGER DEFAULT 0,
    last_reviewed TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, vocabulary_id)
);

-- Learning sessions table
CREATE TABLE learning_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(100) NOT NULL,
    language_code VARCHAR(10) NOT NULL REFERENCES languages(code),
    session_type VARCHAR(50) NOT NULL,
    duration_minutes INTEGER DEFAULT 0,
    words_practiced INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    points_earned INTEGER DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for better performance
CREATE INDEX idx_languages_code ON languages(code);
CREATE INDEX idx_languages_category ON languages(category);
CREATE INDEX idx_languages_difficulty ON languages(difficulty_level);
CREATE INDEX idx_languages_popular ON languages(is_popular);

CREATE INDEX idx_vocabulary_category ON vocabulary_words(category);
CREATE INDEX idx_vocabulary_difficulty ON vocabulary_words(difficulty_level);
CREATE INDEX idx_vocabulary_common ON vocabulary_words(is_common);
CREATE INDEX idx_vocabulary_frequency ON vocabulary_words(frequency_rank);

CREATE INDEX idx_translations_vocabulary ON translations(vocabulary_id);
CREATE INDEX idx_translations_language ON translations(language_code);

CREATE INDEX idx_learning_tips_language ON learning_tips(language_code);
CREATE INDEX idx_learning_tips_type ON learning_tips(tip_type);
CREATE INDEX idx_learning_tips_featured ON learning_tips(is_featured);

CREATE INDEX idx_cultural_insights_language ON cultural_insights(language_code);
CREATE INDEX idx_cultural_insights_featured ON cultural_insights(is_featured);

CREATE INDEX idx_daily_challenges_date ON daily_challenges(date);
CREATE INDEX idx_daily_challenges_language ON daily_challenges(language_code);
CREATE INDEX idx_daily_challenges_active ON daily_challenges(is_active);

CREATE INDEX idx_user_progress_user ON user_progress(user_id);
CREATE INDEX idx_user_progress_language ON user_progress(language_code);

CREATE INDEX idx_user_vocabulary_user ON user_vocabulary(user_id);
CREATE INDEX idx_user_vocabulary_vocabulary ON user_vocabulary(vocabulary_id);

CREATE INDEX idx_learning_sessions_user ON learning_sessions(user_id);
CREATE INDEX idx_learning_sessions_language ON learning_sessions(language_code);
CREATE INDEX idx_learning_sessions_date ON learning_sessions(started_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_languages_updated_at BEFORE UPDATE ON languages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vocabulary_words_updated_at BEFORE UPDATE ON vocabulary_words
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_translations_updated_at BEFORE UPDATE ON translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_learning_tips_updated_at BEFORE UPDATE ON learning_tips
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cultural_insights_updated_at BEFORE UPDATE ON cultural_insights
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_vocabulary_updated_at BEFORE UPDATE ON user_vocabulary
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
