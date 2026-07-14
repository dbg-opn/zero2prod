use crate::routes::{health_check, subscribe};
use actix_web::dev::Server;
use actix_web::{App, HttpServer, web};
use sqlx::PgPool;
use std::net::TcpListener;
use tracing_actix_web::TracingLogger;

pub fn run(listener: TcpListener, db_pool: PgPool) -> Result<Server, std::io::Error> {
    // wrap connection in a smart pointer & shadow variable
    let db_pool = web::Data::new(db_pool);
    // capture `connection` from the surrounding environment
    let server = HttpServer::new(move || {
        App::new()
            // middleware added using `wrap` method on `App`
            .wrap(TracingLogger::default())
            .route("health_check", web::head().to(health_check))
            .route("subscriptions", web::post().to(subscribe))
            // register connection as part of app state (pointer copy)
            .app_data(db_pool.clone())
    })
    .listen(listener)?
    .run();

    Ok(server)
}
