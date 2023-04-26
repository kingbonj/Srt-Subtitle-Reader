# Srt-Subtitle-Reader
A shell script that displays the dialogue contents of a subtitle file in the .srt format on the terminal screen with a specified delay between each line.

![Screenshot 2023-04-26 22 47 34](https://user-images.githubusercontent.com/38471159/234710387-423e5ec5-fc93-4aa1-b1c8-c06042a0fca4.png)

## Prerequisites

`bc` (available from apt)

## Usage

`./srt2screen.sh [-k] [-t delay] [-v] file.srt`

The script takes the following options:

-`k` : Pause after each line of text and wait for user input.

-`t delay` : Set the delay (in milliseconds) between each line of text (default: 1000).

-`v` : Verbose mode. Print additional information about the input file and runtime.

-`h` : Print the help message.

## Installation

Clone the repository:

`git clone https://github.com/yourusername/srt2screen.git`

Navigate to the srt2screen directory:

`cd srt2screen`

Make the shell script executable:

`chmod +x srt2screen.sh`

## Example
To display the contents of a subtitle file called `example.srt` with a delay of 500 milliseconds and pause after each line, run the following command:

`./srt2screen.sh -k -t 500 example.srt`


