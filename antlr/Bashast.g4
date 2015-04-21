/*
   Please use git log for copyright holder and year information

   This file is part of libbash.

   libbash is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 2 of the License, or
   (at your option) any later version.

   libbash is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with libbash.  If not, see <http://www.gnu.org/licenses/>.
*/


grammar Bashast;


options
{

	language = Java;

}

tokens{
	ANSI_C_QUOTING;
	ARG;
	ARRAY;
	ARRAY_SIZE;
	BRACE_EXP;
	COMMAND_SUB;
	CASE_PATTERN;
	CASE_COMMAND;
	SUBSHELL;
	CURRENT_SHELL;
	COMPOUND_COND;
	CFOR;
	FOR_INIT;
	FOR_COND;
	FOR_MOD;
	IF_STATEMENT;
	OP;
	PRE_INCR;
	PRE_DECR;
	POST_INCR;
	POST_DECR;
	PROCESS_SUBSTITUTION;
	VAR_REF;
	NEGATION;
	LIST;
	STRING;
	COMMAND;
	FILE_DESCRIPTOR;
	FILE_DESCRIPTOR_MOVE;
	REDIR;
	ARITHMETIC_CONDITION;
	ARITHMETIC_EXPRESSION;
	ARITHMETIC;
	KEYWORD_TEST;
	BUILTIN_TEST;
	MATCH_ANY_EXCEPT;
	EXTENDED_MATCH_EXACTLY_ONE;
	EXTENDED_MATCH_AT_MOST_ONE;
	EXTENDED_MATCH_NONE;
	EXTENDED_MATCH_ANY;
	EXTENDED_MATCH_AT_LEAST_ONE;
	BRANCH;
	MATCH_PATTERN;
	MATCH_REGULAR_EXPRESSION;
	ESCAPED_CHAR;
	NOT_MATCH_PATTERN;
	MATCH_ANY;
	MATCH_ANY_EXCEPT;
	MATCH_ALL;
	MATCH_ONE;
	CHARACTER_CLASS;
	EQUIVALENCE_CLASS;
	COLLATING_SYMBOL;
	DOUBLE_QUOTED_STRING;
	SINGLE_QUOTED_STRING;
	VARIABLE_DEFINITIONS;

	USE_DEFAULT_WHEN_UNSET;
	USE_ALTERNATE_WHEN_UNSET;
	DISPLAY_ERROR_WHEN_UNSET;
	ASSIGN_DEFAULT_WHEN_UNSET;
	USE_DEFAULT_WHEN_UNSET_OR_NULL;
	USE_ALTERNATE_WHEN_UNSET_OR_NULL;
	DISPLAY_ERROR_WHEN_UNSET_OR_NULL;
	ASSIGN_DEFAULT_WHEN_UNSET_OR_NULL;
	OFFSET;
	LIST_EXPAND;
	REPLACE_FIRST;
	REPLACE_ALL;
	REPLACE_AT_START;
	REPLACE_AT_END;
	LAZY_REMOVE_AT_START;
	LAZY_REMOVE_AT_END;
	EMPTY_EXPANSION_VALUE;

	PLUS_SIGN;
	MINUS_SIGN;
	PLUS_ASSIGN;
	MINUS_ASSIGN;
	DIVIDE_ASSIGN;
	MUL_ASSIGN;
	MOD_ASSIGN;
	LSHIFT_ASSIGN;
	RSHIFT_ASSIGN;
	AND_ASSIGN;
	XOR_ASSIGN;
	OR_ASSIGN;
	LEQ;
	GEQ;

	NOT_EQUALS;
	EQUALS_TO;
	BUILTIN_LOGIC_AND;
	BUILTIN_LOGIC_OR;

	FUNCTION;
}

@lexer::context
{

}

@lexer::apifuncs
{

}

