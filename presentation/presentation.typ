//
// Example slideshow: Introduction to GPU Programming
// Using polylux for Typst presentations.
//

#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.4.2"

#set text(font: "Iosevka", size: 20pt)
#show raw: set text(font: "Iosevka")

#set page(
  paper: "presentation-16-9",
  margin: (x: 1em, top: 1em, bottom: 2em),
  header: {
    place(right + top, dx: 1em, float: true)[
      #image("ph-logo.svg", height: 3em)
    ]
  },
  footer: {
    place(right + bottom, dy: -.75em, dx: .25em)[
      #toolbox.slide-number
    ]
  },
)

#show heading.where(level: 1): set text(size: 32pt, weight: "black", tracking: -1.5pt)
#show heading.where(level: 2): set text(size: 24pt, weight: "black", tracking: -1pt)

#set document(author: "Kartavya Vashishtha")

#slide[
  = Before we start...
  Workshop structure:

  #item-by-item[
  - *\~10 minutes*: theory.
  - *\~30 minutes*: guided coding.
  - the rest of the time: self-directed hacking.
  ]

  #uncover("4-")[
    == guided coding: you'll write a matrix multiplication kernel.
  ]
  #uncover(5)[
    == #h(3.2em) hacking: write some other kernels. maybe convolution.
  ]
]

#slide[
  = Before we start...

  Hi! Rules for this presentation:
  #item-by-item[
    - You *_should_* ask questions during the presentation.
    - in fact...
  ]

  #uncover("2-")[
    = Ask me a question right now.
  ]
  #uncover(3)[
    = Another.
  ]
]

#slide[
  #set page(footer: none)
  #align(center + horizon)[
    #text(size: 40pt, weight: "black", tracking: -3pt)[Introduction to GPU Programming]
    #v(2em)
    #text(size: 16pt)[#text(weight: 900, size: 1.5em)[Kart]#text(size: 1.5em)[avya Vashishtha]]
    #v(0.5em)
    #text(size: 14pt, fill: gray)[#datetime.today().display("[month repr:long] [day], [year]")]
  ]
]

#slide[
  = A GPU from a thousand feet away

  #align(center + horizon)[
    #only("2")[
      where is it?!
    ]
    #only("3-")[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        content((0, 1), [oh need to zoom in])
        line((4, 1), (5, 1), mark: (end: ">"), stroke: 1.5pt)
        rect((5, 0), (7.5, 2), fill: rgb("#0000"), stroke: black, name: "box")
      })
    ]
  ]
]

// Slide 3: GPUs from a Foot Away
#slide[
  = A GPU from a few inches away

  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    align: horizon,
    [
      #item-by-item[
        - *not* a CPU
        - trades single-thread speed for many-thread throughput \ \ #h(1.5em) (more on this later!)
      ]],
    [
      #align(center + horizon, figure(
        image("VisionTek_GeForce_256.jpg"),
        caption: "120 MHz Nvidia GeForce 256",
        numbering: none,
      ))
    ],
  )
]

// Slide 4: A History of GPU Usage
#slide[
  = A History of GPU Usage

  1. *Graphics era:* Fixed-function rendering. Push pixels to a buffer, modify, and dump to screen. Rigid APIs.

  #only("2-")[
    2. *Mid-2000s:* _what if... we use these chips for things that aren't games._ NVIDIA releases CUDA (2007) --- general-purpose computing API.
  ]

  #only("3-")[
    3. *2010s:* people start running machine learning on them.
  ]
]

// Slide 5: A History of GPU Usage (cont.)
#slide[
  = Many ways to program a GPU

  #only("1")[
    #align(center + horizon)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        let axis-style = (
          stroke: 1pt + gray.darken(10%),
          mark: (start: "stealth", end: "stealth", fill: gray.darken(10%), size: 0.3),
        )

        line((-9.5, 0), (9.5, 0), ..axis-style) // Purpose: Rendering <-> Compute
        line((0, -5), (0, 5), ..axis-style) // Abstraction: Low-level <-> High-level

        let label-style(txt) = text(size: 1.1em, weight: "extralight", style: "italic", (txt))

        content((10, 0), label-style([Compute]), anchor: "west")
        content((-10, 0), label-style([Rendering]), anchor: "east")
        content((0, 5.5), label-style([High-level]), anchor: "south")
        content((0, -5.5), label-style([Low-level]), anchor: "north")

        let data-style(txt) = text(size: 0.9em, weight: "regular", fill: gray.darken(50%), txt)

        // Coordinates stretched horizontally to prevent central clustering
        let tools = (
          (-8, -4.0, data-style[Vulkan]),
          (-5.5, 1.0, data-style[HLSL]),
          (-6.0, -1.0, data-style[OpenGL]),
          (-3.5, 2.0, data-style[WebGPU]),
          (1.3, -4, data-style[Metal]),
          (1.8, 3.8, data-style[MLX]),
          (3.2, 4.6, data-style[PyTorch]),
          (4.5, 4.0, data-style[Pallas]),
          (5.8, 1.8, data-style[Triton]),
          (7.0, -1.8, data-style[CUDA Tile]),
          (7.8, 3.2, data-style[Mojo]),
          (8.2, 0.5, data-style[OpenCL]),
          (9.0, -3.8, data-style[CUDA]),
          (9.0, -4.8, data-style[ROCm]),
        )

        for (x, y, name) in tools {
          content((x, y), (name))
        }
      })
    ]
  ]

  #only("2-")[
    #align(center + horizon)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        let axis-style = (
          stroke: 1pt + gray.darken(10%),
          mark: (start: "stealth", end: "stealth", fill: gray.darken(10%), size: 0.3),
        )

        line((-9.5, 0), (9.5, 0), ..axis-style) // Purpose: Rendering <-> Compute
        line((0, -5), (0, 5), ..axis-style) // Abstraction: Low-level <-> High-level

        let label-style(txt) = text(size: 1.1em, weight: "extralight", style: "italic", (txt))

        content((10, 0), label-style([Compute]), anchor: "west")
        content((-10, 0), label-style([Rendering]), anchor: "east")
        content((0, 5.5), label-style([High-level]), anchor: "south")
        content((0, -5.5), label-style([Low-level]), anchor: "north")

        let data-style(txt) = text(size: 0.9em, weight: "regular", fill: gray.darken(50%), txt)

        // Coordinates stretched horizontally to prevent central clustering
        let tools = (
          (-8, -4.0, data-style[Vulkan]),
          (-5.5, 1.0, data-style[HLSL]),
          (-6.0, -1.0, data-style[OpenGL]),
          (-3.5, 2.0, data-style[WebGPU]),
          (1.3, -4, data-style[Metal]),
          (1.8, 3.8, data-style[MLX]),
          (3.2, 4.6, data-style[PyTorch]),
          (4.5, 4.0, data-style[Pallas]),
          (5.8, 1.8, text(size: 3em, weight: "extrabold", "Triton")),
          (7.0, -1.8, data-style[CUDA Tile]),
          (7.8, 3.2, data-style[Mojo]),
          (8.2, 0.5, data-style[OpenCL]),
          (9.0, -3.8, data-style[CUDA]),
          (9.0, -4.8, data-style[ROCm]),
        )

        for (x, y, name) in tools {
          content((x, y), (name))
        }
      })
    ]
  ]
]

