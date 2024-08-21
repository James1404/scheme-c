CC = gcc
CPP = g++

EXE = warlock

SRC_DIR = src
BUILD_DIR = build
CACHE_DIR = $(BUILD_DIR)/cache
DEPS_DIR = deps

TEST_DIR = test
STD_DIR = lib

INCLUDE = include\

INCLUDE_DIRS := $(foreach dir,$(INCLUDE),-I$(dir))

CCFLAGS = -Wall -pedantic -g -O0 -std=c99\
		  $(INCLUDE_DIRS)\
	      `llvm-config --cflags`

CPPFLAGS = -Wall -pedantic -g -O0 -std=c++20 $(INCLUDE_DIRS)

LDFLAGS =\
	      `llvm-config --libs`

SRC := $(shell find $(SRC_DIR)/ -type f \( -iname \*.c -o -iname \*.cpp \))
OBJ := $(addprefix $(CACHE_DIR)/, $(addsuffix .o,$(basename $(notdir $(SRC)))))

DEPS := $(OBJ:.o=.d)

$(BUILD_DIR)/$(EXE): $(OBJ) | $(BUILD_DIR) $(CACHE_DIR) $(BUILD_DIR)/$(TEST_DIR) $(BUILD_DIR)/$(STD_DIR)
	@echo Linking: $@
	@$(CPP) -o $@ $^ $(LDFLAGS)

run: $(BUILD_DIR)/$(EXE)
	@echo Running: \"$(EXE)\"
	@(cd $(BUILD_DIR) && ./$(EXE))

-include $(DEPS)

$(CACHE_DIR)/%.o: $(SRC_DIR)/%.c | $(CACHE_DIR)
	@echo Building: $(notdir $<)
	@$(CC) $(CCFLAGS) -MMD -MP -c $< -o $@

$(CACHE_DIR)/%.o: $(SRC_DIR)/%.cpp | $(CACHE_DIR)
	@echo Building: $(notdir $<)
	@$(CPP) $(CPPFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR):
	@echo Making \'$@\' directory
	@mkdir $@

$(CACHE_DIR): | $(BUILD_DIR)
	@echo Making $@ directory
	@mkdir -p $@

$(BUILD_DIR)/$(TEST_DIR): | $(TEST_DIR) $(BUILD_DIR)
	@echo Creating Symbolic Link: $(TEST_DIR) to $(BUILD_DIR)/ output folder
	@ln -sf $(realpath $(TEST_DIR)) $(abspath $(BUILD_DIR))

$(BUILD_DIR)/$(STD_DIR): | $(STD_DIR) $(BUILD_DIR)
	@echo Creating Symbolic Link: $(STD_DIR) to $(BUILD_DIR)/ output folder
	@ln -sf $(realpath $(STD_DIR)) $(abspath $(BUILD_DIR))

clean:
	@echo Deleting: $(BUILD_DIR)/
	@unlink $(BUILD_DIR)/$(TEST_DIR)
	@unlink $(BUILD_DIR)/$(STD_DIR)
	@rm -rf $(BUILD_DIR)/

.PHONY: clean run
