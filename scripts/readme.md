# Git Scripts

The git scripts are based on the blog post of 
[Ankit Samarthya](https://betterprogramming.pub/git-hooks-for-your-rails-app-to-run-rubocop-brakeman-and-rspec-on-push-or-commit-ab51cd65e713) and modified to the needs of xmera Solutions. That is, the hooks might not work in your environment.

## Hooks

### Configuration

First, configure required environment variables in `./scripts/.env` file:

```txt
CASE=(development-case)
```

### Pre-Commit Hook

The pre-commit hook will run before every git commit and let rubocop check your code.

### Pre-Push Hook

The pre-push hook will run before every git push and let brakeman check your code
as well as start your plugin tests.

## Install Hooks

In order to symlink the git hooks into the required directory you need to navigate
into the plugins root dir and run

```shell
./scripts/install-hooks.bash
```

## Uninstall Hooks

When you need to disable the hooks in some situations then you can uninstall them
by running:

```shell
./scripts/uninstall-hooks.bash
```
