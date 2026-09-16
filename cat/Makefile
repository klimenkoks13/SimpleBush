CC = gcc
CFLAGS = -Wall -Werror -Wextra -std=c11
TARGET = s21_cat
SRCS = s21_cat.c

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET)

rebuild:
	$(MAKE) clean
	$(MAKE) all


test: $(TARGET)
	chmod +x test_cat.sh
	./test_cat.sh

.PHONY: all clean rebuild test