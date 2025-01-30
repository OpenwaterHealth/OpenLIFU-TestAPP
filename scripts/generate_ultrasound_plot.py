import numpy as np
import matplotlib.pyplot as plt
from scipy.special import j1
import sys
import os
import time
import base64
from io import BytesIO

# ✅ Fix: Set the non-GUI backend before using matplotlib
import matplotlib
matplotlib.use("Agg")  # Prevents QWidget errors

def generate_ultrasound_plot(x_focus, y_focus, z_focus, frequency, cycles, trigger, mode="file"):
    try:
        # Convert input values
        x_focus = float(x_focus)
        y_focus = float(y_focus)
        z_focus = float(z_focus)
        frequency = float(frequency)
        cycles = int(cycles)
        trigger = float(trigger)

        # Constants
        wavelength = 1500 / frequency  # Speed of sound in tissue ~1500 m/s
        beam_width = 5  # Beam width in mm

        # Generate grid
        x = np.linspace(-20, 20, 100)
        z = np.linspace(0, 100, 100)
        X_grid, Z_grid = np.meshgrid(x, z)

        # Compute beam intensity using Gaussian approximation
        r = np.sqrt((X_grid - x_focus)**2)
        z_rel = Z_grid - z_focus

        # Bessel-Gaussian Beam Profile
        with np.errstate(divide='ignore', invalid='ignore'):  # Avoid warnings
            bessel_term = j1(2 * np.pi * r / beam_width) / (2 * np.pi * r / beam_width)
            bessel_term[r == 0] = 0.5  # Handling singularity at r = 0

        intensity = (bessel_term**2) * np.exp(-((z_rel / beam_width)**2))
        intensity /= np.max(intensity)
        intensity[intensity < 0.01] = np.nan  # Apply threshold to enhance visibility

        # Create plot
        fig, ax = plt.subplots(figsize=(10, 6))
        c = ax.contourf(X_grid, Z_grid, intensity, levels=50, cmap='plasma')
        plt.colorbar(c, label='Normalized Intensity')
        ax.set_xlabel("X (mm)")
        ax.set_ylabel("Z (mm)")
        ax.set_title("Focused Ultrasound Beam 2D Profile")

        if mode == "file":
            # Save plot as file
            output_path = os.path.abspath("generated_plot.png")
            plt.savefig(output_path, dpi=100, bbox_inches='tight')
            plt.close()
            return output_path + f"?v={int(time.time())}"

        elif mode == "buffer":
            # Save to a BytesIO buffer instead of a file
            buffer = BytesIO()
            plt.savefig(buffer, format="png", dpi=100, bbox_inches='tight')
            plt.close()
            
            # Encode image in Base64
            buffer.seek(0)
            base64_image = base64.b64encode(buffer.getvalue()).decode("utf-8")
            return base64_image

    except Exception as e:
        print(f"Error generating ultrasound plot: {e}", file=sys.stderr)
        return "ERROR"

# If running as script
if __name__ == "__main__":
    if len(sys.argv) < 7:
        print("ERROR: Not enough arguments provided", file=sys.stderr)
        sys.exit(1)

    x, y, z, freq, cycles, trigger = sys.argv[1:7]
    mode = sys.argv[7] if len(sys.argv) > 7 else "file"  # Default to file mode
    output = generate_ultrasound_plot(x, y, z, freq, cycles, trigger, mode)
    print(output)  # Print Base64 image or file path
