use actix_web::{web, App, HttpServer, Result, HttpResponse};
use serde_json::json;
use std::collections::HashMap;
use chrono::Utc;
use sqlx::{PgPool, Row};
use anyhow::Result as AnyhowResult;

/// Database connection pool with optimized settings
async fn create_pool(database_url: &str) -> AnyhowResult<PgPool> {
    let pool = PgPool::connect(database_url).await?;
    
    sqlx::query("SELECT 1")
        .fetch_one(&pool)
        .await?;
    
    log::info!("Database connection established successfully");
    Ok(pool)
}

/// Initialize database with essential data
async fn initialize_database(pool: &PgPool) -> AnyhowResult<()> {
    log::info!("Initializing database with essential data");
    
    let count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM languages")
        .fetch_one(pool)
        .await?;
    
    if count.0 > 0 {
        log::info!("Database already contains {} languages, skipping initialization", count.0);
        return Ok(());
    }
    
    // Insert essential languages
    let languages = vec![
        ("EN", "English", "English", "US", "Popular", "beginner", true, true),
        ("ES", "Spanish", "Español", "ES", "Romance", "beginner", true, true),
        ("FR", "French", "Français", "FR", "Romance", "intermediate", true, true),
        ("DE", "German", "Deutsch", "DE", "Germanic", "intermediate", true, true),
        ("IT", "Italian", "Italiano", "IT", "Romance", "beginner", true, true),
        ("PT", "Portuguese", "Português", "PT", "Romance", "beginner", true, true),
        ("RU", "Russian", "Русский", "RU", "Slavic", "advanced", true, true),
        ("JA", "Japanese", "日本語", "JP", "Asian", "advanced", true, true),
        ("KO", "Korean", "한국어", "KR", "Asian", "advanced", true, true),
        ("ZH", "Chinese", "中文", "CN", "Asian", "advanced", true, true),
        ("AR", "Arabic", "العربية", "SA", "Middle Eastern", "advanced", true, true),
        ("HI", "Hindi", "हिन्दी", "IN", "Asian", "intermediate", true, true),
        ("NL", "Dutch", "Nederlands", "NL", "Germanic", "intermediate", true, true),
        ("SV", "Swedish", "Svenska", "SE", "Nordic", "intermediate", true, true),
        ("NO", "Norwegian", "Norsk", "NO", "Nordic", "intermediate", true, true),
    ];
    
    for (code, name, native_name, flag, category, difficulty, is_popular, is_active) in languages {
        sqlx::query(
            "INSERT INTO languages (id, code, name, native_name, flag_emoji, category, difficulty_level, is_popular, is_active, created_at, updated_at) 
             VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6::difficulty_level, $7, $8, NOW(), NOW())"
        )
        .bind(code)
        .bind(name)
        .bind(native_name)
        .bind(flag)
        .bind(category)
        .bind(difficulty)
        .bind(is_popular)
        .bind(is_active)
        .execute(pool)
        .await?;
    }
    
    // Insert essential vocabulary
    let vocabulary = vec![
        ("Hello", "Greetings", "beginner", "interjection", 1, true),
        ("Thank you", "Politeness", "beginner", "phrase", 2, true),
        ("Goodbye", "Greetings", "beginner", "interjection", 3, true),
        ("Please", "Politeness", "beginner", "adverb", 4, true),
        ("Yes", "Basic", "beginner", "adverb", 5, true),
        ("No", "Basic", "beginner", "adverb", 6, true),
        ("Water", "Basic", "beginner", "noun", 7, true),
        ("Food", "Basic", "beginner", "noun", 8, true),
        ("House", "Basic", "beginner", "noun", 9, true),
        ("Family", "Basic", "beginner", "noun", 10, true),
    ];
    
    for (word, category, difficulty, part_of_speech, frequency, is_common) in vocabulary {
        sqlx::query(
            "INSERT INTO vocabulary_words (id, english_word, category, difficulty_level, part_of_speech, frequency_rank, is_common, created_at, updated_at) 
             VALUES (gen_random_uuid(), $1, $2, $3::difficulty_level, $4, $5, $6, NOW(), NOW())"
        )
        .bind(word)
        .bind(category)
        .bind(difficulty)
        .bind(part_of_speech)
        .bind(frequency)
        .bind(is_common)
        .execute(pool)
        .await?;
    }
    
    // Insert learning tips
    let tips = vec![
        ("ES", "Pronunciation", "Practice rolling your R's daily - it's essential for Spanish pronunciation", "pronunciation", "beginner", true),
        ("FR", "Pronunciation", "French nasal sounds are key - practice 'bonjour' and 'merci'", "pronunciation", "beginner", true),
        ("DE", "Grammar", "Understand German case system (nominative, accusative, dative, genitive)", "grammar", "advanced", true),
        ("JA", "Writing", "Learn Hiragana and Katakana before tackling Kanji characters", "cultural", "intermediate", true),
        ("ZH", "Tones", "Master the four tones in Mandarin Chinese - they change word meanings", "pronunciation", "advanced", true),
        ("AR", "Script", "Arabic is written from right to left - practice the alphabet daily", "cultural", "intermediate", true),
        ("RU", "Cyrillic", "Learn the Cyrillic alphabet - it's different from Latin script", "cultural", "intermediate", true),
        ("KO", "Hangul", "Korean Hangul is phonetic - learn the basic characters first", "cultural", "beginner", true),
    ];
    
    for (language_code, title, content, tip_type, difficulty, is_featured) in tips {
        sqlx::query(
            "INSERT INTO learning_tips (id, language_code, title, content, tip_type, difficulty_level, is_featured, created_at, updated_at) 
             VALUES (gen_random_uuid(), $1, $2, $3, $4::tip_type, $5::difficulty_level, $6, NOW(), NOW())"
        )
        .bind(language_code)
        .bind(title)
        .bind(content)
        .bind(tip_type)
        .bind(difficulty)
        .bind(is_featured)
        .execute(pool)
        .await?;
    }
    
    log::info!("Database initialization completed successfully");
    Ok(())
}

