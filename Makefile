# Make variables
# Compiler and simulation utilities
XVLOG = xvlog
XELAB = xelab
XSIM  = xsim

# Simulation snapshot name
SNAPSHOT = ahb_sim_snapshot

# Top Module name defined here (Temporary Top Module Name, slave_1_top )
TOP_MODULE = slave_1_top

# Find all SystemVerilog files in the current directory
SRC_FILES = $(wildcard *.sv)

# Default target
all: simulate

# Compile target (compiles SystemVerilog files)
compile:
	@echo "==========================================="
	@echo " Compiling SystemVerilog files...          "
	@echo "==========================================="
	$(XVLOG) -sv $(SRC_FILES)

# Elaboration target (elaborates compiled modules and sets up the debug snapshot)
elaborate: compile
	@echo "==========================================="
	@echo " Elaborating design: $(TOP_MODULE)...      "
	@echo "==========================================="
	$(XELAB) -debug typical $(TOP_MODULE) -s $(SNAPSHOT)

# Simulation target (runs the compiled and elaborated snapshot)
simulate: elaborate
	@echo "==========================================="
	@echo " Running Simulation...                     "
	@echo "==========================================="
	$(XSIM) $(SNAPSHOT) -runall

# GUI Simulation target (runs simulation inside the Vivado Waveform Viewer GUI)
gui: elaborate
	@echo "==========================================="
	@echo " Opening GUI Simulation...                 "
	@echo "==========================================="
	$(XSIM) $(SNAPSHOT) -gui

# Clean target (removes Vivado log/simulation artifacts and workspace junk)
clean:
	@echo "==========================================="
	@echo " Cleaning up simulation generated files... "
	@echo "==========================================="
	@if exist xsim.dir rmdir /s /q xsim.dir
	@if exist webtalk*.log del /f /q webtalk*.log
	@if exist webtalk*.jou del /f /q webtalk*.jou
	@if exist xsim*.jou del /f /q xsim*.jou
	@if exist xsim*.log del /f /q xsim*.log
	@if exist xvlog*.log del /f /q xvlog*.log
	@if exist xvlog*.pb del /f /q xvlog*.pb
	@if exist xelab*.log del /f /q xelab*.log
	@if exist xelab*.pb del /f /q xelab*.pb
