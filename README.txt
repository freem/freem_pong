+------------+----------------------------------------------------------------+
| freem pong | a small pong clone for NES/Famicom and PC Engine/TurboGrafx 16 |
+------------+----------------------------------------------------------------+
(This file is meant to be viewed in a text editor with monospaced font.)

--[Introduction]---------------------------------------------------------------
For some odd reason, I thought it might be a neat idea to create a Pong clone
that targets both the NES/Famicom and PC Engine/TurboGrafx 16. Unlike most
PCE projects, ca65 and ld65 are used instead of the standard pceas.

Pong is simple enough to understand, yet complex enough to introduce a number
of concepts required when making a video game:

- Game states (attract mode vs. gameplay)
- Game logic  (what to update and when)
- Collision   (object interaction)
- Input       (handling controller input)
- Display     (sprites and background)

Since the codebase has two targets, the most optimal code is not always used.
When necessary, the NES and PCE behaviors have been split.

--[Requirements]---------------------------------------------------------------
For both targets (NES and PCE):
- GNU Make
- A recent version of CC65 (with PC Engine/TurboGrafx 16 support)
- Some way to run the ROMs (an emulator, a flashcart, an EPROM cart, etc.)

--[Compiling]------------------------------------------------------------------
In the main folder is a Makefile with the following targets:

- release
"make release" builds both NES and PCE release versions. (nes and pce)

- debug
"make debug" builds both NES and PCE debug versions. (nes_debug and pce_debug)

- all
"make all" builds all possible combinations (debug and release)

- nes
"make nes" builds the NES release version.

- nes_debug
"make nes_debug" builds the NES debug version.

- pce
"make pce" builds the PCE release version.

- pce_debug
"make pce_debug" builds the PCE debug version.

ROM binaries are output into the "bin" directory. Object files remain in "src".

--[Controls]--------------------------------------------------------------------
Start (NES) - begin game   (title screen)
Run (PCE)   - begin game   (title screen)
Left, Right - change score (title screen)
Up, Down    - move paddle  (gameplay)
Select      - toggle ball debug (gameplay; debug builds only)

When the ball debug mode is active, Player 1's controller moves the ball
around the screen.

--[Title Screen]----------------------------------------------------------------
(currently not implemented)

The title screen greets you when turning the game on.

You can set the number of points for a game by pressing Left and Right.
Valid values are between 05 and ??.

When ready, press either Start (NES) or Run (PCE) to begin the game.

--[Gameplay]--------------------------------------------------------------------
Gameplay is pretty basic. The ball doesn't really speed up when you hit it,
since the current collision checks suck.


--[License]---------------------------------------------------------------------
All graphics and code are released into the public domain. Where that is not
available, the Unlicense is used instead. see LICENSE file for more information.

NES and Famicom are trademarks of Nintendo.
PC Engine and TurboGrafx 16 are trademarks of NEC.
freem is not affiliated with or endorsed by Nintendo, NEC, Hudson Soft, Sunsoft,
or any other companies.
