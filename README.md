Unofficial SteamLink SDK
========================

[![Travis CI][travis_img]][travis_url]
[![GPLv3 License][license_img]][license_url]

SteamLinkSDK is a third-party SDK for developing native Steam Link applications.

About
-----

SteamLinkSDK was created to provide an alternative to the official vendor's
development kit for the Steam Link, which is available at
<https://github.com/ValveSoftware/steamlink-sdk>. SteamLinkSDK is not a fork
of Valve's steamlink-sdk, though it is inspired by it.

SteamLinkSDK is in no way affiliated or endorsed by Valve.

Getting Started
---------------

This project is still in pre-release beta. Users must clone the GitHub
repository and build it themselves if they wish to use it. In the future,
binary releases may be uploaded for easier use.

Building
--------

SteamLinkSDK uses [CMake] as the build system. CMake 3.0.0 or later is
required. 

To download and build SteamLinkSDK using CMake and [Ninja] (Recommended), run:

```bash
$ git clone https://github.com/Symbitic/SteamLinkSDK
$ mkdir SteamLinkSDK/build
$ cd SteamLinkSDK/build
$ cmake -G "Ninja" ..
$ cmake --build .
```

CMake will then handle downloading, configuring, and building of any external
projects needed by SteamLinkSDK. An active internet connection is needed while
CMake is downloading project files.

Legal
-----

Copyright (c) 2016 Symbitic.

SteamLinkSDK is distributed under the FSF and OSI-approved BSD 2-clause license.
For full terms, see [LICENSE.md].

[travis_img]: https://img.shields.io/travis/Symbitic/SteamLinkSDK.svg?style=flat-square&label=Build

[travis_url]: https://travis-ci.org/Symbitic/SteamLinkSDK

[license_img]: https://img.shields.io/github/license/Symbitic/SteamLinkSDK.svg?style=flat-square&label=License

[license_url]: http://choosealicense.com/licenses/bsd-2-clause/

[CMake]: http://www.cmake.org/

[Ninja]: https://ninja-build.org/

[GNU General Public License]: http://www.gnu.org/licenses/gpl-3.0.html

[LICENSE.md]: ./LICENSE.md