/// Health check endpoint
async fn health_check() -> Result<HttpResponse> {
    Ok(HttpResponse::Ok().json(json!({
        "status": "healthy",
        "message": "Translation API is operational",
        "timestamp": Utc::now()
    })))
}

/// Get all available languages
async fn get_languages(pool: web::Data<PgPool>) -> Result<HttpResponse> {
    let start_time = std::time::Instant::now();
    
    let languages = sqlx::query(
        "SELECT id, code, name, native_name, flag_emoji, category, difficulty_level::text as difficulty_level, is_popular, is_active, created_at, updated_at 
         FROM languages WHERE is_active = true ORDER BY is_popular DESC, name ASC"
    )
    .fetch_all(&**pool)
    .await
    .map_err(|e| {
        log::error!("Failed to fetch languages: {e}");
        actix_web::error::ErrorInternalServerError("Failed to fetch languages")
    })?;

    let result: Vec<serde_json::Value> = languages.into_iter().map(|row| {
        json!({
            "id": row.get::<uuid::Uuid, _>("id"),
            "code": row.get::<String, _>("code"),
            "name": row.get::<String, _>("name"),
            "native_name": row.get::<String, _>("native_name"),
            "flag_emoji": row.get::<String, _>("flag_emoji"),
            "category": row.get::<String, _>("category"),
            "difficulty_level": row.get::<String, _>("difficulty_level"),
            "is_popular": row.get::<bool, _>("is_popular"),
            "is_active": row.get::<bool, _>("is_active"),
            "created_at": row.get::<chrono::DateTime<chrono::Utc>, _>("created_at"),
            "updated_at": row.get::<chrono::DateTime<chrono::Utc>, _>("updated_at")
        })
    }).collect();

    let duration = start_time.elapsed();
    log::debug!("Languages query completed in {duration:?}");

    Ok(HttpResponse::Ok()
        .insert_header(("Cache-Control", "public, max-age=300"))
        .insert_header(("X-Response-Time", format!("{duration:?}")))
        .json(result))
}

