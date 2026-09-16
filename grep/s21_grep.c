#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <getopt.h>
#include <regex.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  bool i;
  bool v;
  bool c;
  bool l;
  bool n;
} Flags;

void ParseFlags(int argc, char* argv[], Flags* flags, bool* error,
                char** patterns, int* pattern_count);
bool CompilePatterns(char** patterns, int pattern_count, bool ignore_case,
                     regex_t** out_compiled);
bool StrMatches(const char* str, regex_t* regexes, int count, bool invert);
void OnMatch(const char* str, int str_num, Flags* flags, const char* filename,
             bool print_filename, int* match_count);
bool FindFirstMatch(FILE* file, regex_t* regexes, int regex_count, bool invert,
                    const char* filename, char** str_ptr, size_t* buf_size);
int ProcessStr(FILE* file, Flags* flags, regex_t* regexes, int regex_count,
               const char* filename, bool print_filename, char** str_ptr,
               size_t* buf_size);
void ProcessFile(const char* filename, Flags* flags, regex_t* regexes,
                 int regex_count, bool print_filename, int* total_matches,
                 bool* error);
int ExecuteGrep(Flags* flags, char** patterns, int pattern_count, int argc,
                char* argv[]);

int main(int argc, char* argv[]) {
  Flags flags = {0};
  char** patterns = malloc(sizeof(char*) * argc);
  int exit_code = 0;
  int pattern_count = 0;
  bool error = false;

  if (!patterns) {
    fprintf(stderr, "grep: memory allocation failed\n");
    exit_code = 2;
  } else {
    ParseFlags(argc, argv, &flags, &error, patterns, &pattern_count);
    if (error) {
      exit_code = 2;
    } else {
      if (pattern_count == 0 && optind < argc) {
        patterns[pattern_count++] = argv[optind++];
      }

      if (pattern_count == 0) {
        fprintf(stderr, "grep: no pattern given\n");
        exit_code = 2;
      } else if (optind >= argc) {
        fprintf(stderr, "grep: files are not specified\n");
        exit_code = 2;
      } else {
        exit_code = ExecuteGrep(&flags, patterns, pattern_count, argc, argv);
      }
    }
    free(patterns);
  }

  return exit_code;
}

void ParseFlags(int argc, char* argv[], Flags* flags, bool* error,
                char** patterns, int* pattern_count) {
  int op;
  opterr = 0;

  while ((op = getopt(argc, argv, "e:ivcln")) != -1) {
    switch (op) {
      case 'e':
        patterns[(*pattern_count)++] = optarg;
        break;
      case 'i':
        flags->i = true;
        break;
      case 'v':
        flags->v = true;
        break;
      case 'c':
        flags->c = true;
        break;
      case 'l':
        flags->l = true;
        break;
      case 'n':
        flags->n = true;
        break;
      case '?':
        fprintf(stderr, "grep: invalid option -- '%c'\n", optopt);
        *error = true;
        break;
    }
  }
}

bool CompilePatterns(char** patterns, int pattern_count, bool ignore_case,
                     regex_t** out_compiled) {
  bool success = false;
  regex_t* compiled = malloc(sizeof(regex_t) * pattern_count);
  int cflags = REG_NOSUB;
  int i = 0;
  bool error = false;

  if (ignore_case) cflags |= REG_ICASE;

  while (compiled && i < pattern_count && !error) {
    int ret = regcomp(&compiled[i], patterns[i], cflags);
    if (ret != 0) {
      char buf[256];
      regerror(ret, &compiled[i], buf, sizeof(buf));
      fprintf(stderr, "grep: %s\n", buf);
      error = true;
    } else {
      i++;
    }
  }

  if (!compiled) {
    fprintf(stderr, "grep: memory allocation failed\n");
  } else if (!error) {
    *out_compiled = compiled;
    success = true;
  } else {
    for (int j = 0; j < i; j++) regfree(&compiled[j]);
    free(compiled);
  }

  return success;
}

bool StrMatches(const char* str, regex_t* regexes, int count, bool invert) {
  bool match = false;
  for (int i = 0; i < count && !match; i++) {
    if (regexec(&regexes[i], str, 0, NULL, 0) == 0) match = true;
  }
  if (invert) match = !match;
  return match;
}

void OnMatch(const char* str, int str_num, Flags* flags, const char* filename,
             bool print_filename, int* match_count) {
  (*match_count)++;
  if (!flags->c) {
    if (print_filename) printf("%s:", filename);
    if (flags->n) printf("%d:", str_num);
    printf("%s\n", str);
  }
}

bool FindFirstMatch(FILE* file, regex_t* regexes, int regex_count, bool invert,
                    const char* filename, char** str_ptr, size_t* buf_size) {
  bool found = false;
  ssize_t read;
  while (!found && (read = getline(str_ptr, buf_size, file)) != -1) {
    if (StrMatches(*str_ptr, regexes, regex_count, invert)) {
      printf("%s\n", filename);
      found = true;
    }
  }
  return found;
}

int ProcessStr(FILE* file, Flags* flags, regex_t* regexes, int regex_count,
               const char* filename, bool print_filename, char** str_ptr,
               size_t* buf_size) {
  int str_num = 0;
  int match_count = 0;
  ssize_t read;

  while ((read = getline(str_ptr, buf_size, file)) != -1) {
    str_num++;
    if (read > 0 && (*str_ptr)[read - 1] == '\n') {
      (*str_ptr)[read - 1] = '\0';
    }
    if (StrMatches(*str_ptr, regexes, regex_count, flags->v)) {
      OnMatch(*str_ptr, str_num, flags, filename, print_filename, &match_count);
    }
  }
  return match_count;
}

void ProcessFile(const char* filename, Flags* flags, regex_t* regexes,
                 int regex_count, bool print_filename, int* total_matches,
                 bool* error) {
  FILE* file = fopen(filename, "r");
  if (file) {
    char* str = NULL;
    size_t buf_size = 0;
    int match_count = 0;

    if (flags->l) {
      if (FindFirstMatch(file, regexes, regex_count, flags->v, filename, &str,
                         &buf_size)) {
        match_count = 1;
      }
    } else {
      match_count = ProcessStr(file, flags, regexes, regex_count, filename,
                               print_filename, &str, &buf_size);
      if (flags->c && print_filename) printf("%s:", filename);
      if (flags->c) printf("%d\n", match_count);
    }

    free(str);
    *total_matches += match_count;
    fclose(file);
  } else {
    fprintf(stderr, "grep: %s: %s\n", filename, strerror(errno));
    *error = true;
  }
}

int ExecuteGrep(Flags* flags, char** patterns, int pattern_count, int argc,
                char* argv[]) {
  int exit_code = 0;
  regex_t* regexes = NULL;

  if (!CompilePatterns(patterns, pattern_count, flags->i, &regexes)) {
    exit_code = 2;
  } else {
    int file_count = argc - optind;
    bool print_filename = (file_count > 1);
    int total_matches = 0;
    bool error = false;
    for (int i = 0; i < file_count; i++) {
      ProcessFile(argv[optind + i], flags, regexes, pattern_count,
                  print_filename, &total_matches, &error);
    }
    for (int i = 0; i < pattern_count; i++) regfree(&regexes[i]);
    free(regexes);
    if (error) {
      exit_code = 2;
    } else if (total_matches == 0) {
      exit_code = 1;
    }
  }

  return exit_code;
}