//! Valve's text KeyValues (VDF) as Steam writes localconfig.vdf: `"key" "value"` pairs and `"key" { ... }` blocks,
//! `\"` and `\\` escapes in quoted strings, `//` comments. Keys are matched without regard to case, as Steam does
//! ("apps" in one file is "Apps" in another).
//!
//! `set` edits the text in place: it replaces the one value's quoted string, or inserts the missing blocks before the
//! closing brace of the deepest one that exists, indented with tabs as Steam does. Every other byte is kept, so the
//! rest of a file Steam owns survives exactly.
use std::ops::Range;

#[derive(Debug)]
enum Token {
    /// A quoted or bare string: its unescaped text and its span in the file (quotes included).
    Str(String, Range<usize>),
    Open,
    /// A closing brace, at this byte offset.
    Close(usize),
}

fn tokenize(text: &str) -> Result<Vec<Token>, String> {
    let b = text.as_bytes();
    let mut out = Vec::new();
    let mut i = 0;
    while i < b.len() {
        match b[i] {
            c if c.is_ascii_whitespace() => i += 1,
            b'/' if b.get(i + 1) == Some(&b'/') => i = text[i..].find('\n').map_or(b.len(), |n| i + n),
            b'{' => {
                out.push(Token::Open);
                i += 1;
            }
            b'}' => {
                out.push(Token::Close(i));
                i += 1;
            }
            // A conditional such as [$WIN32] after a value; it does not change where anything is.
            b'[' => i = text[i..].find(']').map_or(b.len(), |n| i + n + 1),
            b'"' => {
                let start = i;
                let mut s = Vec::new();
                i += 1;
                loop {
                    match b.get(i) {
                        None => return Err(format!("a string at byte {} is not closed", start)),
                        Some(b'"') => break,
                        Some(b'\\') if i + 1 < b.len() => {
                            s.push(match b[i + 1] {
                                b'n' => b'\n',
                                b't' => b'\t',
                                other => other,
                            });
                            i += 2;
                        }
                        Some(&c) => {
                            s.push(c);
                            i += 1;
                        }
                    }
                }
                i += 1;
                out.push(Token::Str(String::from_utf8_lossy(&s).into_owned(), start..i));
            }
            _ => {
                let start = i;
                while i < b.len() && !b[i].is_ascii_whitespace() && !matches!(b[i], b'{' | b'}' | b'"') {
                    i += 1;
                }
                out.push(Token::Str(text[start..i].to_string(), start..i));
            }
        }
    }
    Ok(out)
}

#[derive(Debug)]
enum Value {
    /// The text and the span of its string in the file.
    Str(String, Range<usize>),
    /// The pairs inside and the offset of the closing brace.
    Block(Vec<Pair>, usize),
}

#[derive(Debug)]
struct Pair {
    key: String,
    value: Value,
}

/// The pairs from `tokens[*pos]` up to the closing brace of the block they are in (`None` at the top level, which
/// ends with the file).
fn parse_pairs(tokens: &[Token], pos: &mut usize, top: bool) -> Result<(Vec<Pair>, Option<usize>), String> {
    let mut pairs = Vec::new();
    loop {
        let key = match tokens.get(*pos) {
            None if top => return Ok((pairs, None)),
            None => return Err("a block is not closed".into()),
            Some(Token::Close(_)) if top => return Err("a closing brace has no block".into()),
            Some(Token::Close(at)) => {
                *pos += 1;
                return Ok((pairs, Some(*at)));
            }
            Some(Token::Open) => return Err("a block has no key".into()),
            Some(Token::Str(key, _)) => key.clone(),
        };
        *pos += 1;
        let value = match tokens.get(*pos) {
            Some(Token::Str(v, span)) => {
                *pos += 1;
                Value::Str(v.clone(), span.clone())
            }
            Some(Token::Open) => {
                *pos += 1;
                let (inner, close) = parse_pairs(tokens, pos, false)?;
                Value::Block(inner, close.expect("a nested block ends at its brace"))
            }
            _ => return Err(format!("\"{}\" has no value", key)),
        };
        pairs.push(Pair { key, value });
    }
}

fn parse(text: &str) -> Result<Vec<Pair>, String> {
    let tokens = tokenize(text)?;
    Ok(parse_pairs(&tokens, &mut 0, true)?.0)
}

fn find<'a>(pairs: &'a [Pair], key: &str) -> Option<&'a Pair> {
    pairs.iter().find(|p| p.key.eq_ignore_ascii_case(key))
}

/// The string at `path` (block keys, then the value's key), or None when any part of it is missing.
pub fn get(text: &str, path: &[&str]) -> Result<Option<String>, String> {
    let doc = parse(text)?;
    let mut pairs = &doc;
    for (i, key) in path.iter().enumerate() {
        match (find(pairs, key).map(|p| &p.value), i + 1 == path.len()) {
            (Some(Value::Str(v, _)), true) => return Ok(Some(v.clone())),
            (Some(Value::Block(inner, _)), false) => pairs = inner,
            _ => return Ok(None),
        }
    }
    Ok(None)
}

