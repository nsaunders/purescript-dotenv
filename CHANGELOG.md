# Changelog

Notable changes are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Breaking changes:
- `loadFile` and `loadContents` now return `Aff Unit`. (#40 by @nsaunders)

New features:

Bugfixes:
- Handling of escaped quotes (#39 by @nsaunders)

Other improvements:
- Unused values are no longer resolved. (#40 by @nsaunders)

## [3.0.0] - 2022-08-08

Breaking changes:
- Updated to v0.15 of the compiler, dropping support for previous versions. (#37 by @thomashoneyman)

## [2.0.0] - 2021-03-27

Breaking changes:
- Updated to v0.14 of the compiler, dropping support for previous versions. ([92f5656](https://github.com/nsaunders/purescript-dotenv/commit/92f56564b34760a3d959c9bd1658672d8e0034c9) by @nsaunders)

## [1.1.0] - 2020-02-01

New features:
- Add `loadContents` function. (#34 by @nsaunders)

## [1.0.0] - 2019-07-12

Breaking changes:
- `loadFile` now runs explicitly in `Aff` instead of `MonadAff m => m`. (#28 by @nsaunders)

Other improvements:
- Documentation updates

## [0.4.1] - 2019-06-28

Other improvements:
- Documentation fixes

## [0.4.0] - 2019-06-28

New features:
- Added support for command substitution. (#26 by @nsaunders)

## [0.3.0] - 2019-06-08

Breaking changes:
- Updated to v0.13 of the compiler, dropping support for previous versions. (#21 by @nsaunders)

Other improvements:
- Migrated to Spago for dev/CI. (#20 by @nsaunders)
- Enhanced project README.
- Parser refactoring (#19 by @nsaunders)

## [0.2.2] - 2019-05-30

Bugfixes:
- Fixed parser to re-enable comments at the end of a line containing a setting. (#18 by @nsaunders)

Other improvements:
- Added a test for the variable substitution feature. (#16 by @nsaunders)

## [0.2.1] - 2019-05-24

Bugfixes:
- Fixed compiler warnings. (#15 by @nsaunders)

## [0.2.0] - 2019-05-23

New features:
- Added variable substitution feature. ([ab8eda2](https://github.com/nsaunders/purescript-dotenv/commit/ab8eda2d1b97a359d2cd9f24703a38ff02d6a515), [3a417a5](https://github.com/nsaunders/purescript-dotenv/commit/3a417a5923cbd857b0e8cfb4c2f2d35fcdb8a374) by @nsaunders)

## [0.1.5] - 2019-04-30

- Fixed parser to allow comments at the end of a line containing a setting. (#8 by @nsaunders)

## [0.1.4] - 2019-04-28

- Parser refactoring ([3df29dc](https://github.com/nsaunders/purescript-dotenv/commit/3df29dc08110f1aba60c39419cd53bd68092b263) by @nsaunders)

## [0.1.3] - 2019-04-28

- Advanced parsing rules (#6 by @nsaunders)
- Renamed package from ```purescript-node-dotenv``` to ```purescript-dotenv```. ([3e92fea](https://github.com/nsaunders/purescript-dotenv/commit/3e92fea617bf6c1414bdf504a038e97c91d1e740) by @nsaunders)
- Improved unit tests.

## [0.1.2] - 2019-04-09

- Exported ```Setting``` and ```Settings``` types. ([21ec469](https://github.com/nsaunders/purescript-dotenv/commit/21ec469b49b8f363a9f0e598b85fa241f88d94e2) by @nsaunders)

## [0.1.1] - 2019-04-09

- Removed redundant module ```Configuration.Dotenv.Types```. ([f80792f](https://github.com/nsaunders/purescript-dotenv/commit/f80792f7ea237377094373be6d57c821c05ef971) by @nsaunders)

## [0.1.0] -  2019-04-09

- Initial release