@lexer::members
{

	self.double_quoted = False
	self.paren_level = 0
def LA(self, index) :
	return self._input.LA(index)
}
@parser::members
{
def is_here_end(self, here_document_word, number_of_tokens):
	word = ""
	for i in range(1, number_of_tokens + 1):
		word += self._input.LT(i).getText()
	return (word == here_document_word)


def get_string(self, token):
	return token.getText()
	

def LT(self, index):
	return self._input.LT(index)


def LA(self, index):
	return self._input.LA(index)


def is_special_token(self, token):
	return (token == self.AMP 
	or token == self.BLANK 
	# for bash redirection
	or token == self.LESS_THAN 
	or token == self.GREATER_THAN 
	or token == self.RSHIFT 
	or token == self.AMP_LESS_THAN 
	or token == self.AMP_GREATER_THAN 
	or token == self.AMP_RSHIFT 
	# for end of command
	or token == self.SEMIC 
	or token == self.EOL 
	# for sub shell
	or token == self.LPAREN 
	or token == self.RPAREN 
	# for case statement
	or token == self.DOUBLE_SEMIC 
	# for logical operator
	or token == self.LOGICAND 
	or token == self.LOGICOR 
	# for pipeline
	or token == self.PIPE 
	# for document and here string
	or token == self.HERE_STRING_OP 
	or token == self.LSHIFT)
}
		
start
	:	(first_line_comment)? EOL* BLANK? command_list BLANK? (SEMIC|AMP|EOL)? EOF;

first_line_comment
	:	POUND ~(EOL)* EOL;

command_list
	:	list_level_2;
list_level_1
	:	pipeline (BLANK?(LOGICAND|LOGICOR)(BLANK|EOL)* pipeline)*;
list_level_2
	:	list_level_1 (BLANK? command_separator (BLANK? EOL)* BLANK? list_level_1)*;
command_separator
	:	SEMIC
	|	AMP
	|	EOL;
pipeline
	:	time? ((BANG BLANK))? command (BLANK? PIPE wspace? command)*;

time
	:	TIME BLANK (time_posix)?;
time_posix
	:	MINUS LETTER BLANK;

redirection
	:	redirection_atom+;
redirection_atom
	:	redirection_operator redirection_destination
	|	BLANK process_substitution
	|	here_string;

process_substitution
	:	(dir_=LESS_THAN|dir_=GREATER_THAN)LPAREN BLANK* command_list BLANK* RPAREN;

redirection_destination
	:	BLANK? file_descriptor
	|	BLANK process_substitution
	|	BLANK? string_expr;
file_descriptor
	:	DIGIT
	|	DIGIT MINUS;

here_string
	:	BLANK? HERE_STRING_OP BLANK? string_expr;

here_document
locals [
	self.here_document_word = "",
	self.number_of_tokens = 0
]
	:	BLANK? here_document_operator BLANK? here_document_begin
		redirection? EOL here_document_content? here_document_end;

here_document_operator
	:	LSHIFT
		(
			MINUS
			|
		);

here_document_begin
	:	(
			token=~(EOL|BLANK|LESS_THAN|HERE_STRING_OP|GREATER_THAN|RSHIFT|AMP_LESS_THAN|AMP_GREATER_THAN|AMP_RSHIFT)
			{
if self.LA(-1) != DQUOTE and self.LA(-1) != ESC:
	$here_document::here_document_word += self.get_string($token)
	$here_document::number_of_tokens = $here_document::number_of_tokens +1
			}
		)+;
here_document_end
	:	({$here_document::number_of_tokens != 0 }? => . {$here_document::number_of_tokens = $here_document::number_of_tokens-1 })+;
here_document_content

	:	({self.is_here_end($here_document::here_document_word, $here_document::number_of_tokens)}? => .)+;


redirection_operator
	:	BLANK DIGIT redirection_operator
	|	BLANK?
		(
			AMP_LESS_THAN
			|	GREATER_THAN AMP
			|	LESS_THAN AMP
			|	LESS_THAN GREATER_THAN
			|	RSHIFT
			|	AMP_GREATER_THAN
			|	AMP_RSHIFT
			|	LESS_THAN
			|	GREATER_THAN
		);

command
	:	command_atom
		(
			redirection here_document?
			|	here_document
			|
		);

