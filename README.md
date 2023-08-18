# ChatGPT CLI

[![build](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml)

[ChatGPT CLI](https://github.com/kojix2/chatgpt-cli/) is a command-line interface tool that interacts with OpenAI's [ChatGPT API](https://platform.openai.com/docs/api-reference/chat). It allows users to communicate with GPT models, adjust API parameters, use magic commands, insert file contents, fetch content from URLs, and execute system commands while chatting.

## Features

- Interactive command-line interface using [GNU Readline](https://tiswww.case.edu/php/chet/readline/rltop.html) with [Emacs keyboard shortcuts](https://en.wikipedia.org/wiki/GNU_Readline).
- Expand file contents from the file path(s) using the placeholder.
- Expand web page contents from the URL using the placeholder.
- Magic commands to `clear`, `undo`, `edit`, `write`, `save`, and `load` data.
- Execute system commands and pass captured stdout and stderr output to ChatGPT.
- Code blocks in the response are saved in temp files and can be referenced from `$CODE1`, `$CODE2`...
- Output execution results in HTML (experimental).
- Substitution patterns of placeholders can be configurable in the configuration file.

## Installation

### GtiHub Release

Download binaries from [Github Release](https://github.com/kojix2/chatgpt-cli/releases/latest) for Linux or macOS.

- Binaries for macOS are [not statically compiled](https://crystal-lang.org/reference/1.7/guides/static_linking.html#macos).
- Windows is not supported.

### From source code

1. Install [Crystal](https://github.com/crystal-lang/crystal)
2. Build the project:

   ```bash
   git clone https://github.com/kojix2/chatgpt-cli
   git submodule update -i # Awesome ChatGPT Prompts
   cd chatgpt-cli
   make
   sudo make install # Or simply copy bin/chatgpt to your directory in $PATH.
   ```

### Set your [OpenAI API key](https://platform.openai.com/account/api-keys)

```bash
export OPENAI_API_KEY="your_openai_api_key"
```

### Proxy settings

```
export HTTP_PROXY=http://[IP]:[port]
export HTTPS_PROXY=https://[IP]:[port]
```

## Usage

```bash
chatgpt
```

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

Note that short options cannot be concatenated.

```
chatgpt -rm gpt-4
# Error: Invalid option: -rm
```

### Interactive mode (default)

Start ChatGPT CLI.

```
chatgpt
```

To exit, type `exit`, `quit`, or press `Ctrl + D`.
Write your message using GNU Readline, which supports [Emacs shortcuts](https://en.wikipedia.org/wiki/GNU_Readline), such as `↑` and `↓`.

```
> Hi
```

You can cancel a query to ChatGPT with `Ctrl + C`.

Unfortunately, line breaks are not currently supported in the interactive mode, but still you can copy-paste line breaks.

### Batch mode

- `-b` `--batch` Pass input by filename or standard input. ChatGPT will output to standard output and exit immediately.
- `-r` `--resume` The chat from the last time you exited is carried over to the startup.

```sh
echo "hello" | chatgpt -b
# How can I assist you today?
echo "It's okay now. Rest." | chatgpt -b -r
# Thank you for your concern. I hope you have a pleasant day as well. Feel free to reach out if you need any assistance in the future. Take care and rest well!
echo "%html" | chatgpt -b -r
```

### Awesome ChatGPT Prompts

You can select system commands in [Awesome ChatGPT Prompts](https://github.com/f/awesome-chatgpt-prompts).

```bash
chatgpt -i "Linux Terminal"
```

### Embed files `%{foo.txt}`

```
> Please explain the following code: %{src/beatles.py} Are there any bugs?
```

```
> Please read the code of the tool: %{src/*.cr} %{src/**/*.cr} Then update README.md %{README.md}
...
> %w README.md # This will save README.md
```

`%{}` can be changed in the config file.

### Web pages `%%{www.example.com}`

```
> Pick five interesting news items: %%{https://news.ycombinator.com/}
```

Here, the HTML from the URL is fetched, the words used in the `body` are extracted and passed to ChatGPT.

`%%{}` can be changed in the config file.

### Magic Commands `%HELP`

During the dialogue, you can use a variety of magic commands.

| Magic Command       | Description                                                        |
| ------------------- | ------------------------------------------------------------------ |
| `%clear`            | Clear all messages. Change the topic and set token back to zero.   |
| `%undo <n>`         | Undo the last n query and response [1].                            |
| `%shift <n>`        | Remove first <n> messages and responses.                           |
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
Note that the tool is still being improved and the behavior of the magic commands will continue to change.

### Executing System Commands `!pwd`

```
> !pwd
```

```
> !vim
```

```
> !top
```

#### Capture STDOUT and STDERR `!!cmd` `%STDOUT` `%STDERR` `!{cmd}`

````
```bash
> !!git diff
````

```
> Please write a commit message: %STDOUT
```

```bash
> !!wrong_command
```

```
> Explain the meaning of this error message: %STDERR
```

You can also use `!{ cmd }`. In this case, it will be replaced by the contents of standard input

```
> What time is it now? Hint: !{date}
```

#### Code Blocks in the Response `$CODE1` `$CODE2`

When ChatGPT returns code blocks, ChatGPT CLI saves these blocks temporarily and assigns them to environment variables named `CODE1`, `CODE2`, ... and so on. This allows you to execute the code blocks on your computer.

````md
> Write code to display 1 to 10 in Python and Ruby.
> Python:

```
for i in range(1, 11):
    print(i)
```

Ruby:

```
(1..10).each { |i| puts i }
```

> ! python $CODE1
> ! ruby $CODE2
````

Save code block only.

```
> Please write comments/documentation for the code: %{src/client.cr}
> !cp $CODE1 src/client.cr
# Then check diff with your code editor...
```

## Configuration

`config.json` is located in `~/.config/chatgpt-cli/` by default.

- substitute_patterns: `%{}` `%%{}` `!{}` `%STDOUT` `%STDERR`
- terminal_colors: `chatgpt` `warning` `debug` `stdout` `stderr`

Type `%config` to launch editor.
Placeholders such as `%{}` and `%%{}` can be set with regular expressions

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

Or

```
sudo make uninstall
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

## License

This project is open source and available under the terms of the [MIT License](https://opensource.org/licenses/MIT).