/// Get vocabulary words
async fn get_vocabulary(pool: web::Data<PgPool>) -> Result<HttpResponse> {
    let start_time = std::time::Instant::now();
    
    let vocabulary = sqlx::query(
        "SELECT id, english_word, category, difficulty_level::text as difficulty_level, part_of_speech, frequency_rank, is_common, created_at, updated_at 
         FROM vocabulary_words ORDER BY frequency_rank ASC LIMIT 20"
    )
    .fetch_all(&**pool)
    .await
    .map_err(|e| {
        log::error!("Failed to fetch vocabulary: {e}");
        actix_web::error::ErrorInternalServerError("Failed to fetch vocabulary")
    })?;

    let result: Vec<serde_json::Value> = vocabulary.into_iter().map(|row| {
        json!({
            "id": row.get::<uuid::Uuid, _>("id"),
            "english_word": row.get::<String, _>("english_word"),
            "category": row.get::<String, _>("category"),
            "difficulty_level": row.get::<String, _>("difficulty_level"),
            "part_of_speech": row.get::<String, _>("part_of_speech"),
            "frequency_rank": row.get::<i32, _>("frequency_rank"),
            "is_common": row.get::<bool, _>("is_common"),
            "created_at": row.get::<chrono::DateTime<chrono::Utc>, _>("created_at"),
            "updated_at": row.get::<chrono::DateTime<chrono::Utc>, _>("updated_at")
        })
    }).collect();

    let duration = start_time.elapsed();
    log::debug!("Vocabulary query completed in {duration:?}");

    Ok(HttpResponse::Ok()
        .insert_header(("Cache-Control", "public, max-age=180"))
        .insert_header(("X-Response-Time", format!("{duration:?}")))
        .json(result))
}

/// Get random vocabulary for learning
async fn get_random_vocabulary(pool: web::Data<PgPool>) -> Result<HttpResponse> {
    let vocabulary = sqlx::query(
        "SELECT id, english_word, category, difficulty_level::text as difficulty_level, part_of_speech, frequency_rank, is_common, created_at, updated_at 
         FROM vocabulary_words ORDER BY RANDOM() LIMIT 10"
    )
    .fetch_all(&**pool)
    .await
    .map_err(|e| {
        log::error!("Failed to fetch random vocabulary: {e}");
        actix_web::error::ErrorInternalServerError("Failed to fetch random vocabulary")
    })?;

    let result: Vec<serde_json::Value> = vocabulary.into_iter().map(|row| {
        json!({
            "id": row.get::<uuid::Uuid, _>("id"),
            "english_word": row.get::<String, _>("english_word"),
            "category": row.get::<String, _>("category"),
            "difficulty_level": row.get::<String, _>("difficulty_level"),
            "part_of_speech": row.get::<String, _>("part_of_speech"),
            "frequency_rank": row.get::<i32, _>("frequency_rank"),
            "is_common": row.get::<bool, _>("is_common"),
            "created_at": row.get::<chrono::DateTime<chrono::Utc>, _>("created_at"),
            "updated_at": row.get::<chrono::DateTime<chrono::Utc>, _>("updated_at")
        })
    }).collect();

    Ok(HttpResponse::Ok().json(json!({
        "vocabulary": result,
        "count": result.len()
    })))
}

