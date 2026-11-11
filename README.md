# 🚀 Beyond Mars — an arcade game written in assembly

> **TL;DR:** The first part of a small space game where a spaceship crosses an asteroid belt, written from scratch in **assembly language** for a 16-bit educational processor (PEPE). It reads a keypad, draws the spaceship and an asteroid pixel by pixel, plays a sound and shows the ship's energy on 7-segment displays, all by talking directly to the hardware. University project for *Computer Architecture* at Instituto Superior Técnico.

---

## What is this, in plain words?

Most programs are written in languages like Python or Java, which hide how the computer really works. **Assembly** is the lowest level a programmer usually goes: every line is one instruction for the processor ("copy this number into that register", "jump to this line if the result was zero", ...).

The goal of this project was to build a playable game using only those tiny instructions, running on **PEPE**, a simple 16-bit processor designed for teaching, inside a simulator (SEPE) that also emulates a screen, a keypad, displays and a speaker.

## The game

The screen is the window of a spaceship that is travelling beyond Mars and must cross the asteroid belt.

- Asteroids come towards the ship. Hitting one is fatal.
- The ship can fire **probes** (left, straight ahead, or right) to destroy asteroids.
- Some asteroids can be **mined**, which gives the ship energy back.
- The ship's **energy** is shown on the displays. It slowly drops while flying and every time a probe is fired.

Keys used in this version:

| Key | Action |
|---|---|
| `C` | Start the game |
| `3` | Move the asteroid down |
| `4` | Increase the energy counter |
| `5` | Decrease the energy counter |

## What is implemented in this version

This repository contains the **intermediate version** of the game, which focuses on the hardware building blocks:

- Reading the **keypad** by scanning its rows and columns.
- Drawing the **spaceship** and an **asteroid** pixel by pixel on a 64×32 screen, from tables that describe their shapes.
- Moving the asteroid down the screen when a key is pressed, and playing a **sound** when it moves.
- Showing an **energy counter** on the 7-segment displays and changing it with the keypad.
- Controlling the **media module**: background image and front image.

Firing probes, collisions and timer interrupts were part of the final game and are **not** in this version.

## How to run it

1. Get the **SEPE simulator** used in IST's Computer Architecture course (Java application).
2. Open `simulator/beyond-mars.cir` in the simulator. This file describes the whole "computer": processor, memory, screen, keypad, displays. Keep the image and sound files in the same folder.
3. Load and assemble `beyond-mars.asm` into the processor and start the simulation.
4. Press `C` on the simulated keypad to start.

## Project structure

```
beyond-mars.asm          # The game, in PEPE assembly (commented, in Portuguese)
simulator/
  beyond-mars.cir        # Circuit for the SEPE simulator
  fundo.jpg              # Background image
  imagem-frontal.jpg     # Front overlay image
  disparo.wav            # Shooting sound
```

## Authors

Vasco Caetano and group colleagues, Instituto Superior Técnico.

## Context

- **Course:** Computer Architecture (Arquitetura de Computadores), Instituto Superior Técnico, University of Lisbon
- **Language:** PEPE-16 assembly
- The project statement and the simulator belong to the course teaching staff and are not included here.
