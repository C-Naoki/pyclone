# PyClone

PyClone is a command-line utility to help you efficiently use [my-python-template](https://github.com/C-Naoki/my-python-template), providing a quick way to clone, set up, and commit the initial version of the project on GitHub.

## Setup

In order to use PyClone, you must first copy the `pyclone` function into your shell's configuration file. This file will be `.bashrc` for Bash users or `.zshrc` for ZSH users.

The function declaration should look something like this:

```bash
pyclone() {
    ...
}
```

## Environment Variables

There are two environment variables that need to be defined to use PyClone:

- `PYCLONE_PATH`: This variable should contain the path to the directory where you want your new project directories to be created.
- `GITHUB_TOKEN`: This should contain your GitHub access token. This token will be used when creating a new repository on GitHub. For more information on GitHub access tokens, [click here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

## Usage

PyClone can be invoked simply by calling `pyclone` in your terminal. If you would like PyClone to automatically create a new repository on GitHub and make an initial commit, you can use the `-g` option:

```bash
pyclone -g
```

During execution, PyClone will ask for a virtual environment name, which will also be used as the directory name for the new project. If the directory already exists, PyClone will ask if you want to overwrite it. If the `-g` option is used, PyClone will also ask if you want to publish the new repository on GitHub.

## Support

If you encounter any issues while using PyClone, or if you have suggestions for new features, please submit an issue on this repository. I appreciate your feedback and contributions!