command_atom
	:	{(LA(1) == FOR or LA(1) == SELECT or LA(1) == IF or LA(1) == WHILE or LA(1) == UNTIL or
		 LA(1) == CASE or LA(1) == LPAREN or LA(1) == LBRACE or LA(1) == LLPAREN or LA(1) == LSQUARE or
		(LA(1) == NAME and LA(2) == BLANK and "test" == self.get_string(self.LT(1))))}? => compound_command
	|	{LA(1) == NAME and LA(2) == BLANK and "function" == self.get_string(self.LT(1))}? =>

			NAME BLANK string_expr_no_reserved_word ((BLANK? parens wspace?)|wspace) compound_command
	|	variable_definitions
			(
				BLANK bash_command
				|
			)
	|	EXPORT BLANK builtin_variable_definition_item
	|	LOCAL BLANK builtin_variable_definition_item
	|	DECLARE BLANK builtin_variable_definition_item
	|	command_name
		(
			BLANK? parens wspace? compound_command
			|	(
					{(self.LA(1) == BLANK and
					(
						self.is_special_token(self.LA(2))
						# redirection
						and (self.LA(2) != DIGIT or (self.LA(3) != AMP_LESS_THAN and
											  self.LA(3) != AMP_GREATER_THAN and
											  self.LA(3) != AMP_RSHIFT and
											  self.LA(3) != GREATER_THAN and
											  self.LA(3) != LESS_THAN and
											  self.LA(3) != RSHIFT))
					))}? => BLANK bash_command_arguments
				)*
		);

command_name
	:	string_expr_no_reserved_word
	|	{LA(1) == GREATER_THAN}? => redirection_atom;

variable_definitions
	:	variable_definition_atom (BLANK variable_definition_atom)* ;

variable_definition_atom
	:	name LSQUARE BLANK? explicit_arithmetic BLANK? RSQUARE EQUALS string_expr?
	|	name EQUALS value?
	|	name PLUS EQUALS array_value
	|	name PLUS EQUALS string_expr_part*;
value
	:	string_expr
	|	array_value;

array_value
locals [

	array_value_end

]
	:	LPAREN wspace?
		(
			RPAREN
			|	{$array_value::array_value_end = False } array_atom
				({$array_value::array_value_end}? => wspace array_atom)*
		);
array_atom
	:	(
			LSQUARE BLANK? explicit_arithmetic BLANK? RSQUARE EQUALS string_expr
			|	string_expr
		)
		(
			wspace RPAREN {$array_value::array_value_end = true; }
			|	RPAREN {$array_value::array_value_end = true; }
			|
		);

builtin_variable_definition_item
locals [
	_parens = 0, 
	dquotes = False

]
	:	(
			LPAREN { ++$builtin_variable_definition_item::_parens; }
			|RPAREN { --$builtin_variable_definition_item::_parens; }
			|DQUOTE { $builtin_variable_definition_item::dquotes =  $builtin_variable_definition_item::dquotes; }
			|expansion_base
			| {LA(1) == SEMIC and $builtin_variable_definition_item::dquotes}? => SEMIC
			| {LA(1) == EOL and $builtin_variable_definition_item::_parens > 0 || $builtin_variable_definition_item::dquotes}? => EOL
		)+;


builtin_variable_definitions
	:	(builtin_variable_definition_atom) (BLANK builtin_variable_definition_atom)*;


builtin_variable_definition_atom
	:	variable_definition_atom
	// We completely ignore the options for export, local and readonly for now
	|	MINUS LETTER;

bash_command
	:	string_expr_no_reserved_word (BLANK bash_command_arguments)*;

bash_command_arguments
	:	bash_command_argument_atom+;
// TODO support brace expansion and braces
bash_command_argument_atom
	:	(
			brace_expansion
			|LBRACE
		)
	|	RBRACE
	|	string_expr_part;

parens
	:	LPAREN BLANK? RPAREN;

compound_command
	:	for_expr
	|	select_expr
	|	if_expr
	|	while_expr
	|	until_expr
	|	case_expr
	|	subshell
	|	current_shell
	|	arithmetic_expression
	|	condition_comparison;

semiel
	:	BLANK? SEMIC wspace?
	|	BLANK? EOL wspace?;

for_expr
	:	FOR BLANK?
		(
			name
			(
				wspace IN for_each_value* BLANK? (SEMIC|EOL) wspace?
				| wspace? SEMIC wspace?
				| wspace
			) DO wspace command_list semiel DONE
			|	LLPAREN EOL?
				// initilization
				(BLANK? init=arithmetics BLANK?|BLANK)?
				// condition
				(SEMIC (BLANK? fcond=arithmetics BLANK?|BLANK)? SEMIC|DOUBLE_SEMIC)
				// modification
				(BLANK? mod=arithmetics)? wspace? RPAREN RPAREN semiel DO wspace command_list semiel DONE
		);
