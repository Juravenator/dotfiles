use std::fs;
use std::fs::File;
use std::io;
use std::io::{Seek, SeekFrom, BufRead, BufReader, Error, ErrorKind, Write};
use std::mem::swap;
use std::ops::Sub;

// https://man7.org/linux/man-pages/man5/proc.5.html
// https://stackoverflow.com/questions/23367857/accurate-calculation-of-cpu-usage-given-in-percentage-in-linux
// /proc/stat
// kernel/system statistics.  Varies with architecture.  Common
// entries include:

// cpu 10132153 290696 3084719 46828483 16683 0 25195 0 175628 0
// cpu0 1393280 32966 572056 13343292 6130 0 17875 0 23933 0
//        The amount of time, measured in units of USER_HZ
//        (1/100ths of a second on most architectures, use
//        sysconf(_SC_CLK_TCK) to obtain the right value), that
//        the system ("cpu" line) or the specific CPU ("cpuN"
//        line) spent in various states:

//        user   (1) Time spent in user mode.

//        nice   (2) Time spent in user mode with low priority
//               (nice).

//        system (3) Time spent in system mode.

//        idle   (4) Time spent in the idle task.  This value
//               should be USER_HZ times the second entry in the
//               /proc/uptime pseudo-file.

//        iowait (since Linux 2.5.41)
//               (5) Time waiting for I/O to complete.  This
//               value is not reliable, for the following rea‐
//               sons:

//               1. The CPU will not wait for I/O to complete;
//                  iowait is the time that a task is waiting for
//                  I/O to complete.  When a CPU goes into idle
//                  state for outstanding task I/O, another task
//                  will be scheduled on this CPU.

//               2. On a multi-core CPU, the task waiting for I/O
//                  to complete is not running on any CPU, so the
//                  iowait of each CPU is difficult to calculate.

//               3. The value in this field may decrease in cer‐
//                  tain conditions.

//        irq (since Linux 2.6.0)
//               (6) Time servicing interrupts.

//        softirq (since Linux 2.6.0)
//               (7) Time servicing softirqs.

//        steal (since Linux 2.6.11)
//               (8) Stolen time, which is the time spent in
//               other operating systems when running in a virtu‐
//               alized environment

//        guest (since Linux 2.6.24)
//               (9) Time spent running a virtual CPU for guest
//               operating systems under the control of the Linux
//               kernel.

//        guest_nice (since Linux 2.6.33)
//               (10) Time spent running a niced guest (virtual
//               CPU for guest operating systems under the con‐
//               trol of the Linux kernel).

// page 5741 1808
//        The number of pages the system paged in and the number
//        that were paged out (from disk).

// swap 1 0
//        The number of swap pages that have been brought in and
//        out.

// intr 1462898
//        This line shows counts of interrupts serviced since
//        boot time, for each of the possible system interrupts.
//        The first column is the total of all interrupts ser‐
//        viced including unnumbered architecture specific inter‐
//        rupts; each subsequent column is the total for that
//        particular numbered interrupt.  Unnumbered interrupts
//        are not shown, only summed into the total.

// disk_io: (2,0):(31,30,5764,1,2) (3,0):...
//        (major,disk_idx):(noinfo, read_io_ops, blks_read,
//        write_io_ops, blks_written)
//        (Linux 2.4 only)

// ctxt 115315
//        The number of context switches that the system under‐
//        went.

// btime 769041601
//        boot time, in seconds since the Epoch, 1970-01-01
//        00:00:00 +0000 (UTC).

// processes 86031
//        Number of forks since boot.

// procs_running 6
//        Number of processes in runnable state.  (Linux 2.5.45
//        onward.)

// procs_blocked 2
//        Number of processes blocked waiting for I/O to com‐
//        plete.  (Linux 2.5.45 onward.)

