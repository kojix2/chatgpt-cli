# ChatGPT CLI

[![build](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml)

:eight_spoked_asterisk: Yet another [ChatGPT](https://openai.com/chatgpt) command line tool.

## Features

- Interactive mode using [GNU Readline](https://tiswww.case.edu/php/chet/readline/rltop.html).
- Batch mode.
- Ready-to-use system messages.
- Expand file contents from the `%{file/path}`.
- Expand web page contents from the `%u{URL}`.
- Magic commands to `%clear`, `%pop`, `%list`, `%w`, `%save`, and `%load` data.
- Execute system `!{commands}` and pass captured stdout and stderr.
- Code blocks in the response can be referenced from `$CODE0`, `$CODE1`...
- Syntax highlighting for code blocks using [`bat`](https://github.com/sharkdp/bat).
- Output [`%HTML`](https://github.com/hidao80/MonopolyGPT).

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

- `CHATGPT_READLINE=0` disables GNU Readline.
- `CHATGPT_URL=0` disables URL fetching.

  ```powershell
  git clone https://github.com/kojix2/chatgpt-cli
  git submodule update -i # Awesome ChatGPT Prompts
  cd chatgpt-cli
  $env:CHATGPT_READLINE=0
  $env:CHATGPT_URL=0
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

<details>
<summary><b>Windows</b></summary>

Set the environment variable `CHATGPT_CLI_CONFIG`.

The path to the directory where the configuration file will be saved. This is required on Windows.

</details>

## Usage

### Interactive mode

```
chatgpt i
```

- To exit, type `exit`, `quit`, or press `Ctrl + D`.
- You can cancel a query to ChatGPT with `Ctrl + C`.
- GNU Readline supports [Emacs shortcuts](https://en.wikipedia.org/wiki/GNU_Readline), such as `↑` and `↓`.
- Line breaks are not currently supported.

### Batch mode

```
chatgpt run
```

```sh
echo "hello" | chatgpt
# How can I assist you today?
echo "It's okay now. Rest." | chatgpt -r
# Thank you for your concern. I hope you have a pleasant day as well. Feel free to reach out if you need any assistance in the future. Take care and rest well!
echo "%html" | chatgpt -r
```

### Awesome ChatGPT Prompts

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

### System Commands

Execute the system command.

```
!pwd
```

Execute the system command and capture `%STDOUT` and `%STDERR`.

```
!!git diff --cached
```

### File Inclusion

```
Improve the code: %{my/script.py}
```

```
Find the bugs: %{src/*.py}
```

### Web Page Inclusion

```
Select important news: %u{https://news.ycombinator.com/}
```

The words used in the `<body>` are extracted.

### Standard Streams Inclusion

`!{command}` Execute the command and insert standard output and standard error output.

```
Please write a commit message: !{git diff}
```

`%STDOUT` - captured standard output of `!!{command}`

```
Please write a commit message: %STDOUT
```

`%STDERR` - captured standard error output of `!!{command}`

```
Explain this error message: %STDERR
```

### Code Blocks in the Response

#### Syntax highlighting

The [`bat`](https://github.com/sharkdp/bat) command is required. You can use the development version by setting the following environment variables and compiling.

- `CHATGPT_BAT=1 shards build` Only code blocks are targeted for syntax highlighting.
- `CHATGPT_BAT=2 shards bulid` The entire response is considered markdown and subject to syntax highlighting.

#### Code block temporary file path `$CODE0` `$CODE1`

- Code blocks are extracted and saved in the temporary files.
- `$CODE0`, `$CODE1`, ... are path to the temporary files.

```
Write code to display 1 to 10 in Python and Ruby.
```

````md
Python:

```python
for i in range(1, 11):
    print(i)
```

Ruby:

```ruby
(1..10).each { |i| puts i }
```
````

```
! python $CODE0
! ruby $CODE1
```

Save the code block to a file. (There is obvious room for improvement here)

```
!cp $CODE0 src/client.cr
```

## Configuration

`config.json` is located in `~/.config/chatgpt-cli/` by default.

- substitute_patterns: `%{}` `%u{}` `!{}` `%STDOUT` `%STDERR`
- terminal_colors: `chatgpt` `warning` `debug` `stdout` `stderr`

To edit, run `chatgpt config`. Or use `%config` in interactive mode.
Placeholders such as `%{}` and `%u{}` can be set with regular expressions

[config.json](config.json)

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

<details>
<summary><b>Overview</b></summary>

![overview](https://raw.githubusercontent.com/kojix2/chatgpt-cli/main/docs/overview.png)

</details>

```
crystal spec
```

- You can quickly try development by using [Gitpod](https://www.gitpod.io/).

## Acknowledgments

- @hidao80 - [MonopolyGPT](https://github.com/hidao80/MonopolyGPT)

## License

This project is open source and available under the terms of the [MIT License](https://opensource.org/licenses/MIT).