for_each_value
	:	{LA(1) == BLANK && LA(2) != EOL && LA(2) != SEMIC && LA(2) != DO}?
			=> (BLANK string_expr);

select_expr
	:	SELECT BLANK name (wspace IN BLANK string_expr)? semiel DO wspace command_list semiel DONE;
if_expr
	:	IF wspace ag=command_list semiel THEN wspace iflist=command_list semiel
		(elif_expr)*
		(ELSE wspace else_list=command_list semiel)? FI;
elif_expr
	:	ELIF BLANK ag=command_list semiel THEN wspace iflist=command_list semiel;
while_expr
	:	WHILE wspace? istrue=command_list semiel DO wspace dothis=command_list semiel DONE;
until_expr
	:	UNTIL wspace? istrue=command_list semiel DO wspace dothis=command_list semiel DONE;

case_expr
	:	CASE BLANK string_expr wspace IN case_body;
case_body
locals [

	boolean case_end

]
	:	{$case_body::case_end = false;}
		(
			(wspace ESAC)
			|({$case_body::case_end}? => case_statement)+
		);
case_statement
	:	wspace? (LPAREN BLANK?)? extended_pattern (BLANK? PIPE BLANK? extended_pattern)* BLANK? RPAREN
		(wspace command_list)?
		(
			wspace? DOUBLE_SEMIC (wspace ESAC {$case_body::case_end = true;})?
			|wspace ESAC {$case_body::case_end = true;}
		);

subshell
	:	LPAREN wspace? command_list (BLANK? SEMIC)? wspace? RPAREN;

current_shell
	:	LBRACE wspace command_list semiel RBRACE;

arithmetic_expression
	:	LLPAREN wspace? arithmetics wspace? RPAREN RPAREN;
condition_comparison
	:	condition_expr;

condition_expr
	:	LSQUARE LSQUARE wspace keyword_condition wspace RSQUARE RSQUARE
	|	LSQUARE wspace builtin_condition wspace RSQUARE

	|	{LA(1) == NAME && LA(2) == BLANK && "test".equals(get_string(LT(1)))}? => NAME wspace? builtin_condition;


keyword_condition_and
	:	keyword_condition_primary ( wspace? LOGICAND wspace? keyword_condition_primary)*;
keyword_condition
	:	keyword_condition_and ( wspace? LOGICOR wspace? keyword_condition_and)*;
keyword_negation_primary
	:	BANG BLANK keyword_condition_primary;
keyword_condition_primary
	:	LPAREN BLANK? keyword_condition BLANK? RPAREN
	|	keyword_negation_primary
	|	keyword_condition_unary
	|	keyword_condition_binary;
keyword_condition_unary
	:	unary_operator BLANK condition_part;
keyword_condition_binary
	:	condition_part
		(
			BLANK EQUALS TILDE BLANK bash_pattern_part
			|	keyword_binary_string_operator right=condition_part
			|	BLANK (BANG EQUALS) BLANK extended_pattern_match+
			|	BLANK (EQUALS EQUALS) BLANK extended_pattern_match+
			|
		);
bash_pattern_part
locals [
	int _parens = 0,
	boolean quoted = false;

]
	:(
		DQUOTE { $bash_pattern_part::quoted = $bash_pattern_part::quoted; }
		|	{$bash_pattern_part::quoted}? => preserved_tokens
		|	ESC BLANK
		|	LPAREN { if(LA(-2) != ESC) $bash_pattern_part::_parens++; }
		|	LLPAREN { if(LA(-2) != ESC) $bash_pattern_part::_parens += 2; }
		|	{$bash_pattern_part::_parens != 0}? => RPAREN { if(LA(-2) != ESC) $bash_pattern_part::_parens--; }
		|	~(BLANK|EOL|LOGICAND|LOGICOR|LPAREN|RPAREN|DQUOTE|LLPAREN)
	 )+;

preserved_tokens
	:	non_dquote;

non_dquote
	:	~DQUOTE;

keyword_binary_string_operator
	:	BLANK binary_operator BLANK
	|	BLANK EQUALS BLANK
	|	BLANK? LESS_THAN BLANK?
	|	BLANK? GREATER_THAN BLANK?;