pub fn escape(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"")
}

fn quoted(s: &str) -> String {
    format!("\"{}\"", escape(s))
}

/// `path[0]` at `depth` tabs, then the blocks for the rest, the last key holding `value`.
fn render(path: &[&str], depth: usize, value: &str) -> String {
    let tabs = "\t".repeat(depth);
    match path {
        [] => String::new(),
        [key] => format!("{}{}\t\t{}\n", tabs, quoted(key), quoted(value)),
        [key, rest @ ..] => format!("{t}{}\n{t}{{\n{}{t}}}\n", quoted(key), render(rest, depth + 1, value), t = tabs),
    }
}

/// The text with the string at `path` set to `value`. The first key must exist (it names the file's kind); any
/// block below it, and the value itself, is created when missing.
pub fn set(text: &str, path: &[&str], value: &str) -> Result<String, String> {
    let doc = parse(text)?;
    let mut pairs = &doc;
    let mut close = None;
    for (depth, key) in path.iter().enumerate() {
        let last = depth + 1 == path.len();
        match find(pairs, key).map(|p| &p.value) {
            Some(Value::Str(_, span)) if last => return Ok(format!("{}{}{}", &text[..span.start], quoted(value), &text[span.end..])),
            Some(Value::Block(inner, at)) if !last => {
                pairs = inner;
                close = Some(*at);
            }
            Some(_) => return Err(format!("\"{}\" is {} where Steam writes {}", key, if last { "a block" } else { "a string" }, if last { "a string" } else { "a block" })),
            None => {
                let at = close.ok_or_else(|| format!("there is no \"{}\" block", key))?;
                return Ok(insert_before_brace(text, at, &render(&path[depth..], depth, value), depth));
            }
        }
    }
    Err("the path is empty".into())
}

