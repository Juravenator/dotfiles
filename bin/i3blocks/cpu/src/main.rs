#[macro_use]
extern crate log;
extern crate stderrlog;
extern crate structopt;

use std::io;
use std::thread;
use std::time::Duration;

// mod diskstat;
mod cpu;
// mod ram;


fn main() -> io::Result<()> {
  info!("starting...");

  debug!("starting diskstat controller");
//   let mut diskstat_controller = diskstat::Controller::new()?;
  let mut cpu_controller = cpu::Controller::new()?;
//   let mut ram_controller = ram::Controller::new()?;
  info!("all controllers ready");

  let mut cpuhistory: [u8; 8] = [0; 8];
  // let mut v = vec![1, 2, 3, 4, 5];
  // v.rotate_right(1);

  // let mut i = 0;
  loop {
    // let diskstats = diskstat_controller.get_diff()?;
    let cpustats = cpu_controller.get_diff()?;
    cpuhistory.rotate_right(1);
    // cpuhistory[3] = cpuhistory[2];
    // cpuhistory[2] = cpuhistory[1];
    // cpuhistory[1] = cpuhistory[0];
    cpuhistory[0] = to_dot_nr(cpustats);
    // let ramstats = ram_controller.read()?;
    // if i % 2 == 0 {
      // print!("\x1B[2J\x1B[H");
    // }
    // diskstat::print(diskstats);
    for i in (0..cpuhistory.len()).step_by(2).rev() {
      // print!("{}", i)
      print!("{}", to_graph_glyph(cpuhistory[i+1], cpuhistory[i]))
    }
    print!(" ");
    // print!("{}{}", to_graph_glyph(cpuhistory[3], cpuhistory[2]), to_graph_glyph(cpuhistory[1], cpuhistory[0]));
    cpustats.print();
    // ramstats.print();
    // print!("{}\n", i);
    // i += 1;
    thread::sleep(Duration::from_millis(500));
  }
}

fn to_dot_nr(e: cpu::Entry) -> u8 {
  let percentage = e.percentage();
  if percentage < 25.0 {
    return 1
  } else if percentage < 5.0 {
    return 2
  } else if percentage < 75.0 {
    return 3
  } else {
    return 4
  }
}

fn to_graph_glyph(dots1: u8, dots2: u8) -> char {
  match (dots1, dots2) {
    (1, 1) => '⣀',
    (1, 2) => '⣠',
    (1, 3) => '⣰',
    (1, 4) => '⣸',
    (2, 1) => '⣄',
    (2, 2) => '⣤',
    (2, 3) => '⣴',
    (2, 4) => '⣼',
    (3, 1) => '⣆',
    (3, 2) => '⣦',
    (3, 3) => '⣶',
    (3, 4) => '⣾',
    (4, 1) => '⣇',
    (4, 2) => '⣧',
    (4, 3) => '⣷',
    (4, 4) => '⣿',
    _ => ' ',
}
}