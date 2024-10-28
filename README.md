# HTB Machines Terminal Search

This terminal script is designed to facilitate the search and filtering of HackTheBox (HTB) machines using information available from the website managed by s4vitar. It's a useful tool for cybersecurity enthusiasts looking to explore HTB machines more efficiently from the command line.

## Features

- **Download and update necessary files**: Keep the information up to date with a simple command.
- **Machine search**: Filter machines by name, IP address, operating system, difficulty level, and skill.
- **Solution links**: Quickly access s4vitar's solution videos to learn from the resolutions.

## Script Usage

Run the script from the terminal and use the following options:

- `-h`: Show the help panel.
- `-u`: Download or update the necessary files.
- `-l`: List all available machines.

### Search Options

- `-y <machine_name>`: Get the solution video link by machine name.
- `-m <machine_name>`: Search for machines by name.
- `-i <ip_address>`: Search for machines by IP address.
- `-d <level>`: Filter machines by difficulty level (1-4).
- `-o <os_type>`: Filter machines by operating system type (1 for Linux, 2 for Windows).
- `-s <skill>`: Search for machines by skill.

### Example Usage

```bash
bash htbmachines.sh -m <machine_name> -i <ip_address> -d <difficulty_level> -o <os_type> -s <skill>
