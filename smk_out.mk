include config.mk
$(BUILD_DIR)/player.o: $(SRC_DIR)/player.c $(INCLUDE_DIR)/player.h 
	$(CC) -c $(SRC_DIR)/player.c $(FLAGS) -o $(BUILD_DIR)/player.o
$(BUILD_DIR)/main.o: $(SRC_DIR)/main.c $(BUILD_DIR)/player.o 
	$(CC) -c $(SRC_DIR)/main.c $(BUILD_DIR)/player.o $(FLAGS) -o $(BUILD_DIR)/main.o
$(BUILD_DIR)/tungsten: $(SRC_DIR)/tungsten.c $(BUILD_DIR)/main.o 
	$(CC) $(SRC_DIR)/tungsten.c $(BUILD_DIR)/main.o $(FLAGS) -o $(BUILD_DIR)/tungsten
