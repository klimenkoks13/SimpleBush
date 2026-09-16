CC = gcc
CFLAGS = -Wall -Werror -Wextra -std=c11
TARGET = s21_grep
SRCS = s21_grep.c

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET)

rebuild: 
	$(MAKE) clean
	$(MAKE) all

test: $(TARGET)
	chmod +x test_grep.sh
	./test_grep.sh

.PHONY: all clean rebuild test