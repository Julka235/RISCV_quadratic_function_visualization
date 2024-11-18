# Quadratic Function Visualization in RISC-V

This project visualizes a quadratic function (y = ax^2 + bx + c) on a BMP image using the RISC-V architecture and the rars emulator. The user inputs the coefficients of the quadratic function and the program modifies an input BMP image (in.bmp) to visualize the function, saving the result as out.bmp.

## Requirements

- Java: Ensure Java is installed for running the RARS emulator.
- RARS Emulator
- Input BMP (in.bmp): The background image for plotting the function.
- Output BMP (out.bmp): The result image after the quadratic function is visualized.

## How It Works

- Input BMP: The program reads in.bmp to get the image dimensions and pixels.
- User Input: Enter coefficients a, b, and c for the quadratic formula.
- Function Visualization: The quadratic function is visualized by modifying pixel values.
- Output BMP: The processed image is saved as out.bmp.

## How to Run

- Install Java: Ensure Java is installed (java -version).
- Download and Run RARS: Open quadratic.asm in RARS.
- Input Coefficients: Enter a, b, and c when prompted.
- Provide in.bmp: Place in.bmp in the same directory.
- Run: Execute the program in RARS. The result will be saved as out.bmp.

## Example

- Input: a = 1, b = -2, c = 1, with in.bmp.
- Output: A new image out.bmp with the x^2-2x+1 quadratic function plotted.

## Troubleshooting

- Ensure Java and RARS are correctly installed.
- Verify input file is in correct format.

## License

MIT License.