builtin_condition_and
	:	builtin_condition_primary (builtin_logic_and BLANK builtin_condition_primary)*;
builtin_condition
	:	builtin_condition_and (builtin_logic_or BLANK builtin_condition_and)*;
builtin_negation_primary
	:	BANG BLANK builtin_condition_primary;
builtin_condition_primary
	:	LPAREN BLANK? builtin_condition BLANK? RPAREN
	|	builtin_negation_primary
	|	builtin_condition_unary
	|	builtin_condition_binary;
builtin_condition_unary
	:	unary_operator BLANK condition_part;
builtin_condition_binary
	:	condition_part (BLANK builtin_binary_string_operator BLANK condition_part)?;
builtin_binary_string_operator
	:	binary_operator
	|	EQUALS EQUALS
	|	EQUALS
	|	BANG EQUALS
	|	ESC_LT
	|	ESC_GT;
builtin_logic_and

	:	{LA(1) == BLANK && LA(2) == MINUS && LA(3) == LETTER && "a".equals(get_string(LT(3)))}?=> BLANK MINUS LETTER;

builtin_logic_or

	:	{LA(1) == BLANK && LA(2) == MINUS && LA(3) == LETTER && "o".equals(get_string(LT(3)))}?=> BLANK MINUS LETTER;


binary_operator
	:	MINUS NAME;
unary_operator
	:	MINUS LETTER;

// TODO support brace expansion
condition_part
	:	string_expr;

name
	:	NAME |	LETTER | UNDERSCORE;

num
options{k=1;}
	:	DIGIT|NUMBER;

string_expr
	:	string_expr_part string_expr_part*;

string_expr_part
	:	quoted_string | non_quoted_string | reserved_word;

string_expr_no_reserved_word
	:	(
				non_quoted_string wspace? string_expr_part*
				|	quoted_string wspace? string_expr_part*
			);

reserved_word
	:	CASE|DO|DONE|ELIF|ELSE|ESAC|FI|FOR|IF|IN|SELECT|THEN|UNTIL|WHILE|TIME;

non_quoted_string
	:	string_part
	|	variable_reference
	|	command_substitution
	|	arithmetic_expansion
	|	brace_expansion
	|	BANG
	|	DOLLAR SINGLE_QUOTED_STRING_TOKEN;

quoted_string
	:	double_quoted_string
	|	SINGLE_QUOTED_STRING_TOKEN;

double_quoted_string
	:	DQUOTE (expansion_base)* DQUOTE;

// Perform all kinds of expansions
expansion_base
	:	variable_reference
	|	command_substitution
	|	arithmetic_expansion
	|	ESC DQUOTE
	|	ESC TICK
	|	ESC DOLLAR
	|	brace_expansion
	|	DOLLAR SINGLE_QUOTED_STRING_TOKEN
	|	.;

all_expansions
	:	expansion_atom+;
expansion_atom
	:	double_quoted_string
	|	expansion_base;

string_part
	:	ns_string_part
	|	SLASH;

ns_string_part
	:	num|name|escaped_character
	|OTHER|EQUALS|PCT|PCTPCT|PLUS|MINUS|DOT|DOTDOT|COLON
	|TILDE|LSQUARE|RSQUARE|CARET|POUND|COMMA|EXPORT|LOCAL|DECLARE|AT
	// Escaped characters
	|ESC_RPAREN|ESC_LPAREN|ESC_RSQUARE|ESC_LSQUARE|ESC_DOLLAR|ESC_GT|ESC_LT|ESC_TICK|ESC_DQUOTE|ESC_SQUOTE
	// The following is for filename expansion
	|TIMES|QMARK;

escaped_character
	:	ESC
		(
			DIGIT
			|	DIGIT DIGIT
			|	DIGIT DIGIT DIGIT
			|	LETTER ALPHANUM ALPHANUM?
			|	.
		);

extended_pattern_match
	:	QMARK LPAREN extended_pattern (PIPE extended_pattern)* RPAREN
	|	TIMES LPAREN extended_pattern (PIPE extended_pattern)* RPAREN
	|	PLUS LPAREN extended_pattern (PIPE extended_pattern)* RPAREN
	|	AT LPAREN extended_pattern (PIPE extended_pattern)* RPAREN
	|	BANG LPAREN extended_pattern (PIPE extended_pattern)* RPAREN
	|	bracket_pattern_match
	|	pattern_class_match
	|	string_expr_part;

