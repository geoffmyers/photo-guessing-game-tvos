# Contributing to Photo Guessing Game Tvos

Thanks for taking an interest. This project is developed inside a private
mono repo and published here as a snapshot, which shapes a couple of the
rules below — please read the last section before opening a PR.

## Getting set up

**Stack:** Swift / Xcode.

```bash
git clone https://github.com/geoffmyers/photo-guessing-game-tvos.git
cd photo-guessing-game-tvos
open PhotoGuessingGame.xcodeproj   # Xcode 15 or newer
```

## Checks

The project has no test target yet, so there is no automated suite to run.
Before pushing, build with **⌘B** and play a round in the tvOS Simulator in the
mode you changed, using **Use Demo Photos** if the simulator has no library.
A test target is a welcome contribution.

## Before you open a pull request

- Keep the change focused. One concern per PR is much easier to review.
- Match the surrounding style rather than introducing a new one. There is no
  separate style guide; the existing code is the guide.
- Update the README if you change behaviour a user can see.
- Explain **why** in the commit message, not just what. The diff already says
  what changed.

## Reporting a bug

Open an issue with what you did, what you expected, and what happened instead.
Version numbers and the exact command or steps help more than anything else.
If it is a crash, include the full error rather than a summary of it.

## Security

Please do **not** open a public issue for a security problem. Report it
privately through GitHub's *Report a vulnerability* button on the Security tab.

## How this repo is published

This project lives in a private mono repo and is published here as a
**one-commit snapshot**, so the history you see starts at the import rather
than at the first day of the project. Two consequences:

- Pull requests are reviewed here and applied upstream, then republished. Your
  authorship is preserved in the commit message; your commit SHA will not
  survive, because the next snapshot replaces this history.
- Operator configuration (`*.tpl` and similar) is deliberately excluded from
  the snapshot. If a config file looks missing, look for the matching
  `.example` file instead.

## Licence

By contributing you agree that your contribution is licensed under the same
terms as this project — see [LICENSE.md](LICENSE.md).
