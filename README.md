# 🏎️ F1CLI 

F1CLI is a command-line tool that allows you to follow the latest results and statistics of Formula 1. Get the latest race results, driver and constructor standings, and individual driver and team statistics in a simple and easy-to-read format.

## Features 🌟
- 🏁 Display the latest Formula 1 race results
- 📊 Show driver and constructor standings
- 🏎️ View individual driver statistics
- 🏢 View individual constructor statistics

## Usage 💻

```bash
./f1cli.sh [OPTIONS]
```

### Options:

| Option                      | Description                                          |
|-----------------------------|------------------------------------------------------|
| `-r`, `--results`           | Display the results of the latest races              |
| `-s`, `--standings`         | Display the standings of drivers and constructors    |
| `-d`, `--driver <driver_id>`| Display the statistics for a specific driver         |
| `-t`, `--team <constructor_id>`| Display the statistics for a specific team        |

**Info:** You can find the `driver_id` and `constructor_id` with `-d` and `-t` options.

### Examples:

```bash
./f1cli.sh --driver leclerc
./f1cli.sh --team ferrari
```

## Installation 🔧

1. Clone the repository or download the `f1cli.sh` script
2. Ensure the script has execute permissions with `chmod +x f1cli.sh`
3. Run the script with the desired options
