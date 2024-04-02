# ChatGPT CLI

[![build](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml)

:eight_spoked_asterisk: Yet another [ChatGPT](https://openai.com/chatgpt) command line tool.

## Features

- Interactive mode using [GNU Readline](https://tiswww.case.edu/php/chet/readline/rltop.html).
- Support for batch mode and Crinja template engine (experimental)
- Ready-to-use system messages.
- Expand file contents from the `%{file/path}`.
- Expand web page contents from the `%u{URL}`.
- Magic commands to `%clear`, `%pop`, `%list`, `%w`, `%save`, and `%load` data.
- Execute system `!{commands}` and pass captured stdout and stderr.
- Code blocks in the response can be referenced from `$CODE0`, `$CODE1`...
- Syntax highlighting for code blocks using [`bat`](https://github.com/sharkdp/bat).
- Output [`%HTML`](https://github.com/hidao80/MonopolyGPT).
- Support for clipboard.

## Installation

### GitHub Release

Download binaries from [Github Release](https://github.com/kojix2/chatgpt-cli/releases/latest).

### homebrew

[![chatgpt-cli (macos)](https://github.com/kojix2/homebrew-brew/actions/workflows/chatgpt-cli-macos.yml/badge.svg)](https://github.com/kojix2/homebrew-brew/actions/workflows/chatgpt-cli-macos.yml)
[![chatgpt-cli (ubuntu)](https://github.com/kojix2/homebrew-brew/actions/workflows/chatgpt-cli-ubuntu.yml/badge.svg)](https://github.com/kojix2/homebrew-brew/actions/workflows/chatgpt-cli-ubuntu.yml)

```sh
brew install kojix2/brew/chatgpt-cli
```

### From source code (recommended)

- [Install Crystal](https://crystal-lang.org/install/)
- `sudo apt install libreadline-dev`
- `brew install readline`

```bash
git clone https://github.com/kojix2/chatgpt-cli
git submodule update --init --recursive # awesome-chatgpt-prompts
cd chatgpt-cli
sudo make install
```

Please disable Conda or similar environments when building to ensure correct linking.

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
chatgpt
```

```sh
echo "hello" | chatgpt
# How can I assist you today?

echo "It's okay now. Rest." | chatgpt -r
# Thank you for your concern. I hope you have a pleasant day as well. Feel free to reach out if you need any assistance in the future. Take care and rest well!
```

(under development)

```sh
cat paper.txt | chatgpt -m "Please summarize this paper."
```

```sh
chatgpt -m "Please summarize this paper." paper.txt
```

```sh
chatgpt -M gpt-4 -m "Please write a simple commit message" <(git diff --cached)
```

#### Template Engine

Run chatgpt script with the [Crinja](https://github.com/straight-shoota/crinja) template engine. (experimental)

```
Please translate the following text into {{language}}.
```

```sh
cat document.txt | chatgpt run -M gpt-4 translate.txt -- --language spanish
```

### Preset Prompts

You can select system commands in [Awesome ChatGPT Prompts](https://github.com/f/awesome-chatgpt-prompts).

```bash
# Output list of available prompts
chatgpt prompts

# by id number
chatgpt i --ap 0
```

### Magic Commands

During the dialogue, you can use a variety of magic commands. `%help`

| Magic Command          | Description                                                        |
| ---------------------- | ------------------------------------------------------------------ |
| `%list` `%list[n]` `n` | Displays the message(s).                                           |
| `%clear`               | Clear all messages. Change the topic and set token back to zero.   |
| `%pop <n>`             | Remove the last n messages and response [1].                       |
| `%shift <n>`           | Remove first n messages and responses [1].                         |
| `%copy <n>`            | Save the nth message to the clipboard. [-1]                        |
| `%write <filename>`    | Write the most recent message to a file. Save the text or code.    |
| `%w <filename>`        | Alias for `write`.                                                 |
| `%config`              | Edit the config file. Open a text editor and rewrite the settings. |
| `%system`              | Show the current system message.                                   |
| `%system <message>`    | Set a new system message.                                          |
| `%edit`                | Edit data in JSON format. You are free to tamper with the past.    |
| `%html <filename>`     | Export the conversation to HTML and launch your browser.           |
| `%save <filename>`     | Save the data. This allows you to do things like "save session".   |
| `%load <filename>`     | Load the data. This allows you to do things like "load session".   |
| `%resume`              | Load data from auto-saved data file.                               |
| `%model <name>`        | Change the model.                                                  |
| `%tokens`              | Show number of tokens used from the ChatGPT response.              |
| `%webapp`              | Open the ChatGPT website.                                          |
| `%debug`               | Show debug message.                                                |
| `%help`                | Show the help. Humans forget commands.                             |

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

### Embed files

```
Improve the code: %{my/script.py}
```

```
Find the bugs: %{src/*.py}
```

### Embed Web Pages

```
Select important news: %u{https://news.ycombinator.com/}
```

The words used in the `<body>` are extracted using [lexbor](https://github.com/kostya/lexbor).

### Embed Standard Output

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

### Extract code blocks

#### Syntax highlighting

The [`bat`](https://github.com/sharkdp/bat) command is required. You can use the development version by setting the following environment variables and compiling.

- `CHATGPT_BAT=1 shards build` Only code blocks are targeted for syntax highlighting.
- `CHATGPT_BAT=2 shards build` The entire response is considered markdown and subject to syntax highlighting.

#### Code block temporary file path `$CODE0` `$CODE1`

- Code blocks are extracted and stored in temporary files
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

Run `chatgpt config` to get the path to the configuration file.

`config.json` is located in `~/.config/chatgpt-cli/` by default.

- `embedded_patterns`: Defines patterns for `%{}`, `%u{}`, `!{}`, `%STDOUT` and `%STDERR`
- `extraction pattern`: Defines patterns for code block extraction.
- `terminal_colors`: Set colors for `chatgpt`, `warning`, `debug`, `stdout` and `stderr`.

To edit, run `chatgpt config --edit`. Or use `%config` in interactive mode.
To reset, run `chatgpt config --reset`.

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

## Acknowledgements

This tool has been greatly influenced, both directly and indirectly, by the creative work of the following individuals.

- @mamantoha - [http_proxy](https://github.com/mamantoha/http_proxy)
- @hkalexling - [Mango/src/util/proxy.cr](https://github.com/getmango/Mango/blob/master/src/util/proxy.cr)
- @hidao80 - [MonopolyGPT](https://github.com/hidao80/MonopolyGPT)
- @lancecarlson - [clipboard_manager.cr](https://github.com/lancecarlson/chatcopy)
- @straight-shoota - [Crinja](https://github.com/straight-shoota/crinja)
- @Flipez - [spinner](https://github.com/Flipez/spinner)

## License

This project is open source and available under the terms of the [MIT License](https://opensource.org/licenses/MIT).