extended_pattern
	:	(extended_pattern_match)+;

bracket_pattern_match
	:	LSQUARE bracket_pattern_match_operator bracket_pattern RSQUARE
	|	TIMES
	|	QMARK;
bracket_pattern_match_operator
	:	BANG
	|	CARET
	|;

bracket_pattern_part
	:	pattern_class_match
	|	string_expr_part;

bracket_pattern
	:	(bracket_pattern_part)+;

pattern_class_match
	:	LSQUARE COLON NAME COLON RSQUARE
	|	LSQUARE EQUALS pattern_char EQUALS RSQUARE
	|	LSQUARE DOT NAME DOT RSQUARE;

pattern_char
	:	LETTER|DIGIT|OTHER|QMARK|COLON|AT|SEMIC|POUND|SLASH
		|BANG|TIMES|COMMA|PIPE|AMP|MINUS|PLUS|PCT|LSQUARE|RSQUARE
		|RPAREN|LPAREN|RBRACE|LBRACE|DOLLAR|TICK|DOT|LESS_THAN
		|GREATER_THAN|SQUOTE|DQUOTE|AMP_LESS_THAN|AMP_GREATER_THAN|AMP_RSHIFT;

variable_reference
	:	DOLLAR LBRACE parameter_expansion RBRACE
	|	DOLLAR name
	|	DOLLAR num
	|	DOLLAR TIMES
	|	DOLLAR AT
	|	DOLLAR POUND
	|	DOLLAR QMARK
	|	DOLLAR MINUS
	|	DOLLAR DOLLAR
	|	DOLLAR BANG;

parameter_expansion
	:	variable_name
		(
			parameter_value_operator parameter_expansion_value
			|	COLON BLANK?
				(
					os=explicit_arithmetic (COLON BLANK? len_=explicit_arithmetic)?
					// It will make the tree parser's work easier if OFFSET is used as the root of arithmetic.
					// Otherwise, the tree parser can see several arithmetic expressions but can not tell
					// which one is for offset and which one is for length.
					|	COLON BLANK? len_=explicit_arithmetic
				)
			|	parameter_delete_operator parameter_delete_pattern
			|	parameter_replace_operator parameter_replace_pattern (SLASH parameter_expansion_value)?
			|	BLANK?
		)
		|	BANG variable_name_for_bang
			(
				TIMES
				|	AT
				|	LSQUARE (op=TIMES|op=AT) RSQUARE
			)
		|	{LA(1) == POUND && LA(2) != RBRACE }? => variable_size_ref;
parameter_delete_operator
	:	POUND POUND
	|	POUND
	|	PCT
	|	PCTPCT;
parameter_value_operator
	:	COLON MINUS
	|	COLON EQUALS
	|	COLON QMARK
	|	COLON PLUS
	|	MINUS
	|	EQUALS
	|	QMARK
	|	PLUS;
parameter_replace_pattern
	:
	|	(parameter_pattern_part)+;
parameter_delete_pattern
	:	parameter_pattern_part+;
parameter_pattern_part
	:	extended_pattern_match|{is_special_token(LA(1))}? => .;

// TODO fix this rule
parameter_expansion_value
locals [
	int num_of_braces
]
	:	parameter_expansion_value_atom;

parameter_expansion_value_atom
	:	{$parameter_expansion_value::num_of_braces = 1;}
			(
				{$parameter_expansion_value::num_of_braces != 0}? => .
				{
					if(LA(1) == LBRACE && LA(-1) != ESC)
						++$parameter_expansion_value::num_of_braces;
					else if(LA(1) == RBRACE && LA(-1) != ESC)
						--$parameter_expansion_value::num_of_braces;
				}
			)+
	|;

parameter_replace_operator
	:	SLASH SLASH
	|	SLASH PCT
	|	SLASH POUND
	|	SLASH;

variable_name
	:	num
	|	name LSQUARE AT RSQUARE
	|	name LSQUARE TIMES RSQUARE
	|	BANG variable_name_for_bang
	|	variable_name_no_digit
	|	DOLLAR
	|	TIMES
	|	AT
	|	QMARK
	|	POUND;

