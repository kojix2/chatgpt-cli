# ChatGPT CLI

[![build](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml)

:eight_spoked_asterisk: Yet another ChatGPT command line tool.

## Features

- Interactive mode using [GNU Readline](https://tiswww.case.edu/php/chet/readline/rltop.html).
- Batch mode.
- Ready-to-use system messages.
- Expand file contents from the file path(s) using the placeholder.
- Expand web page contents from the URL using the placeholder.
- Magic commands to `clear`, `pop`, `edit`, `write`, `save`, and `load` data.
- Execute system commands and pass captured stdout and stderr output to ChatGPT.
- Code blocks in the response can be referenced from `$CODE0`, `$CODE1`...
- Syntax highlighting for code blocks using [bat](https://github.com/sharkdp/bat).
- Output HTML.

## Installation

### GtiHub Release

Download binaries from [Github Release](https://github.com/kojix2/chatgpt-cli/releases/latest).

### From source code (recommended)

Install [Crystal](https://github.com/crystal-lang/crystal) and build the project:

```bash
git clone --recursive https://github.com/kojix2/chatgpt-cli
cd chatgpt-cli
shards build --release
sudo cp bin/chatgpt /usr/local/bin
```

Please disable Conda or similar environments when building to ensure correct linking.

<details>
<summary><b>Windows</b></summary>

To compile on Windows, set environment variables to turn off the following two features.

- `CHATGPT_NO_READLINE=1` disables GNU Readline.
- `CHATGPT_NO_URL=1` disables URL fetching.

  ```powershell
  git clone https://github.com/kojix2/chatgpt-cli
  git submodule update -i # Awesome ChatGPT Prompts
  cd chatgpt-cli
  $env:CHATGPT_NO_READLINE=1
  $env:CHATGPT_NO_URL=1
  shard build --release --skip-postinstall
  # bin/chatgpt.ext is created
  ```

</details>

### Set your [OpenAI API key](https://platform.openai.com/account/api-keys)

```bash
export OPENAI_API_KEY="your_openai_api_key"
```

### Proxy settings (optional)

```
export HTTP_PROXY=http://[IP]:[port]
export HTTPS_PROXY=https://[IP]:[port]
```

## Usage

```bash
chatgpt
```

<details>
<summary><b>Windows</b></summary>

Set the environment variable `CHATGPT_CLI_CONFIG`.

The path to the directory where the configuration file will be saved. This is required on Windows.

</details>

### Options

```
Usage: chatgpt [options]
    prompts                          Print all system message IDs and exit
    -r, --resume                     Resume the session
    -l FILE, --load FILE             Load session from file
    -m MODEL, --model MODEL          Model name [gpt-3.5-turbo]
    -i ID, --id ID                   ID of the custom system message
    -s STR, --system STR             System message
    -E INT                           Number of edits to generate [1]
    -T Float, --temperature Float    Sampling temperature to use [1.0]
    -P Float, --top_p Float          Probability threshold of nucleus sampling [1.0]
    -b, --batch                      Batch mode (no interactive prompts)
    -d, --debug                      Debug mode
    -v, --version                    Print version info and exit
    -h, --help                       Print help
```

Restore the previous chat and use the gpt-4 model.

```
chatgpt -r -m gpt-4
```

#### Interactive mode

```
chatgpt i
```

To exit, type `exit`, `quit`, or press `Ctrl + D`.
Write your message using GNU Readline, which supports [Emacs shortcuts](https://en.wikipedia.org/wiki/GNU_Readline), such as `↑` and `↓`.

```
Hi
```

You can cancel a query to ChatGPT with `Ctrl + C`.

Line breaks are not currently supported in the interactive mode.

#### Batch mode

- `-r` `--resume` The chat from the last time you exited is carried over to the startup.

```sh
echo "hello" | chatgpt
# How can I assist you today?
echo "It's okay now. Rest." | chatgpt -r
# Thank you for your concern. I hope you have a pleasant day as well. Feel free to reach out if you need any assistance in the future. Take care and rest well!
echo "%html" | chatgpt -r
```

#### Awesome ChatGPT Prompts

You can select system commands in [Awesome ChatGPT Prompts](https://github.com/f/awesome-chatgpt-prompts).

```bash
# Output list of available prompts
chatgpt prompts
# Set system message by name
chatgpt -i "Linux Terminal"
# by id number
chatgpt -i 0
```

### Magic Commands

During the dialogue, you can use a variety of magic commands. `%help`

| Magic Command       | Description                                                        |
| ------------------- | ------------------------------------------------------------------ |
| `%list` `%list[n]`  | Displays the message(s).                                           |
| `%clear`            | Clear all messages. Change the topic and set token back to zero.   |
| `%pop <n>`          | Remove the last n messages and response [1].                       |
| `%shift <n>`        | Remove first n messages and responses [1].                         |
| `%write <filename>` | Write the most recent message to a file. Save the text or code.    |
| `%w <filename>`     | Alias for `write`.                                                 |
| `%config`           | Edit the config file. Open a text editor and rewrite the settings. |
| `%system`           | Show the current system message.                                   |
| `%system <message>` | Set a new system message.                                          |
| `%edit`             | Edit data in JSON format. You are free to tamper with the past.    |
| `%html <filename>`  | Export the conversation to HTML and launch your browser.           |
| `%save <filename>`  | Save the data. This allows you to do things like "save session".   |
| `%load <filename>`  | Load the data. This allows you to do things like "load session".   |
| `%resume`           | Load data from auto-saved data file.                               |
| `%model <name>`     | Change the model.                                                  |
| `%tokens`           | Show number of tokens used from the ChatGPT response.              |
| `%webapp`           | Open the ChatGPT website.                                          |
| `%debug`            | Show debug message.                                                |
| `%help`             | Show the help. Humans forget commands.                             |

Note that for `%config`, `%data`, and other commands launch an editor. The editor used can be set by the `EDITOR` environment variable.

### Substitution

#### Files `%{foo.txt}`

```
Please explain the following code: %{src/beatles.py} Are there any bugs?
```

```
Please read the code of the tool: %{src/*.cr} %{src/**/*.cr} Then update README.md %{README.md}
```

`%{}` can be changed in the config file.

#### Web pages `%u{www.example.com}`

```
Pick five interesting news items: %u{https://news.ycombinator.com/}
```

Here, the HTML from the URL is fetched, the words used in the `body` are extracted and passed to ChatGPT.

`%u{}` can be changed in the config file.

### System Commands

#### `!cmd`

Simply execute the system command.

```
!pwd
```

#### `!{ cmd }`

Replaced by the contents of the standard output and standard error output.

```
Please write a commit message: !{git diff}
```

#### `!!cmd`

capture STDOUT and STDERR.

```bash
!!git diff

Please write a commit message: %STDOUT
```

```bash
!!wrong_command

Explain this error message: %STDERR
```

### Code Blocks in the Response

#### Syntax highlighting

The [`bat`](https://github.com/sharkdp/bat) command is required. You can use the development version by setting the following environment variables and compiling.

- `CHATGPT_BAT=1 shards build` Only code blocks are targeted for syntax highlighting.
- `CHATGPT_BAT=2 shards bulid` The entire response is considered markdown and subject to syntax highlighting.

#### `$CODE0` `$CODE1`

When ChatGPT returns code blocks, ChatGPT CLI saves these blocks temporarily and assigns them to environment variables named `CODE0`, `CODE1`, ... and so on. This allows you to execute the code blocks on your computer.

```
Write code to display 1 to 10 in Python and Ruby.
```

````md
Python:

```
for i in range(1, 11):
    print(i)
```

Ruby:

```
(1..10).each { |i| puts i }
```
````

```
! python $CODE0
! ruby $CODE1
```

Save code block.

```
Please write comments/documentation for the code: %{src/client.cr}
!cp $CODE0 src/client.cr
# Then check diff with your code editor...
```

## Configuration

`config.json` is located in `~/.config/chatgpt-cli/` by default.

- substitute_patterns: `%{}` `%u{}` `!{}` `%STDOUT` `%STDERR`
- terminal_colors: `chatgpt` `warning` `debug` `stdout` `stderr`

Type `%config` to launch editor.
Placeholders such as `%{}` and `%u{}` can be set with regular expressions

Please refer to the latest `config.json` file in the repository for the most recent information.

### Prompts (system commands)

`prompts.csv` is located in `~/.config/chatgpt-cli/` by default.

## Uninstallation

ChatGPT CLI uses the following 3 files and directories. This is all there is to it.

```sh
rm /usr/local/bin/chatgpt   # Remove the executable
rm -r ~/.config/chatgpt-cli # Remove the config directory
rm ~/.chatgpt_history       # Remove command history
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/chatgpt-cli](https://github.com/kojix2/chatgpt-cli).

## Development

![overview](https://raw.githubusercontent.com/kojix2/chatgpt-cli/main/docs/overview.png)

Building:

```bash
git clone https://github.com/kojix2/chatgpt-cli
git submodule update -i
cd chatgpt-cli
shards install
shards build
```

Testing:

```
crystal spec
```

You can quickly try development by using [Gitpod](https://www.gitpod.io/).

## Acknowledgments

- @hidao80 - [MonopolyGPT](https://github.com/hidao80/MonopolyGPT)

## License

This project is open source and available under the terms of the [MIT License](https://opensource.org/licenses/MIT).
