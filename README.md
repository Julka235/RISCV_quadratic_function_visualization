# Quadratic Function Visualization in RISC-V

This project visualizes a quadratic function (y = ax^2 + bx + c) on a **BMP image** using the RISC-V architecture and the rars emulator. The user inputs the coefficients of the quadratic function and the program modifies an input BMP image (in.bmp) to visualize the function, saving the result as out.bmp.

<div align="center">
  <img src="images/qf1.png" alt="Quadratic function 1 Screenshot" width="49%">
  <img src="images/qf2.png" alt="uadratic function 2 Screenshot" width="49%">
</div>

## Requirements

- **Java**: Ensure Java is installed for running the RARS emulator.
- **RARS Emulator**
- Input BMP (**in.bmp**): The background image for plotting the function.
- Output BMP (**out.bmp**): The result image after the quadratic function is visualized.

## How It Works

- Input BMP: The program reads in.bmp to get the image dimensions and pixels.
- User Input: Enter coefficients a, b, and c for the quadratic formula.
- Function Visualization: The quadratic function is visualized by modifying pixel values.
- Output BMP: The processed image is saved as out.bmp.

## How to Run

1. **Install Java**: Ensure Java is installed (`java -version`).
2. **Download and Run RARS**: Open `quadratic.asm` in RARS.
3. **Input Coefficients**: Enter a, b, and c when prompted.
4. **Provide in.bmp** : Place `in.bmp` in the same directory.
5. **Run**: Execute the program in RARS. The result will be saved as out.bmp.

## Example

- Input: _a = 1, b = -2, c = 1_, with `in.bmp`.
- Output: A new image out.bmp with the **x<sup>2</sup> - 2x + 1** quadratic function plotted.

## Troubleshooting

- Ensure Java and RARS are correctly installed.
- Verify input file is in correct format.

## License

MIT License.
