use rocket::figment::providers::{Toml, Format, Env};

#[macro_use]
extern crate rocket;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[launch]
fn rocket() -> _ {
    let figment = rocket::Config::figment();
    let config = rocket::Config::from(figment);
    if config.tls_enabled() {
        println!("TLS is enabled!");
    } else {
        println!("TLS is disabled.");
    }
    rocket::build()
        .mount("/", routes![index])
}