variable_name_no_digit
	:	name LSQUARE BLANK? explicit_arithmetic BLANK? RSQUARE
	|	name;

variable_name_for_bang
	:	num|name|POUND;
variable_size_ref
	:	POUND name LSQUARE array_size_index RSQUARE
	|	POUND variable_name;
array_size_index
	:	DIGIT+
	|	(AT|TIMES);

wspace
	:	(BLANK|EOL)+;

command_substitution
	:	COMMAND_SUBSTITUTION_PAREN
	|	COMMAND_SUBSTITUTION_TICK;

brace_expansion
	:	LBRACE BLANK* brace_expansion_inside BLANK* RBRACE;
brace_expansion_inside
	:	commasep|range_;
range_
	:	DIGIT DOTDOT DIGIT
	|	LETTER DOTDOT LETTER;
brace_expansion_part
	:	(string_expr_part)*;
commasep
	:	brace_expansion_part (COMMA brace_expansion_part)+;

explicit_arithmetic
	:	arithmetic_part // (the predicate resolves the conflict with the primary rule)
	|	arithmetics;

arithmetic_expansion
	:	arithmetic_part;

arithmetic_part
	:	DOLLAR LLPAREN BLANK? arithmetics BLANK? RPAREN RPAREN
	|	DOLLAR LSQUARE BLANK? arithmetics BLANK? RSQUARE;

arithmetics
	:	arithmetic (COMMA BLANK? arithmetic)*;

arithmetics_test
	:	arithmetics EOF;

arithmetic
	:variable_name_no_digit BLANK? arithmetic_assignment_operator BLANK? logicor
	|	arithmetic_variable_reference BLANK? arithmetic_assignment_operator BLANK? logicor
	|	cnd=logicor
		(
			QMARK t=logicor COLON f=logicor
			|
		);

arithmetic_assignment_operator
	:	{LA(1) == EQUALS && LA(2) != EQUALS}? => EQUALS
	|	TIMES EQUALS
	|	SLASH EQUALS
	|	PCT EQUALS
	|	PLUS EQUALS
	|	MINUS EQUALS
	|	LSHIFT EQUALS
	|	RSHIFT EQUALS
	|	AMP EQUALS
	|	CARET EQUALS
	|	PIPE EQUALS;

arithmetic_variable_reference
	:	variable_reference;
primary
	:	num
	|	command_substitution
	|	variable_name_no_digit
	|	variable_reference
	|	arithmetic_expansion
	|	LPAREN (arithmetics) RPAREN;
pre_post_primary
	:	DQUOTE? primary DQUOTE?;
post_inc_dec
	:	pre_post_primary (BLANK)?
		(
			BLANK? PLUS PLUS
			|	BLANK? MINUS MINUS
			|
		);
pre_inc_dec
	:	PLUS PLUS BLANK? pre_post_primary
	|	MINUS MINUS BLANK? pre_post_primary;
unary_with_operator
	:	PLUS BLANK? unary
	|	MINUS BLANK? unary
	|	TILDE BLANK? unary
	|	BANG BLANK? unary;
unary
	:	post_inc_dec
	|	pre_inc_dec
	|	unary_with_operator;
exponential
	:	unary (EXP BLANK? unary)* ;
times_division_modulus
	:	exponential ((TIMES|SLASH|PCT) BLANK? exponential)*;
addsub
	:	times_division_modulus ((PLUS|MINUS) BLANK? times_division_modulus)*;
shifts
	:	addsub ((LSHIFT|RSHIFT) BLANK? addsub)*;
compare
	:	shifts (compare_operator BLANK? shifts)?;
compare_operator
	:	LESS_THAN EQUALS
	|	GREATER_THAN EQUALS
	|	LESS_THAN
	|	GREATER_THAN
	|	EQUALS EQUALS
	|	BANG EQUALS;
bitwiseand
	:	compare (AMP BLANK? compare)*;
bitwisexor
	:	bitwiseand (CARET BLANK? bitwiseand)*;
bitwiseor
	:	bitwisexor (PIPE BLANK? bitwisexor)*;
logicand
	:	bitwiseor (LOGICAND BLANK? bitwiseor)*;
