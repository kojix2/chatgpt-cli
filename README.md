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

Note: Binaries for macOS are [not statically compiled](https://crystal-lang.org/reference/1.7/guides/static_linking.html#macos) and require shared libraries, such as `libssl` and `libcrypto`. If you encounter any errors, please check the required libraries by running `otool -L /usr/local/bin/chatgpt`.

Windows is not supported.

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

### Set your [OpenAI API key](https://platform.openai.com/account/api-keys) as an environment variable by running:

```bash
export OPENAI_API_KEY="your_openai_api_key"
```

### Using a proxy server

```
export HTTP_PROXY=http://[IP]:[port]
export HTTPS_PROXY=https://[IP]:[port]
```

## Usage

To start using ChatGPT CLI, run the `chatgpt` command in your terminal:

```bash
chatgpt
```

Type a message and press Enter to get a response from GPT-3.5 Turbo. To exit, type `exit`, `quit`, or press `Ctrl + D`.

### Options

You can set various options when running the `chatgpt` command:

```
Usage: bin/chatgpt [options]
    -r, --resume                     Resume the session
    -m MODEL, --model MODEL          Model name [gpt-3.5-turbo]
    -i ID, --id ID                   ID of the custom system message
    -s STR, --system STR             System message
    -n INT                           Number of edits to generate [1]
    -t Float, --temperature Float    Sampling temperature to use [1.0]
    -p Float, --top_p Float          Probability threshold of nucleus sampling [1.0]
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

### Using ChatGPT interactively

Start ChatGPT CLI.

```
chatgpt
```

Write your message using GNU Readline, which supports [Emacs shortcuts](https://en.wikipedia.org/wiki/GNU_Readline), such as `↑` and `↓`.

```
> Hi
```

You can cancel a query to ChatGPT with `Ctrl + C`. This is especially useful when you make a writing mistake, and it takes a long time to reply.

Unfortunately, line breaks are not currently supported, but still you can copy-paste line breaks.

### Selecting ChatGPT System Commands

Select pre-registered system commands:

```bash
chatgpt -i "Linux Terminal"
```

[Awesome ChatGPT Prompts](https://github.com/f/awesome-chatgpt-prompts) are available.

### Passing Files to ChatGPT

You can pass the contents of files to ChatGPT by using the `%{foo.txt}` pattern.

```
> Please explain the following code: %{src/beatles.py} Are there any bugs?
```

With this feature, you can pass the code to ChatGPT and have them write README.md.

```
> Please read the code of the tool: %{src/*.cr} %{src/**/*.cr} Then update README.md %{README.md}
...
> %w README.md # This will save README.md
```

Note: READMEs created this way tend to be characterless. Still, it is marvelous to have a computer write the README for you.

`%{}` can be changed in the config file.

### Passing Web Pages to ChatGPT

You can pass the contents of a web page to ChatGPT by using `%%{www.example.com}`.

```
> Pick five interesting news items: %%{https://news.ycombinator.com/}
```

Here, the HTML from the URL is fetched, the words used in the `body` are extracted and passed to ChatGPT. It is much smaller than the raw HTML, but still not enough.

`%%{}` can be changed in the config file.

### Magic Commands

During the dialogue, you can use a variety of magic commands.

```
%clear
```

Clear all messages. This is useful when you want to change the topic and set TOKEN back to zero.

```
%undo <n>
```

Undo the last n query and response [1]. If you make a mistake asking ChatGPT or if the reply is not what you are looking for, you can undo.

```
%shift <n>
```

Remove first <n> messages and responses. This is useful when you want to continue the chat even after the Token count has reached its limit.


```
%write <filename>
```

Write the most recent message to a file. Save the text and scripts written by ChatGPT.

```
%w <filename>
```

Alias for `write`. This magic command is used so often that an alias is provided.

```
%config
```

Edit the config file. Open a text editor and rewrite the settings.

```
%system
```

Show the current system message.

```
%system <message>
```

Set a new system message (this behavior is subject to change).

```
%edit
```

Edit data in JSON format. All data passed to ChatGPT can be edited here. You are free to tamper with the past.

```
%html <filename>
```

Export the conversation to HTML and launch your browser. This feature is useful when you want to save a conversation or check path expansion, etc. (Experimental and the output HTML may not be correct)

```
%save <filename>
```

Save the data. This allows you to do things like "save session". The file is a JSON file to be posted to ChatGPT.

```
%load <filename>
```

Load the data. This allows you to do things like "load session".

```
%resume
```

Load data from auto-saved data file. We humans forget to save data. Therefore, the last session is automatically saved.

```
%model <name>
```

You can change the model used in the next request. For example, if you find your question is too difficult for gpt-3.5-turbo, you can change to gpt-4 at that point.

```
%tokens
```

Total tokens used. You will see a more detailed number of TOKENs than is shown in the prompt. Please note that chatgpt-cli does not have the ability to calculate the number of TOKENs. It only displays the ChatGPT response. Therefore, if any edits may have been made, it will be Unknown.

```
%webapp
```

Open the ChatGPT website.

```
%debug
```

Show debug message. Display the data actually posted to ChatGPT and the response in JSON format.

```
%help
```

Show the help. Humans forget commands.

Note that for `%config`, `%data`, and other commands launch an editor. The editor used can be set by the `EDITOR` environment variable.
Note that the tool is still being improved and the behavior of the magic commands will continue to change.

### Executing System Commands

You can execute system commands while chatting by prefixing the command with the `!` symbol.

Execute a command, and display the output immediately:

```bash
> !pwd
```

This way you can also run commands like `vim` and `top`.

#### Capture STDOUT and STDERR

Capture the output of a command for later use:

```bash
> !!git diff
```

The standard output can be inserted into the chat with `%STDOUT`.

```
> Please write a commit message: %STDOUT
```

The results can be referenced through the environment variable `RESP` (experimental).

```
> !git commit -m "$RESP"
```

You can also insert the contents of the standard error output into the chat using `%STDERR`.

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

#### Run Code Blocks in the Response

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
