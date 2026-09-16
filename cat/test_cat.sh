#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

TEMP_FILE=$(mktemp)

run_test() {
    local flags="$1"
    local test_name="$2"
    local expected_output="$3"
    
    ((TOTAL_TESTS++))
    
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}Тест $TOTAL_TESTS: $test_name${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "Флаги: ${CYAN}$flags${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────────────┤${NC}"
    
    ./s21_cat $flags test.txt > "$TEMP_FILE" 2>&1
    local exit_code=$?
    
    echo -e "${MAGENTA}Первые 5 строк вывода:${NC}"
    head -n 5 "$TEMP_FILE" | sed 's/^/  /'
    if [ $(wc -l < "$TEMP_FILE") -gt 5 ]; then
        echo "  ..."
    fi
    
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────────────┤${NC}"
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ Тест выполнен успешно (код возврата: $exit_code)${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Ошибка выполнения теста (код возврата: $exit_code)${NC}"
        ((FAILED_TESTS++))
    fi
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

run_quick_test() {
    local flags="$1"
    local test_name="$2"
    
    ((TOTAL_TESTS++))
    
    echo -ne "${YELLOW}Тест $TOTAL_TESTS: $test_name${NC} ... "
    
    ./s21_cat $flags test.txt > /dev/null 2>&1
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ FAILED (код: $exit_code)${NC}"
        ((FAILED_TESTS++))
    fi
}

if [ ! -f "test.txt" ]; then
    echo -e "${RED}Ошибка: Файл test.txt не найден!${NC}"
    echo "Создайте файл test.txt для тестирования."
    exit 1
fi

if [ ! -f "./s21_cat" ]; then
    echo -e "${RED}Ошибка: Исполняемый файл s21_cat не найден!${NC}"
    exit 1
fi

echo "========================================"
echo "  ПОЛНОЕ ТЕСТИРОВАНИЕ S21_CAT"
echo "========================================"
echo ""

echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  1. ТЕСТЫ С ОДИНОЧНЫМИ ФЛАГАМИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "" "Без флагов"
run_quick_test "-n" "Флаг -n (нумерация всех строк)"
run_quick_test "-b" "Флаг -b (нумерация только непустых)"
run_quick_test "-s" "Флаг -s (сжатие пустых строк)"
run_quick_test "-E" "Флаг -E (отображение $ в конце)"
run_quick_test "-T" "Флаг -T (отображение табов как ^I)"
run_quick_test "-v" "Флаг -v (отображение непечатаемых)"
run_quick_test "-e" "Флаг -e (отображение $ + непечатаемые)"
run_quick_test "-t" "Флаг -t (отображение табов + непечатаемые)"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  2. ТЕСТЫ С ДВУМЯ ФЛАГАМИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -b" "-n -b"
run_quick_test "-n -s" "-n -s"
run_quick_test "-n -E" "-n -E"
run_quick_test "-n -T" "-n -T"
run_quick_test "-n -v" "-n -v"
run_quick_test "-n -e" "-n -e"
run_quick_test "-n -t" "-n -t"

run_quick_test "-b -s" "-b -s"
run_quick_test "-b -E" "-b -E"
run_quick_test "-b -T" "-b -T"
run_quick_test "-b -v" "-b -v"
run_quick_test "-b -e" "-b -e"
run_quick_test "-b -t" "-b -t"

run_quick_test "-s -E" "-s -E"
run_quick_test "-s -T" "-s -T"
run_quick_test "-s -v" "-s -v"
run_quick_test "-s -e" "-s -e"
run_quick_test "-s -t" "-s -t"

run_quick_test "-E -T" "-E -T"
run_quick_test "-E -v" "-E -v"
run_quick_test "-E -e" "-E -e"
run_quick_test "-E -t" "-E -t"

run_quick_test "-T -v" "-T -v"
run_quick_test "-T -e" "-T -e"
run_quick_test "-T -t" "-T -t"

run_quick_test "-v -e" "-v -e"
run_quick_test "-v -t" "-v -t"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  3. ТЕСТЫ С ТРЕМЯ ФЛАГАМИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -b -s" "-n -b -s"
run_quick_test "-n -b -E" "-n -b -E"
run_quick_test "-n -b -T" "-n -b -T"
run_quick_test "-n -b -v" "-n -b -v"
run_quick_test "-n -b -e" "-n -b -e"
run_quick_test "-n -b -t" "-n -b -t"

run_quick_test "-n -s -E" "-n -s -E"
run_quick_test "-n -s -T" "-n -s -T"
run_quick_test "-n -s -v" "-n -s -v"
run_quick_test "-n -s -e" "-n -s -e"
run_quick_test "-n -s -t" "-n -s -t"

run_quick_test "-n -E -T" "-n -E -T"
run_quick_test "-n -E -v" "-n -E -v"
run_quick_test "-n -E -e" "-n -E -e"
run_quick_test "-n -E -t" "-n -E -t"

run_quick_test "-n -T -v" "-n -T -v"
run_quick_test "-n -T -e" "-n -T -e"
run_quick_test "-n -T -t" "-n -T -t"

run_quick_test "-b -s -E" "-b -s -E"
run_quick_test "-b -s -T" "-b -s -T"
run_quick_test "-b -s -v" "-b -s -v"
run_quick_test "-b -s -e" "-b -s -e"
run_quick_test "-b -s -t" "-b -s -t"

run_quick_test "-b -E -T" "-b -E -T"
run_quick_test "-b -E -v" "-b -E -v"
run_quick_test "-b -E -e" "-b -E -e"
run_quick_test "-b -E -t" "-b -E -t"

run_quick_test "-b -T -v" "-b -T -v"
run_quick_test "-b -T -e" "-b -T -e"
run_quick_test "-b -T -t" "-b -T -t"

run_quick_test "-s -E -T" "-s -E -T"
run_quick_test "-s -E -v" "-s -E -v"
run_quick_test "-s -E -e" "-s -E -e"
run_quick_test "-s -E -t" "-s -E -t"

run_quick_test "-s -T -v" "-s -T -v"
run_quick_test "-s -T -e" "-s -T -e"
run_quick_test "-s -T -t" "-s -T -t"

run_quick_test "-E -T -v" "-E -T -v"
run_quick_test "-E -T -e" "-E -T -e"
run_quick_test "-E -T -t" "-E -T -t"

run_quick_test "-v -e -t" "-v -e -t"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  4. ТЕСТЫ С ЧЕТЫРЬМЯ ФЛАГАМИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -b -s -E" "-n -b -s -E"
run_quick_test "-n -b -s -T" "-n -b -s -T"
run_quick_test "-n -b -s -v" "-n -b -s -v"
run_quick_test "-n -b -s -e" "-n -b -s -e"
run_quick_test "-n -b -s -t" "-n -b -s -t"

run_quick_test "-n -b -E -T" "-n -b -E -T"
run_quick_test "-n -b -E -v" "-n -b -E -v"
run_quick_test "-n -b -E -e" "-n -b -E -e"
run_quick_test "-n -b -E -t" "-n -b -E -t"

run_quick_test "-n -b -T -v" "-n -b -T -v"
run_quick_test "-n -b -T -e" "-n -b -T -e"
run_quick_test "-n -b -T -t" "-n -b -T -t"

run_quick_test "-n -s -E -T" "-n -s -E -T"
run_quick_test "-n -s -E -v" "-n -s -E -v"
run_quick_test "-n -s -E -e" "-n -s -E -e"
run_quick_test "-n -s -E -t" "-n -s -E -t"

run_quick_test "-n -s -T -v" "-n -s -T -v"
run_quick_test "-n -s -T -e" "-n -s -T -e"
run_quick_test "-n -s -T -t" "-n -s -T -t"

run_quick_test "-n -E -T -v" "-n -E -T -v"
run_quick_test "-n -E -T -e" "-n -E -T -e"
run_quick_test "-n -E -T -t" "-n -E -T -t"

run_quick_test "-b -s -E -T" "-b -s -E -T"
run_quick_test "-b -s -E -v" "-b -s -E -v"
run_quick_test "-b -s -E -e" "-b -s -E -e"
run_quick_test "-b -s -E -t" "-b -s -E -t"

run_quick_test "-b -s -T -v" "-b -s -T -v"
run_quick_test "-b -s -T -e" "-b -s -T -e"
run_quick_test "-b -s -T -t" "-b -s -T -t"

run_quick_test "-b -E -T -v" "-b -E -T -v"
run_quick_test "-b -E -T -e" "-b -E -T -e"
run_quick_test "-b -E -T -t" "-b -E -T -t"

run_quick_test "-s -E -T -v" "-s -E -T -v"
run_quick_test "-s -E -T -e" "-s -E -T -e"
run_quick_test "-s -E -T -t" "-s -E -T -t"

run_quick_test "-n -b -s -E -T" "-n -b -s -E -T (4 флага)"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  5. ТЕСТЫ С ПЯТЬЮ ФЛАГАМИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -b -s -E -T" "-n -b -s -E -T"
run_quick_test "-n -b -s -E -v" "-n -b -s -E -v"
run_quick_test "-n -b -s -E -e" "-n -b -s -E -e"
run_quick_test "-n -b -s -E -t" "-n -b -s -E -t"

run_quick_test "-n -b -s -T -v" "-n -b -s -T -v"
run_quick_test "-n -b -s -T -e" "-n -b -s -T -e"
run_quick_test "-n -b -s -T -t" "-n -b -s -T -t"

run_quick_test "-n -b -E -T -v" "-n -b -E -T -v"
run_quick_test "-n -b -E -T -e" "-n -b -E -T -e"
run_quick_test "-n -b -E -T -t" "-n -b -E -T -t"

run_quick_test "-n -s -E -T -v" "-n -s -E -T -v"
run_quick_test "-n -s -E -T -e" "-n -s -E -T -e"
run_quick_test "-n -s -E -T -t" "-n -s -E -T -t"

run_quick_test "-b -s -E -T -v" "-b -s -E -T -v"
run_quick_test "-b -s -E -T -e" "-b -s -E -T -e"
run_quick_test "-b -s -E -T -t" "-b -s -E -T -t"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  6. ТЕСТЫ С ШЕСТЬЮ ФЛАГАМИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -b -s -E -T -v" "-n -b -s -E -T -v"
run_quick_test "-n -b -s -E -T -e" "-n -b -s -E -T -e"
run_quick_test "-n -b -s -E -T -t" "-n -b -s -E -T -t"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  7. ВСЕ ВОЗМОЖНЫЕ ФЛАГИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -b -s -E -T -v -e -t" "Все флаги (-n -b -s -E -T -v -e -t)"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  8. ТЕСТЫ С РАЗНЫМИ ПОРЯДКАМИ ФЛАГОВ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -s -E" "-n -s -E (порядок 1)"
run_quick_test "-n -E -s" "-n -E -s (порядок 2)"
run_quick_test "-s -n -E" "-s -n -E (порядок 3)"
run_quick_test "-s -E -n" "-s -E -n (порядок 4)"
run_quick_test "-E -n -s" "-E -n -s (порядок 5)"
run_quick_test "-E -s -n" "-E -s -n (порядок 6)"

run_quick_test "-n -s -T" "-n -s -T (порядок 1)"
run_quick_test "-n -T -s" "-n -T -s (порядок 2)"
run_quick_test "-s -n -T" "-s -n -T (порядок 3)"
run_quick_test "-s -T -n" "-s -T -n (порядок 4)"
run_quick_test "-T -n -s" "-T -n -s (порядок 5)"
run_quick_test "-T -s -n" "-T -s -n (порядок 6)"

run_quick_test "-b -s -E" "-b -s -E (порядок 1)"
run_quick_test "-b -E -s" "-b -E -s (порядок 2)"
run_quick_test "-s -b -E" "-s -b -E (порядок 3)"
run_quick_test "-s -E -b" "-s -E -b (порядок 4)"
run_quick_test "-E -b -s" "-E -b -s (порядок 5)"
run_quick_test "-E -s -b" "-E -s -b (порядок 6)"

run_quick_test "-b -s -T" "-b -s -T (порядок 1)"
run_quick_test "-b -T -s" "-b -T -s (порядок 2)"
run_quick_test "-s -b -T" "-s -b -T (порядок 3)"
run_quick_test "-s -T -b" "-s -T -b (порядок 4)"
run_quick_test "-T -b -s" "-T -b -s (порядок 5)"
run_quick_test "-T -s -b" "-T -s -b (порядок 6)"

run_quick_test "-n -s -E -T" "-n -s -E -T (порядок 1)"
run_quick_test "-n -E -s -T" "-n -E -s -T (порядок 2)"
run_quick_test "-n -E -T -s" "-n -E -T -s (порядок 3)"
run_quick_test "-s -n -E -T" "-s -n -E -T (порядок 4)"
run_quick_test "-s -E -n -T" "-s -E -n -T (порядок 5)"
run_quick_test "-s -E -T -n" "-s -E -T -n (порядок 6)"
run_quick_test "-E -n -s -T" "-E -n -s -T (порядок 7)"
run_quick_test "-E -s -n -T" "-E -s -n -T (порядок 8)"
run_quick_test "-E -s -T -n" "-E -s -T -n (порядок 9)"
run_quick_test "-T -n -s -E" "-T -n -s -E (порядок 10)"
run_quick_test "-T -s -n -E" "-T -s -n -E (порядок 11)"
run_quick_test "-T -s -E -n" "-T -s -E -n (порядок 12)"

run_quick_test "-b -s -E -T" "-b -s -E -T (порядок 1)"
run_quick_test "-b -E -s -T" "-b -E -s -T (порядок 2)"
run_quick_test "-b -E -T -s" "-b -E -T -s (порядок 3)"
run_quick_test "-s -b -E -T" "-s -b -E -T (порядок 4)"
run_quick_test "-s -E -b -T" "-s -E -b -T (порядок 5)"
run_quick_test "-s -E -T -b" "-s -E -T -b (порядок 6)"
run_quick_test "-E -b -s -T" "-E -b -s -T (порядок 7)"
run_quick_test "-E -s -b -T" "-E -s -b -T (порядок 8)"
run_quick_test "-E -s -T -b" "-E -s -T -b (порядок 9)"
run_quick_test "-T -b -s -E" "-T -b -s -E (порядок 10)"
run_quick_test "-T -s -b -E" "-T -s -b -E (порядок 11)"
run_quick_test "-T -s -E -b" "-T -s -E -b (порядок 12)"

run_quick_test "-n -b -s -E -T" "-n -b -s -E -T (порядок 1)"
run_quick_test "-T -E -s -b -n" "-T -E -s -b -n (порядок 2)"
run_quick_test "-E -n -T -s -b" "-E -n -T -s -b (порядок 3)"
run_quick_test "-s -T -n -E -b" "-s -T -n -E -b (порядок 4)"
run_quick_test "-b -E -s -T -n" "-b -E -s -T -n (порядок 5)"
run_quick_test "-n -E -s -T -b" "-n -E -s -T -b (порядок 6)"
run_quick_test "-T -s -E -b -n" "-T -s -E -b -n (порядок 7)"
run_quick_test "-s -b -n -E -T" "-s -b -n -E -T (порядок 8)"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  9. ФЛАГИ, ВКЛЮЧАЮЩИЕ ДРУГ ДРУГА${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-e -n -b" "-e -n -b (e в начале)"
run_quick_test "-n -e -b" "-n -e -b (e в середине)"
run_quick_test "-n -b -e" "-n -b -e (e в конце)"
run_quick_test "-b -e -n" "-b -e -n (перестановка)"
run_quick_test "-e -v -n" "-e -v -n (e и v)"
run_quick_test "-v -e -n" "-v -e -n (v и e)"

run_quick_test "-t -n -b" "-t -n -b (t в начале)"
run_quick_test "-n -t -b" "-n -t -b (t в середине)"
run_quick_test "-n -b -t" "-n -b -t (t в конце)"
run_quick_test "-b -t -n" "-b -t -n (перестановка)"
run_quick_test "-t -v -n" "-t -v -n (t и v)"
run_quick_test "-v -t -n" "-v -t -n (v и t)"

run_quick_test "-e -t -n" "-e -t -n (e и t)"
run_quick_test "-t -e -n" "-t -e -n (t и e)"
run_quick_test "-e -t -v" "-e -t -v (e, t и v)"
run_quick_test "-t -e -v" "-t -e -v (t, e и v)"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  10. ТЕСТЫ С LONG OPTIONS${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "--number" "--number (аналог -n)"
run_quick_test "--number-nonblank" "--number-nonblank (аналог -b)"
run_quick_test "--squeeze-blank" "--squeeze-blank (аналог -s)"

run_quick_test "--number --number-nonblank" "--number --number-nonblank"
run_quick_test "--number --squeeze-blank" "--number --squeeze-blank"
run_quick_test "--number-nonblank --squeeze-blank" "--number-nonblank --squeeze-blank"
run_quick_test "--number --number-nonblank --squeeze-blank" "--number --number-nonblank --squeeze-blank"

run_quick_test "--number -s" "--number -s (long + short)"
run_quick_test "-n --squeeze-blank" "-n --squeeze-blank (short + long)"
run_quick_test "--number -s -E" "--number -s -E (long в начале)"
run_quick_test "-s --number -E" "-s --number -E (long в середине)"
run_quick_test "-s -E --number" "-s -E --number (long в конце)"
run_quick_test "--number -E -s" "--number -E -s (перестановка)"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  11. ТЕСТЫ С ПОВТОРЯЮЩИМИСЯ ФЛАГАМИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -n" "-n -n (повтор)"
run_quick_test "-b -b" "-b -b (повтор)"
run_quick_test "-s -s" "-s -s (повтор)"
run_quick_test "-E -E" "-E -E (повтор)"
run_quick_test "-T -T" "-T -T (повтор)"
run_quick_test "-v -v" "-v -v (повтор)"
run_quick_test "-e -e" "-e -e (повтор)"
run_quick_test "-t -t" "-t -t (повтор)"

run_quick_test "-n -n -n" "-n -n -n (тройной повтор)"
run_quick_test "-n -b -n -b" "-n -b -n -b (повторяющиеся разные)"
run_quick_test "-n -s -n -s -n" "-n -s -n -s -n (многократный повтор)"

run_quick_test "-n -n -s -E" "-n -n -s -E (повтор с другими)"
run_quick_test "-b -b -s -T" "-b -b -s -T (повтор с другими)"
run_quick_test "-v -v -E -T" "-v -v -E -T (повтор с другими)"
run_quick_test "-n -b -n -s -E" "-n -b -n -s -E (сложный повтор)"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  12. КОМБИНИРОВАННЫЕ ФЛАГИ -e И -t${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-e" "-e (один флаг)"
run_quick_test "-t" "-t (один флаг)"
run_quick_test "-e -t" "-e -t (оба)"
run_quick_test "-t -e" "-t -e (обратный порядок)"
run_quick_test "-e -n" "-e -n"
run_quick_test "-t -n" "-t -n"
run_quick_test "-e -n -b" "-e -n -b"
run_quick_test "-t -n -b" "-t -n -b"
run_quick_test "-e -t -n -b" "-e -t -n -b"
run_quick_test "-t -e -n -b" "-t -e -n -b"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  13. РАЗНЫЕ КОМБИНАЦИИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -s -v" "-n -s -v"
run_quick_test "-b -s -v" "-b -s -v"
run_quick_test "-n -E -v" "-n -E -v"
run_quick_test "-b -E -v" "-b -E -v"
run_quick_test "-n -T -v" "-n -T -v"
run_quick_test "-b -T -v" "-b -T -v"

run_quick_test "-n -s -E -v" "-n -s -E -v"
run_quick_test "-n -s -T -v" "-n -s -T -v"
run_quick_test "-b -s -E -v" "-b -s -E -v"
run_quick_test "-b -s -T -v" "-b -s -T -v"
run_quick_test "-n -E -T -v" "-n -E -T -v"
run_quick_test "-b -E -T -v" "-b -E -T -v"

run_quick_test "-n -s -E -T -v" "-n -s -E -T -v"
run_quick_test "-b -s -E -T -v" "-b -s -E -T -v"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  14. НЕОБЫЧНЫЕ ПОРЯДКИ ФЛАГОВ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-v -n -s -E -T -b" "-v -n -s -E -T -b"
run_quick_test "-E -v -n -s -T -b" "-E -v -n -s -T -b"
run_quick_test "-T -E -v -n -s -b" "-T -E -v -n -s -b"
run_quick_test "-s -T -E -v -n -b" "-s -T -E -v -n -b"
run_quick_test "-b -s -T -E -v -n" "-b -s -T -E -v -n"
run_quick_test "-n -b -s -T -E -v" "-n -b -s -T -E -v"

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  15. КРАЙНИЕ СЛУЧАИ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

run_quick_test "-n -b -s -E -T -v -e -t -n -b" "Много повторяющихся флагов"
run_quick_test "-n -b -s -E -T -v -e -t --number" "Смесь short и long"
run_quick_test "--number --number-nonblank --squeeze-blank -E -T -v -e -t" "Все long + short"
run_quick_test "-n -b -s -E -T -v -e -t --number --number-nonblank --squeeze-blank" "Максимальное количество"

echo ""
echo "========================================"
echo "  РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ"
echo "========================================"
echo -e "Всего тестов: ${YELLOW}$TOTAL_TESTS${NC}"
echo -e "Успешно: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Провалено: ${RED}$FAILED_TESTS${NC}"
echo "========================================"

if [ $TOTAL_TESTS -gt 0 ]; then
    PERCENT=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "Процент успешности: ${YELLOW}${PERCENT}%${NC}"
fi

echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!${NC}"
    exit 0
else
    echo -e "${RED}❌ ЕСТЬ ПРОВАЛЕННЫЕ ТЕСТЫ!${NC}"
    exit 1
fi

rm -f "$TEMP_FILE"