/// Search vocabulary by query
async fn search_vocabulary(query: web::Query<HashMap<String, String>>, pool: web::Data<PgPool>) -> Result<HttpResponse> {
    let search_term = query.get("q").cloned().unwrap_or_default();
    
    if search_term.is_empty() {
        return Ok(HttpResponse::BadRequest().json(json!({
            "error": "Search query parameter 'q' is required"
        })));
    }
    
    let vocabulary = sqlx::query(
        "SELECT id, english_word, category, difficulty_level::text as difficulty_level, part_of_speech, frequency_rank, is_common, created_at, updated_at 
         FROM vocabulary_words WHERE english_word ILIKE $1 ORDER BY frequency_rank ASC LIMIT 20"
    )
    .bind(format!("%{search_term}%"))
    .fetch_all(&**pool)
    .await
    .map_err(|e| {
        log::error!("Failed to search vocabulary: {e}");
        actix_web::error::ErrorInternalServerError("Failed to search vocabulary")
    })?;

    let result: Vec<serde_json::Value> = vocabulary.into_iter().map(|row| {
        json!({
            "id": row.get::<uuid::Uuid, _>("id"),
            "english_word": row.get::<String, _>("english_word"),
            "category": row.get::<String, _>("category"),
            "difficulty_level": row.get::<String, _>("difficulty_level"),
            "part_of_speech": row.get::<String, _>("part_of_speech"),
            "frequency_rank": row.get::<i32, _>("frequency_rank"),
            "is_common": row.get::<bool, _>("is_common"),
            "created_at": row.get::<chrono::DateTime<chrono::Utc>, _>("created_at"),
            "updated_at": row.get::<chrono::DateTime<chrono::Utc>, _>("updated_at"),
            "relevance_score": 0.95
        })
    }).collect();

    Ok(HttpResponse::Ok().json(json!({
        "results": result,
        "total": result.len(),
        "query": search_term
    })))
}

/// Get learning tips
async fn get_learning_tips(pool: web::Data<PgPool>) -> Result<HttpResponse> {
    let tips = sqlx::query(
        "SELECT id, language_code, title, content, tip_type::text as tip_type, difficulty_level::text as difficulty_level, is_featured, created_at, updated_at 
         FROM learning_tips ORDER BY is_featured DESC, created_at DESC LIMIT 20"
    )
    .fetch_all(&**pool)
    .await
    .map_err(|e| {
        log::error!("Failed to fetch learning tips: {e}");
        actix_web::error::ErrorInternalServerError("Failed to fetch learning tips")
    })?;

    let result: Vec<serde_json::Value> = tips.into_iter().map(|row| {
        json!({
            "id": row.get::<uuid::Uuid, _>("id"),
            "language_code": row.get::<String, _>("language_code"),
            "title": row.get::<String, _>("title"),
            "content": row.get::<String, _>("content"),
            "tip_type": row.get::<String, _>("tip_type"),
            "difficulty_level": row.get::<String, _>("difficulty_level"),
            "is_featured": row.get::<bool, _>("is_featured"),
            "created_at": row.get::<chrono::DateTime<chrono::Utc>, _>("created_at"),
            "updated_at": row.get::<chrono::DateTime<chrono::Utc>, _>("updated_at")
        })
    }).collect();

    Ok(HttpResponse::Ok().json(json!({
        "tips": result,
        "total": result.len()
    })))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();
    
    dotenv::dotenv().ok();
    
    let database_url = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgresql://translator_user:translator_password@localhost:5432/translator_db".to_string());
    
    let port = std::env::var("PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse::<u16>()
        .unwrap_or(8080);
    
    let pool = create_pool(&database_url).await
        .expect("Failed to create database pool");
    
    initialize_database(&pool).await
        .expect("Failed to initialize database");
    
    log::info!("Starting Translation API server on port {port}");
    
    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(pool.clone()))
            .route("/api/v1/health", web::get().to(health_check))
            .route("/api/v1/languages", web::get().to(get_languages))
            .route("/api/v1/vocabulary", web::get().to(get_vocabulary))
            .route("/api/v1/vocabulary/random", web::get().to(get_random_vocabulary))
            .route("/api/v1/vocabulary/search", web::get().to(search_vocabulary))
            .route("/api/v1/learning-tips", web::get().to(get_learning_tips))
    })
    .bind(format!("0.0.0.0:{port}"))?
    .run()
    .await
}