// softirq 229245889 94 60001584 13619 5175704 2471304 28
// 51212741 59130143 0 51240672
//        This line shows the number of softirq for all CPUs.
//        The first column is the total of all softirqs and each
//        subsequent column is the total for particular softirq.
//        (Linux 2.6.31 onward.)
// example:
// cpu  2568119 315 895239 16271335 23500 258334 84758 0 0 0
// cpu0 637013 90 222955 4077539 7915 59032 21980 0 0 0
// cpu1 645355 82 222425 4056352 5394 76032 19147 0 0 0
// cpu2 637946 76 226763 4063521 5625 65509 25163 0 0 0
// cpu3 647803 65 223094 4073922 4564 57760 18467 0 0 0
// intr 173556467 9 0 0 0 0 0 0 0 1 1828191 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 792884 1560577 0 19 435 435 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1461 4504736 236 1113378 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
// ctxt 472741895
// btime 1592473600
// processes 1691568
// procs_running 1
// procs_blocked 0
// softirq 123030711 4505047 52066340 7 1314480 672703 0 202739 40220106 8843 24040446

#[derive(Clone, Copy, Debug)]
pub struct Entry {
  pub idle: usize,
  pub user: usize,
  pub system: usize,
}

impl Entry {
  pub fn percentage(&self) -> f64 {
    let total_used = self.user + self.system;
    let total = (self.idle + total_used) as f64 / 100.0;
    if total == 0.0 {
      return total
    }
    return total_used as f64 / total
  }
  pub fn print(&self) {
    let percentage = self.percentage();
    if percentage == 0.0 {
      println!("0%");
    } else {
      // print!("CPU: {:05.2}% ({:05.2} system + {:05.2} user)\n", total_used as f64 / total , self.system as f64 / total, self.user as f64 / total);
      println!("{:05.2}%", percentage);
    }
    io::stdout().flush().unwrap();
  }
}

impl Sub for Entry {
  type Output = Entry;

  fn sub(self, other: Entry) -> Entry {
    Entry {
      idle: self.idle - other.idle,
      user: self.user - other.user,
      system: self.system - other.system,
    }
  }
}

pub struct Controller {
  f: fs::File,
  old: Entry,
  latest: Entry,
}

impl Controller {
  pub fn new() -> Result<Controller, io::Error> {
    let f = File::open("/proc/stat")?;
    let entry = read(&f)?;
    Ok(Controller{
      f,
      old: entry.clone(),
      latest: entry.clone(),
    })
  }
  pub fn get_diff(&mut self) -> Result<Entry, io::Error> {
    // print!("previous {}, latest {}", self.old.idle, self.latest.idle);
    swap(&mut self.latest, &mut self.old);
    self.latest = read(&self.f)?;
    // print!("previous {}, latest {}", self.old.idle, self.latest.idle);


    Ok(self.latest - self.old)
  }
}

fn read(mut f: &fs::File) -> Result<Entry, io::Error> {
  f.seek(SeekFrom::Start(0))?;

  let mut buffer = String::new();
  let mut cursor = BufReader::new(f);
  loop {
    let num_bytes = cursor.read_line(&mut buffer)?;
    if num_bytes == 0 {
      return Err(Error::new(ErrorKind::UnexpectedEof, "data does not contain global CPU info"));
    }
    // we only bother with total CPU, not individual cores
    // this should also be the first line
    if buffer.starts_with("cpu ") {
      let pieces: Vec<usize> = buffer
      .split_ascii_whitespace()
      .enumerate()
      .filter_map(|(_, s)| s.parse().ok())
      .collect();
      // print!("{:?}", pieces);
      assert_eq!(pieces.len(), 10);
      let (user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice) = (pieces[0], pieces[1], pieces[2], pieces[3], pieces[4], pieces[5], pieces[6], pieces[7], pieces[8], pieces[9]);

      // print!("user {}, nice {}, system {}, idle {}", user, nice, system, idle);
      // assert_eq!(pieces.len(), 11);
      return Ok(Entry {
        idle: idle + iowait,
        user: user + nice,
        system: system + irq + softirq + steal + guest + guest_nice,
      });
    }
    buffer.clear();
  }
}