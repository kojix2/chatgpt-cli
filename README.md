# ChatGPT CLI

[![build](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/chatgpt-cli/actions/workflows/build.yml)

ChatGPT CLI is a command-line interface tool for interacting with OpenAI's [ChatGPT API](https://platform.openai.com/docs/api-reference/chat). It allows users to communicate with the GPT model, adjust API parameters, use magic commands, insert file contents, fetch content from URLs, and execute system commands while chatting.

## Features

- Interact with OpenAI's ChatGPT API through a command-line interface
- Set API parameters like model name (`gpt-3.5-turbo` by default), temperature, and top_p
- Select pre-registered system messages with ID
- Execute magic commands for various actions (e.g., modifying the system message, saving messages, debugging)
- Execute system commands while chatting
- Fetch file contents from paths and insert them into the chat
- Fetch contents from URLs and insert them into the chat

## Installation

1. Install [Crystal](https://github.com/crystal-lang/crystal)
2. Build the project:

   ```bash
   git clone https://github.com/kojix2/chatgpt-cli
   cd chatgpt-cli
   make
   sudo make install
   ```

3. Set your [OpenAI API key](https://platform.openai.com/account/api-keys) as an environment variable:

   ```bash
   export OPENAI_API_KEY="your_openai_api_key"
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
    -m MODEL, --model MODEL          Model name [gpt-3.5-turbo]
    -i ID, --id ID                   ID of the custom system message
    -s STR, --system STR             System message
    -n INT                           Number of edits to generate [1]
    -t Float, --temperature Float    Sampling temperature to use [1.0]
    -p Float, --top_p Float          Probability threshold of nucleus sampling [1.0]
    -v, --version                    Print version info and exit
    -h, --help                       Print help
```

### System commands

Select pre-registered system commands:

```bash
chatgpt -i code
```

`code` `edit` `poet` `tran` is available.
To edit system commands, edit the config file. Type %config to open a text editor.

### Files

You can pass the contents of files to ChatGPT by using `%{foo.txt}` pattern.

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

### Web Page Insertion

You can pass the contents of web page to ChatGPT by using %{www.example.com}

```
> Pick five interesting news items: %%{https://news.ycombinator.com/}
```

Here the HTML from the URL is fetched, the words used in the `body` are extracted and passed to ChatGPT. It is much smaller than the raw HTML, but still not enough.

### Magic Commands

During the dialogue, you can use a variety of magic commands, such as:

```
> %clear
```

Clear all messages. This is useful when you want to change the topic and set TOKEN back to zero.

```
> %undo <n>
```

Undo last n query and response [1].  If you make a mistake asking chatgpt or if the reply is not what you are looking for, you can undo.

```
> %write <filename>
```

Write the most recent message to a file. Save the text and scripts written by ChatGPT.

```
> %w <filename>
```

Alias for `write`. This magic command is used so often that an alias is provided.


- `%config`: Edit config file
- `%system`: Show the current system message
- `%system <message>`: Set a new system message
- `%resume` : Load data from auto saved data file
- `%edit`: Edit data in JSON format
- `%html` : Export messages in HTML format
- `%save <filename>`: Save data to a file [`chatgpt.json`]
- `%load <filename>`: Load data from a file [`chatgpt.json`]
- `%token(s)`: Total tokens used
- `%debug`: Toggle debug mode
- `%help`: Show the help

Note that for `%config`, `%data`, and other commands launch an editor. The editor used can be set by the `EDITOR` environment variable.
Note that the tool is still being improved and the behavior of the magic commands will continue to change.

### Executing System Commands

You can execute system commands while chatting by prefixing the command with the `!` symbol. For example, to check the current working directory, type `!pwd` and press Enter. Similarly, you can execute other system commands like `!ls`, `!date`, etc. If you want to execute a command and record its output for later use, you can prefix the command with `!!` instead, then use `%STDOUT` or `%STDERR` to insert the captured output into the chat.

#### Examples:

1. Execute a command, and display the output immediately:

```bash
> !pwd
> !vim
> !htop
```

2. Capture the output of a command for later use:

```bash
> !! git diff
... git diff output ...
> Please write commit message: %STDOUT
```

```bash
> !!wrong_command
> Explain the meaning of this error message: %STDERR
```

#### Execute code blocks captured from markdown in the response

When ChatGPT returns code blocks enclosed with triple backticks, ChatGPT CLI saves these blocks temporarily and assigns them to environment variables named `CODE1`, `CODE2`, ... and so on in sequential order. This allows you to execute the code blocks by referencing the environment variables in a system command. For example, if the response contains Python, Ruby, and Bash code blocks, you can execute them using `$CODE1`, `$CODE2`, and `$CODE3`, respectively.

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

## Configuration

The system messages used by ChatGPT CLI can be customized through the `config.json` file. The file is located in `~/.config/chatgpt-cli/` by default, but it can be changed by setting the `CHATGPT_CLI_CONFIG` environment variable.

The `config.json` file has the following structure:

```json
{
  "system_messages": {
    "tran": {
      "role": "system",
      "content": "I want you to act as a translator, spelling corrector, and improver."
    },
    "code": {
      "role": "system",
      "content": "I want you to act as a programmer, writing code."
    },
    "poet": {
      "role": "system",
      "content": "I want you to act as a poet, writing poetry."
    }
  }
}
```

## Uninstallation

```sh
rm /usr/local/bin/chatgpt   # Remove the executable
rm -r ~/.config/chatgpt-cli # Remove the config directory
rm ~/.chatgpt_history       # Remove command history
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/chatgpt-cli](https://github.com/kojix2/chatgpt-cli).

## Development

```bash
git clone https://github.com/kojix2/chatgpt-cli
cd chatgpt-cli
shards install
shards build --release
bin/chatgpt
```

## License

This project is open-source and available under the terms of the [MIT License](https://opensource.org/licenses/MIT).
