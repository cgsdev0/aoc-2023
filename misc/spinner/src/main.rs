use spinners::{Spinner, Spinners};
use std::process::{Command, Stdio};

fn main() {
    let mut sp = Spinner::with_timer(Spinners::Pong, std::env::args().nth(1).unwrap().into());

    let start = std::time::Instant::now();
    let output = Command::new(std::env::args().nth(2).unwrap())
        .args(std::env::args().skip(3))
        .output()
        .unwrap();

    let ecode = output.status;
    let dur = std::time::Instant::now() - start;
    let time: String = pretty_duration::pretty_duration(&dur, None);
    sp.stop_with_message(if ecode.success() {
        format!("✅ Success!\n{}\n", time).into()
    } else {
        format!("❌ Failure :(\n{}\n", time).into()
    });
    use std::io::Write;
    std::io::stdout().write_all(&output.stdout).unwrap();

    if ecode.success() {
        // put it into the clipboard in a really fucked up way
        let mut child = Command::new("yank")
            .stdout(Stdio::piped())
            .stdin(Stdio::piped())
            .spawn()
            .unwrap();
        let child_stdin = child.stdin.as_mut().unwrap();
        child_stdin.write_all(&output.stdout).unwrap();

        let output = child.wait_with_output().unwrap();
        std::io::stdout().write_all(&output.stdout).unwrap();
    }
}
