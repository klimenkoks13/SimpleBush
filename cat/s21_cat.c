#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

typedef struct {
  bool b;
  bool e;
  bool E;
  bool n;
  bool s;
  bool t;
  bool T;
  bool v;
} Flags;

static struct option const long_flags[] = {
    {"number-nonblank", no_argument, NULL, 'b'},
    {"number", no_argument, NULL, 'n'},
    {"squeeze-blank", no_argument, NULL, 's'},
    {NULL, 0, NULL, 0}};

void ParseFlags(int argc, char* argv[], Flags* flags, bool* error);
bool SkipEmptyStr(bool is_empty, int empty_str_count, Flags* flags);
void PrintNumStr(bool is_empty, char* str, ssize_t read, Flags* flags,
                 int* str_num);
void UpdateEmptyCount(bool is_empty, Flags* flags, int* empty_str_count);
bool ProcessFile(char* filename, Flags* flags, int* str_num);
void ShowNonprint(unsigned char ch);
void PrintNewStr(bool show_ends);
void PrintTab(bool show_tabs);
void PrintStr(char* str, ssize_t read, Flags* flags);

int main(int argc, char* argv[]) {
  Flags flags = {0};
  int str_num = 0;
  bool error = false;
  int exit_code = 0;

  ParseFlags(argc, argv, &flags, &error);

  if (error) {
    exit_code = 1;
  } else if (optind >= argc) {
    fprintf(stderr, "cat: files are not specified\n");
    exit_code = 1;
  } else {
    for (int i = optind; i < argc; i++) {
      if (!ProcessFile(argv[i], &flags, &str_num)) {
        exit_code = 1;
      }
    }
  }

  return exit_code;
}

void ParseFlags(int argc, char* argv[], Flags* flags, bool* error) {
  int op;
  opterr = 0;

  while ((op = getopt_long(argc, argv, "beEnstTv", long_flags, NULL)) != -1) {
    switch (op) {
      case 'b':
        flags->b = 1;
        break;
      case 'e':
        flags->e = 1;
        break;
      case 'E':
        flags->E = 1;
        break;
      case 'n':
        flags->n = 1;
        break;
      case 's':
        flags->s = 1;
        break;
      case 't':
        flags->t = 1;
        break;
      case 'T':
        flags->T = 1;
        break;
      case 'v':
        flags->v = 1;
        break;
      case '?':
        *error = true;
        break;
    }
  }

  if (*error) {
    fprintf(stderr, "cat: invalid option -- '%c'\n", optopt);
  }

  if (flags->b) flags->n = 0;
  if (flags->e) flags->v = 1;
  if (flags->t) flags->v = 1;
}

bool SkipEmptyStr(bool is_empty, int empty_str_count, Flags* flags) {
  bool skip_str = false;
  if (flags->s && is_empty && empty_str_count > 1) {
    skip_str = true;
  }
  return skip_str;
}

void PrintNumStr(bool is_empty, char* str, ssize_t read, Flags* flags,
                 int* str_num) {
  if (flags->b) {
    if (!is_empty) {
      (*str_num)++;
      printf("%6d\t", *str_num);
    }
  } else if (flags->n) {
    (*str_num)++;
    printf("%6d\t", *str_num);
  }

  PrintStr(str, read, flags);
}

void UpdateEmptyCount(bool is_empty, Flags* flags, int* empty_str_count) {
  if (flags->s) {
    if (is_empty)
      (*empty_str_count)++;
    else
      *empty_str_count = 0;
  }
}

bool ProcessFile(char* filename, Flags* flags, int* str_num) {
  bool success = false;
  FILE* file = fopen(filename, "r");
  if (file) {
    char* str = NULL;
    size_t str_len = 0;
    ssize_t read;
    int empty_str_count = 0;

    while ((read = getline(&str, &str_len, file)) != -1) {
      bool is_empty = (read == 1 && str[0] == '\n');
      UpdateEmptyCount(is_empty, flags, &empty_str_count);
      bool skip_str = SkipEmptyStr(is_empty, empty_str_count, flags);
      if (!skip_str) {
        PrintNumStr(is_empty, str, read, flags, str_num);
      }
    }
    free(str);
    fclose(file);
    success = true;
  } else {
    fprintf(stderr, "cat: %s: %s\n", filename, strerror(errno));
  }
  return success;
}

void ShowNonprint(unsigned char ch) {
  if (ch < 0x20) {
    putchar('^');
    putchar(ch + 0x40);
  } else if (ch == 0x7F) {
    putchar('^');
    putchar('?');
  } else if (ch & 0x80) {
    putchar('M');
    putchar('-');
    unsigned char low = ch & 0x7F;
    if (low < 0x20) {
      putchar('^');
      putchar(low + 0x40);
    } else if (low == 0x7F) {
      putchar('^');
      putchar('?');
    } else {
      putchar(low);
    }
  } else {
    putchar(ch);
  }
}

void PrintNewStr(bool show_ends) {
  if (show_ends) {
    putchar('$');
  }
  putchar('\n');
}

void PrintTab(bool show_tabs) {
  if (show_tabs) {
    putchar('^');
    putchar('I');
  } else {
    putchar('\t');
  }
}

void PrintStr(char* str, ssize_t read, Flags* flags) {
  if (!flags->e && !flags->E && !flags->t && !flags->T && !flags->v) {
    fwrite(str, 1, read, stdout);
  } else {
    bool show_ends = flags->E || flags->e;
    bool show_tabs = flags->T || flags->t;
    bool show_nonprint = flags->v || flags->e || flags->t;

    for (ssize_t i = 0; i < read; i++) {
      unsigned char ch = str[i];

      if (ch == '\n') {
        PrintNewStr(show_ends);
      } else if (ch == '\t') {
        PrintTab(show_tabs);
      } else if (show_nonprint) {
        ShowNonprint(ch);
      } else {
        putchar(ch);
      }
    }
  }
}