/// `lines` (each ending in a newline, indented for the block) inserted before the closing brace at `at`: on the
/// brace's own line when it starts one, as Steam writes it, else on a new line before it.
fn insert_before_brace(text: &str, at: usize, lines: &str, depth: usize) -> String {
    let line_start = text[..at].rfind('\n').map_or(0, |n| n + 1);
    if text[line_start..at].trim().is_empty() {
        format!("{}{}{}", &text[..line_start], lines, &text[line_start..])
    } else {
        format!("{}\n{}{}{}", &text[..at], lines, "\t".repeat(depth - 1), &text[at..])
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const PATH: [&str; 7] = ["UserLocalConfigStore", "Software", "Valve", "Steam", "apps", "427520", "LaunchOptions"];

    /// The shape of a real localconfig.vdf: a decoy "427520" string elsewhere, other apps around Factorio's.
    fn config(factorio: &str) -> String {
        format!(
            "\"UserLocalConfigStore\"\n{{\n\t\"Broadcast\"\n\t{{\n\t\t\"Permissions\"\t\t\"1\"\n\t}}\n\t\"apptickets\"\n\t{{\n\t\t\"427520\"\t\t\"38000000\"\n\t}}\n\t\"Software\"\n\t{{\n\t\t\"Valve\"\n\t\t{{\n\t\t\t\"Steam\"\n\t\t\t{{\n\t\t\t\t\"apps\"\n\t\t\t\t{{\n\t\t\t\t\t\"7\"\n\t\t\t\t\t{{\n\t\t\t\t\t\t\"LaunchOptions\"\t\t\"-novid\"\n\t\t\t\t\t}}\n{}\t\t\t\t\t\"446310\"\n\t\t\t\t\t{{\n\t\t\t\t\t\t\"Playtime\"\t\t\"35\"\n\t\t\t\t\t}}\n\t\t\t\t}}\n\t\t\t}}\n\t\t}}\n\t}}\n\t\"WebStorage\"\n\t{{\n\t\t\"Cached\"\t\t\"{{\\\"a\\\":1}}\"\n\t}}\n}}\n",
            factorio
        )
    }

    const OURS: &str = "\"/Users/x/Library/Application Support/FactorioAccess/FactorioAccess.app\" %command%";
    const OURS_IN_FILE: &str = "\"\\\"/Users/x/Library/Application Support/FactorioAccess/FactorioAccess.app\\\" %command%\"";

    fn factorio_block(inner: &str) -> String {
        format!("\t\t\t\t\t\"427520\"\n\t\t\t\t\t{{\n\t\t\t\t\t\t\"LastPlayed\"\t\t\"1794641141\"\n{}\t\t\t\t\t}}\n", inner)
    }

    #[test]
    fn key_present_is_replaced_in_place() {
        let before = config(&factorio_block("\t\t\t\t\t\t\"LaunchOptions\"\t\t\"-old\"\n"));
        let after = set(&before, &PATH, OURS).unwrap();
        assert_eq!(after, config(&factorio_block(&format!("\t\t\t\t\t\t\"LaunchOptions\"\t\t{}\n", OURS_IN_FILE))));
        assert_eq!(get(&after, &PATH).unwrap().as_deref(), Some(OURS));
        assert_eq!(get(&after, &["UserLocalConfigStore", "Software", "Valve", "Steam", "apps", "7", "LaunchOptions"]).unwrap().as_deref(), Some("-novid"));
        assert_eq!(get(&after, &["UserLocalConfigStore", "apptickets", "427520"]).unwrap().as_deref(), Some("38000000"));
    }

    #[test]
    fn key_missing_is_added_to_the_block() {
        let before = config(&factorio_block(""));
        let after = set(&before, &PATH, OURS).unwrap();
        assert_eq!(after, config(&factorio_block(&format!("\t\t\t\t\t\t\"LaunchOptions\"\t\t{}\n", OURS_IN_FILE))));
    }

    #[test]
    fn block_missing_is_created_among_the_other_apps() {
        let before = config("");
        assert_eq!(get(&before, &PATH).unwrap(), None);
        let after = set(&before, &PATH, OURS).unwrap();
        let block = "\t\t\t\t\t\"427520\"\n\t\t\t\t\t{\n\t\t\t\t\t\t\"LaunchOptions\"\t\t";
        let expected = before.replace("\t\t\t\t}\n\t\t\t}\n", &format!("{}{}\n\t\t\t\t\t}}\n\t\t\t\t}}\n\t\t\t}}\n", block, OURS_IN_FILE));
        assert_eq!(after, expected);
        assert_eq!(get(&after, &PATH).unwrap().as_deref(), Some(OURS));
    }

    #[test]
    fn apps_missing_is_created_and_its_case_is_ignored() {
        let text = "\"UserLocalConfigStore\"\n{\n\t\"Software\"\n\t{\n\t\t\"Valve\"\n\t\t{\n\t\t\t\"Steam\"\n\t\t\t{\n\t\t\t\t\"SurveyDate\"\t\t\"2017-08-31\"\n\t\t\t}\n\t\t}\n\t}\n}\n";
        let after = set(text, &PATH, "-x").unwrap();
        assert_eq!(
            after,
            text.replace(
                "\t\t\t}\n\t\t}",
                "\t\t\t\t\"apps\"\n\t\t\t\t{\n\t\t\t\t\t\"427520\"\n\t\t\t\t\t{\n\t\t\t\t\t\t\"LaunchOptions\"\t\t\"-x\"\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\t\t}"
            )
        );
        let capital = config(&factorio_block("\t\t\t\t\t\t\"LaunchOptions\"\t\t\"-old\"\n")).replace("\"apps\"", "\"Apps\"");
        let after = set(&capital, &PATH, "-new").unwrap();
        assert_eq!(after, capital.replace("\"-old\"", "\"-new\""));
    }

    #[test]
    fn escaping_round_trips() {
        assert_eq!(escape("a \"b\" c:\\d"), "a \\\"b\\\" c:\\\\d");
        let after = set(&config(&factorio_block("")), &PATH, "say \"hi\" \\ there").unwrap();
        assert!(after.contains("\"LaunchOptions\"\t\t\"say \\\"hi\\\" \\\\ there\""));
        assert_eq!(get(&after, &PATH).unwrap().as_deref(), Some("say \"hi\" \\ there"));
        assert_eq!(get(&after, &["UserLocalConfigStore", "WebStorage", "Cached"]).unwrap().as_deref(), Some("{\"a\":1}"));
    }

    #[test]
    fn brace_on_the_same_line_and_comments() {
        let text = "// written by hand\n\"UserLocalConfigStore\" { \"Software\" { \"Valve\" { \"Steam\" { \"apps\" { } } } } }";
        let after = set(text, &PATH, "-x").unwrap();
        assert_eq!(get(&after, &PATH).unwrap().as_deref(), Some("-x"));
        assert!(after.starts_with("// written by hand\n"));
    }

    #[test]
    fn refuses_what_is_not_a_localconfig() {
        assert!(set("\"Other\"\n{\n}\n", &PATH, "-x").is_err());
        assert!(set("\"UserLocalConfigStore\"\n{\n", &PATH, "-x").is_err());
        assert!(set("\"UserLocalConfigStore\"\n{\n\t\"Software\"\t\t\"oops\"\n}\n", &PATH, "-x").is_err());
        assert!(get("\"UserLocalConfigStore\" { \"unterminated }", &PATH).is_err());
        assert!(set("}", &PATH, "-x").is_err());
    }
}