// Slide 6: GPU Programming Model
#slide[
  #only("1")[
    = A simple model]
  #only("2")[
    = An (overly) simple model
  ]
  #align(center + horizon)[#image("simple.drawio.png", height: 40%)]
]

#slide[
  = Switching gears: time to write ReLU!

  _Recall, or learn very quickly,_
  $
    "ReLU"(x) = cases(x quad "if" x > 0, 0 quad "else")
  $

  Pseudocode:

  #uncover("2-")[
    ```py
    def relu(x):
      return max(x, 0)
    ```]

  #uncover("3-")[
    For an array:
  ]

  #uncover("4-")[
    ```py
    def relu_array(arr):
      return [max(x, 0) for x in arr]
    ```
  ]
]

#slide[
  = A GPU from a few millimeters away

  - trades single-thread speed for many-thread throughput
  - question: _*how do you divide work between these threads?*_

  #uncover(2)[

  #align(center + bottom)[
    #image("gpu-v-cpu.drawio.png", height: 70%)
  ]
  ]
]

#slide[
  = A simple model for a GPU
  #align(center + horizon)[#image("complex.drawio.png", height: 90%)]
]

#slide[
  = Taking ReLU to the GPU
  Grid with dimension (2); blocks are [0, 1]. Each block has 4 threads.
  #image("relu-1.drawio.png", height: 80%)
]

#slide[
  = Taking ReLU to the GPU
  What happens at block 1?
  #image("relu-2.drawio.png", height: 80%)
]

#slide[
  = Time to move over to writing code!!

  #align(horizon)[
    #set text(size: 1.5em)
    - go to #link("https://puhack.horse/gpu-colab", "https://puhack.horse/gpu-colab")
    - click 'Copy to Drive' in top bar.
  ]
]

#slide[
  = An example problem decomposition

  Hm. What sort of problems can be broken into parallel chunks?

  #uncover(2)[

    Enter the humble matmul.

    #align(center + horizon)[#image("simple-matmul.drawio.png", height: 70%)]
  ]
]

#slide[
  = The humble matmul

  ```python
  for i in range(M):
      for j in range(N):
          for k in range(K):
              C[i, j] += A[i, k] * B[k, j]
  ```

  #item-by-item[
    - Imagine one thread per (i, j) index:
      - Thread (0, 0) loads *A[0, k]* and *B[k, 0]*
      - Thread (0, 1) loads #text(weight: "extralight")[A[0, k]] and #text(weight: "bold")[B[k, 1]]
      - Thread (1, 0) loads *A[1, k]* and #text(weight: "extralight")[B[k, 0]]
      - etc.
    - GPUs execute a whole block on one compute unit.
    - This compute unit _has very fast memory._
    - Sharing these accesses is _good_.
    - So let's write this with tiles!
  ]
]

#slide[
  = Presenting: the tiled matmul

  #align(center + horizon)[#image("matmul.drawio.png", height: 70%)]
]

#slide[
  = Tiled matmul pseudocode

  ```python
  def matmul_kernel(A, B, C, M, N, K):
      c_m, c_n = program_id(0), program_id(1)
      accumulator = zeros((MT, NT))

      for k in range(0, K, KT):
          tile_A = A[c_m * MT : (c_m + 1) * MT,        k : k + KT        ]
          tile_B = B[       k : k + KT        , c_n * NT : (c_n + 1) * NT]

          accumulator += dot(tile_A, tile_B)

      C[c_m * MT : (c_m + 1) * MT, c_n * NT : (c_n + 1) * NT] = accumulator
  ```

  #uncover(2)[
    = CODING TIEM!! <\- so excited I cna\'t  spell
  ]
]

#show link: underline

#slide[
  = Hacking Section!
  You can:
  - go to #link("https://tensara.org/", "https://tensara.org/")
  or
  - go to #link("https://puhack.horse/gpu-colab-conv", "https://puhack.horse/gpu-colab-conv")
]
