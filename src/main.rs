#[macro_use]
extern crate rocket;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[launch]
fn rocket() -> _ {
    let config = rocket::Config::default();
    if config.tls_enabled() {
        println!("TLS is enabled!");
    } else {
        println!("TLS is disabled.");
    }
    rocket::build()
        .mount("/", routes![index])
}