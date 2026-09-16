CC = gcc
CFLAGS = -Wall -Werror -Wextra -std=c11

all: s21_cat s21_grep

s21_cat:
	cd cat && make

s21_grep:
	cd grep && make

test: s21_cat s21_grep
	$(MAKE) -C cat test
	$(MAKE) -C grep test

clean:
	cd cat && make clean
	cd grep && make clean

rebuild:
	$(MAKE) clean
	$(MAKE) all

.PHONY: all s21_cat s21_grep test clean rebuild