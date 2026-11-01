//! Community and project links (shown in Help ▸, the About dialog, the start screen and the
//! header's Discord button).

pub const APP_NAME: &str = "EffectZ";
pub const APP_SLUG: &str = "effectz";
pub const DISCORD: &str = "https://github.com/danish0440/effectz/issues";
pub const WEBSITE: &str = "https://github.com/danish0440/effectz";
pub const APP_PAGE: &str = "https://github.com/danish0440/effectz";
pub const GITHUB: &str = "https://github.com/danish0440/effectz";
pub const ISSUES: &str = "https://github.com/danish0440/effectz/issues";

/// Sibling apps of the ArtCraft family: (name, what it is, GitHub repo, app page).
pub const SIBLINGS: &[(&str, &str)] = &[
    ("PhotoZ", "photocraft"),
    ("VectorZ", "vectorcraft"),
    ("FilmZ", "filmcraft"),
    ("LightZ", "lightcraft"),
    ("PdfZ", "pdfcraft"),
    ("DesignZ", "designcraft"),
];

pub fn github_of(slug: &str) -> String {
    format!("https://github.com/storytold/{slug}")
}
pub fn page_of(slug: &str) -> String {
    format!("https://github.com/danish0440/{slug}")
}
