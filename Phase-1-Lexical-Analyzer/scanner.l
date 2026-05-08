%{
/*
 * scanner.l  -  Lexical Analyzer for PunjAura++ (Punjabi Inspired Language)
 *
 * Student  : Khubaib Saleem
 * Roll No  : L1F22BSCS0597
 * Course   : Compiler Construction
 * Section  : G3
 *
 * Personalization Rules:
 *   - R = 97 (last 2 digits of roll number, ODD)
 *       -> Exponential numbers allowed  e.g. 1.2e10
 *       -> Hexadecimal / binary NOT allowed
 *   - Name: Khubaib Saleem
 *       -> Identifiers must START with 'K' (first letter of Khubaib)
 *       -> Identifiers must END   with 'm' (last  letter of Saleem)
 *       -> Regex: K[a-zA-Z0-9_]*m
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int  line_num  = 1;
FILE *token_fp = NULL;
FILE *error_fp = NULL;

/* ------------------------------------------------------------------ */
void log_token(const char *type, const char *lexeme) {
    printf("Line %-3d : %-15s -> %s\n", line_num, type, lexeme);
    fprintf(token_fp, "Line %-3d : %-15s -> %s\n", line_num, type, lexeme);
}

void log_error(const char *msg, const char *lexeme) {
    printf("Line %-3d : ERROR          -> %s: \"%s\"\n", line_num, msg, lexeme);
    fprintf(error_fp, "Line %-3d : ERROR          -> %s: \"%s\"\n", line_num, msg, lexeme);
}
/* ------------------------------------------------------------------ */

%}

%option noyywrap

DIGIT      [0-9]
ALNUM_     [a-zA-Z0-9_]

%%

 /* ---------------------------------------------------------------
    Whitespace and newlines
    --------------------------------------------------------------- */
\n                              { line_num++; }
[ \t\r]+                        { /* skip whitespace */ }

 /* ---------------------------------------------------------------
    Keywords  (15 total)
    Punjabi/Urdu  : agar, warna, jadon, fer, chalo, ruk,
                    likho, lao, func, wapas
    With symbols  : @loop, print$, go#back
    Others        : set, check
    --------------------------------------------------------------- */
"agar"                          { log_token("KEYWORD",     yytext); }
"warna"                         { log_token("KEYWORD",     yytext); }
"jadon"                         { log_token("KEYWORD",     yytext); }
"fer"                           { log_token("KEYWORD",     yytext); }
"chalo"                         { log_token("KEYWORD",     yytext); }
"ruk"                           { log_token("KEYWORD",     yytext); }
"likho"                         { log_token("KEYWORD",     yytext); }
"lao"                           { log_token("KEYWORD",     yytext); }
"func"                          { log_token("KEYWORD",     yytext); }
"wapas"                         { log_token("KEYWORD",     yytext); }
"@loop"                         { log_token("KEYWORD",     yytext); }
"print$"                        { log_token("KEYWORD",     yytext); }
"go#back"                       { log_token("KEYWORD",     yytext); }
"set"                           { log_token("KEYWORD",     yytext); }
"check"                         { log_token("KEYWORD",     yytext); }

 /* ---------------------------------------------------------------
    Valid Identifier: starts with K, ends with m
    Regex: K[a-zA-Z0-9_]*m
    --------------------------------------------------------------- */
K{ALNUM_}*m                     { log_token("IDENTIFIER",  yytext); }

 /* ---------------------------------------------------------------
    Numbers  (R = 97, ODD -> exponential format allowed)
    Regex: [0-9]+(.[0-9]+)?(e[0-9]+)?
    Examples: 10, 3.14, 1.2e10
    --------------------------------------------------------------- */
{DIGIT}+("."{DIGIT}+)?("e"{DIGIT}+)?   { log_token("NUMBER", yytext); }

 /* ---------------------------------------------------------------
    Strings - must start with 'K' inside the quotes
    Valid  : "Khello world"
    Invalid: "hello world"
    --------------------------------------------------------------- */
\"K([^\"\\\n]|\\.)*\"           { log_token("STRING",      yytext); }
\"([^\"\\\n]|\\.)*\"            { log_error("Invalid String (must start with K)", yytext); }
\"([^\"\\\n]|\\.)*              { log_error("Unterminated String", yytext); }

 /* ---------------------------------------------------------------
    Operators
    +    : addition
    -    : subtraction
    %%=  : custom assign-mod  (multi-character, custom-designed)
    <<<  : custom shift-like  (multi-character, custom-designed)
    =    : assignment (used with keyword 'set')
    --------------------------------------------------------------- */
"%%="                           { log_token("OPERATOR",    yytext); }
"<<<"                           { log_token("OPERATOR",    yytext); }
"+"                             { log_token("OPERATOR",    yytext); }
"-"                             { log_token("OPERATOR",    yytext); }
"="                             { log_token("OPERATOR",    yytext); }

 /* ---------------------------------------------------------------
    Punctuations
    ;   : statement end
    ,   : separator
    ()  : grouping
    --------------------------------------------------------------- */
";"                             { log_token("PUNCTUATION", yytext); }
","                             { log_token("PUNCTUATION", yytext); }
"("                             { log_token("PUNCTUATION", yytext); }
")"                             { log_token("PUNCTUATION", yytext); }

 /* ---------------------------------------------------------------
    Error Rules
    --------------------------------------------------------------- */

 /* invalid identifier: word-like token not matching K...m */
[a-zA-Z_][a-zA-Z0-9_]*         { log_error("Invalid Identifier (must start with K and end with m)", yytext); }

 /* invalid number: hex or binary (0xFF, 0b10) */
{DIGIT}+[a-zA-Z][a-zA-Z0-9]*   { log_error("Invalid Number Format (only exponential allowed)", yytext); }

 /* unknown symbol */
.                               { log_error("Unknown Symbol", yytext); }

%%

/* ================================================================
   main
   Usage: ./scanner <input_file>
   Output: tokens.txt and errors.txt in current directory
   ================================================================ */
int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file.pj>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Error: Cannot open '%s'\n", argv[1]);
        return 1;
    }
    yyin = input;

    token_fp = fopen("tokens.txt", "w");
    error_fp = fopen("errors.txt", "w");
    if (!token_fp || !error_fp) {
        fprintf(stderr, "Error: Cannot create output files.\n");
        fclose(input);
        return 1;
    }

    fprintf(token_fp,
        "===================================================\n"
        "  PunjAura++ Lexical Analyzer - Token Output\n"
        "  Student : Khubaib Saleem\n"
        "  Roll No : L1F22BSCS0597\n"
        "  Input   : %s\n"
        "===================================================\n\n",
        argv[1]);

    fprintf(error_fp,
        "===================================================\n"
        "  PunjAura++ Lexical Analyzer - Error Log\n"
        "  Student : Khubaib Saleem\n"
        "  Roll No : L1F22BSCS0597\n"
        "  Input   : %s\n"
        "===================================================\n\n",
        argv[1]);

    printf("\n--- PunjAura++ Scanner Running on: %s ---\n\n", argv[1]);
    yylex();

    fclose(input);
    fclose(token_fp);
    fclose(error_fp);

    printf("\n--- Scan complete. Output saved to tokens.txt and errors.txt ---\n");
    return 0;
}