logicor
	:	logicand (LOGICOR BLANK? logicand)*;

COMMENT
	:	{ self.double_quoted }?=> (BLANK|EOL) '#' ~('\n'|'\r')* -> channel(HIDDEN)
	;

BANG	:	'';
CASE	:	'case';
DO		:	'do';
DONE	:	'done';
ELIF	:	'elif';
ELSE	:	'else';
ESAC	:	'esac';
FI		:	'fi';
FOR		:	'for';
IF		:	'if';
IN		:	'in';
SELECT	:	'select';
THEN	:	'then';
UNTIL	:	'until';
WHILE	:	'while';
LBRACE	:	'{';
RBRACE	:	'}';
TIME	:	'time';
RPAREN	:	')';
LPAREN	:	'(';
LLPAREN	:	'((';
LSQUARE	:	'[';
RSQUARE	:	']';
TICK	:	'`';
DOLLAR	:	'$';
AT	:	'@';
DOT	:	'.';
DOTDOT	:	'..';

TIMES	:	'*';
EQUALS	:	'=';
MINUS	:	'-';
PLUS	:	'+';
EXP		:	'**';
AMP		:	'&';
CARET	:	'';
LESS_THAN	:	'<';
GREATER_THAN	:	'>';
LSHIFT	:	'<<';
RSHIFT	:	'>>';
AMP_LESS_THAN	:	'&<';
AMP_GREATER_THAN	:	'&>';
AMP_RSHIFT	:	'&>>';

SEMIC	:	';';
DOUBLE_SEMIC	:	';;';
PIPE	:	'|';
ESC_DQUOTE	:	'\\"';
ESC_SQUOTE	: { self.double_quoted }? => '\\\'';
DQUOTE	:	'"' { if self.LA(-1) != '\\':
	self.double_quoted = not self.double_quoted 
};
SQUOTE	:	{ self.double_quoted }? => '\'';
SINGLE_QUOTED_STRING_TOKEN	:	{ self.double_quoted }? => '\'' .* '\'';
COMMA	:	',';
BLANK	:	(' '|'\t')+;
EOL		:	('\r'?'\n')+ ;

DIGIT	:	'0'..'9';
NUMBER	:	DIGIT DIGIT+;
LETTER	:	('a'..'z'|'A'..'Z');
fragment
ALPHANUM	:	(DIGIT|LETTER);

TILDE	:	'~';
HERE_STRING_OP	:	'<<<';
POUND	:	'#';
PCT		:	'%';
PCTPCT	:	'%%';
SLASH	:	'/';
COLON	:	':';
QMARK	:	'?';

LOCAL	:	'local';
EXPORT	:	'export';
DECLARE	:	'declare';
LOGICAND	:	'&&';
LOGICOR	:	'||';

CONTINUE_LINE	:	(ESC EOL)+-> channel(HIDDEN);
ESC_RPAREN	:	ESC RPAREN;
ESC_LPAREN	:	ESC LPAREN;
ESC_RSQUARE	:	ESC RSQUARE;
ESC_LSQUARE	:	ESC LSQUARE;
ESC_DOLLAR	:	ESC DOLLAR;
ESC_TICK	:	ESC TICK;
COMMAND_SUBSTITUTION_PAREN
	:	{self.LA(1) == '$' and self.LA(2) == '(' and self.LA(3) != '('}? =>
			(DOLLAR LPAREN ({ self.paren_level = 1; }
				(
					ESC_LPAREN
					|	ESC_RPAREN
					|	LPAREN { ++self.paren_level; }
					|	RPAREN
						{
							if --self.paren_level == 0:
								print("Parenlevel is 0")
								# throw new UnsupportedOperationException("Command substitution paren: RPAREN");
								#state.type = _type;
								#state.channel = _channel;

								#return;
						}
					|	SINGLE_QUOTED_STRING_TOKEN
					|	.
				)+
			));
COMMAND_SUBSTITUTION_TICK	:	TICK .+ (~[\\]) TICK;
ESC_LT	:	ESC'<';
ESC_GT	:	ESC'>';

ESC	:	'\\';
UNDERSCORE	:	'_';
NAME	:	(LETTER|UNDERSCORE)(ALPHANUM|UNDERSCORE)+;
OTHER	:	.;
