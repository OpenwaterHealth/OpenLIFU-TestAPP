# OpenLIFU Test Application

Python example UI for OPEN LIFU used for Hardware Testing and Basic Usage

![App Image](docs/app_image.png)

## Installation

### Prerequisites
- **Python 3.9 or later**: Make sure you have Python 3.9 or later installed on your system. You can download it from the [official Python website](https://www.python.org/downloads/).

### Steps to Set Up the Project
1. **Clone the repository and Install Required Packages**:
   ```bash
   git clone https://github.com/OpenwaterHealth/OpenLIFU-TestAPP.git
   cd OpenLIFU-TestAPP
   pip install -r requirements.txt
   ```

2. **Install OpenLIFU Python**
   ```bash
   https://github.com/OpenwaterHealth/OpenLIFU-python.git
   ```

3. **Run application**
   ```bash
   python main.py
   ```

## Run packager
```
python -m PyInstaller -y openwater.spec
```